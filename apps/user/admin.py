from django.contrib import admin
from apps.user.models import OtpStore, User, SalesExecutive, Coupon, SubscriptionTransaction
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin

# Register your models here.

@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ('id', 'username', 'mobile_number', 'email', 'user_role', 'is_active', 'is_staff', 'date_joined', 'is_guest')
    list_filter = ('user_role', 'is_active', 'is_staff', 'platform')
    search_fields = ('username', 'first_name', 'last_name', 'mobile_number', 'email')
    ordering = ('-date_joined',)
    readonly_fields = ('created', 'modified')
    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        ('Personal Info', {'fields': ('first_name', 'last_name', 'email', 'mobile_number', 'profile_picture', 'gender', 'date_of_birth', 'blood_group')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'user_permissions', 'groups')}),
        ('Role Info', {'fields': ('user_role', 'platform', 'platforms')}),
        ('Important Dates', {'fields': ('last_login', 'created', 'modified')}),
    )


@admin.register(OtpStore)
class OtpStoreAdmin(admin.ModelAdmin):
    list_display = ('id', 'mobile_number', 'process', 'otp', 'source', 'created_at', 'verified_at')
    list_filter = ('process', 'source', 'created_at')
    search_fields = ('mobile_number', 'otp')
    readonly_fields = ('created_at', 'verified_at')
    ordering = ('-created_at',)

@admin.register(SalesExecutive)
class SalesExecutiveAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "name",
        "phone",
        "email",
        "is_active",
        "created_at",
    )
    search_fields = ("name", "phone", "email")
    list_filter = ("is_active",)
    ordering = ("-created_at",)

@admin.register(Coupon)
class CouponAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "code",
        "discount_type",
        "discount_value",
        "sales_executive",
        "share_type",
        "share_value",
        "is_active",
        "valid_from",
        "valid_to",
    )

    search_fields = ("code",)
    list_filter = ("discount_type", "share_type", "is_active")

    autocomplete_fields = ["sales_executive"]

    ordering = ("-created_at",)

@admin.register(SubscriptionTransaction)
class SubscriptionTransactionAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "user",
        "plan",
        "coupon",
        "sales_executive",
        "final_amount",
        "executive_commission",
        "commission_paid",
        "created_at",
    )

    list_filter = ("commission_paid",)
    search_fields = ("user__username", "coupon__code")
    ordering = ("-created_at",)