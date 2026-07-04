from django.contrib import admin

# Register your models here.


from django.contrib import admin

from apps.customers.models import Customer, CustomerMembership, CustomerMembershipTransaction, CustomerReview, Injury, MedicalCondition, MembershipRequest
from apps.subscription.models import PartnerTransfer


@admin.register(Injury)
class InjuryAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'display_order', 'is_active')
    list_editable = ('display_order', 'is_active')
    list_filter = ('is_active',)
    search_fields = ('name',)
    ordering = ('display_order',)

@admin.register(MedicalCondition)
class MedicalConditionAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'display_order', 'is_active')
    list_editable = ('display_order', 'is_active')
    list_filter = ('is_active',)
    search_fields = ('name',)
    ordering = ('display_order',)


@admin.register(Customer)
class CustomerAdmin(admin.ModelAdmin):
    list_display = (
        'id', 'get_user_name', 'organization', 'bmi', 'bmr', 'is_active_member', 'created_by', 'created', 'modified'
    )
    list_filter = ('organization', 'is_active_member', 'created')
    search_fields = ('user__first_name', 'user__last_name', 'user__mobile_number', 'profession')
    readonly_fields = ('hash_of_user_phone_number', 'created', 'modified')

    def get_user_name(self, obj):
        return obj.user.get_full_name() if obj.user else 'N/A'
    get_user_name.short_description = 'Customer Name'


@admin.register(CustomerMembership)
class CustomerMembershipAdmin(admin.ModelAdmin):
    list_display = (
        'id', 'customer_name', 'membership', 'status', 'start_date', 'end_date', 'is_trial', 'assign_free', 'payment_status', 'is_active'
    )
    list_filter = ('status', 'payment_status', 'is_trial', 'is_active', 'membership__organization')
    search_fields = ('customer__user__first_name', 'customer__user__last_name', 'membership__name')
    readonly_fields = ('created_at', 'updated_at')

    def customer_name(self, obj):
        return obj.customer.user.get_full_name() if obj.customer and obj.customer.user else 'N/A'
    customer_name.short_description = 'Customer'


class PartnerTransferInline(admin.TabularInline):
    model = PartnerTransfer
    extra = 0
    readonly_fields = ('transfer_id', 'account_id', 'amount', 'status', 'settlement_date', 'created_at')
    can_delete = False

    def has_add_permission(self, request, obj=None):
        return False


@admin.register(CustomerMembershipTransaction)
class CustomerMembershipTransactionAdmin(admin.ModelAdmin):
    inlines = [PartnerTransferInline]
    list_display = (
        'id', 'user_name', 'customer', 'membership', 'subscription', 'amount',
        'status', 'payment_method', 'payment_date', 'order_id', 'payment_id'
    )
    list_filter = ('status', 'payment_method', 'payment_date', 'created_at')
    search_fields = (
        'user__username', 'customer__user__first_name', 'customer__user__last_name',
        'order_id', 'payment_id'
    )
    readonly_fields = ('created_at', 'updated_at', 'razorpay_signature')

    def user_name(self, obj):
        return obj.user.get_full_name() if obj.user else 'N/A'
    user_name.short_description = 'User'
    
    
@admin.register(CustomerReview)
class CustomerReviewAdmin(admin.ModelAdmin):
    list_display = (
        'id', 'customer_name', 'organization_name', 'rating', 'short_comment', 'created',
    )
    list_filter = ('rating', 'organization')
    search_fields = ('customer__user__first_name', 'customer__user__last_name', 'organization__name', 'comment')
    readonly_fields = ('created', 'modified')

    def customer_name(self, obj):
        return f"{obj.customer.user.first_name} {obj.customer.user.last_name}" if obj.customer and obj.customer.user else "-"
    customer_name.short_description = "Customer"

    def organization_name(self, obj):
        return obj.organization.name if obj.organization else "-"
    organization_name.short_description = "Organization"

    def short_comment(self, obj):
        return (obj.comment[:50] + '...') if obj.comment and len(obj.comment) > 50 else obj.comment
    short_comment.short_description = "Comment"


@admin.register(MembershipRequest)
class MembershipRequestAdmin(admin.ModelAdmin):
    list_display = (
        'id', 'customer_name', 'organization_name', 'requested_plan_name',
        'selected_plan_name', 'status', 'payment_mode', 'requested_at', 'responded_at'
    )
    list_filter = ('status', 'payment_mode', 'organization', 'requested_at')
    search_fields = (
        'customer__user__first_name', 'customer__user__last_name',
        'organization__name', 'membership_plan__name'
    )
    readonly_fields = ('requested_at',)
    raw_id_fields = ('customer', 'organization', 'membership_plan', 'selected_plan')

    def customer_name(self, obj):
        return obj.customer.user.full_name if obj.customer and obj.customer.user else '-'
    customer_name.short_description = 'Customer'

    def organization_name(self, obj):
        return obj.organization.name if obj.organization else '-'
    organization_name.short_description = 'Organization'

    def requested_plan_name(self, obj):
        return obj.membership_plan.name if obj.membership_plan else '-'
    requested_plan_name.short_description = 'Requested Plan'

    def selected_plan_name(self, obj):
        return obj.selected_plan.name if obj.selected_plan else '-'
    selected_plan_name.short_description = 'Selected Plan'