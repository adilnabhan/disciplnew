from rest_framework import serializers
from apps.communication.models import (
    DeviceToken,
    MessageCreditWallet, MessageCreditTransaction,
    WhatsAppTemplate, AutomationRule,
    MessageQueue, MessageLog,
)


# ============================================================
# Device Token Serializer (existing)
# ============================================================

class DeviceTokenSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceToken
        fields = ['token', 'platform']


# ============================================================
# Credit Serializers
# ============================================================

class CreditWalletSerializer(serializers.ModelSerializer):
    total_purchased = serializers.IntegerField(read_only=True)

    class Meta:
        model = MessageCreditWallet
        fields = ['id', 'available_credits', 'used_credits', 'total_purchased', 'updated_at']


class CreditTransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = MessageCreditTransaction
        fields = [
            'id', 'type', 'credits', 'amount',
            'reference_type', 'reference_id', 'payment_id',
            'notes', 'created_at'
        ]


class CreditPurchaseSerializer(serializers.Serializer):
    credits = serializers.IntegerField(min_value=1)
    amount = serializers.DecimalField(max_digits=10, decimal_places=2, required=False)
    payment_id = serializers.CharField(required=False, default='')
    notes = serializers.CharField(required=False, default='')


# ============================================================
# Template Serializers
# ============================================================

class WhatsAppTemplateSerializer(serializers.ModelSerializer):
    class Meta:
        model = WhatsAppTemplate
        fields = [
            'id', 'name', 'event_type', 'meta_template_id',
            'content', 'variables', 'status',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at']


class WhatsAppTemplateCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = WhatsAppTemplate
        fields = ['name', 'event_type', 'meta_template_id', 'content', 'variables']
        extra_kwargs = {
            'meta_template_id': {'required': False},
            'variables': {'required': False},
        }


# ============================================================
# Automation Rule Serializers
# ============================================================

class AutomationRuleSerializer(serializers.ModelSerializer):
    template_name = serializers.CharField(source='template.name', read_only=True)

    class Meta:
        model = AutomationRule
        fields = [
            'id', 'event_type', 'template', 'template_name',
            'trigger_days_before', 'send_time', 'enabled',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at']


class AutomationRuleCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = AutomationRule
        fields = ['event_type', 'template', 'trigger_days_before', 'send_time', 'enabled']


# ============================================================
# Campaign Serializers
# ============================================================

class CampaignSendSerializer(serializers.Serializer):
    template_id = serializers.IntegerField()
    member_ids = serializers.ListField(
        child=serializers.IntegerField(),
        required=False,
        help_text="Specific member IDs. If empty, sends to all active members."
    )
    scheduled_at = serializers.DateTimeField(required=False)
    filter_status = serializers.ChoiceField(
        choices=['all', 'active', 'expired'],
        default='active',
        required=False
    )


# ============================================================
# Message Queue / Log Serializers
# ============================================================

class MessageQueueSerializer(serializers.ModelSerializer):
    member_name = serializers.SerializerMethodField()

    class Meta:
        model = MessageQueue
        fields = [
            'id', 'phone', 'member', 'member_name',
            'rendered_message', 'scheduled_at', 'status',
            'retry_count', 'error_message', 'source',
            'created_at'
        ]

    def get_member_name(self, obj):
        if obj.member and obj.member.user:
            return obj.member.user.full_name
        return None


class MessageLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = MessageLog
        fields = [
            'id', 'whatsapp_message_id', 'status',
            'sent_at', 'delivered_at', 'read_at', 'created_at'
        ]


# ============================================================
# Analytics Serializer
# ============================================================

class MessageAnalyticsSerializer(serializers.Serializer):
    total_sent = serializers.IntegerField()
    total_delivered = serializers.IntegerField()
    total_read = serializers.IntegerField()
    total_failed = serializers.IntegerField()
    delivery_rate = serializers.FloatField()
    read_rate = serializers.FloatField()
    credits_used = serializers.IntegerField()
