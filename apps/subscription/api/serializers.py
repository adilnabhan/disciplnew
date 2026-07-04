import django.db
from rest_framework import serializers
from django.utils import timezone

from apps.customers.models import CustomerMembership, CustomerMembershipTransaction
from apps.fitnesscenter.models import EmiPlan, MembershipPlan
from apps.subscription.models import DisciplSubscriptionPlan, OrganizationSubscriptionsDetails, OrganizationTransaction
from apps.user.models import User


class RazorpayOrderCreateSerializer(serializers.Serializer):
    plan_id = serializers.UUIDField()
    organization_id = serializers.IntegerField()
    coupon_code = serializers.CharField(required=False, allow_blank=True, allow_null=True)

    def validate_plan_id(self, value):
        if not DisciplSubscriptionPlan.objects.filter(id=value, is_active=True).exists():
            raise serializers.ValidationError("Invalid or inactive plan.")
        return value

    def validate_organization_id(self, value):
        from apps.subscription.models import Organization
        mentor = self.context['mentor']
        if not Organization.objects.filter(id=value, mentor=mentor).exists():
            raise serializers.ValidationError("Invalid organization.")
        return value

    def validate(self, data):
        user = self.context['request'].user
        organization_id = data.get('organization_id')
        plan_id = data.get('plan_id')

        existing_sub = OrganizationSubscriptionsDetails.objects.filter(
            user=user,
            organization_id=organization_id,
            plan_id=plan_id,
            status__in=[OrganizationSubscriptionsDetails.TRIAL, OrganizationSubscriptionsDetails.ACTIVE],
            end_date__gte=timezone.now()
        ).last()

        if existing_sub:
            raise serializers.ValidationError(f"You already have an active or trial subscription for this organization with the selected plan. It will expire on {existing_sub.end_date}.")
        return data


class UserDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'first_name', 'last_name', 'mobile_number']
        read_only_fields = fields


class DisciplPlanDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = DisciplSubscriptionPlan
        fields = ['id', 'name', 'plan_type', 'regular_price', 'discounted_price', 'period']
        read_only_fields = fields


class OrganizationTransactionSerializer(serializers.ModelSerializer):
    user = UserDetailSerializer(read_only=True)
    discipl_plan = DisciplPlanDetailSerializer(read_only=True)
    organization = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = OrganizationTransaction
        fields = ['id', 'order_id', 'user', 'organization', 'discipl_plan', 'amount']

    def to_representation(self, obj):
        td = super(OrganizationTransactionSerializer, self).to_representation(obj)
        return td


class CustomerRazorpayOrderCreateSerializer(serializers.Serializer):
    plan_id = serializers.IntegerField()
    coupon_code = serializers.CharField(required=False, allow_blank=True, allow_null=True)

    def validate_plan_id(self, value):
        try:
            plan = MembershipPlan.objects.get(id=value, is_active=True)
        except MembershipPlan.DoesNotExist:
            raise serializers.ValidationError("Invalid or inactive membership plan.")
        return plan


class CustomerTransactionSerializer(serializers.ModelSerializer):
    user = UserDetailSerializer(read_only=True)

    class Meta:
        model = CustomerMembershipTransaction
        fields = ['id', 'order_id', 'user', 'amount']

    def to_representation(self, obj):
        td = super(CustomerTransactionSerializer, self).to_representation(obj)
        return td


class CustomerRazorpaySubscriptionCreateSerializer(serializers.Serializer):
    plan_id = serializers.IntegerField()
    emi_plan_id = serializers.IntegerField(required=False)

    def validate_plan_id(self, value):
        try:
            membership_plan = MembershipPlan.objects.get(id=value, is_active=True)
        except MembershipPlan.DoesNotExist:
            raise serializers.ValidationError("Invalid or inactive membership plan.")
        return membership_plan

    def validate(self, data):
        plan = data.get('plan_id')
        emi_plan_id = data.get('emi_plan_id')

        if emi_plan_id:
            try:
                EmiPlan.objects.get(id=emi_plan_id, membership_plan=plan)
            except EmiPlan.DoesNotExist:
                raise serializers.ValidationError({"emi_plan_id": "Invalid EMI plan for the selected membership."})

        customer = self.context['request'].user.customer
        if CustomerMembership.objects.filter(customer=customer, status='Active').exists():
            raise serializers.ValidationError("You already have an active subscription.")

        return data


class TrainerRazorpayOrderCreateSerializer(serializers.Serializer):
    plan_id = serializers.IntegerField()

    def validate_plan_id(self, value):
        from apps.trainer.models import TrainerSubscriptionPlan
        try:
            return TrainerSubscriptionPlan.objects.get(id=value, is_active=True)
        except TrainerSubscriptionPlan.DoesNotExist:
            raise serializers.ValidationError("Invalid or inactive plan.")


class TrainerTransactionSerializer(serializers.ModelSerializer):
    user = UserDetailSerializer(read_only=True)
    trainer = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = OrganizationTransaction
        fields = ['id', 'order_id', 'user', 'trainer', 'amount']
