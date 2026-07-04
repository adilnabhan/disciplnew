import json
from django.test import TestCase
from rest_framework.test import APIClient
from django.urls import reverse
from apps.user.models import User
from apps.trainer.models import Trainer, OrganizationTrainerLink
from apps.fitnesscenter.models import Organization
from apps.mentors.models import MentorProfile
from phonenumber_field.phonenumber import PhoneNumber

class GymDirectAddTrainerTests(TestCase):
    def setUp(self):
        # Create a gym owner / mentor
        self.mentor_user = User.objects.create_user(
            username='+919999999999',
            email='owner@gym.com',
            mobile_number='+919999999999',
            password='securepassword123',
            user_role=User.MENTOR
        )
        # Fetch or create the mentor profile since signal might auto-create it
        self.mentor_profile, _ = MentorProfile.objects.get_or_create(user=self.mentor_user)
        self.mentor_profile.designation = MentorProfile.ADMIN
        self.mentor_profile.save()

        self.org = Organization.objects.create(
            name='Alpha Gym',
            mentor=self.mentor_profile
        )

        # Create another user to represent an existing user in the database
        self.existing_user_phone = '+918888888888'
        self.existing_user = User.objects.create_user(
            username=self.existing_user_phone,
            mobile_number=self.existing_user_phone,
            password='password123',
            user_role=User.CUSTOMER
        )

        # Create a user with an email to test email conflicts
        self.conflict_user = User.objects.create_user(
            username='+917777777777',
            email='conflict@example.com',
            mobile_number='+917777777777',
            password='password123'
        )

        # Setup APIClient and authenticate as gym owner
        self.client = APIClient()
        self.client.credentials(HTTP_X_PLATFORM='mentor-app-web')
        self.client.force_authenticate(user=self.mentor_user)
        self.url = reverse('gym-trainer-direct-add')  # matches the name in urls.py

    def test_gym_add_new_trainer_success(self):
        payload = {
            'organization_id': self.org.id,
            'mobile': '+919876543210',
            'first_name': 'New',
            'last_name': 'Trainer',
            'email': 'newtrainer@example.com',
            'user_type': 'trainer',
            'experience_years': 5
        }
        response = self.client.post(self.url, data=payload)
        self.assertEqual(response.status_code, 201)
        
        # Verify user and trainer were created
        user = User.objects.get(mobile_number='+919876543210')
        self.assertEqual(user.first_name, 'New')
        self.assertEqual(user.email, 'newtrainer@example.com')
        self.assertEqual(user.user_role, User.MENTOR_TRAINER)

        trainer = Trainer.objects.get(user=user)
        self.assertEqual(trainer.first_name, 'New')
        self.assertEqual(trainer.email, 'newtrainer@example.com')
        self.assertEqual(trainer.experience_years, 5)

        # Verify link was created as approved
        link = OrganizationTrainerLink.objects.get(trainer=trainer, organization=self.org)
        self.assertEqual(link.status, OrganizationTrainerLink.APPROVED)
        self.assertTrue(link.invited_by_org)

    def test_gym_add_existing_user_without_trainer_profile(self):
        # The existing user starts with no email and role = CUSTOMER
        self.assertFalse(Trainer.objects.filter(user=self.existing_user).exists())
        self.assertNotEqual(self.existing_user.user_role, User.MENTOR_TRAINER)
        self.assertNilOrEmpty(self.existing_user.email)

        payload = {
            'organization_id': self.org.id,
            'mobile': self.existing_user_phone,
            'first_name': 'UpdatedName',
            'last_name': 'UpdatedLastName',
            'email': 'existing_user_new@example.com',
            'user_type': 'trainer',
            'experience_years': 3
        }
        response = self.client.post(self.url, data=payload)
        self.assertEqual(response.status_code, 201)

        # Verify existing user's email was updated and role was upgraded
        self.existing_user.refresh_from_db()
        self.assertEqual(self.existing_user.email, 'existing_user_new@example.com')
        self.assertEqual(self.existing_user.user_role, User.MENTOR_TRAINER)

        # Verify trainer profile was created and has the email
        trainer = Trainer.objects.get(user=self.existing_user)
        self.assertEqual(trainer.email, 'existing_user_new@example.com')
        self.assertEqual(trainer.experience_years, 3)

    def test_gym_add_existing_trainer_with_new_email(self):
        # Create trainer profile for existing user
        trainer = Trainer.objects.create(
            user=self.existing_user,
            mobile=self.existing_user_phone,
            first_name='Existing',
            last_name='Trainer',
            user_type='trainer'
        )

        payload = {
            'organization_id': self.org.id,
            'mobile': self.existing_user_phone,
            'email': 'updated_trainer_email@example.com',
            'user_type': 'trainer'
        }
        response = self.client.post(self.url, data=payload)
        self.assertEqual(response.status_code, 201)

        # Verify both user and trainer profiles got the new email
        self.existing_user.refresh_from_db()
        trainer.refresh_from_db()
        self.assertEqual(self.existing_user.email, 'updated_trainer_email@example.com')
        self.assertEqual(trainer.email, 'updated_trainer_email@example.com')

    def test_gym_add_trainer_email_conflict(self):
        payload = {
            'organization_id': self.org.id,
            'mobile': self.existing_user_phone,
            'email': 'conflict@example.com', # already taken by conflict_user
            'user_type': 'trainer'
        }
        response = self.client.post(self.url, data=payload)
        self.assertEqual(response.status_code, 400)
        self.assertIn('already exists', response.json()['detail'])

        # Verify email was not set on the existing user
        self.existing_user.refresh_from_db()
        self.assertNotEqual(self.existing_user.email, 'conflict@example.com')

    def assertNilOrEmpty(self, val):
        self.assertTrue(val is None or val == '')


class CreateOrgStaffTests(TestCase):
    def setUp(self):
        # Create admin user
        self.admin_user = User.objects.create_superuser(
            username='admin_user',
            email='admin@example.com',
            password='adminpassword123',
            is_staff=True,
            is_superuser=True
        )
        self.mentor_profile, _ = MentorProfile.objects.get_or_create(user=self.admin_user)
        self.mentor_profile.designation = MentorProfile.ADMIN
        self.mentor_profile.save()

        self.org = Organization.objects.create(
            name='Alpha Gym',
            mentor=self.mentor_profile
        )

        # Create user with conflict email
        self.conflict_user = User.objects.create_user(
            username='conflict_user',
            email='conflict@example.com',
            password='password123'
        )

        self.client = APIClient()
        self.client.credentials(HTTP_X_PLATFORM='mentor-app-web')
        self.client.force_authenticate(user=self.admin_user)
        self.url = reverse('organization-create-staff')

    def test_create_org_staff_new_user(self):
        payload = {
            'username': 'new_staff',
            'password': 'StaffPassword123!',
            'organization_id': self.org.id,
            'email': 'staff@gym.com',
            'first_name': 'Staff',
            'last_name': 'One'
        }
        response = self.client.post(self.url, data=json.dumps(payload), content_type='application/json')
        self.assertEqual(response.status_code, 201)

        user = User.objects.get(username='new_staff')
        self.assertEqual(user.email, 'staff@gym.com')
        self.assertEqual(user.first_name, 'Staff')
        self.assertEqual(user.last_name, 'One')
        self.assertTrue(user.is_staff)

    def test_create_org_staff_existing_user_updates_fields(self):
        # Create existing user with empty names/email
        existing_user = User.objects.create_user(
            username='existing_staff_user',
            password='password123'
        )
        self.assertEqual(existing_user.email, '')
        self.assertEqual(existing_user.first_name, '')
        self.assertEqual(existing_user.last_name, '')

        payload = {
            'username': 'existing_staff_user',
            'password': 'password123',
            'organization_id': self.org.id,
            'email': 'staff_updated@gym.com',
            'first_name': 'UpdatedStaff',
            'last_name': 'UpdatedOne'
        }
        response = self.client.post(self.url, data=json.dumps(payload), content_type='application/json')
        self.assertEqual(response.status_code, 200)

        existing_user.refresh_from_db()
        self.assertEqual(existing_user.email, 'staff_updated@gym.com')
        self.assertEqual(existing_user.first_name, 'UpdatedStaff')
        self.assertEqual(existing_user.last_name, 'UpdatedOne')
        self.assertTrue(existing_user.is_staff)

    def test_create_org_staff_email_conflict(self):
        # Create existing user
        existing_user = User.objects.create_user(
            username='existing_staff_user2',
            password='password123'
        )

        payload = {
            'username': 'existing_staff_user2',
            'password': 'password123',
            'organization_id': self.org.id,
            'email': 'conflict@example.com', # conflict
            'first_name': 'UpdatedStaff',
            'last_name': 'UpdatedOne'
        }
        response = self.client.post(self.url, data=json.dumps(payload), content_type='application/json')
        self.assertEqual(response.status_code, 400)
        self.assertIn('already exists', response.json()['detail'])

        existing_user.refresh_from_db()
        self.assertNotEqual(existing_user.email, 'conflict@example.com')


class OwnerDashboardTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.mentor_user = User.objects.create_user(
            username='+919999999999',
            email='owner@gym.com',
            mobile_number='+919999999999',
            password='securepassword123',
            user_role=User.MENTOR
        )
        self.mentor_profile, _ = MentorProfile.objects.get_or_create(user=self.mentor_user)
        self.org = Organization.objects.create(
            name='Alpha Gym',
            mentor=self.mentor_profile
        )
        self.client.credentials(HTTP_X_PLATFORM='mentor-app-web')
        self.client.force_authenticate(user=self.mentor_user)

    def test_owner_dashboard(self):
        url = reverse('owner-dashboard')
        response = self.client.get(url, {'organization_id': self.org.id})
        self.assertEqual(response.status_code, 200)
        self.assertIn('total_customers', response.data)
        self.assertIn('total_trainers', response.data)
        self.assertIn('total_revenue', response.data)
        self.assertIn('community_posts_count', response.data)
