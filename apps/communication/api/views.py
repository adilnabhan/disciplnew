from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from apps.communication.api.serializers import DeviceTokenSerializer
from apps.communication.models import DeviceToken


class DeviceTokenRegisterView(APIView):
    """Register or update an FCM device token for the authenticated user."""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = DeviceTokenSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        token = serializer.validated_data['token']
        platform = serializer.validated_data['platform']

        # Upsert: update if token exists, create otherwise
        device_token, created = DeviceToken.objects.update_or_create(
            token=token,
            defaults={
                'user': request.user,
                'platform': platform,
                'is_active': True,
            }
        )

        return Response(
            {
                "message": "Device token registered successfully.",
                "token": device_token.token,
                "platform": device_token.platform,
                "created": created,
            },
            status=status.HTTP_201_CREATED if created else status.HTTP_200_OK
        )


class DeviceTokenDeleteView(APIView):
    """Delete/deactivate a device token (e.g., on logout)."""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        token = request.data.get('token')
        if not token:
            return Response(
                {"detail": "Token is required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        deleted_count, _ = DeviceToken.objects.filter(
            user=request.user, token=token
        ).delete()

        if deleted_count == 0:
            return Response(
                {"detail": "Token not found."},
                status=status.HTTP_404_NOT_FOUND
            )

        return Response(
            {"message": "Device token removed successfully."},
            status=status.HTTP_200_OK
        )


# ============================================================
# WhatsApp Automation & Credit System Views
# ============================================================

from apps.utils.permission import MentorOnlyPermission
from apps.communication.models import (
    MessageCreditWallet, MessageCreditTransaction,
    WhatsAppTemplate, AutomationRule,
    MessageQueue, MessageLog,
)
from apps.communication.api.serializers import (
    CreditWalletSerializer, CreditTransactionSerializer, CreditPurchaseSerializer,
    WhatsAppTemplateSerializer, WhatsAppTemplateCreateSerializer,
    AutomationRuleSerializer, AutomationRuleCreateSerializer,
    CampaignSendSerializer, MessageQueueSerializer, MessageLogSerializer,
)
from apps.fitnesscenter.models import Organization
from django.utils import timezone


def _get_organization(request):
    """Helper: get organization from request for mentor users."""
    org_id = request.query_params.get('organization_id') or request.data.get('organization_id')
    if not org_id:
        mentor_profile = getattr(request.user, 'mentor_profile', None)
        if mentor_profile:
            org = Organization.objects.filter(mentor=mentor_profile).first()
            return org
        return None
    try:
        return Organization.objects.get(id=org_id, mentor__user=request.user)
    except Organization.DoesNotExist:
        return None


# ----- Credit Views -----

class CreditBalanceView(APIView):
    """Get credit wallet balance for the gym."""
    permission_classes = [MentorOnlyPermission]

    def get(self, request):
        org = _get_organization(request)
        if not org:
            return Response({'detail': 'Organization not found.'}, status=404)
        wallet, _ = MessageCreditWallet.objects.get_or_create(organization=org)
        return Response(CreditWalletSerializer(wallet).data)


class CreditPurchaseView(APIView):
    """Purchase message credits."""
    permission_classes = [MentorOnlyPermission]

    def post(self, request):
        org = _get_organization(request)
        if not org:
            return Response({'detail': 'Organization not found.'}, status=404)

        serializer = CreditPurchaseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        wallet, _ = MessageCreditWallet.objects.get_or_create(organization=org)
        wallet.add_credits(data['credits'])

        # Record transaction
        MessageCreditTransaction.objects.create(
            organization=org,
            type='purchase',
            credits=data['credits'],
            amount=data.get('amount'),
            payment_id=data.get('payment_id', ''),
            reference_type='purchase',
            notes=data.get('notes', ''),
        )

        return Response({
            'message': f"{data['credits']} credits added successfully.",
            'wallet': CreditWalletSerializer(wallet).data,
        }, status=status.HTTP_201_CREATED)


class CreditTransactionListView(APIView):
    """Get credit transaction history."""
    permission_classes = [MentorOnlyPermission]

    def get(self, request):
        org = _get_organization(request)
        if not org:
            return Response({'detail': 'Organization not found.'}, status=404)
        txns = MessageCreditTransaction.objects.filter(organization=org)[:50]
        return Response(CreditTransactionSerializer(txns, many=True).data)


# ----- Template Views -----

class WhatsAppTemplateListCreateView(APIView):
    """List and create WhatsApp templates."""
    permission_classes = [MentorOnlyPermission]

    def get(self, request):
        org = _get_organization(request)
        if not org:
            return Response({'detail': 'Organization not found.'}, status=404)
        templates = WhatsAppTemplate.objects.filter(organization=org)
        return Response(WhatsAppTemplateSerializer(templates, many=True).data)

    def post(self, request):
        org = _get_organization(request)
        if not org:
            return Response({'detail': 'Organization not found.'}, status=404)
        serializer = WhatsAppTemplateCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        template = serializer.save(organization=org)
        return Response(
            WhatsAppTemplateSerializer(template).data,
            status=status.HTTP_201_CREATED
        )


class WhatsAppTemplateDetailView(APIView):
    """Update or delete a WhatsApp template."""
    permission_classes = [MentorOnlyPermission]

    def get(self, request, pk):
        org = _get_organization(request)
        if not org:
            return Response({'detail': 'Organization not found.'}, status=404)
        try:
            template = WhatsAppTemplate.objects.get(id=pk, organization=org)
        except WhatsAppTemplate.DoesNotExist:
            return Response({'detail': 'Template not found.'}, status=404)
        return Response(WhatsAppTemplateSerializer(template).data)

    def put(self, request, pk):
        org = _get_organization(request)
        if not org:
            return Response({'detail': 'Organization not found.'}, status=404)
        try:
            template = WhatsAppTemplate.objects.get(id=pk, organization=org)
        except WhatsAppTemplate.DoesNotExist:
            return Response({'detail': 'Template not found.'}, status=404)
        serializer = WhatsAppTemplateCreateSerializer(template, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        template = serializer.save()
        return Response(WhatsAppTemplateSerializer(template).data)

    def delete(self, request, pk):
        org = _get_organization(request)
        if not org:
            return Response({'detail': 'Organization not found.'}, status=404)
        try:
            template = WhatsAppTemplate.objects.get(id=pk, organization=org)
        except WhatsAppTemplate.DoesNotExist:
            return Response({'detail': 'Template not found.'}, status=404)
        template.delete()
        return Response({'message': 'Template deleted.'}, status=status.HTTP_200_OK)


# ----- Automation Rule Views -----

class AutomationRuleListCreateView(APIView):
    """List and create automation rules."""
    permission_classes = [MentorOnlyPermission]

    def get(self, request):
        org = _get_organization(request)
        if not org:
            return Response({'detail': 'Organization not found.'}, status=404)
        rules = AutomationRule.objects.filter(organization=org)
        return Response(AutomationRuleSerializer(rules, many=True).data)

    def post(self, request):
        org = _get_organization(request)
        if not org:
            return Response({'detail': 'Organization not found.'}, status=404)
        serializer = AutomationRuleCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        # Verify template belongs to this org
        template = serializer.validated_data['template']
        if template.organization_id != org.id:
            return Response({'detail': 'Template does not belong to your organization.'}, status=400)
        rule = serializer.save(organization=org)
        return Response(
            AutomationRuleSerializer(rule).data,
            status=status.HTTP_201_CREATED
        )


class AutomationRuleDetailView(APIView):
    """Update or delete an automation rule."""
    permission_classes = [MentorOnlyPermission]

    def put(self, request, pk):
        org = _get_organization(request)
        if not org:
            return Response({'detail': 'Organization not found.'}, status=404)
        try:
            rule = AutomationRule.objects.get(id=pk, organization=org)
        except AutomationRule.DoesNotExist:
            return Response({'detail': 'Rule not found.'}, status=404)
        serializer = AutomationRuleCreateSerializer(rule, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        rule = serializer.save()
        return Response(AutomationRuleSerializer(rule).data)

    def delete(self, request, pk):
        org = _get_organization(request)
        if not org:
            return Response({'detail': 'Organization not found.'}, status=404)
        try:
            rule = AutomationRule.objects.get(id=pk, organization=org)
        except AutomationRule.DoesNotExist:
            return Response({'detail': 'Rule not found.'}, status=404)
        rule.delete()
        return Response({'message': 'Rule deleted.'}, status=status.HTTP_200_OK)


class AutomationRuleToggleView(APIView):
    """Enable/disable an automation rule."""
    permission_classes = [MentorOnlyPermission]

    def patch(self, request, pk):
        org = _get_organization(request)
        if not org:
            return Response({'detail': 'Organization not found.'}, status=404)
        try:
            rule = AutomationRule.objects.get(id=pk, organization=org)
        except AutomationRule.DoesNotExist:
            return Response({'detail': 'Rule not found.'}, status=404)
        rule.enabled = not rule.enabled
        rule.save(update_fields=['enabled', 'updated_at'])
        return Response({
            'message': f"Rule {'enabled' if rule.enabled else 'disabled'}.",
            'enabled': rule.enabled,
        })


# ----- Campaign Views -----

class CampaignSendView(APIView):
    """Send a campaign message to members."""
    permission_classes = [MentorOnlyPermission]

    def post(self, request):
        org = _get_organization(request)
        if not org:
            return Response({'detail': 'Organization not found.'}, status=404)

        serializer = CampaignSendSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        # Get template
        try:
            template = WhatsAppTemplate.objects.get(
                id=data['template_id'], organization=org, status='active'
            )
        except WhatsAppTemplate.DoesNotExist:
            return Response({'detail': 'Template not found or inactive.'}, status=404)

        # Check credit balance
        wallet, _ = MessageCreditWallet.objects.get_or_create(organization=org)

        # Get target members
        from apps.customers.models import CustomerOrganizationMembership
        memberships = CustomerOrganizationMembership.objects.filter(
            organization=org
        ).select_related('customer__user')

        filter_status = data.get('filter_status', 'active')
        if filter_status == 'active':
            memberships = memberships.filter(status='active')
        elif filter_status == 'expired':
            memberships = memberships.filter(status='expired')

        member_ids = data.get('member_ids')
        if member_ids:
            memberships = memberships.filter(customer_id__in=member_ids)

        if not memberships.exists():
            return Response({'detail': 'No members found matching criteria.'}, status=400)

        member_count = memberships.count()
        if not wallet.has_credits(member_count):
            return Response({
                'detail': f'Insufficient credits. Need {member_count}, have {wallet.available_credits}.'
            }, status=400)

        # Queue messages
        scheduled = data.get('scheduled_at') or timezone.now()
        queued = []
        for membership in memberships:
            customer = membership.customer
            user = customer.user
            phone = str(user.mobile_number) if user.mobile_number else ''
            if not phone:
                continue
            context = {
                'member_name': user.full_name or user.first_name,
                'gym_name': org.name,
            }
            msg = MessageQueue.objects.create(
                organization=org,
                member=customer,
                phone=phone,
                template=template,
                rendered_message=template.render(context),
                payload=context,
                scheduled_at=scheduled,
                source='campaign',
            )
            queued.append(msg.id)

        return Response({
            'message': f'{len(queued)} messages queued for delivery.',
            'queued_count': len(queued),
            'scheduled_at': scheduled.isoformat(),
        }, status=status.HTTP_201_CREATED)


# ----- Message History & Analytics -----

class MessageQueueListView(APIView):
    """View message queue / history."""
    permission_classes = [MentorOnlyPermission]

    def get(self, request):
        org = _get_organization(request)
        if not org:
            return Response({'detail': 'Organization not found.'}, status=404)
        status_filter = request.query_params.get('status')
        qs = MessageQueue.objects.filter(organization=org)
        if status_filter:
            qs = qs.filter(status=status_filter)
        qs = qs[:100]
        return Response(MessageQueueSerializer(qs, many=True).data)


class MessageAnalyticsView(APIView):
    """Get messaging analytics for the gym."""
    permission_classes = [MentorOnlyPermission]

    def get(self, request):
        org = _get_organization(request)
        if not org:
            return Response({'detail': 'Organization not found.'}, status=404)

        from django.db.models import Count, Q
        queue_qs = MessageQueue.objects.filter(organization=org)
        total_sent = queue_qs.filter(status='sent').count()
        total_failed = queue_qs.filter(status='failed').count()

        log_qs = MessageLog.objects.filter(queue_entry__organization=org)
        total_delivered = log_qs.filter(status='delivered').count() + log_qs.filter(status='read').count()
        total_read = log_qs.filter(status='read').count()

        total_all = total_sent + total_failed
        delivery_rate = round((total_delivered / total_all * 100), 1) if total_all > 0 else 0.0
        read_rate = round((total_read / total_delivered * 100), 1) if total_delivered > 0 else 0.0

        wallet, _ = MessageCreditWallet.objects.get_or_create(organization=org)

        return Response({
            'total_sent': total_sent,
            'total_delivered': total_delivered,
            'total_read': total_read,
            'total_failed': total_failed,
            'delivery_rate': delivery_rate,
            'read_rate': read_rate,
            'credits_used': wallet.used_credits,
            'credits_available': wallet.available_credits,
        })

