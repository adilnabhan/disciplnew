from django.contrib import admin
from apps.communication.models import (
    DeviceToken, MessageCreditWallet, MessageCreditTransaction,
    WhatsAppTemplate, AutomationRule, MessageQueue, MessageLog,
)


@admin.register(DeviceToken)
class DeviceTokenAdmin(admin.ModelAdmin):
    list_display = ('user', 'platform', 'is_active', 'created_at')
    list_filter = ('platform', 'is_active')
    search_fields = ('user__first_name', 'user__mobile_number', 'token')


@admin.register(MessageCreditWallet)
class MessageCreditWalletAdmin(admin.ModelAdmin):
    list_display = ('organization', 'available_credits', 'used_credits', 'updated_at')
    search_fields = ('organization__name',)


@admin.register(MessageCreditTransaction)
class MessageCreditTransactionAdmin(admin.ModelAdmin):
    list_display = ('organization', 'type', 'credits', 'amount', 'reference_type', 'created_at')
    list_filter = ('type', 'reference_type')
    search_fields = ('organization__name', 'payment_id')


@admin.register(WhatsAppTemplate)
class WhatsAppTemplateAdmin(admin.ModelAdmin):
    list_display = ('name', 'organization', 'event_type', 'status', 'created_at')
    list_filter = ('event_type', 'status')
    search_fields = ('name', 'organization__name', 'content')


@admin.register(AutomationRule)
class AutomationRuleAdmin(admin.ModelAdmin):
    list_display = ('organization', 'event_type', 'template', 'trigger_days_before', 'send_time', 'enabled')
    list_filter = ('event_type', 'enabled')
    search_fields = ('organization__name',)


@admin.register(MessageQueue)
class MessageQueueAdmin(admin.ModelAdmin):
    list_display = ('phone', 'organization', 'status', 'source', 'scheduled_at', 'retry_count')
    list_filter = ('status', 'source')
    search_fields = ('phone', 'organization__name')


@admin.register(MessageLog)
class MessageLogAdmin(admin.ModelAdmin):
    list_display = ('queue_entry', 'status', 'sent_at', 'delivered_at', 'read_at')
    list_filter = ('status',)
    search_fields = ('whatsapp_message_id',)
