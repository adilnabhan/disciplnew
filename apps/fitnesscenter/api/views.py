import logging

from django.shortcuts import get_object_or_404
from apps.fitnesscenter.api.mixins import DashboardStatsMixin

logger = logging.getLogger(__name__)
from psycopg import Transaction
from rest_framework.response import Response
from rest_framework.views import APIView
from apps.customers.models import Customer, CustomerMembership, CustomerMembershipTransaction, CustomerReview
from apps.fitnesscenter.api.serializers import BankAccountDetailsSerializer, CustomerListSerializer, CustomerMembershipExpirationSerializer, CustomerReviewListSerializer, CustomerTransactionListSerializer, MembershipPlanSerializer, OrganizationCreateSerializer, OrganizationDetailSerializer, OrganizationSubscriptionStatusSerializer, OrganizationUpdateSerializer, TrainerListSerializer
from apps.fitnesscenter.models import Amenity, BankAccountDetails, Category, MembershipPlan, Organization, OrganizationPhoto
from apps.mentors.api.serializers import OrganizationSerializer
from apps.mentors.models import MentorProfile
from apps.user.models import User
from apps.fitnesscenter.api.serializers import BankAccountDetailsSerializer, CustomerListSerializer, CustomerMembershipExpirationSerializer, CustomerReviewListSerializer, CustomerTransactionListSerializer, MembershipPlanSerializer, OrganizationCreateSerializer, OrganizationDetailSerializer, OrganizationSubscriptionStatusSerializer, OrganizationUpdateSerializer, TrainerListSerializer, CouponValidateSerializer
from apps.fitnesscenter.models import Amenity, BankAccountDetails, Category, MembershipPlan, Organization, OrganizationPhoto
from apps.mentors.api.serializers import OrganizationSerializer
from apps.mentors.models import MentorProfile
from apps.user.models import User, Coupon
from apps.utils.pagination import CustomPagination
from apps.utils.permission import MentorOnlyPermission
from rest_framework import status
from rest_framework.decorators import (
    api_view,
    permission_classes,
)
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import IsAuthenticated,AllowAny
from django.http import JsonResponse
from rest_framework import viewsets, permissions
from rest_framework.generics import RetrieveAPIView, UpdateAPIView, ListAPIView
from datetime import timedelta
from django.utils import timezone
from django.db.models import Q, F, ExpressionWrapper, fields, Sum, OuterRef, Subquery, Count
from rest_framework import serializers
from rest_framework.exceptions import PermissionDenied, ValidationError
from django.db import IntegrityError
from datetime import datetime
from apps.fitnesscenter.utils import create_linked_account


# common apis
@api_view()
@permission_classes((AllowAny,))
def get_categories(request):
    name = request.GET.get('name', '')
    queryset = Category.objects.filter(is_active=True)
    if name:
        queryset = queryset.filter(name__icontains=name)
    data = []
    for item in queryset.order_by('display_order'):
        logo_url = item.logo.url if item.logo else None
        data.append({
            'id': item.id,
            'name': item.name,
            'logo': logo_url
        })
    return JsonResponse({
        'results': data
    }, safe=False)


@api_view()
@permission_classes((IsAuthenticated,))
def get_amenities(request):
    name = request.GET.get('name', '')
    queryset = Amenity.objects.all()
    if name:
        queryset = queryset.filter(name__icontains=name)
    data = []
    for item in queryset.order_by('display_order'):
        logo_url = item.logo.url if item.logo else None
        data.append({
            'id': item.id,
            'name': item.name,
            'logo': logo_url
        })
    return JsonResponse({
        'results': data
    }, safe=False)


class OrganizationUpcomingRenewalApiView(DashboardStatsMixin, APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request, *args, **kwargs):
        user = request.user
        organization_id = request.query_params.get('organization_id')
        status = request.query_params.get('status')  # active, expired, or None
        sort = request.query_params.get('sort', 'recent')  # recent or oldest
        filter_param = request.query_params.get('day_filter', '10d') # 1d, 7d, 1m
        search = request.query_params.get('search', '').strip()
        print(search, 'SEARCH')
        if not organization_id:
            return Response({"detail": "Organization ID is required."}, status=400)

        try:
            organization = Organization.objects.get(id=organization_id, mentor__user=user)
        except Organization.DoesNotExist:
            return Response({"detail": "Organization not found or not associated with this mentor."})
        customers = Customer.objects.filter(organization=organization)
        days = 10

        if filter_param and filter_param.endswith('d'):
            try:
                days = int(filter_param[:-1])
            except ValueError:
                days = 10  # fallback if invalid input

        now = timezone.now()
        future_date = now + timedelta(days=days)
        if status == "upcomingpayments":
            memberships = CustomerMembership.objects.filter(
                            membership__organization_id=organization.id,
                            status=CustomerMembership.ACTIVE,
                            next_due_date__gte=now,
                            next_due_date__lte=future_date
                        ).select_related(
                            'customer__user',
                            'membership'
                        ).order_by('next_due_date')

            response_data = []

            for membership in memberships:
                customer = membership.customer
                user = customer.user
                full_name = f"{user.first_name} {user.last_name}".strip()
                days_remaining = (membership.next_due_date.date() - now.date()).days

                if days_remaining <= 0:
                    expiry_label = "Expires By Today"
                elif days_remaining == 1:
                    expiry_label = "Expires In 1 Day"
                else:
                    expiry_label = f"Expires In {days_remaining} Days"

                response_data.append({
                    "id": customer.id,
                    "name": full_name,
                    "phone": str(user.mobile_number) if user and user.mobile_number else None,
                    "profile_image": user.profile_picture.url if user.profile_picture else None,
                    "membership_name": membership.membership.name,
                    "renewal_date": membership.next_due_date,
                    "days_remaining": days_remaining,
                    "expiry_label": expiry_label
                })

                return Response({
                    "status": "success",
                    "data": response_data
                })
        
        if status == "upcomingemis":

            memberships = CustomerMembership.objects.filter(
                membership__organization_id=organization.id,
                status=CustomerMembership.ACTIVE,
                emi_plan_id__isnull=False,
                next_due_date__gte=now,
                next_due_date__lte=future_date
            ).select_related(
                'customer__user',
                'membership'
            ).order_by('next_due_date')

            response_data = []

            for membership in memberships:
                customer = membership.customer
                user = customer.user

                full_name = " ".join(
                    filter(None, [user.first_name, user.last_name])
                )

                days_remaining = (membership.next_due_date.date() - now.date()).days

                if days_remaining <= 0:
                    expiry_label = "Due Today"
                elif days_remaining == 1:
                    expiry_label = "Due In 1 Day"
                else:
                    expiry_label = f"Due In {days_remaining} Days"

                response_data.append({
                    "id": customer.id,
                    "name": full_name,
                    "phone": str(user.mobile_number) if user and user.mobile_number else None,
                    "profile_image": user.profile_picture.url if user.profile_picture else None,
                    "membership_name": membership.membership.name,
                    "next_due_date": membership.next_due_date,
                    "days_remaining": days_remaining,
                    "expiry_label": expiry_label,
                    "emi_plan_id": membership.emi_plan_id
                })

            return Response({
                "status": "success",
                "data": response_data
            })

        # Default fallback
        serializer = CustomerListSerializer(customers, many=True)
        return Response(serializer.data)
        

class OrganizationHomeAPIView(DashboardStatsMixin, APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        user = request.user
        organization_id = request.query_params.get('organization_id')

        if user.user_role not in [
            User.MENTOR, User.MENTOR_STAFF,
            User.MENTOR_ACCOUNTS, User.MENTOR_TRAINER
        ]:
            return Response({"detail": "Not authorized."}, status=403)

        if not organization_id:
            return Response({"detail": "Organization ID is required."}, status=400)

        # Validate organization access
        org_id, error = self.validate_organization(request, organization_id)
        if error:
            return error

        organization = Organization.objects.get(id=org_id)

        trainer_count = self.get_trainer_count(organization)
        active_customers_count = self.get_active_customers_count(organization)
        expired_customers_count = self.get_expired_customers_count(organization)
        upcoming_renewals_count = self.get_upcoming_renewals_count(org_id)
        upcoming_emis_count = self.get_upcoming_emi_count(org_id)
        total_payment = self.get_total_payment_received(org_id)

        # Today's leads: unique customers who enquired today
        from apps.customers.models import MembershipRequest
        from django.utils.timezone import localdate
        today = localdate()
        todays_leads = MembershipRequest.objects.filter(
            organization=organization,
            requested_at__date=today,
        ).exclude(
            status__in=['closed', 'rejected']
        ).values('customer').distinct().count()

        # Total pending leads (all time)
        total_pending_leads = MembershipRequest.objects.filter(
            organization=organization,
            status__in=['pending', 'contacted']
        ).count()

        # Static banner images
        filenames = ["gymbanner1.png", "gymbanner2.png", "gymbanner3.png"]
        home_banner = [
            f"/static/images/{f}" for f in filenames
        ]
        print("total_payment:", total_payment)

        return Response({
            "organization_id": organization.id,
            "trainer_count": trainer_count,
            "active_customers_count": active_customers_count,
            "expired_customers_count": expired_customers_count,
            "home_banner": home_banner,
            "upcoming_payment_count": upcoming_renewals_count,
            "upcoming_renewals_count": 0,  # future enhancement,
            "upcoming_emis_count": upcoming_emis_count,
            "total_payment": total_payment,
            "allPayment_count": total_payment,
            "todays_leads": todays_leads,
            "total_pending_leads": total_pending_leads,
        })


from rest_framework.exceptions import ValidationError

class OrganizationCreateAPIView(APIView):
    permission_classes = [MentorOnlyPermission]

    def post(self, request):
        try:
            mentor_profile = getattr(request.user, 'mentor_profile', None)
            if not mentor_profile:
                # Auto-create MentorProfile if missing (user registered via OTP but profile wasn't created)
                from apps.utils.mobilenumber import hash_contact_number
                mobile_hash = hash_contact_number(
                    request.user.mobile_number.as_international
                ) if request.user.mobile_number else None
                mentor_profile = MentorProfile.objects.create(
                    user=request.user,
                    hash_of_user_phone_number=mobile_hash,
                    designation=MentorProfile.ADMIN
                )
            serializer = OrganizationCreateSerializer(data=request.data, context={'request': request, 'mentor': mentor_profile})
            serializer.is_valid(raise_exception=True)
            organization = serializer.save()
            organization.registration_status = Organization.REGISTERED
            organization.save(update_fields=['registration_status'])
            return Response({
                "success": True,
                "message": "Organization created successfully",
                "id": organization.id,
                "name": organization.name,
                "slug": organization.slug,
            }, status=status.HTTP_201_CREATED)

        except ValidationError as ve:
            return Response({
                "success": False,
                "errors": ve.detail
            }, status=status.HTTP_400_BAD_REQUEST)

        except Exception as e:
            return Response({
                "success": False,
                "message": f"Failed to create organization: {str(e)}"
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
class OrganizationBasedUserGetAPIView(APIView):
    permission_classes = [MentorOnlyPermission]

    def get(self, request):
        mentor_profile = getattr(request.user, 'mentor_profile', None)

        if not mentor_profile:
            return Response({
                    "success": False,
                    "message": "User is not a mentor"
                }, status=status.HTTP_403_FORBIDDEN)

        organizations = Organization.objects.filter(mentor=mentor_profile).all() 

        if not organizations.exists(): 
            return Response({
                "success": False,
                "message": "No organizations found for this mentor."
            }, status=status.HTTP_404_NOT_FOUND)  

        serializer = OrganizationSerializer(organizations,many=True)
        return Response({
            "success": True,
            "result": serializer.data
        }, status=status.HTTP_200_OK)

class MembershipPlanViewSet(viewsets.ModelViewSet):
    queryset = MembershipPlan.objects.all()
    serializer_class = MembershipPlanSerializer
    permission_classes = [MentorOnlyPermission]

    def get_queryset(self):
        """
        Optionally restricts the returned membership plans to a given organization,
        by filtering against a `organization_id` query parameter in the URL.
        """
        mentor = getattr(self.request.user, 'mentor_profile', None)

        org_ids = mentor.organizations.values_list('id', flat=True) if mentor else []
        queryset = MembershipPlan.objects.filter(organization_id__in=org_ids)
        org_id = self.request.query_params.get('organization_id')
        if org_id:
            queryset = queryset.filter(organization_id=org_id)

        return queryset
    
    
class OrganizationDetailAPIView(RetrieveAPIView):
    queryset = Organization.objects.all()
    serializer_class = OrganizationDetailSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = 'id'
    

class OrganizationUpdateAPIView(viewsets.ModelViewSet):
    """
    ViewSet for handling organization and all related models updates.
    Uses a single unified update endpoint with section identifiers.
    """
    queryset = Organization.objects.all()
    serializer_class = OrganizationUpdateSerializer
    permission_classes = [IsAuthenticated]
    
    def get_serializer_context(self):
        context = super().get_serializer_context()
        context.update({"request": self.request})
        return context

    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        partial = request.method.lower() == 'patch'
        serializer = self.get_serializer(instance, data=request.data, partial=partial)

        try:
            serializer.is_valid(raise_exception=True)
            org = serializer.save()
            bank_details = getattr(org, "bank_account_details", None)
            return Response({"message": "Organization updated successfully.","data": serializer.data}, status=status.HTTP_200_OK)
        except serializers.ValidationError as e:
            return Response({"errors": e.detail}, status=status.HTTP_400_BAD_REQUEST)
   

class CustomerListAPIView(APIView):
    permission_classes = [IsAuthenticated]
    pagination_class = CustomPagination()


    def get(self, request, *args, **kwargs):
        user = request.user
        organization_id = request.query_params.get('organization_id')
        status = request.query_params.get('status')  # active, expired, or None
        sort = request.query_params.get('sort', 'recent')  # recent or oldest
        filter_param = request.query_params.get('day_filter') # 1d, 7d, 1m
        search = request.query_params.get('search', '').strip()
        print(search, 'SEARCH')
        if not organization_id:
            return Response({"detail": "Organization ID is required."}, status=400)

        try:
            organization = Organization.objects.get(id=organization_id, mentor__user=user)
        except Organization.DoesNotExist:
            return Response({"detail": "Organization not found or not associated with this mentor."})

        customers = Customer.objects.filter(organization=organization)

        if status == 'active':
            customers = Customer.objects.filter(
                            memberships__membership__organization=organization,
                            memberships__status__in=[
                                CustomerMembership.ACTIVE,
                                CustomerMembership.TRIAL
                            ]
                        ).distinct()
        elif status == 'expired':
            now = timezone.now()
            today = now.date()
            customers = Customer.objects.filter(
                            memberships__membership__organization=organization
                        ).exclude(
                            memberships__status__in=[
                                CustomerMembership.ACTIVE,
                                CustomerMembership.TRIAL
                            ]
                        ).distinct()
            
            if filter_param:
                if filter_param == 'today':
                    target_day = today
                elif filter_param.endswith('d'):
                    try:
                        days = int(filter_param.replace('d', ''))
                        target_day = (today - timedelta(days=days))
                    except ValueError:
                        target_day = None
                else:
                    target_day = None

                if target_day:
                    customers = customers.filter(
                        memberships__end_date__date=target_day
                    )
            customers = customers.distinct()
            
        elif status == 'upcoming':
            now = timezone.now()
            fifteen_days_from_now = now + timedelta(days=15)

            customers = customers.filter(
                memberships__status__in=[CustomerMembership.ACTIVE, CustomerMembership.TRIAL],
                memberships__end_date__lte=fifteen_days_from_now,
                memberships__end_date__gte=now
            )

            if filter_param == 'today':
                target_day = now.date()
            elif filter_param.endswith('d'):
                try:
                    days = int(filter_param.replace('d', ''))
                    target_day = (now + timedelta(days=days)).date()
                except ValueError:
                    target_day = None
            else:
                target_day = None

            if target_day:
                customers = customers.filter(
                    memberships__end_date__date=target_day
                )


        if search:
            print(customers, 'CUSTOMERS')
            search_parts = search.split()
            q_obj = (
                Q(user__first_name__icontains=search) |
                Q(user__last_name__icontains=search) |
                Q(user__mobile_number__icontains=search)
            )

            if len(search_parts) > 1:
                q_obj |= Q(user__first_name__icontains=search_parts[0], user__last_name__icontains=search_parts[-1])

            customers = customers.filter(q_obj)
            print(customers, 'AFTER CUSTOMERS')


        if sort == 'recent':
            customers = customers.order_by('-created')
        elif sort == 'oldest':
            customers = customers.order_by('created')

        paginator = self.pagination_class
        page = paginator.paginate_queryset(customers, request)
        serializer = CustomerListSerializer(page, many=True)

        return paginator.get_paginated_response(serializer.data)
        


class TrainersListAPIView(APIView):
    permission_classes = [IsAuthenticated]
    pagination_class = CustomPagination()

    def get(self, request, *args, **kwargs):
        from apps.trainer.models import Trainer, OrganizationTrainerLink

        organization_id = request.query_params.get('organization_id')
        sort = request.query_params.get('sort', 'recent')
        status_filter = request.query_params.get('status')
        search = request.query_params.get('search', '').strip()

        if not organization_id:
            return Response({"detail": "Organization ID is required."}, status=400)

        try:
            organization = Organization.objects.get(id=organization_id)
        except Organization.DoesNotExist:
            return Response({"detail": "Organization not found."}, status=404)

        links = OrganizationTrainerLink.objects.filter(
            organization=organization,
            status=OrganizationTrainerLink.APPROVED
        ).select_related('trainer__user')

        trainers = [link.trainer for link in links]

        if status_filter == 'active':
            trainers = [t for t in trainers if t.user and t.user.is_active]
        elif status_filter == 'inactive':
            trainers = [t for t in trainers if not t.user or not t.user.is_active]

        if search:
            trainers = [
                t for t in trainers if
                search.lower() in (t.first_name or '').lower() or
                search.lower() in (t.last_name or '').lower() or
                search in (t.mobile or '')
            ]

        if sort == 'oldest':
            trainers = sorted(trainers, key=lambda t: t.created_at)
        else:
            trainers = sorted(trainers, key=lambda t: t.created_at, reverse=True)

        paginator = self.pagination_class
        page = paginator.paginate_queryset(trainers, request)

        result = []
        for trainer in page:
            result.append({
                'id': trainer.id,
                'name': f"{trainer.first_name} {trainer.last_name}".strip(),
                'mobile': trainer.mobile,
                'email': trainer.email,
                'user_type': trainer.user_type,
                'experience_years': trainer.experience_years,
                'profile_image': trainer.profile_image.url if trainer.profile_image else None,
                'is_active': trainer.user.is_active if trainer.user else False,
            })

        return paginator.get_paginated_response(result)
    
    
class OrganizationSubscriptionStatusAPIView(RetrieveAPIView):
    queryset = Organization.objects.all()
    serializer_class = OrganizationSubscriptionStatusSerializer
    permission_classes = [IsAuthenticated] 

    lookup_field = 'id'
    
    
class OrganizationReviewListAPIView(APIView):
    permission_classes = [AllowAny] 
    
    def get(self, request, org_id):
        try:
            organization = Organization.objects.get(id=org_id)
        except Organization.DoesNotExist:
            return Response({"detail": "Organization not found."}, status=status.HTTP_404_NOT_FOUND)
        
        period = request.query_params.get('period', 'latest')

        filter_map = {
            'latest': lambda: timezone.now() - timedelta(days=30),
            'last_3_months': lambda: timezone.now() - timedelta(days=90),
            'last_6_months': lambda: timezone.now() - timedelta(days=180),
            'last_12_months': lambda: timezone.now() - timedelta(days=365),
        }

        queryset = CustomerReview.objects.filter(organization=organization).select_related('customer__user')
        
        if period in filter_map:
            cutoff_date = filter_map[period]()
            queryset = queryset.filter(created__gte=cutoff_date)
            
        queryset = queryset.order_by('-created')
        paginator = CustomPagination()
        paginated_qs = paginator.paginate_queryset(queryset, request)
        serializer = CustomerReviewListSerializer(paginated_qs, many=True, context={'request': request})

        return paginator.get_paginated_response({
            "review_count": organization.review_count,
            "avg_rating": organization.average_rating,
            "reviews": serializer.data
        })
    


class ExpiringMembershipsAPIView(ListAPIView):
    """
    Retrieves and lists customer memberships expiring within the next 10 days,
    filtered by the mentor's organizations.
    """
    permission_classes = [MentorOnlyPermission, IsAuthenticated]
    serializer_class = CustomerMembershipExpirationSerializer 

    def get_queryset(self):
        mentor = self.request.user.mentor_profile
        organization_id = self.request.query_params.get('organization_id')
        
        # 1. Get all organization IDs managed by the mentor
        org_ids = mentor.organizations.values_list('id', flat=True)

        # 2. VALIDATION: Check if a specific organization_id was requested
        if organization_id:
            try:
                # Convert to integer for strict comparison
                org_id_int = int(organization_id)
                
                # Check if the requested organization_id belongs to the mentor
                if org_id_int not in org_ids:
                    # Raise an immediate HTTP 403 Forbidden or similar error
                    return Response(
                        {"error": "You do not have permission to view data for this organization."},
                        status=status.HTTP_403_FORBIDDEN
                    )
                
                # If valid, filter only by this organization
                final_org_filter = [org_id_int]
                
            except ValueError:
                # Handle non-integer organization_id input
                return Response(
                    {"error": "Invalid organization ID format."},
                    status=status.HTTP_400_BAD_REQUEST
                )
        else:
            # If no specific ID is provided, include all mentor's organizations
            final_org_filter = org_ids

        # 3. Filtering and Annotation Logic
        now = timezone.now()
        ten_days_from_now = now + timedelta(days=10)

        queryset = CustomerMembership.objects.filter(
            # Apply the validated organization filter
            membership__organization_id__in=final_org_filter,
            status=CustomerMembership.ACTIVE,
            end_date__gte=now,
            end_date__lte=ten_days_from_now
        ).select_related(
            'customer__user',
            'membership'
        )

        # 4. Annotate and Order
        queryset = queryset.annotate(
            days_until_expire=ExpressionWrapper(
                F('end_date') - timezone.now(), 
                output_field=fields.DurationField()
            )
        ).order_by('end_date')

        return queryset
    

class BankAccountDetailsViewSet(viewsets.ModelViewSet):
    serializer_class = BankAccountDetailsSerializer
    permission_classes = [MentorOnlyPermission, IsAuthenticated]
    
    # We don't want to list ALL bank accounts, only the one requested by the organization_id.
    # The default List action is often disabled for OneToOne relations.
    http_method_names = ['get', 'post', 'patch'] # Limiting methods to what's needed

    def get_queryset(self):
        # We return an empty queryset since we retrieve the object(s) in the list/retrieve methods
        return BankAccountDetails.objects.none() 

    # Retrieve the specific bank details (GET /bank-details/{pk}/)
    def retrieve(self, request, pk=None):
        organization_id = self.kwargs.get('pk')
        mentor = self.request.user.mentor_profile
        try:
            # Check if the organization ID requested belongs to the mentor
            bank_details = get_object_or_404(BankAccountDetails, organization_id=organization_id)

            if bank_details.organization not in mentor.organizations.all():
                 raise PermissionDenied("You do not have permission to view this organization's bank details.")

            serializer = self.get_serializer(bank_details)
            return Response(serializer.data)
        
        except BankAccountDetails.DoesNotExist:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)

    # Create new bank details (POST /bank-details/)
    def create(self, request, *args, **kwargs):
        # 1. Manually extract and validate organization_id
        organization_id = request.data.get('organization_id')

        if not organization_id:
            return Response({"organization_id": "This field is required."}, status=status.HTTP_400_BAD_REQUEST)

        mentor = self.request.user.mentor_profile

        # 2. Check if the mentor owns the organization
        try:
            organization = get_object_or_404(Organization, id=organization_id, mentor=mentor)
        except Organization.DoesNotExist:
            raise PermissionDenied("You do not have permission to manage this organization's bank details.")

        # 3. Check for existing record (OneToOne constraint)
        if BankAccountDetails.objects.filter(organization=organization).exists():
             raise ValidationError({"organization_id": "Bank account details for this organization already exist. Use PATCH to update."})

        # 4. Pass the validated data to the serializer (excluding organization_id from final save)
        mutable_data = request.data.copy()
        mutable_data.pop('organization_id')

        serializer = self.get_serializer(data=mutable_data)
        serializer.is_valid(raise_exception=True)

        # 5. Create temporary unsaved instance
        bank_details = BankAccountDetails(
            organization=organization,
            **serializer.validated_data
        )
    

        bank_details.save()   # creates record and primary key

        # 6. Call Razorpay BEFORE saving - will raise ValidationError if it fails
        rp_data = create_linked_account(organization, bank_details)
        if not rp_data or not rp_data.get("account_id"):
            raise ValidationError({"razorpay_error": "Invalid Razorpay response"})
        # 7. Save with Razorpay IDs and VERIFICATION_PENDING status (only reached if Razorpay succeeds)
        bank_details.razorpay_product_id = rp_data.get("product_id")
        bank_details.razorpay_error_details = rp_data.get("activation_status")  # Store raw Razorpay status
        bank_details.activated_at = rp_data.get("activated_at");
        active_status = rp_data.get("activation_status");
        if active_status=="activated":
            bank_details.razorpay_account_status = BankAccountDetails.ACTIVATED
        else:
            bank_details.razorpay_account_status = BankAccountDetails.VERIFICATION_PENDING
        #bank_details.razorpay_account_status = BankAccountDetails.VERIFICATION_PENDING  # Our status field
        bank_details.save()

        logger.info(f"Bank details created successfully for org {organization.id} with Razorpay account {bank_details.razorpay_account_id}")

        return Response(self.get_serializer(bank_details).data, status=status.HTTP_201_CREATED)

    # Update existing bank details (PATCH /bank-details/{pk}/)
    def partial_update(self, request, pk=None):
        from django.db import transaction

        mentor = self.request.user.mentor_profile

        # 1. Get and authorize the existing bank details object
        bank_details = get_object_or_404(BankAccountDetails, pk=pk)
        if bank_details.organization not in mentor.organizations.all():
            raise PermissionDenied("You do not have permission to modify this record.")

        # 2. Validate serializer
        serializer = self.get_serializer(bank_details, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)

        # 3. Determine if Razorpay call is needed
        # Only call Razorpay if critical field VALUES actually changed (optimization)
        critical_fields = ['account_number', 'ifsc_code', 'account_holder_name', 'business_type']
        fields_changed = any(
            field in serializer.validated_data and
            serializer.validated_data[field] != getattr(bank_details, field)
            for field in critical_fields
        )
        needs_razorpay = not bank_details.razorpay_account_id or fields_changed

        # 4. Atomic update
        with transaction.atomic():
            # Save the updates
            bank_details = serializer.save()

            # Only call Razorpay if needed
            # if needs_razorpay:
                # This will raise ValidationError if Razorpay fails
            rp_data = create_linked_account(
                bank_details.organization,
                bank_details
            )

            # Update Razorpay fields
            active_status = rp_data.get("activation_status")
            bank_details.razorpay_account_id = rp_data.get("account_id")
            bank_details.razorpay_product_id = rp_data.get("product_id")
            bank_details.razorpay_error_details = rp_data.get("activation_status")
            if active_status=="activated":
                bank_details.razorpay_account_status = BankAccountDetails.ACTIVATED
            else:
                bank_details.razorpay_account_status = BankAccountDetails.VERIFICATION_PENDING
            bank_details.save()

            logger.info(f"Updated Razorpay account for org {bank_details.organization.id}")
            # else:
            #     logger.info(f"Updated bank details for org {bank_details.organization.id} without Razorpay call")

        return Response(self.get_serializer(bank_details).data)
        # return Response(serializer.data)


class StandardPagination(PageNumberPagination):
    page_query_param = "page"
    page_size_query_param = "page_size"
    max_page_size = 100
    page_size = 10  # default


class CustomerPaymentsAPIView(APIView, DashboardStatsMixin):
    """
    Returns:
    {
        "all_payments": { paginated list + totals },
        "pending_payments": { paginated list + totals }
    }
    """
    permission_classes = [IsAuthenticated]

    def _filter_queryset(self, request, organization_id):
        """Apply all reusable filters."""
        qs = CustomerMembershipTransaction.objects.select_related(
            "customer__user", "membership"
        ).order_by("-payment_date", "-created_at")

        # --- Organization filter ---
        qs = qs.filter(membership__organization_id=organization_id)

        # --- Search filter ---
        search = request.GET.get("search")
        if search:
            qs = qs.filter(
                Q(customer__user__full_name__icontains=search) |
                Q(membership__name__icontains=search) |
                Q(order_id__icontains=search) |
                Q(payment_id__icontains=search)
            )

        # --- Payment method filter ---
        payment_type = request.GET.get("type")
        if payment_type:
            qs = qs.filter(payment_method__iexact=payment_type)

        # --- Quick date filters ---
        date_filter = request.GET.get("date")
        today = timezone.now().date()

        if date_filter == "today":
            qs = qs.filter(payment_date__date=today)

        elif date_filter == "month":
            now = timezone.now()
            qs = qs.filter(
                payment_date__month=now.month,
                payment_date__year=now.year
            )

        # --- Date range filter ---
        start = request.GET.get("start_date")
        end = request.GET.get("end_date")
        if start and end:
            qs = qs.filter(payment_date__date__range=[start, end])

        return qs

    def _paginate(self, request, queryset):
        """Handles pagination and returns consistent output."""
        paginator = StandardPagination()
        paginated_qs = paginator.paginate_queryset(queryset, request)
        serializer = CustomerTransactionListSerializer(paginated_qs, many=True)
        return paginator.get_paginated_response(serializer.data).data

    def get(self, request):
        # Validate organization access
        organization_id = request.query_params.get("organization_id")
        if not organization_id:
            return Response(
                {"detail": "Organization ID is required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        organization_id, error_response = self.validate_organization(request, organization_id)
        if error_response:
            return error_response

        qs = self._filter_queryset(request, organization_id)

        # Paginated All Payments
        all_payments = self._paginate(request, qs)

        # Paginated Pending Payments - Successful payments awaiting settlement
        pending_qs = qs.filter(
            status="Successful",
            transfer_status="pending"
        )
        pending_payments = self._paginate(request, pending_qs)

        # Shared totals
        today = timezone.now().date()

        total_paid_today = CustomerMembershipTransaction.objects.filter(
            status="Successful",
            payment_date__date=today,
            membership__organization_id=organization_id
        ).aggregate(total=Sum("amount"))["total"] or 0

        total_pending_amount = CustomerMembershipTransaction.objects.filter(
            status="Pending",
            membership__organization_id=organization_id
        ).aggregate(total=Sum("amount"))["total"] or 0

        # Inject totals into both response sections
        for section in (all_payments, pending_payments):
            section["total_paid_today"] = total_paid_today
            section["total_pending_amount"] = total_pending_amount

        return Response({
            "all_payments": all_payments,
            "pending_payments": pending_payments
        })
    
class OrganizationPhotoDeleteAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, photo_id, *args, **kwargs):
        try:
            photo = OrganizationPhoto.objects.get(id=photo_id)
        except OrganizationPhoto.DoesNotExist:
            return Response(
                {
                    "status": "error",
                    "message": "Photo not found"
                },
                status=status.HTTP_404_NOT_FOUND
            )

        # Check ownership
        if photo.organization.mentor.user != request.user:
            return Response(
                {
                    "status": "error",
                    "message": "You are not allowed to delete this photo"
                },
                status=status.HTTP_403_FORBIDDEN
            )

        # Delete file from storage
        if photo.image:
            photo.image.delete(save=False)

        photo.delete()

        return Response(
            {
                "status": "success",
                "message": "Photo deleted successfully"
            },
            status=status.HTTP_200_OK
        )


class OrganizationBulkPhotoUploadAPIView(APIView):
    """
    Bulk upload photos for a fitness center.
    Accepts multipart/form-data with:
      - organization_id (required)
      - photos (multiple files)
      - captions (optional, JSON list matching photo order)
    """
    permission_classes = [MentorOnlyPermission]

    def post(self, request):
        organization_id = request.data.get('organization_id')
        if not organization_id:
            return Response(
                {'detail': 'organization_id is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            organization = Organization.objects.get(
                id=organization_id, mentor__user=request.user
            )
        except Organization.DoesNotExist:
            return Response(
                {'detail': 'Organization not found.'},
                status=status.HTTP_404_NOT_FOUND
            )

        files = request.FILES.getlist('photos')
        if not files:
            return Response(
                {'detail': 'No photos provided.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Optional captions (JSON list or comma-separated)
        captions_raw = request.data.get('captions', '[]')
        try:
            import json
            if isinstance(captions_raw, str):
                captions = json.loads(captions_raw)
            elif isinstance(captions_raw, list):
                captions = captions_raw
            else:
                captions = []
        except (json.JSONDecodeError, TypeError):
            captions = []

        created_photos = []
        for i, photo_file in enumerate(files):
            caption = captions[i] if i < len(captions) else None
            photo = OrganizationPhoto.objects.create(
                organization=organization,
                image=photo_file,
                caption=caption,
                is_primary=(i == 0 and not organization.photos.exists()),
            )
            created_photos.append({
                'id': photo.id,
                'image': photo.image.url if photo.image else None,
                'caption': photo.caption,
                'is_primary': photo.is_primary,
                'uploaded_at': photo.uploaded_at.isoformat(),
            })

        return Response(
            {
                'status': 'success',
                'message': f'{len(created_photos)} photo(s) uploaded successfully.',
                'photos': created_photos,
            },
            status=status.HTTP_201_CREATED
        )


class CouponValidationAPIView(APIView):
    def post(self, request):
        serializer = CouponValidateSerializer(data=request.data)

        if not serializer.is_valid():
            return Response({
                "status": "failure",
                "message": "Invalid request data"
            }, status=status.HTTP_400_BAD_REQUEST)

        code = serializer.validated_data["code"].strip()

        try:
            coupon = Coupon.objects.get(code__iexact=code)
        except Coupon.DoesNotExist:
            return Response({
                "status": "failure",
                "message": "Invalid coupon code"
            }, status=status.HTTP_404_NOT_FOUND)

        now = timezone.now()

        # Check active
        if not coupon.is_active:
            return Response({
                "status": "failure",
                "message": "Coupon is inactive"
            })

        # Check validity period
        if coupon.valid_from and now < coupon.valid_from:
            return Response({
                "status": "failure",
                "message": "Coupon not yet valid"
            })

        if coupon.valid_to and now > coupon.valid_to:
            return Response({
                "status": "failure",
                "message": "Coupon expired"
            })

        # Check usage limit
        if coupon.max_usage and coupon.used_count >= coupon.max_usage:
            return Response({
                "status": "failure",
                "message": "Coupon usage limit exceeded"
            })

        # SUCCESS
        return Response({
            "status": "success",
            "data": {
                "code": coupon.code,
                "discount_type": coupon.discount_type,
                "discount_value": coupon.discount_value,
                "sales_executive": coupon.sales_executive.name if coupon.sales_executive else None
            }
        })


# ============================================
# Gym-side Membership Request Views
# ============================================

from apps.customers.models import MembershipRequest
from apps.fitnesscenter.api.serializers import GymMembershipRequestListSerializer, GymMembershipRequestActionSerializer


class GymMembershipRequestListView(APIView):
    """Gym/mentor lists all join requests (customers + trainers) for their organization."""
    permission_classes = [MentorOnlyPermission]

    def get(self, request):
        organization_id = request.query_params.get('organization_id')
        status_filter = request.query_params.get('status')
        request_type = request.query_params.get('type')  # 'customer', 'trainer', or None (all)

        if not organization_id:
            return Response(
                {"detail": "Organization ID is required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            organization = Organization.objects.get(
                id=organization_id, mentor__user=request.user
            )
        except Organization.DoesNotExist:
            return Response(
                {"detail": "Organization not found or not associated with this mentor."},
                status=status.HTTP_404_NOT_FOUND
            )

        results = []

        # --- Customer membership requests ---
        if not request_type or request_type == 'customer':
            customer_qs = MembershipRequest.objects.filter(
                organization=organization
            ).select_related('customer__user', 'membership_plan', 'selected_plan')
            if status_filter:
                customer_qs = customer_qs.filter(status=status_filter)

            for mr in customer_qs:
                customer = mr.customer
                user = customer.user
                results.append({
                    'id': mr.id,
                    'type': 'customer',
                    'status': mr.status,
                    'requested_at': mr.requested_at,
                    'responded_at': mr.responded_at,
                    'notes': mr.notes,
                    'gym_remarks': mr.gym_remarks,
                    'membership_plan': {
                        'id': mr.membership_plan.id,
                        'name': mr.membership_plan.name,
                    } if mr.membership_plan else None,
                    'requester': {
                        'id': customer.id,
                        'name': f"{user.first_name} {user.last_name}".strip() if user else '',
                        'mobile': str(user.mobile_number) if user and user.mobile_number else None,
                        'profile_picture': u.profile_picture.url if u and u.profile_picture else None,
                    }
                })

        # --- Trainer join requests ---
        if not request_type or request_type == 'trainer':
            trainer_status = status_filter or OrganizationTrainerLink.PENDING
            trainer_qs = OrganizationTrainerLink.objects.filter(
                organization=organization,
                status=trainer_status
            ).select_related('trainer__user')

            for link in trainer_qs:
                trainer = link.trainer
                results.append({
                    'id': link.id,
                    'type': 'trainer',
                    'status': link.status,
                    'requested_at': link.requested_at,
                    'responded_at': link.responded_at,
                    'rejection_reason': link.rejection_reason,
                    'requester': {
                        'id': trainer.id,
                        'name': f"{trainer.first_name} {trainer.last_name}".strip(),
                        'mobile': trainer.mobile,
                        'profile_image': trainer.profile_image.url if trainer.profile_image else None,
                        'user_type': trainer.user_type,
                        'experience_years': trainer.experience_years,
                    }
                })

        results.sort(key=lambda x: x['requested_at'], reverse=True)

        paginator = CustomPagination()
        page = paginator.paginate_queryset(results, request)
        return paginator.get_paginated_response(page)


class GymMembershipRequestActionView(APIView):
    """Gym accepts or rejects a membership request."""
    permission_classes = [MentorOnlyPermission]

    def patch(self, request, pk):
        from django.db import transaction as db_transaction
        from apps.communication.notifications import send_push_notification

        # Get the membership request
        try:
            membership_request = MembershipRequest.objects.select_related(
                'customer', 'organization', 'membership_plan'
            ).get(pk=pk)
        except MembershipRequest.DoesNotExist:
            return Response(
                {"detail": "Membership request not found."},
                status=status.HTTP_404_NOT_FOUND
            )

        # Validate that the gym (mentor) owns this organization
        try:
            Organization.objects.get(
                id=membership_request.organization_id,
                mentor__user=request.user
            )
        except Organization.DoesNotExist:
            return Response(
                {"detail": "You do not have permission for this organization."},
                status=status.HTTP_403_FORBIDDEN
            )

        # Check if already responded (allow action on pending and contacted requests)
        if membership_request.status not in [MembershipRequest.PENDING, MembershipRequest.CONTACTED]:
            return Response(
                {"detail": f"This request has already been {membership_request.status}."},
                status=status.HTTP_400_BAD_REQUEST
            )

        serializer = GymMembershipRequestActionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        new_status = serializer.validated_data['status']
        selected_plan = serializer.validated_data.get('selected_plan')
        gym_remarks = serializer.validated_data.get('gym_remarks', '')

        # New custom fields from gym
        custom_amount = serializer.validated_data.get('amount')
        discount = serializer.validated_data.get('discount', 0) or 0
        custom_start_date = serializer.validated_data.get('start_date')
        custom_end_date = serializer.validated_data.get('end_date')
        transaction_number = serializer.validated_data.get('transaction_number', '')
        payment_mode = serializer.validated_data.get('payment_mode', 'cash')

        with db_transaction.atomic():
            membership_request.status = new_status
            membership_request.gym_remarks = gym_remarks
            membership_request.responded_at = timezone.now()

            if new_status == 'accepted' and selected_plan:
                # Use gym-provided amount or fallback to plan price
                final_amount = custom_amount if custom_amount is not None else (
                    selected_plan.offer_price or selected_plan.actual_price
                )

                # Use gym-provided dates
                start_date = custom_start_date
                end_date = custom_end_date

                # Store accept details on the request
                membership_request.selected_plan = selected_plan
                membership_request.accepted_amount = final_amount
                membership_request.discount_amount = discount
                membership_request.start_date = start_date
                membership_request.end_date = end_date
                membership_request.transaction_number = transaction_number
                membership_request.payment_mode = payment_mode

                # Create a CustomerMembership record (Active)
                customer_membership = CustomerMembership.objects.create(
                    customer=membership_request.customer,
                    membership=selected_plan,
                    status=CustomerMembership.ACTIVE,
                    start_date=start_date,
                    end_date=end_date,
                    amount=final_amount,
                    payment_status='completed',
                    is_active=True,
                    assign_free=False,
                )

                # Create a CustomerMembershipTransaction
                CustomerMembershipTransaction.objects.create(
                    user=membership_request.customer.user,
                    customer=membership_request.customer,
                    membership=selected_plan,
                    subscription=customer_membership,
                    amount=final_amount,
                    status=CustomerMembershipTransaction.SUCCESSFUL,
                    payment_method=payment_mode,
                    payment_date=timezone.now(),
                    remarks=f"Discount: {discount}" if discount else None,
                )

                # Update customer's organization reference
                customer = membership_request.customer
                customer.organization = membership_request.organization
                customer.is_active_member = True
                customer.save()

                # Send push notification to customer
                if customer.user:
                    send_push_notification(
                        user=customer.user,
                        title="Membership Approved! 🎉",
                        body=f"Your membership request at {membership_request.organization.name} has been accepted. Plan: {selected_plan.name}",
                        data={
                            "type": "membership_request_accepted",
                            "request_id": str(membership_request.id),
                            "organization_id": str(membership_request.organization.id),
                            "organization_name": membership_request.organization.name,
                        }
                    )

                logger.info(
                    f"Membership request #{membership_request.id} ACCEPTED. "
                    f"Customer assigned plan '{selected_plan.name}' "
                    f"at '{membership_request.organization.name}' "
                    f"(amount: {final_amount}, discount: {discount}, "
                    f"dates: {start_date} to {end_date}, "
                    f"payment: {payment_mode}, txn: {transaction_number})"
                )

            elif new_status == 'rejected':
                # Send push notification to customer about rejection
                customer = membership_request.customer
                if customer.user:
                    send_push_notification(
                        user=customer.user,
                        title="Membership Request Update",
                        body=f"Your membership request at {membership_request.organization.name} was not approved.",
                        data={
                            "type": "membership_request_rejected",
                            "request_id": str(membership_request.id),
                            "organization_id": str(membership_request.organization.id),
                        }
                    )

            elif new_status == 'contacted':
                # Gym wants to contact the customer — store contact info
                contact_info = serializer.validated_data.get('contact_info', {})
                membership_request.contact_info = contact_info

                # Send push notification to customer with contact details
                customer = membership_request.customer
                if customer.user:
                    send_push_notification(
                        user=customer.user,
                        title="Gym wants to connect with you! 📞",
                        body=f"{membership_request.organization.name} would like to discuss your membership enquiry. Check the app for their contact details.",
                        data={
                            "type": "membership_request_contacted",
                            "request_id": str(membership_request.id),
                            "organization_id": str(membership_request.organization.id),
                            "organization_name": membership_request.organization.name,
                            "contact_info": str(contact_info),
                        }
                    )

                logger.info(
                    f"Membership request #{membership_request.id} CONTACTED. "
                    f"Gym '{membership_request.organization.name}' shared contact info: {contact_info}"
                )

            membership_request.save()

        return Response({
            "status": "success",
            "message": f"Membership request has been {new_status}.",
            "data": GymMembershipRequestListSerializer(membership_request).data
        }, status=status.HTTP_200_OK)


# ============================================
# Trainer Join Request Views (Gym-side)
# ============================================

from apps.trainer.models import OrganizationTrainerLink
from apps.trainer.api.serializers import OrganizationTrainerLinkSerializer


class GymTrainerRequestListView(APIView):
    """Gym lists incoming trainer join requests."""
    permission_classes = [MentorOnlyPermission]

    def get(self, request):
        organization_id = request.query_params.get('organization_id')
        status_filter = request.query_params.get('status', OrganizationTrainerLink.PENDING)
        request_type = request.query_params.get('type')  # 'customer', 'trainer', or None (all)

        if not organization_id:
            return Response({'detail': 'organization_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            organization = Organization.objects.get(id=organization_id, mentor__user=request.user)
        except Organization.DoesNotExist:
            return Response({'detail': 'Organization not found.'}, status=status.HTTP_404_NOT_FOUND)

        results = []

        if not request_type or request_type == 'trainer':
            trainer_links = OrganizationTrainerLink.objects.filter(
                organization=organization,
                status=status_filter
            ).select_related('trainer__user')

            for link in trainer_links:
                trainer = link.trainer
                results.append({
                    'id': link.id,
                    'type': 'trainer',
                    'status': link.status,
                    'requested_at': link.requested_at,
                    'responded_at': link.responded_at,
                    'rejection_reason': link.rejection_reason,
                    'requester': {
                        'id': trainer.id,
                        'name': f"{trainer.first_name} {trainer.last_name}".strip(),
                        'mobile': trainer.mobile,
                        'profile_image': trainer.profile_image.url if trainer.profile_image else None,
                        'user_type': trainer.user_type,
                        'experience_years': trainer.experience_years,
                    }
                })

        if not request_type or request_type == 'customer':
            from apps.customers.models import MembershipRequest
            membership_requests = MembershipRequest.objects.filter(
                organization=organization,
                status=status_filter
            ).select_related('customer__user', 'membership_plan')

            for mr in membership_requests:
                customer = mr.customer
                user = customer.user
                results.append({
                    'id': mr.id,
                    'type': 'customer',
                    'status': mr.status,
                    'requested_at': mr.requested_at,
                    'responded_at': mr.responded_at,
                    'notes': mr.notes,
                    'membership_plan': {
                        'id': mr.membership_plan.id,
                        'name': mr.membership_plan.name,
                    } if mr.membership_plan else None,
                    'requester': {
                        'id': customer.id,
                        'name': f"{user.first_name} {user.last_name}".strip() if user else '',
                        'mobile': str(user.mobile_number) if user and user.mobile_number else None,
                        'profile_image': user.profile_picture.url if user and user.profile_picture else None,
                    }
                })

        # Sort all by requested_at descending
        results.sort(key=lambda x: x['requested_at'], reverse=True)

        paginator = CustomPagination()
        page = paginator.paginate_queryset(results, request)
        return paginator.get_paginated_response(page)


class GymTrainerRequestActionView(APIView):
    """Gym approves or rejects a trainer join request."""
    permission_classes = [MentorOnlyPermission]

    def patch(self, request, link_id):
        from apps.communication.notifications import send_push_notification

        try:
            link = OrganizationTrainerLink.objects.select_related(
                'trainer__user', 'organization'
            ).get(id=link_id)
        except OrganizationTrainerLink.DoesNotExist:
            return Response({'detail': 'Request not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            Organization.objects.get(id=link.organization_id, mentor__user=request.user)
        except Organization.DoesNotExist:
            return Response({'detail': 'Not authorized for this organization.'}, status=status.HTTP_403_FORBIDDEN)

        if link.status != OrganizationTrainerLink.PENDING:
            return Response({'detail': f'Request already {link.status}.'}, status=status.HTTP_400_BAD_REQUEST)

        action = request.data.get('action')
        if action not in ('approve', 'reject'):
            return Response({'detail': "action must be 'approve' or 'reject'."}, status=status.HTTP_400_BAD_REQUEST)

        link.status = OrganizationTrainerLink.APPROVED if action == 'approve' else OrganizationTrainerLink.REJECTED
        link.rejection_reason = request.data.get('rejection_reason') if action == 'reject' else None
        link.responded_at = timezone.now()
        link.save()

        # Notify the trainer
        trainer_user = link.trainer.user
        if trainer_user:
            if action == 'approve':
                send_push_notification(
                    user=trainer_user,
                    title="Join Request Approved! 🎉",
                    body=f"Your request to join {link.organization.name} has been approved.",
                    data={'type': 'trainer_join_approved', 'organization_id': str(link.organization_id)}
                )
            else:
                send_push_notification(
                    user=trainer_user,
                    title="Join Request Update",
                    body=f"Your request to join {link.organization.name} was not approved.",
                    data={'type': 'trainer_join_rejected', 'organization_id': str(link.organization_id)}
                )

        return Response({
            'status': 'success',
            'message': f'Trainer request has been {link.status}.',
            'data': OrganizationTrainerLinkSerializer(link).data
        })

class GymWorkoutPlanListCreateView(APIView):
    """
    Gym manages their workout plans.
    Trainers linked to this gym can see and assign these plans to customers.
    """
    permission_classes = [MentorOnlyPermission]

    def get(self, request):
        from apps.trainer.models import WorkoutPlan, WorkoutGroup
        from apps.trainer.api.serializers import WorkoutPlanSerializer

        organization_id = request.query_params.get('organization_id')
        group_id = request.query_params.get('group')
        search = request.query_params.get('search', '').strip()

        if not organization_id:
            return Response({'detail': 'organization_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            organization = Organization.objects.get(id=organization_id, mentor__user=request.user)
        except Organization.DoesNotExist:
            return Response({'detail': 'Organization not found.'}, status=status.HTTP_404_NOT_FOUND)

        qs = WorkoutPlan.objects.filter(organization=organization, status=True)
        if group_id:
            qs = qs.filter(group_id=group_id)
        if search:
            qs = qs.filter(plan_name__icontains=search)

        return Response(WorkoutPlanSerializer(qs, many=True).data)

    def post(self, request):
        from apps.trainer.models import WorkoutPlan
        from apps.trainer.api.serializers import WorkoutPlanSerializer

        organization_id = request.data.get('organization_id')
        if not organization_id:
            return Response({'detail': 'organization_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            organization = Organization.objects.get(id=organization_id, mentor__user=request.user)
        except Organization.DoesNotExist:
            return Response({'detail': 'Organization not found.'}, status=status.HTTP_404_NOT_FOUND)

        data = request.data.copy()
        data.pop('organization_id', None)
        serializer = WorkoutPlanSerializer(data=data)
        if serializer.is_valid():
            serializer.save(organization=organization)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class GymWorkoutPlanDetailView(APIView):
    permission_classes = [MentorOnlyPermission]

    def get(self, request, pk):
        from apps.trainer.models import WorkoutPlan
        from apps.trainer.api.serializers import WorkoutPlanDetailSerializer
        try:
            plan = WorkoutPlan.objects.get(pk=pk, organization__mentor__user=request.user)
        except WorkoutPlan.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        return Response(WorkoutPlanDetailSerializer(plan).data)

    def put(self, request, pk):
        from apps.trainer.models import WorkoutPlan
        from apps.trainer.api.serializers import WorkoutPlanSerializer
        try:
            plan = WorkoutPlan.objects.get(pk=pk, organization__mentor__user=request.user)
        except WorkoutPlan.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        serializer = WorkoutPlanSerializer(plan, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        from apps.trainer.models import WorkoutPlan
        try:
            plan = WorkoutPlan.objects.get(pk=pk, organization__mentor__user=request.user)
        except WorkoutPlan.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        plan.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class GymWorkoutGroupListCreateView(APIView):
    """
    Gym manages their workout groups (categories for plans).
    """
    permission_classes = [MentorOnlyPermission]

    def get(self, request):
        from apps.trainer.models import WorkoutGroup
        from apps.trainer.api.serializers import WorkoutGroupSerializer

        organization_id = request.query_params.get('organization_id')
        if not organization_id:
            return Response({'detail': 'organization_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            organization = Organization.objects.get(id=organization_id, mentor__user=request.user)
        except Organization.DoesNotExist:
            return Response({'detail': 'Organization not found.'}, status=status.HTTP_404_NOT_FOUND)

        group_type = request.query_params.get('type')
        qs = WorkoutGroup.objects.filter(organization=organization, status=True)
        if group_type:
            qs = qs.filter(type=group_type)
        return Response(WorkoutGroupSerializer(qs, many=True).data)

    def post(self, request):
        from apps.trainer.models import WorkoutGroup
        from apps.trainer.api.serializers import WorkoutGroupSerializer

        organization_id = request.data.get('organization_id')
        if not organization_id:
            return Response({'detail': 'organization_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            organization = Organization.objects.get(id=organization_id, mentor__user=request.user)
        except Organization.DoesNotExist:
            return Response({'detail': 'Organization not found.'}, status=status.HTTP_404_NOT_FOUND)

        data = request.data.copy()
        data.pop('organization_id', None)
        serializer = WorkoutGroupSerializer(data=data)
        if serializer.is_valid():
            serializer.save(organization=organization)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class GymWorkoutLibraryView(APIView):
    """
    Gym manages overrides for master exercises.
    GET  ?organization_id=<id>  - List all overrides set by this gym
    POST                        - Set/update an override for a master exercise
    """
    permission_classes = [MentorOnlyPermission]

    def get(self, request):
        from apps.trainer.models import GymWorkoutOverride, Workout
        from apps.trainer.api.serializers import WorkoutSerializer

        organization_id = request.query_params.get('organization_id')
        search = request.query_params.get('search', '').strip()
        muscle_group = request.query_params.get('muscle_group')
        workout_type = request.query_params.get('type')

        if not organization_id:
            return Response({'detail': 'organization_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            organization = Organization.objects.get(id=organization_id)
        except Organization.DoesNotExist:
            return Response({'detail': 'Organization not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Full master library
        from django.db.models import Q
        global_exercises_q = Q(created_by__isnull=True) | Q(created_by__is_staff=True) | Q(created_by__is_superuser=True) | Q(created_by__user_role__in=[1, 5, 10, 15])
        qs = Workout.objects.filter(global_exercises_q, status=True).select_related('primary_muscle_group', 'equipment')

        if search:
            qs = qs.filter(name__icontains=search)
        if muscle_group:
            qs = qs.filter(primary_muscle_group_id=muscle_group)
        if workout_type:
            qs = qs.filter(type=workout_type)

        # Build override lookup map for this org
        override_map = {
            o.workout_id: o
            for o in GymWorkoutOverride.objects.filter(organization=organization)
        }

        result = []
        for workout in qs:
            override = override_map.get(workout.id)
            if override and not override.is_visible:
                continue
            data = WorkoutSerializer(workout).data
            data['gym_video_url'] = override.video_url if override else None
            data['gym_instructions'] = override.instructions if override else None
            data['override_id'] = override.id if override else None
            result.append(data)

        return Response(result)

    def post(self, request):
        """
        Set or update a gym override for a master exercise.
        Body: { organization_id, workout_id, video_url, instructions, is_visible }
        """
        from apps.trainer.models import GymWorkoutOverride, Workout

        organization_id = request.data.get('organization_id')
        workout_id = request.data.get('workout_id')

        if not organization_id or not workout_id:
            return Response({'detail': 'organization_id and workout_id are required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            organization = Organization.objects.get(id=organization_id, mentor__user=request.user)
        except Organization.DoesNotExist:
            return Response({'detail': 'Organization not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            from django.db.models import Q
            global_exercises_q = Q(created_by__isnull=True) | Q(created_by__is_staff=True) | Q(created_by__is_superuser=True) | Q(created_by__user_role__in=[1, 5, 10, 15])
            workout = Workout.objects.filter(global_exercises_q).get(id=workout_id)
        except Workout.DoesNotExist:
            return Response({'detail': 'Master exercise not found.'}, status=status.HTTP_404_NOT_FOUND)

        override, created = GymWorkoutOverride.objects.update_or_create(
            workout=workout,
            organization=organization,
            defaults={
                'video_url': request.data.get('video_url'),
                'instructions': request.data.get('instructions'),
                'is_visible': request.data.get('is_visible', True),
            }
        )

        return Response({
            'override_id': override.id,
            'workout_id': workout.id,
            'workout_name': workout.name,
            'gym_video_url': override.video_url,
            'gym_instructions': override.instructions,
            'is_visible': override.is_visible,
        }, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)


class GymWorkoutLibraryDetailView(APIView):
    """
    Gym updates or removes a specific override.
    PUT  - Update video_url, instructions, is_visible
    DELETE - Remove override (exercise reverts to master)
    """
    permission_classes = [MentorOnlyPermission]

    def put(self, request, pk):
        from apps.trainer.models import GymWorkoutOverride

        try:
            override = GymWorkoutOverride.objects.get(pk=pk, organization__mentor__user=request.user)
        except GymWorkoutOverride.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        if 'video_url' in request.data:
            override.video_url = request.data['video_url']
        if 'instructions' in request.data:
            override.instructions = request.data['instructions']
        if 'is_visible' in request.data:
            override.is_visible = request.data['is_visible']
        override.save()

        return Response({
            'override_id': override.id,
            'workout_id': override.workout_id,
            'gym_video_url': override.video_url,
            'gym_instructions': override.instructions,
            'is_visible': override.is_visible,
        })

    def delete(self, request, pk):
        from apps.trainer.models import GymWorkoutOverride

        try:
            override = GymWorkoutOverride.objects.get(pk=pk, organization__mentor__user=request.user)
        except GymWorkoutOverride.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        override.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


from apps.fitnesscenter.api.serializers import DirectGymCreateSerializer, GymListSerializer


class DirectGymCreateAPIView(APIView):
    """Create a gym (Organization) directly without requiring user registration or mentor."""
    permission_classes = [AllowAny]

    def post(self, request):
        try:
            serializer = DirectGymCreateSerializer(
                data=request.data,
                context={'request': request}
            )
            serializer.is_valid(raise_exception=True)
            organization = serializer.save()
            return Response({
                "success": True,
                "message": "Gym created successfully",
                "data": {
                    "id": organization.id,
                    "name": organization.name,
                    "slug": organization.slug,
                    "email": organization.email,
                    "phone_number": organization.phone_number,
                }
            }, status=status.HTTP_201_CREATED)

        except ValidationError as ve:
            return Response({
                "success": False,
                "errors": ve.detail
            }, status=status.HTTP_400_BAD_REQUEST)

        except Exception as e:
            return Response({
                "success": False,
                "message": f"Failed to create gym: {str(e)}"
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class GymListAPIView(APIView):
    """List all gyms (Organizations) - public endpoint, no auth required."""
    permission_classes = [AllowAny]

    def get(self, request):
        search = request.query_params.get('search', '').strip()
        category_id = request.query_params.get('category_id')
        is_active = request.query_params.get('active')
        registration_status = request.query_params.get('registration_status')
        lat = request.query_params.get('lat')
        lon = request.query_params.get('lon')
        radius_km = request.query_params.get('radius_km')

        queryset = Organization.objects.all().prefetch_related('category').select_related('location', 'mentor__user')

        if search:
            queryset = queryset.filter(
                Q(name__icontains=search) |
                Q(email__icontains=search) |
                Q(phone_number__icontains=search)
            )

        if category_id:
            queryset = queryset.filter(category__id=category_id)

        if is_active is not None:
            queryset = queryset.filter(active=(is_active.lower() == 'true'))

        if registration_status:
            queryset = queryset.filter(registration_status=registration_status)

        if lat and lon:
            try:
                lat = float(lat)
                lon = float(lon)
                if radius_km:
                    radius_km = float(radius_km)
                else:
                    radius_km = 100000.0
            except ValueError:
                return Response({"error": "Invalid latitude, longitude or radius"}, status=status.HTTP_400_BAD_REQUEST)

            import math
            def calculate_distance(lat1, lon1, lat2, lon2):
                R = 6371  # Earth radius in KM
                dlat = math.radians(lat2 - lat1)
                dlon = math.radians(lon2 - lon1)
                a = (
                    math.sin(dlat / 2) ** 2
                    + math.cos(math.radians(lat1))
                    * math.cos(math.radians(lat2))
                    * math.sin(dlon / 2) ** 2
                )
                c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
                return R * c

            gyms = []
            for org in queryset:
                location = getattr(org, "location", None)
                if not location:
                    continue
                if location.latitude is None or location.longitude is None:
                    continue
                try:
                    lat2 = float(location.latitude)
                    lon2 = float(location.longitude)
                except (ValueError, TypeError):
                    continue

                dist = calculate_distance(lat, lon, lat2, lon2)
                if dist <= radius_km:
                    data = GymListSerializer(org, context={'request': request}).data
                    data["distance_km"] = round(dist, 2)
                    gyms.append(data)

            gyms.sort(key=lambda x: x.get("distance_km", 999999))

            paginator = CustomPagination()
            page = paginator.paginate_queryset(gyms, request)
            if page is not None:
                return paginator.get_paginated_response(page)
            return Response(gyms)

        queryset = queryset.order_by('-created_at')

        paginator = CustomPagination()
        page = paginator.paginate_queryset(queryset, request)
        serializer = GymListSerializer(page, many=True, context={'request': request})

        return paginator.get_paginated_response(serializer.data)


class GymDetailAPIView(APIView):
    """Get details for a specific gym - public endpoint."""
    permission_classes = [AllowAny]

    def get(self, request, gym_id):
        try:
            organization = Organization.objects.prefetch_related(
                'category', 'working_days', 'social_media', 'amenities__amenity', 'photos', 'packages'
            ).select_related('location', 'mentor__user').get(id=gym_id)
        except Organization.DoesNotExist:
            return Response({"detail": "Gym not found."}, status=status.HTTP_404_NOT_FOUND)

        from apps.fitnesscenter.api.serializers import OrganizationDetailSerializer
        serializer = OrganizationDetailSerializer(organization, context={'request': request})
        return Response({
            "success": True,
            "data": serializer.data
        })


class GymTrainerSearchView(APIView):
    """Gym searches the trainer pool to find and invite trainers."""
    permission_classes = [MentorOnlyPermission]

    def get(self, request):
        organization_id = request.query_params.get('organization_id')
        search = request.query_params.get('search', '').strip()
        user_type = request.query_params.get('user_type')  # 'trainer' or 'dietitian'

        if not organization_id:
            return Response({'detail': 'organization_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            organization = Organization.objects.get(id=organization_id, mentor__user=request.user)
        except Organization.DoesNotExist:
            return Response({'detail': 'Organization not found.'}, status=status.HTTP_404_NOT_FOUND)

        from apps.trainer.models import Trainer, OrganizationTrainerLink

        # Exclude trainers already linked (any status) to this org
        already_linked_ids = OrganizationTrainerLink.objects.filter(
            organization=organization
        ).values_list('trainer_id', flat=True)

        qs = Trainer.objects.exclude(id__in=already_linked_ids).select_related('user')

        if user_type:
            qs = qs.filter(user_type=user_type)

        if search:
            qs = qs.filter(
                Q(first_name__icontains=search) |
                Q(last_name__icontains=search) |
                Q(mobile__icontains=search) |
                Q(email__icontains=search)
            )

        qs = qs.order_by('-created_at')

        paginator = CustomPagination()
        page = paginator.paginate_queryset(qs, request)

        result = []
        for trainer in page:
            result.append({
                'id': trainer.id,
                'name': f"{trainer.first_name} {trainer.last_name}".strip(),
                'mobile': trainer.mobile,
                'email': trainer.email,
                'user_type': trainer.user_type,
                'experience_years': trainer.experience_years,
                'bio': trainer.bio,
                'profile_image': trainer.profile_image.url if trainer.profile_image else None,
            })

        return paginator.get_paginated_response(result)


class GymInviteTrainerView(APIView):
    """Gym sends an invite to a trainer to join their organization."""
    permission_classes = [MentorOnlyPermission]

    def post(self, request):
        from apps.trainer.models import Trainer, OrganizationTrainerLink
        from apps.communication.notifications import send_push_notification

        organization_id = request.data.get('organization_id')
        trainer_id = request.data.get('trainer_id')

        if not organization_id or not trainer_id:
            return Response(
                {'detail': 'organization_id and trainer_id are required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            organization = Organization.objects.get(id=organization_id, mentor__user=request.user)
        except Organization.DoesNotExist:
            return Response({'detail': 'Organization not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            trainer = Trainer.objects.get(id=trainer_id)
        except Trainer.DoesNotExist:
            return Response({'detail': 'Trainer not found.'}, status=status.HTTP_404_NOT_FOUND)

        link, created = OrganizationTrainerLink.objects.get_or_create(
            trainer=trainer,
            organization=organization,
            defaults={'status': OrganizationTrainerLink.PENDING, 'invited_by_org': True}
        )

        if not created:
            if link.status == OrganizationTrainerLink.APPROVED:
                return Response({'detail': 'Trainer is already linked to this organization.'}, status=status.HTTP_400_BAD_REQUEST)
            if link.status == OrganizationTrainerLink.PENDING:
                return Response({'detail': 'An invite or request is already pending.'}, status=status.HTTP_400_BAD_REQUEST)
            # Re-invite after rejection
            link.status = OrganizationTrainerLink.PENDING
            link.invited_by_org = True
            link.responded_at = None
            link.rejection_reason = None
            link.save()

        # Notify trainer
        if trainer.user:
            send_push_notification(
                user=trainer.user,
                title=f"Gym Invite from {organization.name} 🏋️",
                body=f"{organization.name} has invited you to join their team.",
                data={
                    'type': 'gym_trainer_invite',
                    'organization_id': str(organization.id),
                    'organization_name': organization.name,
                    'link_id': str(link.id),
                }
            )

        return Response({
            'status': 'success',
            'message': f'Invite sent to {trainer.first_name} {trainer.last_name}.',
            'link_id': link.id,
        }, status=status.HTTP_201_CREATED)


class GymDirectAddTrainerView(APIView):
    """
    Gym directly adds a trainer with full details to their organization.
    - If mobile exists → links existing trainer as approved (no invite needed).
    - If mobile not found → creates User + Trainer + links as approved.
    Only gym's MentorOnly token required. No trainer auth needed.
    """
    permission_classes = [MentorOnlyPermission]

    def post(self, request):
        import json
        from apps.trainer.models import (
            Trainer, OrganizationTrainerLink, TrainerSpecialization,
            TrainerCertification, Location, TrainerSocialLink
        )
        from phonenumber_field.phonenumber import PhoneNumber
        from apps.user.models import User
        from rest_framework.parsers import MultiPartParser, FormParser

        organization_id = request.data.get('organization_id')
        mobile = request.data.get('mobile')

        if not organization_id or not mobile:
            return Response(
                {'detail': 'organization_id and mobile are required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            organization = Organization.objects.get(id=organization_id, mentor__user=request.user)
        except Organization.DoesNotExist:
            return Response({'detail': 'Organization not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            phone = PhoneNumber.from_string(mobile)
        except Exception:
            return Response({'detail': 'Invalid mobile number.'}, status=status.HTTP_400_BAD_REQUEST)

        # ── Extract all fields ────────────────────────────────────────────
        first_name = request.data.get('first_name', '')
        last_name = request.data.get('last_name', '')
        email = request.data.get('email') or None
        user_type = request.data.get('user_type', 'trainer')
        gender = request.data.get('gender', 'other')
        date_of_birth = request.data.get('date_of_birth', '2000-01-01')
        experience_years = int(request.data.get('experience_years', 0) or 0)
        bio = request.data.get('bio', '')
        is_freelancer = str(request.data.get('is_freelancer', 'false')).lower() == 'true'
        join_gym = str(request.data.get('join_gym', 'true')).lower() == 'true'
        event_collaborator = str(request.data.get('event_collaborator', 'false')).lower() == 'true'
        expected_pay_min = request.data.get('expected_pay_min') or None
        expected_pay_max = request.data.get('expected_pay_max') or None
        profile_image = request.FILES.get('profile_image')

        existing_user = User.objects.filter(mobile_number=phone).first()
        is_new = False

        if existing_user:
            # Check for email conflicts
            if email:
                if User.objects.exclude(id=existing_user.id).filter(email=email).exists():
                    return Response(
                        {'detail': 'A user with this email address already exists.'},
                        status=status.HTTP_400_BAD_REQUEST
                    )
                if Trainer.objects.exclude(user=existing_user).filter(email=email).exists():
                    return Response(
                        {'detail': 'A trainer with this email address already exists.'},
                        status=status.HTTP_400_BAD_REQUEST
                    )
                
                # Update email on existing user
                existing_user.email = email
                existing_user.save(update_fields=['email'])

            trainer = Trainer.objects.filter(user=existing_user).first()
            if not trainer:
                trainer = Trainer.objects.create(
                    user=existing_user,
                    mobile=mobile,
                    first_name=existing_user.first_name or first_name,
                    last_name=existing_user.last_name or last_name,
                    email=existing_user.email or email,
                    user_type=user_type,
                    gender=existing_user.gender or gender,
                    date_of_birth=existing_user.date_of_birth or date_of_birth,
                    experience_years=experience_years,
                    bio=bio,
                    is_freelancer=is_freelancer,
                    join_gym=join_gym,
                    event_collaborator=event_collaborator,
                    expected_pay_min=expected_pay_min,
                    expected_pay_max=expected_pay_max,
                    profile_image=profile_image,
                    profile_step=2,
                )
                is_new = True
            else:
                if email and trainer.email != email:
                    trainer.email = email
                    trainer.save(update_fields=['email'])
            
            # Always ensure the user_role is updated to match the trainer type
            expected_role = User.MENTOR_TRAINER if user_type == 'trainer' else User.MENTOR_DIETITIAN
            if existing_user.user_role != expected_role:
                existing_user.user_role = expected_role
                existing_user.save(update_fields=['user_role'])
        else:
            # Check for email conflicts before creating new user
            if email:
                if User.objects.filter(email=email).exists():
                    return Response(
                        {'detail': 'A user with this email address already exists.'},
                        status=status.HTTP_400_BAD_REQUEST
                    )
                if Trainer.objects.filter(email=email).exists():
                    return Response(
                        {'detail': 'A trainer with this email address already exists.'},
                        status=status.HTTP_400_BAD_REQUEST
                    )

            user_role = User.MENTOR_TRAINER if user_type == 'trainer' else User.MENTOR_DIETITIAN
            new_user = User.objects.create(
                mobile_number=phone,
                username=str(phone),
                first_name=first_name,
                last_name=last_name,
                email=email,
                gender=gender,
                date_of_birth=date_of_birth,
                user_role=user_role,
            )
            trainer, trainer_created = Trainer.objects.get_or_create(
                user=new_user,
                defaults={
                    'mobile': mobile,
                    'first_name': first_name,
                    'last_name': last_name,
                    'email': email,
                    'user_type': user_type,
                    'gender': gender,
                    'date_of_birth': date_of_birth,
                    'experience_years': experience_years,
                    'bio': bio,
                    'is_freelancer': is_freelancer,
                    'join_gym': join_gym,
                    'event_collaborator': event_collaborator,
                    'expected_pay_min': expected_pay_min,
                    'expected_pay_max': expected_pay_max,
                    'profile_image': profile_image,
                    'profile_step': 2,
                }
            )
            if not trainer_created:
                trainer.mobile = mobile
                trainer.first_name = first_name
                trainer.last_name = last_name
                trainer.email = email
                trainer.user_type = user_type
                trainer.gender = gender
                trainer.date_of_birth = date_of_birth
                trainer.experience_years = experience_years
                trainer.bio = bio
                trainer.is_freelancer = is_freelancer
                trainer.join_gym = join_gym
                trainer.event_collaborator = event_collaborator
                trainer.expected_pay_min = expected_pay_min
                trainer.expected_pay_max = expected_pay_max
                if profile_image:
                    trainer.profile_image = profile_image
                trainer.profile_step = 2
                trainer.save()
            is_new = True

        # ── Specializations ───────────────────────────────────────────────
        specialization_ids = request.data.get('specializations')
        if specialization_ids:
            if isinstance(specialization_ids, str):
                try:
                    specialization_ids = json.loads(specialization_ids)
                except (ValueError, TypeError):
                    specialization_ids = []
            TrainerSpecialization.objects.filter(trainer=trainer).delete()
            for spec_id in specialization_ids:
                TrainerSpecialization.objects.get_or_create(
                    trainer=trainer, specialization_id=spec_id
                )

        # ── Location ──────────────────────────────────────────────────────
        if request.data.get('city'):
            Location.objects.update_or_create(
                trainer=trainer,
                defaults={
                    'street': request.data.get('street', ''),
                    'area': request.data.get('area', ''),
                    'city': request.data.get('city', ''),
                    'state': request.data.get('state', ''),
                    'country': request.data.get('country', 'India'),
                    'pincode': request.data.get('pincode', ''),
                    'latitude': request.data.get('latitude') or None,
                    'longitude': request.data.get('longitude') or None,
                }
            )

        # ── Social Links ──────────────────────────────────────────────────
        social_fields = ['instagram', 'youtube', 'facebook', 'website', 'whatsapp']
        if any(request.data.get(k) for k in social_fields):
            TrainerSocialLink.objects.update_or_create(
                trainer=trainer,
                defaults={k: request.data.get(k, '') for k in social_fields}
            )

        # ── Certification ─────────────────────────────────────────────────
        cert_name = request.data.get('certificate_name')
        cert_file = request.FILES.get('certificate_file')
        if cert_name and cert_file:
            TrainerCertification.objects.create(
                trainer=trainer,
                certificate_name=cert_name,
                certificate_file=cert_file,
            )

        # ── Link to org — approved immediately ────────────────────────────
        link, created = OrganizationTrainerLink.objects.get_or_create(
            trainer=trainer,
            organization=organization,
            defaults={'status': OrganizationTrainerLink.APPROVED, 'invited_by_org': True}
        )
        if not created:
            if link.status == OrganizationTrainerLink.APPROVED:
                return Response(
                    {'detail': 'Trainer is already linked to this organization.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            link.status = OrganizationTrainerLink.APPROVED
            link.invited_by_org = True
            link.save()

        return Response({
            'status': 'success',
            'message': f'{trainer.first_name} {trainer.last_name} added to {organization.name}.',
            'trainer_id': trainer.id,
            'link_id': link.id,
            'is_new_account': is_new,
        }, status=status.HTTP_201_CREATED)


# ──────────────────────────────────────────────────────────────────────
#  Create Restricted Staff User API  (for Postman / admin use)
# ──────────────────────────────────────────────────────────────────────
class CreateOrgStaffAPIView(APIView):
    """
    POST /api/v1/fitnesscenter/organization/create-staff/
    
    Creates a restricted staff user who can only edit specific
    Organization fields in the Django admin panel.
    
    Required: superuser or admin-role JWT token.
    
    Body (JSON):
    {
        "username": "editor1",
        "password": "SecurePass@123",
        "organization_id": 3,        // required
        "email": "editor@gym.com",   // optional
        "first_name": "John",        // optional
        "last_name": "Doe"           // optional
    }
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        # Only superusers or admin roles can create staff users
        user = request.user
        if not (user.is_superuser or user.user_role in User.ADMIN_ROLES):
            return Response(
                {"detail": "Only admins can create staff users."},
                status=status.HTTP_403_FORBIDDEN
            )

        username = request.data.get('username')
        password = request.data.get('password')
        organization_id = request.data.get('organization_id')
        email = request.data.get('email', '')
        first_name = request.data.get('first_name', '')
        last_name = request.data.get('last_name', '')

        # Validation
        if not username or not password:
            return Response(
                {"detail": "username and password are required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        if not organization_id:
            return Response(
                {"detail": "organization_id is required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Check organization exists
        try:
            org = Organization.objects.get(id=organization_id)
        except Organization.DoesNotExist:
            return Response(
                {"detail": f"Organization with id {organization_id} not found."},
                status=status.HTTP_404_NOT_FOUND
            )

        # Create or get user
        from django.contrib.auth.models import Permission, Group
        from django.contrib.contenttypes.models import ContentType
        from apps.fitnesscenter.models import Location, WorkingDay, OrganizationPhoto, SocialMedia, OrganizationTimeSlot, organizationAmenity

        staff_user, created = User.objects.get_or_create(
            username=username,
            defaults={
                'email': email,
                'first_name': first_name,
                'last_name': last_name,
                'is_staff': True,
                'is_superuser': False,
                'user_role': User.MENTOR,
            }
        )

        if created:
            staff_user.set_password(password)
            staff_user.save()
        else:
            # Update existing user to be staff and update empty/new fields
            staff_user.is_staff = True
            staff_user.is_superuser = False
            update_fields = ['is_staff', 'is_superuser']
            
            if email and staff_user.email != email:
                if User.objects.exclude(id=staff_user.id).filter(email=email).exists():
                    return Response(
                        {"detail": "A user with this email address already exists."},
                        status=status.HTTP_400_BAD_REQUEST
                    )
                staff_user.email = email
                update_fields.append('email')
                
            if first_name and not staff_user.first_name:
                staff_user.first_name = first_name
                update_fields.append('first_name')
                
            if last_name and not staff_user.last_name:
                staff_user.last_name = last_name
                update_fields.append('last_name')
                
            staff_user.save(update_fields=update_fields)

        # Create/get the Organization Editor group with permissions
        group, _ = Group.objects.get_or_create(name='Organization Editor')
        editable_models = [Organization, Location, WorkingDay, OrganizationPhoto, SocialMedia, OrganizationTimeSlot, organizationAmenity]
        perms = []
        for model in editable_models:
            ct = ContentType.objects.get_for_model(model)
            for prefix in ['view', 'change', 'add', 'delete']:
                codename = f'{prefix}_{model._meta.model_name}'
                perm = Permission.objects.filter(content_type=ct, codename=codename).first()
                if perm:
                    perms.append(perm)
        group.permissions.set(perms)
        staff_user.groups.add(group)

        # Link user to organization via MentorProfile
        mentor_profile, _ = MentorProfile.objects.get_or_create(user=staff_user)
        org_updated = False
        if org.mentor != mentor_profile:
            org.mentor = mentor_profile
            org.save(update_fields=['mentor'])
            org_updated = True

        return Response({
            "status": "success",
            "message": f"Staff user '{username}' {'created' if created else 'updated'} successfully.",
            "user": {
                "id": staff_user.id,
                "username": staff_user.username,
                "email": staff_user.email,
                "is_staff": staff_user.is_staff,
                "is_superuser": staff_user.is_superuser,
            },
            "organization": {
                "id": org.id,
                "name": org.name,
                "assigned": org_updated or not created,
            },
            "permissions": [
                "Can view/edit: Organization name, email, phone, description, logo",
                "Can view/edit: Location (building, street, city, state, pin)",
                "Can view/edit: Working days & hours",
                "Can view/edit: Photos",
                "Can view/edit: Social media links",
            ],
            "admin_login_url": "/admin/",
        }, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)


class ListOrgStaffAPIView(APIView):
    """
    GET /api/v1/fitnesscenter/organization/staff-list/
    
    Lists all restricted staff users and their assigned organizations.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        if not (user.is_superuser or user.user_role in User.ADMIN_ROLES):
            return Response(
                {"detail": "Only admins can view staff users."},
                status=status.HTTP_403_FORBIDDEN
            )

        from django.contrib.auth.models import Group
        try:
            group = Group.objects.get(name='Organization Editor')
        except Group.DoesNotExist:
            return Response({"status": "success", "staff_users": []})

        staff_users = group.user_set.all()
        result = []
        for su in staff_users:
            mentor = getattr(su, 'mentor_profile', None)
            orgs = []
            if mentor:
                orgs = list(
                    Organization.objects.filter(mentor=mentor).values('id', 'name', 'email', 'phone_number')
                )
            result.append({
                "id": su.id,
                "username": su.username,
                "email": su.email,
                "first_name": su.first_name,
                "last_name": su.last_name,
                "is_active": su.is_active,
                "organizations": orgs,
            })

        return Response({"status": "success", "staff_users": result})


# ============================================================
# Promotional Banner API Views
# ============================================================

from apps.fitnesscenter.models import PromotionalBanner
from apps.fitnesscenter.api.serializers import PromotionalBannerSerializer

class PromotionalBannerListCreateAPIView(APIView):
    """
    List and create dynamic promotional banners for fitness centers/trainers.
    GET: Returns all active banners, optionally filtered by gym (organization_id) or trainer.
    POST: Mentors/Admins can create promotional banners.
    """
    permission_classes = [IsAuthenticated]

    def get_permissions(self):
        if self.request.method == 'GET':
            return [AllowAny()]
        return [IsAuthenticated()]

    def get(self, request):
        banner_type = request.query_params.get('banner_type') # promotional, workout_log, global
        organization_id = request.query_params.get('organization_id')
        trainer_id = request.query_params.get('trainer_id')

        qs = PromotionalBanner.objects.filter(is_active=True)

        if banner_type:
            qs = qs.filter(banner_type=banner_type)
        if organization_id:
            qs = qs.filter(organization_id=organization_id)
        if trainer_id:
            qs = qs.filter(trainer_id=trainer_id)

        # Include global banners when filtering for a specific gym
        if organization_id:
            qs = qs | PromotionalBanner.objects.filter(is_active=True, banner_type='global')

        serializer = PromotionalBannerSerializer(qs.distinct().order_by('-created_at'), many=True)
        return Response(serializer.data)

    def post(self, request):
        # Only mentors or superusers can create gym/trainer banners
        user = request.user
        if not (user.is_superuser or user.user_role in User.ADMIN_ROLES or getattr(user, 'mentor_profile', None)):
            return Response(
                {"detail": "Only mentors or administrators can create banners."},
                status=status.HTTP_403_FORBIDDEN
            )

        serializer = PromotionalBannerSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        # Auto-assign organization if mentor is creating
        mentor_profile = getattr(user, 'mentor_profile', None)
        org = None
        if mentor_profile:
            org = Organization.objects.filter(mentor=mentor_profile).first()

        banner = serializer.save(organization=org)
        return Response(PromotionalBannerSerializer(banner).data, status=status.HTTP_201_CREATED)


class PromotionalBannerDetailAPIView(APIView):
    """
    Retrieve, update or delete a dynamic promotional banner.
    """
    permission_classes = [IsAuthenticated]

    def get_permissions(self):
        if self.request.method == 'GET':
            return [AllowAny()]
        return [IsAuthenticated()]

    def get(self, request, pk):
        banner = get_object_or_404(PromotionalBanner, id=pk, is_active=True)
        return Response(PromotionalBannerSerializer(banner).data)

    def put(self, request, pk):
        banner = get_object_or_404(PromotionalBanner, id=pk)
        
        # Authorization check
        user = request.user
        if not user.is_superuser:
            mentor_profile = getattr(user, 'mentor_profile', None)
            if not mentor_profile or banner.organization.mentor != mentor_profile:
                return Response(
                    {"detail": "You do not have permission to edit this banner."},
                    status=status.HTTP_403_FORBIDDEN
                )

        serializer = PromotionalBannerSerializer(banner, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(PromotionalBannerSerializer(banner).data)

    def delete(self, request, pk):
        banner = get_object_or_404(PromotionalBanner, id=pk)

        # Authorization check
        user = request.user
        if not user.is_superuser:
            mentor_profile = getattr(user, 'mentor_profile', None)
            if not mentor_profile or banner.organization.mentor != mentor_profile:
                return Response(
                    {"detail": "You do not have permission to delete this banner."},
                    status=status.HTTP_403_FORBIDDEN
                )

        banner.delete()
        return Response({"detail": "Banner deleted successfully."}, status=status.HTTP_200_OK)


# ============================================================
# Advanced Reports & Analytics View
# ============================================================

from django.db.models import Count, Sum, Q
from datetime import date
from apps.customers.models import Injury, MedicalCondition, CustomerMembership, CustomerMembershipTransaction

class AdvancedReportsAPIView(APIView):
    """
    Advanced reports and analytics for gym owners and mentors.
    Provides detailed insight into financial performance, demographics, medical conditions, goals, and trainer performance.
    Query params: organization_id (required), days OR start_date+end_date (optional)
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        organization_id = request.query_params.get('organization_id')

        if not organization_id:
            return Response({'detail': 'organization_id query parameter is required.'}, status=400)

        try:
            org = Organization.objects.get(id=organization_id)
        except Organization.DoesNotExist:
            return Response({'detail': 'Organization not found.'}, status=404)

        # Authorization: must be mentor/staff of this org or superuser
        if not user.is_superuser:
            if user.user_role not in [User.MENTOR, User.MENTOR_STAFF, User.MENTOR_ACCOUNTS, User.MENTOR_TRAINER]:
                return Response({'detail': 'Not authorized.'}, status=403)

        # 2. Get date range inputs
        start_date_str = request.query_params.get('start_date')
        end_date_str = request.query_params.get('end_date')
        days_str = request.query_params.get('days')

        today = timezone.localdate()
        start_dt = None
        end_dt = None

        if days_str:
            try:
                days = int(days_str)
                start_dt = today - timedelta(days=days)
                end_dt = today
            except ValueError:
                pass
        elif start_date_str and end_date_str:
            try:
                start_dt = date.fromisoformat(start_date_str)
                end_dt = date.fromisoformat(end_date_str)
            except ValueError:
                pass

        # 3. Base customer queries
        customers = Customer.objects.filter(organization=org)
        if start_dt and end_dt:
            customers = customers.filter(created__date__range=[start_dt, end_dt])

        total_customers = customers.count()

        # Helper to format values as count and percentage
        def to_pct_dict(count_val, total):
            pct = (count_val / total * 100) if total > 0 else 0.0
            return {
                "count": count_val,
                "percentage": f"{pct:.1f}%"
            }

        # 4. Financial & Revenue Metrics
        # Sum successful transactions for the organization's customers
        txns_qs = CustomerMembershipTransaction.objects.filter(
            customer__organization=org,
            status='Successful'
        )
        if start_dt and end_dt:
            txns_qs = txns_qs.filter(created_at__date__range=[start_dt, end_dt])
        total_revenue = txns_qs.aggregate(total=Sum('amount'))['total'] or 0.0

        # Fallback to completed memberships
        if total_revenue == 0.0:
            mems_qs = CustomerMembership.objects.filter(
                customer__organization=org,
                payment_status='completed'
            )
            if start_dt and end_dt:
                mems_qs = mems_qs.filter(created_at__date__range=[start_dt, end_dt])
            total_revenue = mems_qs.aggregate(total=Sum('amount'))['total'] or 0.0

        total_revenue = float(total_revenue)

        # Plan Revenue Breakdown
        plans = MembershipPlan.objects.filter(organization=org)
        plan_breakdown = []
        for p in plans:
            # Transaction revenue
            p_rev_qs = CustomerMembershipTransaction.objects.filter(
                membership=p,
                status='Successful'
            )
            if start_dt and end_dt:
                p_rev_qs = p_rev_qs.filter(created_at__date__range=[start_dt, end_dt])
            p_revenue = p_rev_qs.aggregate(total=Sum('amount'))['total'] or 0.0

            # Fallback membership revenue
            if p_revenue == 0.0:
                p_mems_qs = CustomerMembership.objects.filter(
                    membership=p,
                    payment_status='completed'
                )
                if start_dt and end_dt:
                    p_mems_qs = p_mems_qs.filter(created_at__date__range=[start_dt, end_dt])
                p_revenue = p_mems_qs.aggregate(total=Sum('amount'))['total'] or 0.0

            p_revenue = float(p_revenue)

            # Subscribers count on this plan
            subscribers_count = CustomerMembership.objects.filter(
                membership=p,
                status='Active'
            ).count()

            percentage = (p_revenue / total_revenue * 100) if total_revenue > 0 else 0.0

            plan_breakdown.append({
                "plan_id": p.id,
                "plan_name": p.name or p.package_type,
                "package_type": p.package_type,
                "revenue": p_revenue,
                "percentage": f"{percentage:.1f}%",
                "subscribers_count": subscribers_count
            })

        # New Signups count (registered in date range or last 30 days)
        new_signups_qs = Customer.objects.filter(organization=org)
        if start_dt and end_dt:
            new_signups_qs = new_signups_qs.filter(created__date__range=[start_dt, end_dt])
        else:
            thirty_days_ago = today - timedelta(days=30)
            new_signups_qs = new_signups_qs.filter(created__date__range=[thirty_days_ago, today])
        new_signups = new_signups_qs.count()

        # Churn Rate
        total_mems = CustomerMembership.objects.filter(customer__organization=org).count()
        churn_mems = CustomerMembership.objects.filter(
            customer__organization=org,
            status__in=['Expired', 'Cancelled']
        ).count()
        churn_pct = (churn_mems / total_mems * 100) if total_mems > 0 else 0.0
        churn_rate = f"{churn_pct:.1f}%"

        financial_metrics = {
            "total_revenue": total_revenue,
            "new_signups": new_signups,
            "churn_rate": churn_rate,
            "plan_revenue_breakdown": plan_breakdown
        }

        # 5. Gender Demographics
        gender_data = customers.values('user__gender').annotate(count=Count('id'))
        gender_dist = {
            item['user__gender'] or 'unspecified': to_pct_dict(item['count'], total_customers)
            for item in gender_data
        }

        # 6. Age Demographics
        under_18 = 0
        age_18_25 = 0
        age_26_35 = 0
        age_36_45 = 0
        age_46_55 = 0
        age_56_plus = 0
        unknown_age = 0

        for c in customers.select_related('user'):
            if c.user and c.user.date_of_birth:
                dob = c.user.date_of_birth
                age = today.year - dob.year - ((today.month, today.day) < (dob.month, dob.day))
                if age < 18:
                    under_18 += 1
                elif age <= 25:
                    age_18_25 += 1
                elif age <= 35:
                    age_26_35 += 1
                elif age <= 45:
                    age_36_45 += 1
                elif age <= 55:
                    age_46_55 += 1
                else:
                    age_56_plus += 1
            else:
                unknown_age += 1

        age_dist = {
            'under_18': to_pct_dict(under_18, total_customers),
            '18-25': to_pct_dict(age_18_25, total_customers),
            '26-35': to_pct_dict(age_26_35, total_customers),
            '36-45': to_pct_dict(age_36_45, total_customers),
            '46-55': to_pct_dict(age_46_55, total_customers),
            '56+': to_pct_dict(age_56_plus, total_customers),
            'unspecified': to_pct_dict(unknown_age, total_customers)
        }

        # 7. Goal Insights (weight_goal, fitness_level, stress_level)
        fitness_levels = {
            item['fitness_level'] or 'unspecified': to_pct_dict(item['count'], total_customers)
            for item in customers.values('fitness_level').annotate(count=Count('id'))
        }
        weight_goals = {
            item['weight_goal'] or 'unspecified': to_pct_dict(item['count'], total_customers)
            for item in customers.values('weight_goal').annotate(count=Count('id'))
        }
        stress_levels = {
            item['stress_level'] or 'unspecified': to_pct_dict(item['count'], total_customers)
            for item in customers.values('stress_level').annotate(count=Count('id'))
        }

        # 8. Injuries & Medical Conditions
        injuries_qs = Injury.objects.filter(customers__in=customers).annotate(count=Count('customers')).values('name', 'count')
        injuries_data = {
            item['name']: to_pct_dict(item['count'], total_customers)
            for item in injuries_qs
        }

        med_qs = MedicalCondition.objects.filter(customers__in=customers).annotate(count=Count('customers')).values('name', 'count')
        medical_data = {
            item['name']: to_pct_dict(item['count'], total_customers)
            for item in med_qs
        }

        # 9. Attendance Patterns / Peak Hours
        from apps.trainer.models import WorkoutSession
        sessions = WorkoutSession.objects.filter(customer__organization=org, status='completed')
        if start_dt and end_dt:
            sessions = sessions.filter(session_date__range=[start_dt, end_dt])

        hour_distribution = {i: 0 for i in range(24)}
        for s in sessions:
            if s.start_time:
                local_time = timezone.localtime(s.start_time)
                hour = local_time.hour
                hour_distribution[hour] = hour_distribution.get(hour, 0) + 1

        peak_hours = {f"{k:02d}:00": v for k, v in hour_distribution.items() if v > 0}

        # 10. Trainer Performance Reports
        from apps.trainer.models import Trainer, CustomerWorkoutPlan
        trainers = Trainer.objects.filter(organization_links__organization=org, organization_links__status='approved')
        
        trainer_reports = []
        for t in trainers:
            # Total clients trained by this trainer (all-time / current links)
            trainer_customers = Customer.objects.filter(
                Q(trainer=t) | Q(id__in=CustomerWorkoutPlan.objects.filter(trainer=t).values('customer_id')),
                organization=org
            ).distinct()
            t_total = trainer_customers.count()

            # Trainer client gender distribution
            t_gender_data = trainer_customers.values('user__gender').annotate(count=Count('id'))
            t_gender_dist = {
                item['user__gender'] or 'unspecified': to_pct_dict(item['count'], t_total)
                for item in t_gender_data
            }

            # Trainer client age distribution
            t_under_18 = 0
            t_age_18_25 = 0
            t_age_26_35 = 0
            t_age_36_45 = 0
            t_age_46_55 = 0
            t_age_56_plus = 0
            t_unknown_age = 0

            for tc in trainer_customers.select_related('user'):
                if tc.user and tc.user.date_of_birth:
                    tc_dob = tc.user.date_of_birth
                    tc_age = today.year - tc_dob.year - ((today.month, today.day) < (tc_dob.month, tc_dob.day))
                    if tc_age < 18:
                        t_under_18 += 1
                    elif tc_age <= 25:
                        t_age_18_25 += 1
                    elif tc_age <= 35:
                        t_age_26_35 += 1
                    elif tc_age <= 45:
                        t_age_36_45 += 1
                    elif tc_age <= 55:
                        t_age_46_55 += 1
                    else:
                        t_age_56_plus += 1
                else:
                    t_unknown_age += 1

            t_age_dist = {
                'under_18': to_pct_dict(t_under_18, t_total),
                '18-25': to_pct_dict(t_age_18_25, t_total),
                '26-35': to_pct_dict(t_age_26_35, t_total),
                '36-45': to_pct_dict(t_age_36_45, t_total),
                '46-55': to_pct_dict(t_age_46_55, t_total),
                '56+': to_pct_dict(t_age_56_plus, t_total),
                'unspecified': to_pct_dict(t_unknown_age, t_total)
            }

            # Calculate total assigned workout plans by this trainer ("how much workouts given")
            workout_plans_given_count = CustomerWorkoutPlan.objects.filter(
                trainer=t,
                customer__organization=org
            ).count()

            from apps.trainer.workout_models import WorkoutSession
            completed_sessions_qs = WorkoutSession.objects.filter(
                customer_workout_plan__trainer=t,
                customer__organization=org,
                status='completed'
            )
            if start_dt and end_dt:
                completed_sessions_qs = completed_sessions_qs.filter(completed_at__date__range=[start_dt, end_dt])
            workouts_completed_count = completed_sessions_qs.count()

            total_sessions_qs = WorkoutSession.objects.filter(
                customer_workout_plan__trainer=t,
                customer__organization=org
            )
            if start_dt and end_dt:
                total_sessions_qs = total_sessions_qs.filter(session_date__range=[start_dt, end_dt])
            total_sessions_count = total_sessions_qs.count()

            completion_rate = 0.0
            active_progress = "No Data"
            if total_sessions_count > 0:
                completion_rate = (workouts_completed_count / total_sessions_count) * 100.0
                if completion_rate >= 75.0:
                    active_progress = "Good"
                elif completion_rate >= 50.0:
                    active_progress = "Average"
                else:
                    active_progress = "Needs Attention"

            attendance_rate = f"{completion_rate:.1f}%"
            completion_rate_str = f"{completion_rate:.1f}%"

            trainer_reports.append({
                'trainer_id': t.id,
                'name': f"{t.first_name} {t.last_name}",
                'user_type': t.user_type,
                'experience_years': t.experience_years,
                'clients_trained_count': t_total,
                'workout_plans_given_count': workout_plans_given_count,
                'workouts_completed_count': workouts_completed_count,
                'attendance_rate': attendance_rate,
                'completion_rate': completion_rate_str,
                'active_progress': active_progress,
                'gender_distribution': t_gender_dist,
                'age_distribution': t_age_dist,
            })

        # Assemble final payload
        report_payload = {
            'organization': {
                'id': org.id,
                'name': org.name,
            },
            'filters': {
                'start_date': start_dt.isoformat() if start_dt else None,
                'end_date': end_dt.isoformat() if end_dt else None,
                'days': days_str,
            },
            'financial_metrics': financial_metrics,
            'client_demographics': {
                'total_clients': total_customers,
                'gender_distribution': gender_dist,
                'age_distribution': age_dist,
            },
            'goals_insights': {
                'fitness_levels': fitness_levels,
                'weight_goals': weight_goals,
                'stress_levels': stress_levels,
            },
            'health_profiles': {
                'injuries': injuries_data,
                'medical_conditions': medical_data,
            },
            'attendance_patterns': {
                'peak_workout_hours': peak_hours,
                'total_completed_sessions': sessions.count(),
            },
            'trainers_performance': trainer_reports
        }

        return Response(report_payload)


# ============================================================
# Affiliate Marketing Views
# ============================================================

from apps.user.models import SalesExecutive, Coupon, SubscriptionTransaction
from apps.fitnesscenter.api.serializers import (
    SalesExecutiveSerializer, CouponSerializer,
    SubscriptionTransactionSerializer, MarkCommissionPaidSerializer
)


class SalesExecutiveListCreateAPIView(APIView):
    """
    GET  - List all sales executives for the mentor's organization
    POST - Create a new sales executive
    """
    permission_classes = [IsAuthenticated]

    def _get_org(self, request):
        user = request.user
        if user.user_role not in [User.MENTOR, User.MENTOR_STAFF, User.MENTOR_ACCOUNTS]:
            return None, Response({'detail': 'Not authorized.'}, status=403)
        org_id = request.query_params.get('organization_id')
        if not org_id:
            mentor_profile = getattr(user, 'mentor_profile', None)
            if mentor_profile:
                org = Organization.objects.filter(mentor=mentor_profile).first()
            else:
                org = None
        else:
            try:
                org = Organization.objects.get(id=org_id)
            except Organization.DoesNotExist:
                return None, Response({'detail': 'Organization not found.'}, status=404)
        if not org:
            return None, Response({'detail': 'No organization found.'}, status=404)
        return org, None

    def get(self, request):
        org, error = self._get_org(request)
        if error:
            return error
        executives = SalesExecutive.objects.filter(organization=org).order_by('-created_at')
        serializer = SalesExecutiveSerializer(executives, many=True)
        return Response(serializer.data)

    def post(self, request):
        org, error = self._get_org(request)
        if error:
            return error
        serializer = SalesExecutiveSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(organization=org)
        return Response(serializer.data, status=201)


class SalesExecutiveDetailAPIView(APIView):
    """
    GET    - Retrieve a sales executive
    PUT    - Update a sales executive
    DELETE - Deactivate a sales executive
    """
    permission_classes = [IsAuthenticated]

    def _get_executive(self, pk):
        try:
            return SalesExecutive.objects.get(id=pk)
        except SalesExecutive.DoesNotExist:
            return None

    def get(self, request, pk):
        executive = self._get_executive(pk)
        if not executive:
            return Response({'detail': 'Sales executive not found.'}, status=404)
        serializer = SalesExecutiveSerializer(executive)
        return Response(serializer.data)

    def put(self, request, pk):
        executive = self._get_executive(pk)
        if not executive:
            return Response({'detail': 'Sales executive not found.'}, status=404)
        serializer = SalesExecutiveSerializer(executive, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)

    def delete(self, request, pk):
        executive = self._get_executive(pk)
        if not executive:
            return Response({'detail': 'Sales executive not found.'}, status=404)
        executive.is_active = False
        executive.save()
        return Response({'detail': 'Sales executive deactivated.'}, status=200)


class CouponListCreateAPIView(APIView):
    """
    GET  - List all coupons for the mentor's organization
    POST - Create a new coupon
    """
    permission_classes = [IsAuthenticated]

    def _get_org(self, request):
        user = request.user
        if user.user_role not in [User.MENTOR, User.MENTOR_STAFF, User.MENTOR_ACCOUNTS]:
            return None, Response({'detail': 'Not authorized.'}, status=403)
        org_id = request.query_params.get('organization_id')
        if not org_id:
            mentor_profile = getattr(user, 'mentor_profile', None)
            if mentor_profile:
                org = Organization.objects.filter(mentor=mentor_profile).first()
            else:
                org = None
        else:
            try:
                org = Organization.objects.get(id=org_id)
            except Organization.DoesNotExist:
                return None, Response({'detail': 'Organization not found.'}, status=404)
        if not org:
            return None, Response({'detail': 'No organization found.'}, status=404)
        return org, None

    def get(self, request):
        org, error = self._get_org(request)
        if error:
            return error
        coupons = Coupon.objects.filter(organization=org).order_by('-created_at')

        # Optional filters
        is_active = request.query_params.get('is_active')
        if is_active is not None:
            coupons = coupons.filter(is_active=is_active.lower() == 'true')

        executive_id = request.query_params.get('sales_executive_id')
        if executive_id:
            coupons = coupons.filter(sales_executive_id=executive_id)

        serializer = CouponSerializer(coupons, many=True)
        return Response(serializer.data)

    def post(self, request):
        org, error = self._get_org(request)
        if error:
            return error
        serializer = CouponSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(organization=org)
        return Response(serializer.data, status=201)


class CouponDetailAPIView(APIView):
    """
    GET    - Retrieve a coupon with usage stats
    PUT    - Update a coupon
    DELETE - Deactivate a coupon
    """
    permission_classes = [IsAuthenticated]

    def _get_coupon(self, pk):
        try:
            return Coupon.objects.get(id=pk)
        except Coupon.DoesNotExist:
            return None

    def get(self, request, pk):
        coupon = self._get_coupon(pk)
        if not coupon:
            return Response({'detail': 'Coupon not found.'}, status=404)
        serializer = CouponSerializer(coupon)
        return Response(serializer.data)

    def put(self, request, pk):
        coupon = self._get_coupon(pk)
        if not coupon:
            return Response({'detail': 'Coupon not found.'}, status=404)
        serializer = CouponSerializer(coupon, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)

    def delete(self, request, pk):
        coupon = self._get_coupon(pk)
        if not coupon:
            return Response({'detail': 'Coupon not found.'}, status=404)
        coupon.is_active = False
        coupon.save()
        return Response({'detail': 'Coupon deactivated.'}, status=200)


class AffiliateDashboardAPIView(APIView):
    """
    GET - Affiliate marketing dashboard with summary metrics.
    Query params: organization_id (required)
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        if user.user_role not in [User.MENTOR, User.MENTOR_STAFF, User.MENTOR_ACCOUNTS]:
            return Response({'detail': 'Not authorized.'}, status=403)

        org_id = request.query_params.get('organization_id')
        if not org_id:
            return Response({'detail': 'organization_id is required.'}, status=400)

        try:
            org = Organization.objects.get(id=org_id)
        except Organization.DoesNotExist:
            return Response({'detail': 'Organization not found.'}, status=404)

        executives = SalesExecutive.objects.filter(organization=org, is_active=True)
        coupons = Coupon.objects.filter(organization=org)
        active_coupons = coupons.filter(is_active=True)

        # Commission aggregation
        txns = SubscriptionTransaction.objects.filter(
            sales_executive__organization=org
        )
        total_commission = txns.aggregate(
            total=Sum('executive_commission')
        )['total'] or 0
        paid_commission = txns.filter(commission_paid=True).aggregate(
            total=Sum('executive_commission')
        )['total'] or 0
        pending_commission = float(total_commission) - float(paid_commission)

        # Revenue from coupon-based transactions
        revenue_via_coupons = txns.filter(
            coupon__isnull=False
        ).aggregate(total=Sum('final_amount'))['total'] or 0

        # Total coupon usage
        total_usage = coupons.aggregate(total=Sum('used_count'))['total'] or 0

        # Top 5 executives by commission
        top_executives = executives.order_by('-id')[:5]

        # Top 5 coupons by usage
        top_coupons = active_coupons.order_by('-used_count')[:5]

        dashboard_data = {
            'total_executives': executives.count(),
            'total_active_coupons': active_coupons.count(),
            'total_coupon_usage': total_usage,
            'total_revenue_via_coupons': float(revenue_via_coupons),
            'total_commission_earned': float(total_commission),
            'total_commission_pending': pending_commission,
            'total_commission_paid': float(paid_commission),
            'top_executives': SalesExecutiveSerializer(top_executives, many=True).data,
            'top_coupons': CouponSerializer(top_coupons, many=True).data,
        }

        return Response(dashboard_data)


class AffiliateTransactionListAPIView(APIView):
    """
    GET - List all affiliate transactions for the organization.
    Query params: organization_id (required), sales_executive_id (optional), commission_paid (optional)
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        if user.user_role not in [User.MENTOR, User.MENTOR_STAFF, User.MENTOR_ACCOUNTS]:
            return Response({'detail': 'Not authorized.'}, status=403)

        org_id = request.query_params.get('organization_id')
        if not org_id:
            return Response({'detail': 'organization_id is required.'}, status=400)

        try:
            org = Organization.objects.get(id=org_id)
        except Organization.DoesNotExist:
            return Response({'detail': 'Organization not found.'}, status=404)

        txns = SubscriptionTransaction.objects.filter(
            sales_executive__organization=org
        ).select_related('plan', 'user', 'coupon', 'sales_executive').order_by('-created_at')

        # Optional filters
        exec_id = request.query_params.get('sales_executive_id')
        if exec_id:
            txns = txns.filter(sales_executive_id=exec_id)

        paid = request.query_params.get('commission_paid')
        if paid is not None:
            txns = txns.filter(commission_paid=paid.lower() == 'true')

        serializer = SubscriptionTransactionSerializer(txns, many=True)
        return Response(serializer.data)


class MarkCommissionPaidAPIView(APIView):
    """
    POST - Mark specific transactions' commissions as paid.
    Body: { "transaction_ids": [1, 2, 3] }
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user = request.user
        if user.user_role not in [User.MENTOR, User.MENTOR_STAFF, User.MENTOR_ACCOUNTS]:
            return Response({'detail': 'Not authorized.'}, status=403)

        serializer = MarkCommissionPaidSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        transaction_ids = serializer.validated_data['transaction_ids']

        updated = SubscriptionTransaction.objects.filter(
            id__in=transaction_ids,
            commission_paid=False
        ).update(
            commission_paid=True,
            commission_paid_date=timezone.now()
        )

        return Response({
            'detail': f'{updated} transaction(s) marked as paid.',
            'updated_count': updated
        })


class GymEquipmentListView(APIView):
    """List equipment available at a specific gym organization."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from apps.fitnesscenter.models import GymEquipment

        organization_id = request.query_params.get('organization_id')
        if not organization_id:
            return Response({'error': 'organization_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            org = Organization.objects.get(id=organization_id)
        except Organization.DoesNotExist:
            return Response({'error': 'Organization not found.'}, status=status.HTTP_404_NOT_FOUND)

        gym_equipments = GymEquipment.objects.filter(
            organization_id=organization_id
        ).select_related('equipment')

        equipment_list = [
            {
                'id': ge.equipment.id,
                'name': ge.equipment.name,
                'is_functional': ge.is_functional,
            }
            for ge in gym_equipments
        ]

        return Response({
            'organization_id': org.id,
            'organization_name': org.name,
            'available_equipment': equipment_list,
        })


class GymEquipmentUpdateView(APIView):
    """Update/set the equipment inventory for a gym organization."""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        from apps.fitnesscenter.models import GymEquipment
        from apps.trainer.workout_models import Equipment

        user = request.user
        if user.user_role not in [User.MENTOR, User.MENTOR_STAFF]:
            return Response({'detail': 'Not authorized.'}, status=status.HTTP_403_FORBIDDEN)

        organization_id = request.data.get('organization_id')
        equipment_ids = request.data.get('equipment_ids', [])

        if not organization_id:
            return Response({'error': 'organization_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            org = Organization.objects.get(id=organization_id)
        except Organization.DoesNotExist:
            return Response({'error': 'Organization not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Validate that all equipment_ids exist
        valid_equipment = Equipment.objects.filter(id__in=equipment_ids).values_list('id', flat=True)
        invalid_ids = set(equipment_ids) - set(valid_equipment)
        if invalid_ids:
            return Response(
                {'error': f'Invalid equipment IDs: {list(invalid_ids)}'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Delete old entries and bulk-create new ones
        GymEquipment.objects.filter(organization=org).delete()
        new_entries = [
            GymEquipment(organization=org, equipment_id=eq_id)
            for eq_id in equipment_ids
        ]
        GymEquipment.objects.bulk_create(new_entries)

        return Response({
            'status': 'success',
            'message': 'Gym equipment inventory updated successfully.',
            'total_count': len(new_entries),
        })


class OwnerDashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from apps.fitnesscenter.models import Organization
        from apps.trainer.models import OrganizationTrainerLink
        from apps.customers.models import Customer, CustomerMembership
        from apps.customers.community_models import CommunityPost
        from apps.trainer.workout_models import WorkoutSession, CustomerWorkoutPlan
        from django.db.models import Sum
        from django.utils import timezone
        import datetime

        user = request.user
        organization_id = request.query_params.get('organization_id')

        # Fallback to the mentor's organization if not specified
        if not organization_id:
            mentor_profile = getattr(user, 'mentor_profile', None)
            if mentor_profile:
                org = Organization.objects.filter(mentor=mentor_profile).first()
                if not org:
                    # Also check if mentor belongs to an organization via ForeignKey
                    org = mentor_profile.organization
            else:
                org = None
        else:
            org = Organization.objects.filter(id=organization_id).first()

        if not org:
            return Response({'error': 'Organization not found.'}, status=404)

        # Get total customers registered in this organization's memberships
        memberships = CustomerMembership.objects.filter(membership__organization=org)
        customer_ids = memberships.values_list('customer_id', flat=True).distinct()
        total_customers = len(customer_ids)

        # Total active trainers
        total_trainers = OrganizationTrainerLink.objects.filter(
            organization=org, status=OrganizationTrainerLink.APPROVED
        ).count()

        # Total revenue
        total_revenue = memberships.aggregate(total=Sum('amount'))['total'] or 0.0

        # Community activity
        community_posts_count = CommunityPost.objects.count()

        # Completed sessions of these customers
        completed_sessions = WorkoutSession.objects.filter(customer_id__in=customer_ids, status='completed').count()

        # Expiring memberships in 30 days
        expiring_count = memberships.filter(end_date__lte=timezone.now() + datetime.timedelta(days=30)).count()
        churn_rate = 0.0
        if total_customers > 0:
            churn_rate = round((expiring_count / total_customers) * 100, 1)

        # New signups last 30 days
        new_signups_last_30_days = memberships.filter(start_date__gte=timezone.now() - datetime.timedelta(days=30)).count()

        # Member retention status
        member_retention_status = "Healthy" if churn_rate < 15.0 else "Critical"

        # Trainers performance leaderboard
        trainer_links = OrganizationTrainerLink.objects.filter(organization=org, status=OrganizationTrainerLink.APPROVED)
        trainers_performance = []
        for link in trainer_links:
            t = link.trainer
            assigned_plans = CustomerWorkoutPlan.objects.filter(trainer=t)
            t_customer_ids = assigned_plans.values_list('customer_id', flat=True).distinct()
            t_clients_count = len(t_customer_ids)

            t_sessions = WorkoutSession.objects.filter(customer_id__in=t_customer_ids)
            t_total_sessions = t_sessions.count()
            t_completed_sessions = t_sessions.filter(status='completed').count()

            t_completion_rate = "0.0%"
            if t_total_sessions > 0:
                t_completion_rate = f"{round((t_completed_sessions / t_total_sessions) * 100, 1)}%"

            # Resolve trainer name
            trainer_name = "Unknown"
            if t.user:
                trainer_name = f"{t.user.first_name} {t.user.last_name}".strip()
                if not trainer_name:
                    trainer_name = t.user.email
            else:
                trainer_name = t.email or "Trainer"

            trainers_performance.append({
                'name': trainer_name,
                'clients_trained_count': t_clients_count,
                'workouts_completed_count': t_completed_sessions,
                'completion_rate': t_completion_rate
            })

        return Response({
            'total_registered_customers': total_customers,
            'total_trainers': total_trainers,
            'total_membership_revenue': float(total_revenue),
            'community_posts_count': community_posts_count,
            'completed_sessions': completed_sessions,
            'churn_rate': f"{churn_rate}%",
            'new_signups_last_30_days': new_signups_last_30_days,
            'member_retention_status': member_retention_status,
            'trainers_performance': trainers_performance,
            'organization_name': org.name,
            'organization_id': org.id
        })

