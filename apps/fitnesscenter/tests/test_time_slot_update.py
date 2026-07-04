import json
from django.test import TestCase
from rest_framework.test import APIClient
from django.urls import reverse
from apps.user.models import User
from apps.mentors.models import MentorProfile
from apps.fitnesscenter.models import Organization, OrganizationTimeSlot

class OrganizationTimeSlotUpdateTest(TestCase):
    def setUp(self):
        # Create a superuser for authentication
        self.user = User.objects.create_user(
            username='testadmin',
            email='admin@example.com',
            password='testpass123',
            is_superuser=True,
            is_staff=True,
        )
        # Create MentorProfile linked to the user
        self.mentor = MentorProfile.objects.create(user=self.user, designation=MentorProfile.ADMIN)
        # Create an organization belonging to the mentor
        self.org = Organization.objects.create(name='Test Gym', mentor=self.mentor)
        # Add an initial time slot
        self.initial_slot = OrganizationTimeSlot.objects.create(
            organization=self.org,
            name='Morning Slot',
            start_time='08:00:00',
            end_time='10:00:00',
            is_active=True,
        )
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)

    def test_update_time_slots(self):
        url = reverse('organization-update', kwargs={'pk': self.org.id})  # adjust name if needed
        payload = {
            "name": "Test Gym Updated",
            "time_slots": [
                # Update existing slot (use its id)
                {
                    "id": self.initial_slot.id,
                    "name": "Morning Updated",
                    "start_time": "07:30:00",
                    "end_time": "09:30:00",
                    "is_active": True,
                },
                # Add a new slot (no id)
                {
                    "name": "Evening Slot",
                    "start_time": "18:00:00",
                    "end_time": "20:00:00",
                    "is_active": True,
                },
            ],
        }
        response = self.client.patch(url, data=json.dumps(payload), content_type='application/json', HTTP_X_PLATFORM='admin-web')
        if response.status_code != 200:
            print("UPDATE ERROR CONTENT:", response.content)
        self.assertEqual(response.status_code, 200)
        # Verify the organization name changed
        self.org.refresh_from_db()
        self.assertEqual(self.org.name, "Test Gym Updated")
        # Verify slots: there should be exactly 2 now
        slots = OrganizationTimeSlot.objects.filter(organization=self.org)
        self.assertEqual(slots.count(), 2)
        names = set(slots.values_list('name', flat=True))
        self.assertIn('Morning Updated', names)
        self.assertIn('Evening Slot', names)

    def test_date_bounds_active_inactive(self):
        from django.utils import timezone
        today = timezone.localdate()
        
        # 1. Slot active within date range (starts yesterday, ends tomorrow)
        active_slot = OrganizationTimeSlot.objects.create(
            organization=self.org,
            name='Ramzan Special Active',
            start_time='18:00:00',
            end_time='20:00:00',
            is_active=True,
            start_date=today - timezone.timedelta(days=1),
            end_date=today + timezone.timedelta(days=1)
        )
        self.assertTrue(active_slot.is_currently_active)

        # 2. Slot inactive because start date is in the future
        future_slot = OrganizationTimeSlot.objects.create(
            organization=self.org,
            name='Future Special',
            start_time='18:00:00',
            end_time='20:00:00',
            is_active=True,
            start_date=today + timezone.timedelta(days=2),
            end_date=today + timezone.timedelta(days=5)
        )
        self.assertFalse(future_slot.is_currently_active)

        # 3. Slot inactive because end date has passed
        expired_slot = OrganizationTimeSlot.objects.create(
            organization=self.org,
            name='Past Special',
            start_time='18:00:00',
            end_time='20:00:00',
            is_active=True,
            start_date=today - timezone.timedelta(days=5),
            end_date=today - timezone.timedelta(days=2)
        )
        self.assertFalse(expired_slot.is_currently_active)

        # 4. Slot inactive because is_active is False (even if dates are valid)
        disabled_slot = OrganizationTimeSlot.objects.create(
            organization=self.org,
            name='Disabled Special',
            start_time='18:00:00',
            end_time='20:00:00',
            is_active=False,
            start_date=today - timezone.timedelta(days=1),
            end_date=today + timezone.timedelta(days=1)
        )
        self.assertFalse(disabled_slot.is_currently_active)

    def test_update_time_slots_with_dates(self):
        url = reverse('organization-update', kwargs={'pk': self.org.id})
        payload = {
            "time_slots": [
                {
                    "name": "Ramzan Night Special",
                    "start_time": "21:00:00",
                    "end_time": "23:00:00",
                    "is_active": True,
                    "start_date": "2026-03-01",
                    "end_date": "2026-04-01"
                }
            ]
        }
        response = self.client.patch(url, data=json.dumps(payload), content_type='application/json', HTTP_X_PLATFORM='admin-web')
        if response.status_code != 200:
            print("UPDATE DATE ERROR CONTENT:", response.content)
        self.assertEqual(response.status_code, 200)
        
        # Verify the slot is created with correct dates
        slots = OrganizationTimeSlot.objects.filter(organization=self.org)
        self.assertEqual(slots.count(), 1)
        slot = slots.first()
        self.assertEqual(slot.name, "Ramzan Night Special")
        self.assertEqual(str(slot.start_date), "2026-03-01")
        self.assertEqual(str(slot.end_date), "2026-04-01")

        # Verify details returned in response
        data = response.json()
        org_data = data["data"]
        self.assertIn("time_slots", org_data)
        resp_slot = org_data["time_slots"][0]
        self.assertEqual(resp_slot["start_date"], "2026-03-01")
        self.assertEqual(resp_slot["end_date"], "2026-04-01")
        self.assertIn("is_currently_active", resp_slot)

    def test_customer_detail_serializer_includes_time_slots(self):
        from apps.customers.api.serializers import FitnesscenterDetailSerializer
        from rest_framework.request import Request
        from django.test import RequestFactory
        factory = RequestFactory()
        django_request = factory.get('/')
        request = Request(django_request)
        serializer = FitnesscenterDetailSerializer(self.org, context={'request': request})
        data = serializer.data
        self.assertIn('time_slots', data)
        self.assertEqual(len(data['time_slots']), 1)
        self.assertEqual(data['time_slots'][0]['name'], 'Morning Slot')
        self.assertIn('is_currently_active', data['time_slots'][0])

