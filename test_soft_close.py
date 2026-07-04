import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from apps.customers.models import MembershipRequest, Customer, Organization, MembershipPlan
from apps.customers.api.serializers import MembershipRequestCreateSerializer
from django.contrib.auth import get_user_model

User = get_user_model()

# Ensure test user exists
user, _ = User.objects.get_or_create(username='testuser', defaults={'first_name':'Test', 'last_name':'User', 'email':'test@example.com'})
user.set_password('testpass')
user.save()

customer, _ = Customer.objects.get_or_create(user=user)
org, _ = Organization.objects.get_or_create(name='Test Gym', defaults={'active':True})
plan, _ = MembershipPlan.objects.get_or_create(name='Basic Plan', organization=org)

# First request
serializer1 = MembershipRequestCreateSerializer(
    data={'organization': org.id, 'membership_plan': plan.id, 'notes':'first', 'payment_mode':'cash'},
    context={'request': type('Req', (), {'user': user})}
)
serializer1.is_valid(raise_exception=True)
req1 = serializer1.save()
print('First request status:', req1.status)

# Second request should close the first
serializer2 = MembershipRequestCreateSerializer(
    data={'organization': org.id, 'membership_plan': plan.id, 'notes':'second', 'payment_mode':'cash'},
    context={'request': type('Req', (), {'user': user})}
)
serializer2.is_valid(raise_exception=True)
req2 = serializer2.save()
print('Second request status:', req2.status)

# Refresh first request
req1.refresh_from_db()
print('First request after second, status:', req1.status)
