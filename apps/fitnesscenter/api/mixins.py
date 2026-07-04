from django.utils import timezone
from datetime import timedelta
from rest_framework.response import Response
from django.db.models import Sum

from apps.customers.models import Customer, CustomerMembership, CustomerMembershipTransaction
from apps.mentors.models import MentorProfile
from apps.user.models import User

class DashboardStatsMixin:
    """
    Optimized count-only helper methods for dashboard analytics.
    """

    def validate_organization(self, request, organization_id):
        """Validate that the mentor has access to this organization."""
        mentor = request.user.mentor_profile
        org_ids = mentor.organizations.values_list("id", flat=True)

        try:
            org_id_int = int(organization_id)
        except ValueError:
            return None, Response({"detail": "Invalid organization ID"}, status=400)

        if org_id_int not in org_ids:
            return None, Response({"detail": "Not authorized for this organization"}, status=403)

        return org_id_int, None

    def get_active_customers_count(self, organization):
        """
        Count unique customers with Active or Trial memberships for this organization.
        Uses CustomerMembership status as the source of truth.
        """
        return CustomerMembership.objects.filter(
            membership__organization=organization,
            status__in=[CustomerMembership.ACTIVE, CustomerMembership.TRIAL]
        ).values('customer').distinct().count()

    def get_expired_customers_count(self, organization):
        """
        Count unique customers with Expired memberships for this organization.
        Uses CustomerMembership status as the source of truth.
        """
        return CustomerMembership.objects.filter(
            membership__organization=organization,
            status=CustomerMembership.EXPIRED
        ).values("customer").distinct().count()

    def get_upcoming_renewals_count(self, org_id):
        now = timezone.now()
        ten_days_from_now = now + timedelta(days=10)

        return CustomerMembership.objects.filter(
            membership__organization_id=org_id,
            status=CustomerMembership.ACTIVE,
            end_date__gte=now,
            end_date__lte=ten_days_from_now
        ).count()

    def get_upcoming_emi_count(self, org_id):
        now = timezone.now()
        ten_days_from_now = now + timedelta(days=10)

        return CustomerMembership.objects.filter(
            membership__organization_id=org_id,
            status=CustomerMembership.ACTIVE,
            emi_plan_id__isnull=False,  # Only memberships with an EMI plan
            next_due_date__gte=now,     # Next due date is today or in future
            next_due_date__lte=ten_days_from_now  # Within 10 days
        ).count()

    def get_trainer_count(self, organization):
        from apps.trainer.models import OrganizationTrainerLink
        return OrganizationTrainerLink.objects.filter(
            organization=organization,
            status=OrganizationTrainerLink.APPROVED
        ).count()
    def get_total_payment_received(self, org_id):
        total = CustomerMembershipTransaction.objects.filter(
            membership__organization=org_id
        ).aggregate(
            total_amount=Sum('amount')
        )['total_amount'] or 0

        return total