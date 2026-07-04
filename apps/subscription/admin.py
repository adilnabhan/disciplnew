from django.contrib import admin

# Register your models here.


from django.contrib import admin
from .models import DisciplSubscriptionPlan, OrganizationSubscriptionStatusHistory, OrganizationSubscriptionsDetails, OrganizationTransaction, PartnerTransfer

@admin.register(DisciplSubscriptionPlan)
class DisciplSubscriptionPlanAdmin(admin.ModelAdmin):
    list_display = ('name', 'plan_type', 'regular_price', 'discounted_price', 'period', 'is_active')
    search_fields = ('name',)
    list_filter = ('plan_type', 'is_active')
    ordering = ('-created_at',)
    readonly_fields = ('created_at', 'updated_at')


@admin.register(OrganizationSubscriptionsDetails)
class OrganizationSubscriptionsDetailsAdmin(admin.ModelAdmin):
    list_display = ('user', 'organization', 'plan', 'status', 'start_date', 'end_date', 'payment_status', 'auto_renew')
    search_fields = ('user__username', 'organization__name', 'plan__name')
    list_filter = ('status', 'payment_status', 'auto_renew')
    ordering = ('-created_at',)
    readonly_fields = ('created_at', 'updated_at')


@admin.register(OrganizationTransaction)
class OrganizationTransactionAdmin(admin.ModelAdmin):
    list_display = ('order_id', 'payment_id', 'user', 'organization', 'discipl_plan', 'amount', 'status', 'payment_method', 'payment_date')
    search_fields = ('order_id', 'payment_id', 'user__username', 'organization__name')
    list_filter = ('status', 'payment_method')
    ordering = ('-created_at',)
    readonly_fields = ('created_at', 'updated_at')


@admin.register(OrganizationSubscriptionStatusHistory)
class OrganizationSubscriptionStatusHistoryAdmin(admin.ModelAdmin):
    list_display = ('subscription', 'old_status', 'new_status', 'changed_at')
    search_fields = ('subscription__user__username',)
    ordering = ('-changed_at',)
    readonly_fields = ('changed_at',)


@admin.register(PartnerTransfer)
class PartnerTransferAdmin(admin.ModelAdmin):
    list_display = (
        'transfer_id', 'status', 'amount', 'platform_fee', 'retry_count',
        'customer_name', 'gym_name', 'created_at'
    )
    search_fields = (
        'transfer_id', 'account_id',
        'order__order_id', 'order__payment_id',
        'customer_transaction__payment_id',
        'customer_transaction__subscription__razorpay_subscription_id',
        'notes'
    )
    list_filter = ('status', 'retry_count', 'created_at')
    ordering = ('-created_at',)
    readonly_fields = (
        'transfer_id', 'account_id', 'amount', 'platform_fee',
        'original_payment_amount', 'customer_transaction', 'order', 'status',
        'notes', 'error_message', 'retry_count', 'last_retry_at',
        'settlement_date', 'created_at'
    )
    raw_id_fields = ('order', 'customer_transaction')

    def customer_name(self, obj):
        """Display customer name from transaction"""
        if obj.customer_transaction and obj.customer_transaction.customer:
            return obj.customer_transaction.customer.user.get_full_name()
        return "-"
    customer_name.short_description = "Customer"

    def gym_name(self, obj):
        """Display gym name from transaction"""
        if obj.customer_transaction and obj.customer_transaction.membership:
            return obj.customer_transaction.membership.organization.name
        return "-"
    gym_name.short_description = "Gym"