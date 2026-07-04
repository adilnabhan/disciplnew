import json
import logging
from django.shortcuts import render

logger = logging.getLogger(__name__)
from apps.customers.models import CustomerMembership, CustomerMembershipTransaction
from apps.user.models import Coupon, SalesExecutive, SubscriptionTransaction
from apps.fitnesscenter.models import MembershipPlan, Organization, EmiPlan
import razorpay
from rest_framework.decorators import (
    api_view,
    permission_classes,
)
from rest_framework.permissions import IsAuthenticated
from django.http import JsonResponse
from django.conf import settings
from django.utils import timezone
from django.db import transaction
import calendar
import datetime

from apps.subscription.api.serializers import CustomerRazorpayOrderCreateSerializer, OrganizationTransactionSerializer, RazorpayOrderCreateSerializer, CustomerRazorpaySubscriptionCreateSerializer, TrainerRazorpayOrderCreateSerializer, TrainerTransactionSerializer
from apps.subscription.models import DisciplSubscriptionPlan, OrganizationSubscriptionsDetails, OrganizationTransaction, PartnerTransfer

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from django.shortcuts import get_object_or_404

from apps.utils.permission import CustomerOnlyPermission, MentorOnlyPermission

client = razorpay.Client(auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET))


def calculate_platform_fee_and_transfer_amount(payment_amount_rupees):
    """
    Calculate platform fee and gym transfer amount.
    Platform fee: max(4% of payment, MIN_PLATFORM_FEE from env)

    Args:
        payment_amount_rupees (Decimal/float): Payment amount in rupees

    Returns:
        tuple: (platform_fee_rupees, transfer_amount_rupees, platform_fee_paise, transfer_amount_paise)
    """
    from decimal import Decimal, ROUND_HALF_UP

    payment_rupees = Decimal(str(payment_amount_rupees))

    # Calculate 4% of payment
    percentage_fee = (payment_rupees * Decimal('0.04')).quantize(
        Decimal('0.01'),
        rounding=ROUND_HALF_UP
    )

    # Minimum platform fee from settings (defaults to ₹4)
    min_fee = Decimal(str(getattr(settings, 'MIN_PLATFORM_FEE', 4.00)))

    # Platform fee is the maximum of 4% and ₹4
    platform_fee_rupees = max(percentage_fee, min_fee)

    # Transfer amount is payment minus platform fee
    transfer_amount_rupees = payment_rupees - platform_fee_rupees

    # Validate transfer amount is positive
    if transfer_amount_rupees < Decimal('1.00'):
        raise ValueError(
            f"Transfer amount too low: ₹{transfer_amount_rupees}. "
            f"Payment: ₹{payment_rupees}, Platform fee: ₹{platform_fee_rupees}"
        )

    # Convert to paise
    platform_fee_paise = int(platform_fee_rupees * 100)
    transfer_amount_paise = int(transfer_amount_rupees * 100)

    return (
        platform_fee_rupees,
        transfer_amount_rupees,
        platform_fee_paise,
        transfer_amount_paise
    )


def build_transfer_notes(customer_transaction):
    """
    Build transfer notes with customer name and gym name.
    Includes sanity checks to prevent errors.

    Args:
        customer_transaction: CustomerMembershipTransaction instance

    Returns:
        str: Formatted notes string or None if data incomplete
    """
    try:
        # Sanity check: customer_transaction must exist
        if not customer_transaction:
            return None

        # Extract customer name
        customer_name = "Unknown Customer"
        if customer_transaction.customer and customer_transaction.customer.user:
            full_name = customer_transaction.customer.user.get_full_name()
            if full_name and full_name.strip():
                customer_name = full_name.strip()[:50]  # Limit to 50 chars

        # Extract gym name
        gym_name = "Unknown Gym"
        if customer_transaction.membership and customer_transaction.membership.organization:
            org_name = customer_transaction.membership.organization.name
            if org_name and org_name.strip():
                gym_name = org_name.strip()[:50]  # Limit to 50 chars

        # Build notes string
        notes = f"Customer: {customer_name} | Gym: {gym_name}"

        # Add period info if available
        if customer_transaction.period and customer_transaction.period > 0:
            notes += f" | Period: {customer_transaction.period}"

        # Razorpay has a 512 character limit on notes
        if len(notes) > 512:
            notes = notes[:509] + "..."

        return notes

    except Exception as e:
        # Log error but don't fail the transfer
        print(f"Warning: Could not build transfer notes: {str(e)}")
        return f"Payment ID: {customer_transaction.payment_id or 'N/A'}"


def create_payment_transfer(
    payment_id,
    payment_entity,
    linked_account_id,
    amount_in_rupees,
    customer_transaction=None,
    org_transaction=None,
    max_retries=1
):
    """
    Create Razorpay transfer for payment with retry logic and comprehensive tracking.

    Key Features:
    - Retry mechanism with backoff for connection errors (max 1 retry = 2 total attempts)
    - Platform fee calculation: max(4% of payment, ₹4)
    - Transfer notes with customer and gym information
    - Creates PartnerTransfer records for both success and failure
    - Updates CustomerMembershipTransaction.transfer_status
    - Idempotency checks to prevent duplicate transfers

    Args:
        payment_id: Razorpay payment ID
        payment_entity: Full payment entity from Razorpay (for validation)
        linked_account_id: Target account for transfer
        amount_in_rupees: Payment amount in rupees
        customer_transaction: CustomerMembershipTransaction instance (optional)
        org_transaction: OrganizationTransaction instance (optional)
        max_retries: Maximum retry attempts (default: 1)

    Returns:
        tuple: (PartnerTransfer instance or None, success: bool, error_message: str or None)
    """
    import time
    from decimal import Decimal

    # =================================================================
    # SAFETY CHECKS
    # =================================================================

    # SAFETY CHECK 1: Payment must be captured
    payment_status = payment_entity.get('status')
    if payment_status != 'captured':
        error_msg = f"Payment not captured (status: {payment_status})"
        _create_failed_transfer_record(
            linked_account_id=linked_account_id,
            amount_in_rupees=amount_in_rupees,
            customer_transaction=customer_transaction,
            org_transaction=org_transaction,
            error_message=error_msg,
            status='failed'
        )
        _update_transaction_transfer_status(customer_transaction, 'failed', error_msg)
        return None, False, error_msg

    # SAFETY CHECK 2: Payment must not be refunded
    refund_status = payment_entity.get('refund_status')
    if refund_status in ['full', 'partial']:
        error_msg = f"Payment is refunded (refund_status: {refund_status})"
        _create_failed_transfer_record(
            linked_account_id=linked_account_id,
            amount_in_rupees=amount_in_rupees,
            customer_transaction=customer_transaction,
            org_transaction=org_transaction,
            error_message=error_msg,
            status='failed'
        )
        _update_transaction_transfer_status(customer_transaction, 'failed', error_msg)
        return None, False, error_msg

    # SAFETY CHECK 3: Check if payment has refunds
    amount_refunded = payment_entity.get('amount_refunded', 0)
    if amount_refunded > 0:
        error_msg = f"Payment has refunds (₹{amount_refunded / 100})"
        _create_failed_transfer_record(
            linked_account_id=linked_account_id,
            amount_in_rupees=amount_in_rupees,
            customer_transaction=customer_transaction,
            org_transaction=org_transaction,
            error_message=error_msg,
            status='failed'
        )
        _update_transaction_transfer_status(customer_transaction, 'failed', error_msg)
        return None, False, error_msg

    # SAFETY CHECK 4: Check for existing successful transfer (idempotency)
    existing_successful_transfer = PartnerTransfer.objects.filter(
        customer_transaction=customer_transaction,
        status='processed'
    ).first()

    if existing_successful_transfer:
        print(f"⚠️ Successful transfer already exists: {existing_successful_transfer.transfer_id}")
        return existing_successful_transfer, True, None

    # =================================================================
    # CALCULATE PLATFORM FEE AND TRANSFER AMOUNT
    # =================================================================

    try:
        platform_fee_rupees, transfer_amount_rupees, platform_fee_paise, transfer_amount_paise = \
            calculate_platform_fee_and_transfer_amount(amount_in_rupees)
    except ValueError as e:
        error_msg = str(e)
        _create_failed_transfer_record(
            linked_account_id=linked_account_id,
            amount_in_rupees=amount_in_rupees,
            customer_transaction=customer_transaction,
            org_transaction=org_transaction,
            error_message=error_msg,
            status='failed'
        )
        _update_transaction_transfer_status(customer_transaction, 'failed', error_msg)
        return None, False, error_msg

    # SAFETY CHECK 5: Verify transfer won't exceed payment amount
    payment_amount_paise = int(Decimal(str(amount_in_rupees)) * 100)
    if transfer_amount_paise > payment_amount_paise:
        error_msg = f"Transfer amount (₹{transfer_amount_rupees}) exceeds payment (₹{amount_in_rupees})"
        _create_failed_transfer_record(
            linked_account_id=linked_account_id,
            amount_in_rupees=amount_in_rupees,
            customer_transaction=customer_transaction,
            org_transaction=org_transaction,
            error_message=error_msg,
            status='failed'
        )
        _update_transaction_transfer_status(customer_transaction, 'failed', error_msg)
        return None, False, error_msg

    # =================================================================
    # BUILD TRANSFER NOTES
    # =================================================================

    transfer_notes = None
    if customer_transaction:
        transfer_notes = build_transfer_notes(customer_transaction)

    # =================================================================
    # RETRY LOOP WITH BACKOFF
    # =================================================================

    last_error = None

    for retry_attempt in range(max_retries + 1):  # +1 for initial attempt
        try:
            # Update status to retrying if this is a retry
            if retry_attempt > 0:
                _update_transaction_transfer_status(
                    customer_transaction,
                    'retrying',
                    f"Retry attempt {retry_attempt}/{max_retries}"
                )

                # Backoff: 2 seconds
                backoff_time = 2
                print(f"⏳ Retrying transfer after {backoff_time}s backoff (attempt {retry_attempt + 1}/{max_retries + 1})")
                time.sleep(backoff_time)
            else:
                # First attempt - update status to pending
                _update_transaction_transfer_status(customer_transaction, 'pending', None)

            # =================================================================
            # CALL RAZORPAY TRANSFER API
            # =================================================================

            transfer_payload = {
                "transfers": [{
                    "account": linked_account_id,
                    "amount": transfer_amount_paise,
                    "currency": "INR",
                    "on_hold": False
                }]
            }

            # Add notes if available
            if transfer_notes:
                transfer_payload["transfers"][0]["notes"] = {"info": transfer_notes}

            print(f"🔄 Calling Razorpay transfer API (attempt {retry_attempt + 1}/{max_retries + 1})")
            print(f"   Payment ID: {payment_id}")
            print(f"   Transfer amount: ₹{transfer_amount_rupees} (Platform fee: ₹{platform_fee_rupees})")

            transfer_response = client.payment.transfer(payment_id, transfer_payload)

            # =================================================================
            # TRANSFER SUCCESS - SAVE TO DATABASE
            # =================================================================

            transfer_data = transfer_response['items'][0]

            partner_transfer = PartnerTransfer.objects.create(
                transfer_id=transfer_data['id'],
                account_id=linked_account_id,
                amount=transfer_amount_rupees,
                customer_transaction=customer_transaction,
                order=org_transaction,
                status=transfer_data.get('status', 'created'),
                notes=transfer_notes,
                platform_fee=platform_fee_rupees,
                original_payment_amount=Decimal(str(amount_in_rupees)),
                retry_count=retry_attempt,
                last_retry_at=timezone.now() if retry_attempt > 0 else None
            )

            # Update transaction transfer_status to pending
            _update_transaction_transfer_status(
                customer_transaction,
                'pending',
                f"Transfer {partner_transfer.transfer_id} created and processed. Awaiting settlement."
            )

            print(f"✅ Transfer created successfully: {partner_transfer.transfer_id}")
            print(f"   Status: {partner_transfer.status}")
            print(f"   Amount: ₹{transfer_amount_rupees} (Platform fee: ₹{platform_fee_rupees})")

            return partner_transfer, True, None

        except razorpay.errors.BadRequestError as e:
            # BadRequestError is not retryable - business logic error
            error_msg = f"Razorpay BadRequestError: {str(e)}"
            last_error = error_msg
            print(f"❌ {error_msg}")
            break  # Don't retry on bad request errors

        except (
            ConnectionError,
            Exception  # Catches "Remote end closed connection without response"
        ) as e:
            # Connection errors are retryable
            error_msg = f"Connection error (attempt {retry_attempt + 1}/{max_retries + 1}): {str(e)}"
            last_error = error_msg
            print(f"⚠️ {error_msg}")

            # If this was the last retry, break
            if retry_attempt == max_retries:
                print(f"❌ Max retries ({max_retries + 1}) reached. Transfer failed.")
                break

            # Otherwise, continue to next retry iteration
            continue

    # =================================================================
    # ALL RETRIES FAILED - CREATE FAILED TRANSFER RECORD
    # =================================================================

    final_error_msg = f"Transfer failed after {max_retries + 1} attempts. Last error: {last_error}"

    failed_transfer = _create_failed_transfer_record(
        linked_account_id=linked_account_id,
        amount_in_rupees=transfer_amount_rupees,
        customer_transaction=customer_transaction,
        org_transaction=org_transaction,
        error_message=final_error_msg,
        status='failed',
        notes=transfer_notes,
        platform_fee=platform_fee_rupees,
        original_payment_amount=Decimal(str(amount_in_rupees)),
        retry_count=max_retries + 1
    )

    # Update transaction transfer_status to failed
    _update_transaction_transfer_status(customer_transaction, 'failed', final_error_msg)

    return failed_transfer, False, final_error_msg


# =================================================================
# HELPER FUNCTIONS
# =================================================================

def _create_failed_transfer_record(
    linked_account_id,
    amount_in_rupees,
    customer_transaction,
    org_transaction,
    error_message,
    status,
    notes=None,
    platform_fee=None,
    original_payment_amount=None,
    retry_count=0
):
    """
    Create a PartnerTransfer record for a failed transfer attempt.
    This ensures we keep records of all transfer attempts, not just successful ones.
    """
    from decimal import Decimal

    return PartnerTransfer.objects.create(
        transfer_id=f"FAILED_{timezone.now().strftime('%Y%m%d%H%M%S')}_{customer_transaction.id if customer_transaction else 'NONE'}",
        account_id=linked_account_id,
        amount=Decimal(str(amount_in_rupees)),
        customer_transaction=customer_transaction,
        order=org_transaction,
        status=status,
        error_message=error_message,
        notes=notes,
        platform_fee=platform_fee,
        original_payment_amount=original_payment_amount,
        retry_count=retry_count,
        last_retry_at=timezone.now() if retry_count > 0 else None
    )


def _update_transaction_transfer_status(customer_transaction, status, remarks):
    """
    Update CustomerMembershipTransaction.transfer_status and optionally remarks.
    """
    if not customer_transaction:
        return

    customer_transaction.transfer_status = status

    if remarks:
        # Append to existing remarks if any
        if customer_transaction.remarks:
            customer_transaction.remarks += f"\n{remarks}"
        else:
            customer_transaction.remarks = remarks

    customer_transaction.save(update_fields=['transfer_status', 'remarks'])


@api_view()
@permission_classes((IsAuthenticated,))
def get_discipl_subscription_plans(request):
    name = request.GET.get('name', '')
    data = DisciplSubscriptionPlan.objects.filter(is_active=True).values(
       'id', 'name', 'plan_type', 'regular_price', 'discounted_price', 'period'
    )
    return JsonResponse({
        'results': list(data)
    }, safe=False)
    
    
    
class CreateRazorpayOrderAPIView(APIView):
    permission_classes = [MentorOnlyPermission]

    def post(self, request):
        mentor = getattr(request.user, 'mentor_profile', None)
        serializer = RazorpayOrderCreateSerializer(
            data=request.data, 
            context={'mentor': mentor, 'request': request}
        )
        serializer.is_valid(raise_exception=True)

        plan_id = serializer.validated_data['plan_id']
        organization_id = serializer.validated_data['organization_id']
        coupon_code = serializer.validated_data.get('coupon_code')

        plan = get_object_or_404(DisciplSubscriptionPlan, id=plan_id, is_active=True)
        organization = get_object_or_404(Organization, id=organization_id, mentor=mentor)

        # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        # 0️⃣ VALIDATE AND APPLY COUPON (IF SUPPLIED)
        # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        coupon_obj = None
        discount_amount = 0
        from django.db.models import Q

        if coupon_code:
            coupon_code = coupon_code.strip()
            try:
                coupon_obj = Coupon.objects.get(
                    Q(organization=organization) | Q(organization__isnull=True),
                    code__iexact=coupon_code,
                    is_active=True
                )
                
                # Check validity dates
                now = timezone.now()
                if coupon_obj.valid_from and now < coupon_obj.valid_from:
                    return Response({'message': 'Coupon is not active yet.'}, status=status.HTTP_400_BAD_REQUEST)
                if coupon_obj.valid_to and now > coupon_obj.valid_to:
                    return Response({'message': 'Coupon has expired.'}, status=status.HTTP_400_BAD_REQUEST)
                
                # Check max usage
                if coupon_obj.max_usage and coupon_obj.used_count >= coupon_obj.max_usage:
                    return Response({'message': 'Coupon maximum usage reached.'}, status=status.HTTP_400_BAD_REQUEST)
                
                # Calculate discount
                if coupon_obj.discount_type == 'percentage':
                    discount_amount = (plan.discounted_price * coupon_obj.discount_value) / 100
                else:
                    discount_amount = coupon_obj.discount_value
                    
            except Coupon.DoesNotExist:
                return Response({'message': 'Invalid coupon code.'}, status=status.HTTP_400_BAD_REQUEST)

        final_amount = max(0, plan.discounted_price - discount_amount)

        # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        # 1️⃣ CHECK IF PLAN IS FREE (OR FULLY DISCOUNTED) — SKIP RAZORPAY
        # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        if plan.total_cost == 0 or final_amount == 0:
            trans = OrganizationTransaction.objects.create(
                user=request.user,
                organization=organization,
                discipl_plan=plan,
                period=plan.period,
                order_id=None,               # No Razorpay order
                amount=final_amount,
                coupon=coupon_obj
            )
            
            organization = trans.organization
            organization.is_subscribed = True
            organization.is_on_free_trial = True
            organization.take_free_trial = True
            organization.is_public = True
            organization.active = True
            organization.save()

            # Increment coupon usage count since the transaction was successful (amount = 0)
            if coupon_obj:
                coupon_obj.used_count += 1
                coupon_obj.save(update_fields=['used_count'])

                # Create commission transaction if sales executive is linked
                if coupon_obj.sales_executive:
                    commission_amt = 0
                    if coupon_obj.share_type == 'percentage':
                        commission_amt = (final_amount * coupon_obj.share_value) / 100
                    else:
                        commission_amt = coupon_obj.share_value

                    SubscriptionTransaction.objects.create(
                        plan=plan,
                        user=request.user,
                        coupon=coupon_obj,
                        sales_executive=coupon_obj.sales_executive,
                        original_amount=plan.discounted_price,
                        discount_amount=discount_amount,
                        final_amount=final_amount,
                        executive_commission=commission_amt,
                        commission_paid=False
                    )

            data = OrganizationTransactionSerializer(trans).data
            data["is_free_plan"] = True   # ensure frontend receives it

            return Response(data, status=status.HTTP_201_CREATED)

        # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        # 2️⃣ IF PLAN IS PAID — CALL RAZORPAY
        # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        amount_in_paise = int(final_amount * 100)
        client = razorpay.Client(auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET))

        try:
            response = client.order.create({
                "amount": amount_in_paise,
                "currency": 'INR',
                "receipt": request.user.username,
                "payment": {
                    "capture": "automatic",
                    "capture_options": {"refund_speed": "normal"},
                },
            })
        except Exception as e:
            return Response({'message': str(e)}, status=status.HTTP_400_BAD_REQUEST)

        if response["status"] == "created":
            trans = OrganizationTransaction.objects.create(
                user=request.user,
                organization=organization,
                discipl_plan=plan,
                period=plan.period,
                order_id=response['id'],
                amount=final_amount,
                coupon=coupon_obj
            )

        data = OrganizationTransactionSerializer(trans).data
        data["is_free_plan"] = False
        return Response(data, status=status.HTTP_201_CREATED)


# customer membership subscription
class CreateRazorpayCustomerOrderAPIView(APIView):
    permission_classes = [CustomerOnlyPermission,]

    def post(self, request):
        serializer = CustomerRazorpayOrderCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        plan = serializer.validated_data['plan_id']
        coupon_code = serializer.validated_data.get('coupon_code')

        linked_account_id = plan.organization.bank_details.razorpay_account_id
        if not linked_account_id:
            return Response(
                {'message': 'Organization bank account not linked for transfers.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        customer = getattr(request.user, 'customer', None)
        if not customer:
            return Response({"error": "Customer profile not found for the logged-in user."}, status=400)

        # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        # 0️⃣ VALIDATE AND APPLY COUPON (IF SUPPLIED)
        # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        coupon_obj = None
        discount_amount = 0
        final_price = plan.offer_price

        if coupon_code:
            coupon_code = coupon_code.strip()
            try:
                coupon_obj = Coupon.objects.get(
                    organization=plan.organization,
                    code__iexact=coupon_code,
                    is_active=True
                )
                
                # Check validity dates
                now = timezone.now()
                if coupon_obj.valid_from and now < coupon_obj.valid_from:
                    return Response({'message': 'Coupon is not active yet.'}, status=status.HTTP_400_BAD_REQUEST)
                if coupon_obj.valid_to and now > coupon_obj.valid_to:
                    return Response({'message': 'Coupon has expired.'}, status=status.HTTP_400_BAD_REQUEST)
                
                # Check max usage
                if coupon_obj.max_usage and coupon_obj.used_count >= coupon_obj.max_usage:
                    return Response({'message': 'Coupon maximum usage reached.'}, status=status.HTTP_400_BAD_REQUEST)
                
                # Calculate discount
                if coupon_obj.discount_type == 'percentage':
                    discount_amount = (plan.offer_price * coupon_obj.discount_value) / 100
                else:
                    discount_amount = coupon_obj.discount_value
                    
                final_price = max(0, plan.offer_price - discount_amount)
                
            except Coupon.DoesNotExist:
                return Response({'message': 'Invalid coupon code.'}, status=status.HTTP_400_BAD_REQUEST)

        # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        # 1️⃣ CHECK IF PLAN IS FREE (OR FULLY DISCOUNTED)
        # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        if final_price == 0:
            # Create transaction
            trans = CustomerMembershipTransaction.objects.create(
                user=customer.user,
                customer=customer,
                membership=plan,
                period=plan.duration_days,
                order_id=None,
                amount=0,
                coupon=coupon_obj,
                status="Successful",
                payment_method="coupon",
                payment_date=timezone.now()
            )

            # Create and activate customer membership directly
            CustomerMembership.objects.create(
                customer=customer,
                membership=plan,
                razorpay_order_id=None,
                razorpay_payment_id=None,
                amount=0,
                status='Active',
                payment_status='completed',
                start_date=timezone.now(),
                end_date=timezone.now() + timezone.timedelta(days=plan.duration_days),
                is_active=True
            )

            # Set customer as active member
            customer.is_active_member = True
            customer.save(update_fields=['is_active_member'])

            # Increment coupon usage count
            if coupon_obj:
                coupon_obj.used_count += 1
                coupon_obj.save(update_fields=['used_count'])

                # Log affiliate transaction to record sales executive commission
                if coupon_obj.sales_executive:
                    commission_amt = 0
                    if coupon_obj.share_type == 'percentage':
                        commission_amt = (final_price * coupon_obj.share_value) / 100
                    else:
                        commission_amt = coupon_obj.share_value

                    SubscriptionTransaction.objects.create(
                        membership_plan=plan,
                        user=customer.user,
                        coupon=coupon_obj,
                        sales_executive=coupon_obj.sales_executive,
                        original_amount=plan.offer_price,
                        discount_amount=discount_amount,
                        final_amount=0,
                        executive_commission=commission_amt,
                        commission_paid=False
                    )

            from apps.subscription.api.serializers import CustomerTransactionSerializer
            transaction = CustomerTransactionSerializer(trans).data
            transaction["is_free_plan"] = True
            return Response(transaction, status=status.HTTP_201_CREATED)

        # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        # 2️⃣ IF PAID — CALL RAZORPAY WITH PLATFORM FEE SPLIT
        # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        amount_in_paise = int(final_price * 100)
        # 96% split to mentor
        mentor_share_amount = int(amount_in_paise * 96 / 100)
        # Remaining 4%
        platform_share_amount = amount_in_paise - mentor_share_amount

        client = razorpay.Client(auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET))

        try:
            response = client.order.create(
                {
                    "amount": amount_in_paise,
                    "currency": 'INR',
                    "receipt": f"cust-{request.user.first_name} {request.user.last_name}",
                    "payment": {
                        "capture": "automatic",
                        "capture_options": {"refund_speed": "normal"},
                    },
                    "transfers":
                    [
                            {
                                "account": linked_account_id,
                                "amount": mentor_share_amount,
                                "currency": "INR",
                                "on_hold": False
                            }
                    ]
                }
            )
        except Exception as e:
            return Response({'message': str(e)}, status=status.HTTP_400_BAD_REQUEST)

        if response["status"] == 'created':
            # Store SubscriptionOrder
            trans = CustomerMembershipTransaction.objects.create(
                user=customer.user,
                customer=customer,
                membership=plan,
                period=plan.duration_days,
                order_id=response["id"],
                amount=final_price,
                coupon=coupon_obj,
                status="Pending",
            )
            
        from apps.subscription.api.serializers import CustomerTransactionSerializer
        transaction = CustomerTransactionSerializer(trans).data
        transaction["is_free_plan"] = False
        return Response(transaction, status=status.HTTP_201_CREATED)
    
# class CheckCustomerPaymentStatusAPIView(APIView):
#     permission_classes = [IsAuthenticated]

#     def get(self, request):
#         order_id = request.query_params.get("order_id")
#         if not order_id:
#             return Response({"message": "order_id is required."}, status=status.HTTP_400_BAD_REQUEST)

#         transaction = None
#         try:
#             transaction = get_object_or_404(CustomerMembershipTransaction, order_id=order_id)
#         except CustomerMembershipTransaction.DoesNotExist:
#             return Response({"message": "Transaction not found."}, status=status.HTTP_404_NOT_FOUND)

#         data = {
#             "order_id": transaction.order_id,
#             "payment_id": transaction.payment_id,
#             "status": transaction.status,
#             "amount": transaction.amount
#         }
#         return Response(data, status=status.HTTP_200_OK)
    
import hmac
import hashlib
from django.http import HttpResponse
    

# def verify_signature(payload, signature, secret):
#     """Check if webhook is really from Razorpay"""
#     expected = hmac.new(
#         secret.encode('utf-8'),
#         payload.encode('utf-8'),
#         hashlib.sha256
#     ).hexdigest()
#     return hmac.compare_digest(expected, signature)

def verify_signature(raw_body: bytes, signature: str, secret: str) -> bool:
    """
    Verify Razorpay webhook signature.
    raw_body: bytes -> request.body
    signature: str -> value of X-Razorpay-Signature header
    secret: str -> your webhook secret from Razorpay Dashboard
    """
    try:
        # Compute HMAC using secret key and the raw body
        generated_signature = hmac.new(
            key=secret.encode("utf-8"),  # secret must be encoded
            msg=raw_body,                # raw_body is already bytes
            digestmod=hashlib.sha256
        ).hexdigest()

        # Compare both signatures safely
        return hmac.compare_digest(generated_signature, signature)
    except Exception as e:
        print("verify_signature error:", e)
        return False


def add_months(dt, months):
    """
    Add `months` months to datetime `dt` while keeping day-of-month where possible.
    Matches implementation in customers/api/serializers.py for consistency.
    """
    if not dt:
        return None
    year = dt.year + (dt.month - 1 + months) // 12
    month = (dt.month - 1 + months) % 12 + 1
    day = min(dt.day, calendar.monthrange(year, month)[1])
    return datetime.datetime(
        year, month, day,
        dt.hour, dt.minute, dt.second, dt.microsecond,
        tzinfo=dt.tzinfo
    )

@api_view(['POST'])
@permission_classes([AllowAny])
@transaction.atomic
def razorpay_webhook(request):
    # Read raw body ONCE
    raw_body = request.body
    print("RAW BODY RECEIVED:", raw_body)
    body_str = raw_body.decode('utf-8')
    payload = json.loads(body_str)
    print(payload, "PAYLOAD--------------------------")

    # Extract event
    event = payload.get('event', '')
    print(event)
    
    try:
        # raw_body = request.body.decode('utf-8')
        signature = (
                request.headers.get('X-Razorpay-Signature')
                or request.META.get('HTTP_X_RAZORPAY_SIGNATURE')
            )

        if not signature:
            print("No signature header found in request")
            return Response({"error": "Missing signature"}, status=400)

        if not verify_signature(raw_body, signature, settings.RAZORPAY_WEBHOOK_SECRET):
            return Response({"error": "Invalid signature"}, status=400)
        
    except json.JSONDecodeError:
        return JsonResponse({"error": "Invalid JSON format"}, status=400)
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

    # Early return for payment downtime events
    if event.startswith('payment.downtime.'):
        logger.info(f"Payment downtime event received: {event} - acknowledging without processing")
        return Response({"status": "acknowledged"}, status=200)

    try:
        if event.startswith('subscription.'):
            subscription_entity = payload['payload']['subscription']['entity']
            subscription_id = subscription_entity['id']
            
            try:
                # Lock the row to prevent race conditions
                customer_sub = CustomerMembership.objects.select_for_update().get(razorpay_subscription_id=subscription_id)
            except CustomerMembership.DoesNotExist:
                return Response({"status": "Subscription not found in DB"}, status=404)

            if event == 'subscription.charged':
                print('Subscription charged event received')
                payment_entity = payload['payload']['payment']['entity']
                payment_id = payment_entity['id']
                amount = payment_entity['amount'] / 100
                payment_method = payment_entity.get('method', '')  # Extract payment method

                # Idempotency check - prevent duplicate processing
                existing_payment = CustomerMembershipTransaction.objects.filter(
                    payment_id=payment_id
                ).first()

                if existing_payment:
                    print(f'⚠️ Payment {payment_id} already processed - idempotency check')
                    return Response({
                        "status": "Payment already processed",
                        "payment_id": payment_id,
                        "period": existing_payment.period
                    }, status=200)

                # Use single timestamp for consistency
                current_time = timezone.now()

                # Check if this is the first payment - prepare activation (don't save yet)
                if customer_sub.payment_status == 'pending':
                    customer_sub.status = 'Active'
                    customer_sub.payment_status = 'completed'
                    customer_sub.start_date = current_time
                    duration_days = customer_sub.membership.duration_days or 0
                    customer_sub.end_date = current_time + timezone.timedelta(days=duration_days)
                    customer_sub.is_active = True

                # Update last payment date (not saved yet)
                customer_sub.last_payment_date = current_time

                # Calculate next_period - ONLY count SUCCESSFUL payments
                previous_successful_periods = customer_sub.payments.filter(
                    period__gt=0,
                    status='Successful'
                ).count()
                next_period = previous_successful_periods + 1

                # Calculate next due date using month-based calculation (not saved yet)
                if customer_sub.emi_plan:
                    customer_sub.next_due_date = add_months(customer_sub.start_date, next_period)
                else:
                    customer_sub.next_due_date = current_time + timezone.timedelta(days=30)

                # VALIDATE - Check for duplicate period (BEFORE saving)
                existing_successful = customer_sub.payments.filter(
                    period=next_period,
                    status='Successful'
                ).exists()

                if existing_successful:
                    print(f'⚠️ Period {next_period} already paid for subscription {customer_sub.razorpay_subscription_id}')
                    return Response({
                        "status": "Duplicate payment detected",
                        "period": next_period
                    }, status=200)

                # All validations passed - now save subscription
                customer_sub.save()

                # Create transaction record with period number
                CustomerMembershipTransaction.objects.create(
                    customer=customer_sub.customer,
                    user=customer_sub.customer.user,
                    membership=customer_sub.membership,
                    subscription=customer_sub,
                    amount=amount,
                    period=next_period,
                    payment_id=payment_id,
                    payment_method=payment_method,
                    status='Successful',
                    payment_date=current_time,
                )

                # Create automatic transfer to gym's linked account
                try:
                    transaction_record = CustomerMembershipTransaction.objects.get(payment_id=payment_id)

                    # Get linked account from membership plan's organization
                    membership_plan = customer_sub.membership
                    linked_account_id = None

                    if membership_plan and membership_plan.organization:
                        bank_details = getattr(membership_plan.organization, 'bank_details', None)
                        if bank_details:
                            linked_account_id = bank_details.razorpay_account_id

                    if not linked_account_id:
                        print(f"⚠️ No linked account for payment {payment_id} - skipping transfer")
                        return Response({
                            "status": "Subscription charged successfully",
                            "warning": "Transfer skipped - no linked account"
                        }, status=200)

                    # Check idempotency - prevent duplicate transfers
                    existing_transfer = PartnerTransfer.objects.filter(
                        customer_transaction=transaction_record
                    ).first()

                    if existing_transfer:
                        return Response({
                            "status": "Subscription charged successfully",
                            "transfer_id": existing_transfer.transfer_id
                        }, status=200)

                    # Create the transfer (with enhanced retry logic and platform fee)
                    partner_transfer, success, error_msg = create_payment_transfer(
                        payment_id=payment_id,
                        payment_entity=payment_entity,  # Pass full entity for validation
                        linked_account_id=linked_account_id,
                        amount_in_rupees=float(amount),
                        customer_transaction=transaction_record,
                        max_retries=1  # Try once, retry once if failed
                    )

                    if success:
                        print(f"✅ Transfer {partner_transfer.transfer_id} created successfully")
                        print(f"   Amount transferred: ₹{partner_transfer.amount}")
                        print(f"   Platform fee: ₹{partner_transfer.platform_fee}")
                    else:
                        print(f"⚠️ Transfer failed after retries: {error_msg}")
                        # Note: transfer_status and PartnerTransfer record already handled by create_payment_transfer

                except Exception as e:
                    print(f"❌ Transfer error: {str(e)}")
                    # Don't fail webhook - payment was successful

                return Response({"status": "Subscription charged successfully"}, status=200)

            elif event == 'subscription.failed' or event == 'subscription.halted':
                customer_sub.status = 'Pending'
                customer_sub.payment_status = 'failed'
                customer_sub.is_active = False
                customer_sub.save()
                return Response({"status": "Subscription payment failed"}, status=200)

            elif event == 'subscription.completed':
                today = timezone.now().date()

                # Only expire if today is the actual end date (or past it)
                if customer_sub.end_date and today >= customer_sub.end_date.date():
                    customer_sub.status = 'Expired'
                    customer_sub.is_active = False
                    customer_sub.end_date = timezone.now()
                    customer_sub.save()
                    return Response({"status": "Subscription completed & expired"}, status=200)
                
                # Otherwise, ignore or log the event (optional)
                return Response({"status": "Subscription completed event ignored (end_date not reached)"}, status=200)

            elif event == 'subscription.cancelled':
                print(f'Subscription cancelled event received for subscription_id: {subscription_id}')

                # Idempotency check - if already cancelled or on hold, return success
                if customer_sub.status in ['Cancelled', 'Hold']:
                    print(f'⚠️ Subscription {subscription_id} already in {customer_sub.status} state')
                    return Response({"status": f"Subscription already {customer_sub.status.lower()}"}, status=200)

                # Log the status change
                old_status = customer_sub.status
                print(f'Status change: {old_status} -> Hold for customer: {customer_sub.customer.user.get_full_name() if customer_sub.customer.user else "Unknown"}')

                # Put the subscription on hold
                customer_sub.hold_subscription(reason='Autopay cancelled via Razorpay webhook')

                return Response({"status": "Subscription placed on hold successfully"}, status=200)

        # Handle one-time payment events (if you still have them)
        elif event.startswith('payment.'):
            payment_entity = payload['payload']['payment']['entity']
            payment_id = payment_entity['id']
            order_id = payment_entity['order_id']
            amount = payment_entity['amount'] / 100

            org_transaction = OrganizationTransaction.objects.filter(
                order_id=order_id
            ).first()
            if org_transaction:
                if event == 'payment.captured':
                    # Trainer subscription payment
                    if org_transaction.trainer_plan:
                        from apps.trainer.models import TrainerSubscription
                        trainer_sub = TrainerSubscription.objects.create(
                            trainer=org_transaction.trainer,
                            plan=org_transaction.trainer_plan,
                            razorpay_order_id=org_transaction.order_id,
                            razorpay_payment_id=payment_id,
                            paid_amount=amount,
                            status=TrainerSubscription.ACTIVE,
                            payment_status='completed',
                            start_date=timezone.now(),
                            end_date=timezone.now() + timezone.timedelta(days=30 * org_transaction.trainer_plan.period),
                        )
                        org_transaction.mark_success()
                        org_transaction.payment_id = payment_id
                        org_transaction.payment_date = timezone.now()
                        org_transaction.save()
                        return Response({'status': 'Trainer subscription activated'}, status=200)

                    # Org subscription payment
                    subscription = OrganizationSubscriptionsDetails.objects.create(
                        user=org_transaction.user,
                        organization=org_transaction.organization,
                        plan=org_transaction.discipl_plan,
                        razorpay_order_id=org_transaction.order_id,
                        razorpay_payment_id=payment_id,
                        paid_amount=amount,
                        last_payment_date=timezone.now()
                    )
                    subscription.start_trial()
                    
                    organization = org_transaction.organization
                    organization.is_subscribed = True
                    organization.is_on_free_trial = True
                    organization.take_free_trial = True
                    organization.is_public = True
                    organization.active = True
                    organization.save()
                    
                    # Increment coupon usage count and log commission
                    if org_transaction.coupon:
                        coupon = org_transaction.coupon
                        coupon.used_count += 1
                        coupon.save(update_fields=['used_count'])
                        
                        if coupon.sales_executive:
                            commission_amt = 0
                            if coupon.share_type == 'percentage':
                                commission_amt = (org_transaction.amount * coupon.share_value) / 100
                            else:
                                commission_amt = coupon.share_value
                                
                            SubscriptionTransaction.objects.create(
                                plan=org_transaction.discipl_plan,
                                user=org_transaction.user,
                                coupon=coupon,
                                sales_executive=coupon.sales_executive,
                                original_amount=org_transaction.discipl_plan.discounted_price,
                                discount_amount=org_transaction.discipl_plan.discounted_price - org_transaction.amount,
                                final_amount=org_transaction.amount,
                                executive_commission=commission_amt,
                                commission_paid=False
                            )
                    
                    # update org_transaction
                    org_transaction.mark_success()
                    org_transaction.subscription = subscription
                    org_transaction.payment_id = payment_id
                    org_transaction.payment_date = timezone.now()
                    org_transaction.save()
                    return Response(
                        {
                            "status":
                            "Subscription started after payment success"
                        },
                        status=200
                    )

                elif event == 'payment.failed':
                    org_transaction.mark_failed()
                    return Response(
                        {"status": "Payment failed, order marked"}, status=200
                    )
                else:
                    return Response({"status": "Ignored event"}, status=200)
            else:
                # Handle customer gym membership payment one-time checkout
                cust_transaction = CustomerMembershipTransaction.objects.filter(
                    order_id=order_id
                ).first()
                if cust_transaction:
                    if event == 'payment.captured':
                        cust_transaction.status = 'Successful'
                        cust_transaction.payment_id = payment_id
                        cust_transaction.payment_date = timezone.now()
                        cust_transaction.save()

                        # Activate customer membership
                        CustomerMembership.objects.create(
                            customer=cust_transaction.customer,
                            membership=cust_transaction.membership,
                            razorpay_order_id=cust_transaction.order_id,
                            razorpay_payment_id=payment_id,
                            amount=cust_transaction.amount,
                            status='Active',
                            payment_status='completed',
                            start_date=timezone.now(),
                            end_date=timezone.now() + timezone.timedelta(days=cust_transaction.membership.duration_days),
                            is_active=True
                        )

                        # Set customer active status
                        customer = cust_transaction.customer
                        customer.is_active_member = True
                        customer.save(update_fields=['is_active_member'])

                        # If coupon is applied, increment and award commission
                        if cust_transaction.coupon:
                            coupon = cust_transaction.coupon
                            coupon.used_count += 1
                            coupon.save(update_fields=['used_count'])

                            if coupon.sales_executive:
                                commission_amt = 0
                                if coupon.share_type == 'percentage':
                                    commission_amt = (cust_transaction.amount * coupon.share_value) / 100
                                else:
                                    commission_amt = coupon.share_value

                                discount_amount = cust_transaction.membership.offer_price - cust_transaction.amount

                                SubscriptionTransaction.objects.create(
                                    membership_plan=cust_transaction.membership,
                                    user=cust_transaction.customer.user,
                                    coupon=coupon,
                                    sales_executive=coupon.sales_executive,
                                    original_amount=cust_transaction.membership.offer_price,
                                    discount_amount=discount_amount,
                                    final_amount=cust_transaction.amount,
                                    executive_commission=commission_amt,
                                    commission_paid=False
                                )

                        return Response({"status": "Customer membership activated after payment success"}, status=200)

                    elif event == 'payment.failed':
                        cust_transaction.status = 'Failed'
                        cust_transaction.save()
                        return Response({"status": "Customer payment failed, transaction marked failed"}, status=200)
                    else:
                        return Response({"status": "Ignored event"}, status=200)

                return Response({"status": "Transaction not found for this order"}, status=200)

        elif event.startswith("transfer."):

            transfer_entity = payload["payload"]["transfer"]["entity"]

            transfer_id = transfer_entity["id"]
            account_id = transfer_entity["recipient"]
            transfer_amount = transfer_entity["amount"] / 100
            transfer_status = transfer_entity.get("status", "")

            # Save/update transfer logs
            transfer_obj, created = PartnerTransfer.objects.update_or_create(
                transfer_id=transfer_id,
                defaults={
                    "account_id": account_id,
                    "amount": transfer_amount,
                    "status": transfer_status,
                }
            )

            # Handle transfer state
            if event == "transfer.created":
                transfer_obj.status = "created"
                transfer_obj.save()
                return Response(
                    {"status": "Transfer created logged"},
                    status=200
                )

            elif event == "transfer.processed":
                transfer_obj.status = "processed"
                transfer_obj.settlement_date = timezone.now()
                transfer_obj.save()
                return Response({"status": "Transfer processed"}, status=200)

            elif event == "transfer.failed":
                transfer_obj.status = "failed"
                transfer_obj.save()
                return Response(
                    {"status": "Transfer failed logged"},
                    status=200
                )

            return Response({"status": "Transfer event logged"}, status=200)

        # Handle settlement events
        elif event.startswith("settlement."):
            settlement_entity = payload["payload"]["settlement"]["entity"]

            if event == "settlement.processed":
                # Extract settlement details
                settlement_id = settlement_entity.get("id")

                if settlement_id:
                    try:
                        # Fetch all transfers for this settlement from Razorpay API
                        settlement_transfers = client.settlement.transfers(settlement_id)

                        # settlement_transfers is a dict with 'items' key containing list of transfers
                        transfers_list = settlement_transfers.get('items', [])

                        # Update status for each transfer in the settlement
                        for transfer_data in transfers_list:
                            transfer_id = transfer_data.get('id')

                            if transfer_id:
                                try:
                                    # Find the PartnerTransfer in our database
                                    transfer_obj = PartnerTransfer.objects.get(transfer_id=transfer_id)

                                    # Update PartnerTransfer status to settled
                                    transfer_obj.status = 'settled'
                                    transfer_obj.save(update_fields=['status'])

                                    # Update transaction transfer status to successful
                                    if transfer_obj.customer_transaction:
                                        _update_transaction_transfer_status(
                                            transfer_obj.customer_transaction,
                                            status='successful',
                                            remarks=f"Settlement processed. Funds settled to gym account. Settlement ID: {settlement_id}"
                                        )

                                except PartnerTransfer.DoesNotExist:
                                    logger.warning(f"PartnerTransfer not found for transfer_id: {transfer_id}")
                                    continue

                        return Response({
                            "status": "Settlement processed",
                            "transfers_updated": len(transfers_list)
                        }, status=200)

                    except Exception as e:
                        logger.error(f"Error fetching transfers for settlement {settlement_id}: {str(e)}")
                        return Response({
                            "error": "Failed to fetch settlement transfers",
                            "details": str(e)
                        }, status=500)

                return Response({"status": "Settlement event logged"}, status=200)

            return Response({"status": "Settlement event logged"}, status=200)

        return Response({"status": "Ignored event"}, status=200)
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


# payment status
class CheckPaymentStatusAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        order_id = request.query_params.get("order_id")
        if not order_id:
            return Response({"message": "order_id is required."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            transaction = OrganizationTransaction.objects.get(order_id=order_id)
        except OrganizationTransaction.DoesNotExist:
            try:
                transaction = CustomerMembershipTransaction.objects.get(order_id=order_id)
            except CustomerMembershipTransaction.DoesNotExist:
                return Response({"message": "Transaction not found."}, status=status.HTTP_404_NOT_FOUND)

        data = {
            "order_id": transaction.order_id,
            "payment_id": transaction.payment_id,
            "status": transaction.status,
            "amount": transaction.amount
        }
        return Response(data, status=status.HTTP_200_OK)


def razorpay_checkout(request, order_id):
    # Get order details from DB
    transaction = CustomerMembershipTransaction.objects.get(order_id=order_id)
    
    context = {
        'razorpay_key': settings.RAZORPAY_KEY_ID,
        'amount': int(transaction.amount * 100),
        'order_id': order_id,
        'user': request.user,
    }
    return render(request, 'razorpay_checkout.html', context)  


class CustomerSubscriptionCreateAPIView(APIView):
    permission_classes = [CustomerOnlyPermission]

    def post(self, request):
        # ------------------
        # Manual Validation and Data Extraction
        # ------------------
        payload = json.loads(request.body)
        membership_plan_id = payload.get('plan_id')
        emi_plan_id = payload.get('emi_plan_id')
        customer = getattr(request.user, 'customer', None)

        if not membership_plan_id:
            return Response({"error": "plan_id is required."}, status=status.HTTP_400_BAD_REQUEST)
        if not customer:
            return Response({"error": "Customer profile not found for the logged-in user."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            membership_plan = get_object_or_404(MembershipPlan, id=membership_plan_id, is_active=True)
        except MembershipPlan.DoesNotExist:
            return Response({"error": "Invalid or inactive membership plan."}, status=status.HTTP_400_BAD_REQUEST)

        emi_plan = None
        if emi_plan_id:
            try:
                emi_plan = get_object_or_404(EmiPlan, id=emi_plan_id, membership_plan=membership_plan)
            except EmiPlan.DoesNotExist:
                return Response({"error": "Invalid EMI plan for the selected membership."}, status=status.HTTP_400_BAD_REQUEST)

        if CustomerMembership.objects.filter(customer=customer, status='Active').exists():
            return Response({"error": "You already have an active subscription."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            
            if emi_plan:
                subscription_data = {
                    "plan_id": emi_plan.razorpay_plan_id,
                    "total_count": emi_plan.number_of_installments,
                    "customer_notify": 1,
                    "quantity": 1,
                    "notes": {"emi_plan_id": emi_plan.id}
                }
                subscription_data["notes"] = {"emi_plan_id": emi_plan.id}
            # Determine subscription parameters based on the plan type
            
            else:
                total_count = 1
                if membership_plan.package_type == 'Quarterly Plan':
                    total_count = 3
                elif membership_plan.package_type == '6 Month Plan':
                    total_count = 6
                elif membership_plan.package_type == 'Yearly Plan':
                    total_count = 12
                
                subscription_data = {
                    "plan_id": membership_plan.razorpay_plan_id,
                    "total_count": total_count,
                    "customer_notify": 1,
                    "quantity": 1,
                }
            
            

            subscription = client.subscription.create(subscription_data)

            CustomerMembership.objects.create(
                customer=customer,
                membership=membership_plan,
                emi_plan=emi_plan,
                razorpay_subscription_id=subscription['id'],
                amount=emi_plan.total_emi_amount if emi_plan else membership_plan.actual_price,
                status="PENDING",
                payment_status="pending",
                start_date=timezone.now(),
                end_date=timezone.now() + timezone.timedelta(days=membership_plan.duration_days),
            )
            
            return Response({'subscription_id': subscription['id']}, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({'message': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class CreateTrainerOrderAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = TrainerRazorpayOrderCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        plan = serializer.validated_data['plan_id']
        trainer = getattr(request.user, 'trainer_profile', None)
        if not trainer:
            return Response({'message': 'Trainer profile not found.'}, status=status.HTTP_400_BAD_REQUEST)

        # Free plan — skip Razorpay
        if plan.total_cost == 0:
            trans = OrganizationTransaction.objects.create(
                user=request.user,
                trainer=trainer,
                trainer_plan=plan,
                period=plan.period,
                amount=0,
            )
            data = TrainerTransactionSerializer(trans).data
            data['is_free_plan'] = True
            return Response(data, status=status.HTTP_201_CREATED)

        # Paid plan — create Razorpay order
        amount_in_paise = int(plan.discounted_price * 100)
        razorpay_client = razorpay.Client(auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET))

        try:
            response = razorpay_client.order.create({
                'amount': amount_in_paise,
                'currency': 'INR',
                'receipt': request.user.username,
                'payment': {
                    'capture': 'automatic',
                    'capture_options': {'refund_speed': 'normal'},
                },
            })
        except Exception as e:
            return Response({'message': str(e)}, status=status.HTTP_400_BAD_REQUEST)

        trans = OrganizationTransaction.objects.create(
            user=request.user,
            trainer=trainer,
            trainer_plan=plan,
            period=plan.period,
            order_id=response['id'],
            amount=plan.discounted_price,
        )

        data = TrainerTransactionSerializer(trans).data
        data['is_free_plan'] = False
        return Response(data, status=status.HTTP_201_CREATED)
