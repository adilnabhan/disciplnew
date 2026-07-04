import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from apps.user.models import User
from apps.customers.models import Customer
from apps.customers.api.workout_views import CustomerWorkoutCalendarView
from rest_framework.test import APIRequestFactory

customer = Customer.objects.first()
if not customer:
    print("No customer found!")
    exit(0)
user = customer.user

factory = APIRequestFactory()
request = factory.get('/api/v1/customer/workout-log/', {'year': '2026', 'month': '06'})
request.user = user

view = CustomerWorkoutCalendarView.as_view()
try:
    response = view(request)
    print("STATUS:", response.status_code)
    print("DATA:", response.data)
except Exception as e:
    import traceback
    traceback.print_exc()
