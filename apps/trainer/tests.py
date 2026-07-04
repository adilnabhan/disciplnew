from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase
from rest_framework import status
import json

from apps.trainer.models import (
    Trainer, WorkoutPlan, CustomerWorkoutPlan, OrganizationTrainerLink
)
from apps.customers.models import Customer
from apps.fitnesscenter.models import Organization

User = get_user_model()


class AssignWorkoutPlanTests(APITestCase):

    def setUp(self):
        # Create users
        self.trainer_user = User.objects.create_user(
            username="+919876543210",
            mobile_number="+919876543210",
            email="trainer@test.com",
            user_role=User.MENTOR_TRAINER,
            password="testpassword",
            first_name="John",
            last_name="Doe"
        )
        # Trainer profile is automatically created by signals on user creation
        self.trainer = self.trainer_user.trainer_profile
        self.trainer.experience_years = 5
        self.trainer.save()

        self.customer_user_1 = User.objects.create_user(
            username="+919876543211",
            mobile_number="+919876543211",
            email="cust1@test.com",
            user_role=User.CUSTOMER,
            password="testpassword"
        )
        self.customer_user_2 = User.objects.create_user(
            username="+919876543212",
            mobile_number="+919876543212",
            email="cust2@test.com",
            user_role=User.CUSTOMER,
            password="testpassword"
        )

        # Create organizations
        self.org_a = Organization.objects.create(
            name="Fitness Center A",
            email="org_a@test.com",
            phone_number="9876543210",
            description="Premium Gym A",
            registration_status=Organization.VERIFIED
        )
        self.org_b = Organization.objects.create(
            name="Fitness Center B",
            email="org_b@test.com",
            phone_number="9876543211",
            description="Premium Gym B",
            registration_status=Organization.VERIFIED
        )

        # Associate customer 1 to Org A, customer 2 to Org B
        # Customer profiles are automatically created by signals on user creation
        self.customer_1 = self.customer_user_1.customer
        self.customer_1.organization = self.org_a
        self.customer_1.save()

        self.customer_2 = self.customer_user_2.customer
        self.customer_2.organization = self.org_b
        self.customer_2.save()

        # Link trainer to Org A (APPROVED)
        OrganizationTrainerLink.objects.create(
            trainer=self.trainer,
            organization=self.org_a,
            status=OrganizationTrainerLink.APPROVED
        )

        # Create workout plans
        self.plan_org_a = WorkoutPlan.objects.create(
            trainer=self.trainer,
            organization=self.org_a,
            plan_name="Gym A Strength Plan",
            total_weeks=4
        )
        self.plan_personal = WorkoutPlan.objects.create(
            trainer=self.trainer,
            plan_name="Trainer Personal Plan",
            total_weeks=4
        )

        # Authenticate client as the trainer and set required headers
        self.client.force_authenticate(user=self.trainer_user)
        self.client.credentials(HTTP_X_PLATFORM="mentor-app-android")

    def test_assign_plan_same_organization_success(self):
        """
        Trainer assigns an organization-specific plan to a customer belonging
        to that same organization.
        """
        url = f"/api/v1/trainer/workout-plans/{self.plan_org_a.id}/assign/"
        data = {"customer_id": self.customer_1.id}
        
        response = self.client.post(url, data, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(
            CustomerWorkoutPlan.objects.filter(
                customer=self.customer_1,
                plan=self.plan_org_a,
                trainer=self.trainer,
                status="active"
            ).exists()
        )

    def test_assign_plan_different_organization_failure(self):
        """
        Trainer attempts to assign an organization-specific plan to a customer
        belonging to a different organization. This should fail.
        """
        url = f"/api/v1/trainer/workout-plans/{self.plan_org_a.id}/assign/"
        data = {"customer_id": self.customer_2.id}
        
        response = self.client.post(url, data, format="json")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        content = json.loads(response.content)
        self.assertIn("belongs to a specific fitness center", content["error"])

    def test_assign_personal_plan_success(self):
        """
        Trainer assigns their own personal workout plan to a customer in
        one of their linked organizations.
        """
        url = f"/api/v1/trainer/workout-plans/{self.plan_personal.id}/assign/"
        data = {"customer_id": self.customer_1.id}
        
        response = self.client.post(url, data, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(
            CustomerWorkoutPlan.objects.filter(
                customer=self.customer_1,
                plan=self.plan_personal,
                trainer=self.trainer,
                status="active"
            ).exists()
        )

    def test_assign_personal_plan_unauthorized_customer_failure(self):
        """
        Trainer attempts to assign a personal plan to a customer at a gym
        they are not linked to/approved at. This should fail.
        """
        url = f"/api/v1/trainer/workout-plans/{self.plan_personal.id}/assign/"
        data = {"customer_id": self.customer_2.id}
        
        response = self.client.post(url, data, format="json")
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        content = json.loads(response.content)
        self.assertIn("do not have permission", content["error"])

    def test_get_customers_for_assignment_org_plan(self):
        """
        Get request for organization-specific plan should list only customers
        belonging to that organization.
        """
        url = f"/api/v1/trainer/workout-plans/{self.plan_org_a.id}/assign/"
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        content = json.loads(response.content)
        customer_ids = [c["customer_id"] for c in content]
        self.assertIn(self.customer_1.id, customer_ids)
        self.assertNotIn(self.customer_2.id, customer_ids)

    def test_get_customers_for_assignment_personal_plan(self):
        """
        Get request for a personal plan should list customers from all of
        the trainer's linked organizations.
        """
        url = f"/api/v1/trainer/workout-plans/{self.plan_personal.id}/assign/"
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        content = json.loads(response.content)
        customer_ids = [c["customer_id"] for c in content]
        self.assertIn(self.customer_1.id, customer_ids)
        self.assertNotIn(self.customer_2.id, customer_ids)  # Org B customer not linked to trainer

    def test_trainer_reports(self):
        url = "/api/v1/trainer/reports/"
        response = self.client.get(url)
        print("TRAINER REPORTS RESP:", response.status_code, response.data if hasattr(response, 'data') else response.content)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('clients_trained_count', response.data)
        self.assertIn('workout_plans_given_count', response.data)
        self.assertIn('workouts_completed_count', response.data)
        self.assertIn('attendance_rate', response.data)
