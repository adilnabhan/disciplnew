from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from apps.fitnesscenter.models import Organization, PromotionalBanner
from apps.trainer.models import Trainer
from apps.customers.models import Customer

User = get_user_model()

class FitnessCenterReportsAndBannersTests(APITestCase):

    def setUp(self):
        # Configure default client headers
        self.client.credentials(HTTP_X_PLATFORM='mentor-app-android')

        # 1. Create a mentor user
        self.mentor_user = User.objects.create_user(
            username='mentor_user',
            email='mentor@discipl.com',
            password='password123',
            user_role=User.MENTOR,
            first_name='Gym',
            last_name='Owner'
        )
        
        # 2. Create organization
        from apps.mentors.models import MentorProfile
        self.mentor_profile = MentorProfile.objects.get(user=self.mentor_user)
        
        self.org = Organization.objects.create(
            name='Elite Fitness Center',
            mentor=self.mentor_profile,
            email='elite@fitness.com',
            phone_number='+919876543210'
        )
        self.mentor_profile.organizations.add(self.org)

        # 3. Create regular/customer user
        self.customer_user = User.objects.create_user(
            username='customer_user',
            email='client@discipl.com',
            password='password123',
            user_role=User.CUSTOMER,
            first_name='John',
            last_name='Doe'
        )
        self.customer = Customer.objects.get(user=self.customer_user)
        self.customer.organization = self.org
        self.customer.fitness_level = 'intermediate'
        self.customer.weight_goal = 'maintain_weight'
        self.customer.save()

    def test_banner_list_and_create(self):
        # Create banner anonymously (should be allowed for GET)
        url = reverse('promotional-banner-list-create')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        # Attempt to create banner anonymously (should fail)
        data = {
            'title': 'Grand Opening Offer',
            'banner_type': 'promotional',
            'external_link': 'https://discipl.com/elite-offer',
            'is_active': True
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

        # Authenticate as mentor
        self.client.force_authenticate(user=self.mentor_user)
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['title'], 'Grand Opening Offer')
        self.assertEqual(response.data['organization_name'], 'Elite Fitness Center')

        # Retrieve active banners list
        self.client.logout()
        self.client.credentials(HTTP_X_PLATFORM='mentor-app-android')
        response = self.client.get(url)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['title'], 'Grand Opening Offer')

    def test_advanced_reports_view(self):
        url = reverse('advanced-reports')
        
        # Access anonymously (should fail)
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

        # Access as customer (should fail since it requires MentorOnlyPermission)
        self.client.force_authenticate(user=self.customer_user)
        response = self.client.get(url, {'organization_id': self.org.id})
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

        # Access as mentor (should succeed)
        self.client.force_authenticate(user=self.mentor_user)
        response = self.client.get(url, {'organization_id': self.org.id})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verify the structure of the analytics response
        self.assertIn('financial_metrics', response.data)
        self.assertIn('client_demographics', response.data)
        self.assertIn('goals_insights', response.data)
        self.assertIn('health_profiles', response.data)
        self.assertIn('attendance_patterns', response.data)
        self.assertIn('trainers_performance', response.data)

        self.assertEqual(response.data['client_demographics']['total_clients'], 1)
        self.assertEqual(response.data['goals_insights']['weight_goals']['maintain_weight']['count'], 1)
        self.assertEqual(response.data['goals_insights']['weight_goals']['maintain_weight']['percentage'], '100.0%')
        self.assertEqual(response.data['financial_metrics']['total_revenue'], 0.0)


class AffiliateMarketingTests(APITestCase):

    def setUp(self):
        self.client.credentials(HTTP_X_PLATFORM='mentor-app-android')

        # Mentor user
        self.mentor_user = User.objects.create_user(
            username='aff_mentor',
            email='affmentor@discipl.com',
            password='password123',
            user_role=User.MENTOR,
            first_name='Affiliate',
            last_name='Mentor'
        )

        # Organization
        from apps.mentors.models import MentorProfile
        self.mentor_profile = MentorProfile.objects.get(user=self.mentor_user)
        self.org = Organization.objects.create(
            name='Affiliate Test Gym',
            mentor=self.mentor_profile,
            email='affgym@test.com',
            phone_number='+919999999999'
        )

        # Customer user (for permission checks)
        self.customer_user = User.objects.create_user(
            username='aff_customer',
            email='affcust@discipl.com',
            password='password123',
            user_role=User.CUSTOMER,
            first_name='Test',
            last_name='Customer'
        )

    def test_sales_executive_crud(self):
        url = reverse('sales-executive-list-create')

        # Unauthenticated
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

        # Customer (forbidden)
        self.client.force_authenticate(user=self.customer_user)
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

        # Mentor - create executive
        self.client.force_authenticate(user=self.mentor_user)
        data = {'name': 'Rahul Sales', 'phone': '+919876543210', 'email': 'rahul@exec.com'}
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['name'], 'Rahul Sales')
        self.assertEqual(response.data['organization_name'], 'Affiliate Test Gym')
        exec_id = response.data['id']

        # List executives
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)

        # Update
        detail_url = reverse('sales-executive-detail', args=[exec_id])
        response = self.client.put(detail_url, {'name': 'Rahul Updated'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['name'], 'Rahul Updated')

        # Delete (soft deactivate)
        response = self.client.delete(detail_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_coupon_crud(self):
        url = reverse('coupon-list-create')
        self.client.force_authenticate(user=self.mentor_user)

        # Create coupon
        from django.utils import timezone
        from datetime import timedelta
        data = {
            'code': 'TESTDISCOUNT20',
            'discount_type': 'percentage',
            'discount_value': 20.00,
            'share_type': 'percentage',
            'share_value': 10.00,
            'max_usage': 100,
            'valid_from': timezone.now().isoformat(),
            'valid_to': (timezone.now() + timedelta(days=30)).isoformat(),
            'is_active': True
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['code'], 'TESTDISCOUNT20')
        self.assertEqual(response.data['organization_name'], 'Affiliate Test Gym')
        coupon_id = response.data['id']

        # List coupons
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['remaining_usage'], 100)
        self.assertFalse(response.data[0]['is_expired'])

        # Update
        detail_url = reverse('coupon-detail', args=[coupon_id])
        response = self.client.put(detail_url, {'discount_value': 25.00}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(float(response.data['discount_value']), 25.00)

        # Delete (soft deactivate)
        response = self.client.delete(detail_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_affiliate_dashboard(self):
        url = reverse('affiliate-dashboard')
        self.client.force_authenticate(user=self.mentor_user)

        # Missing org_id
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

        # Valid org_id
        response = self.client.get(url, {'organization_id': self.org.id})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('total_executives', response.data)
        self.assertIn('total_active_coupons', response.data)
        self.assertIn('total_commission_earned', response.data)
        self.assertIn('total_commission_pending', response.data)
        self.assertIn('total_commission_paid', response.data)
        self.assertIn('top_executives', response.data)
        self.assertIn('top_coupons', response.data)

    def test_affiliate_transactions(self):
        url = reverse('affiliate-transactions')
        self.client.force_authenticate(user=self.mentor_user)

        response = self.client.get(url, {'organization_id': self.org.id})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsInstance(response.data, list)

    def test_mark_commission_paid(self):
        url = reverse('affiliate-mark-paid')
        self.client.force_authenticate(user=self.mentor_user)

        # Empty list should fail
        response = self.client.post(url, {'transaction_ids': []}, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

        # Non-existent IDs should return 0 updated
        response = self.client.post(url, {'transaction_ids': [99999]}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['updated_count'], 0)

    def test_customer_checkout_with_coupon(self):
        from apps.fitnesscenter.models import MembershipPlan, BankAccountDetails
        from apps.user.models import SalesExecutive, Coupon, SubscriptionTransaction
        from apps.customers.models import Customer, CustomerMembershipTransaction, CustomerMembership
        from django.urls import reverse

        # Setup Bank Details for organization
        bank_details = BankAccountDetails.objects.create(
            organization=self.org,
            bank_name="Test Bank",
            account_number="1234567890",
            ifsc_code="ABCD0123456",
            account_holder_name="Gym Owner",
            razorpay_account_id="acc_12345"
        )

        # Create or retrieve customer profile for the customer user
        customer, _ = Customer.objects.get_or_create(
            user=self.customer_user,
            defaults={'is_active_member': False}
        )

        # Create a membership plan with mocked Razorpay API plan creation
        from unittest.mock import patch
        with patch('apps.fitnesscenter.models.create_razorpay_base_plan') as mock_base_plan:
            mock_base_plan.return_value = (True, None)
            plan = MembershipPlan.objects.create(
                organization=self.org,
                name="Super Pack",
                package_type="Monthly Plan",
                actual_price=2000.00,
                offer_price=1000.00,
                duration_days=30,
                is_active=True
            )

        # Create sales executive
        exec_obj = SalesExecutive.objects.create(
            organization=self.org,
            name="John Executive",
            phone="+919999999999",
            email="john@exec.com",
            is_active=True
        )

        # Create a percentage-based 100% discount coupon (free plan checkout)
        from django.utils import timezone
        coupon_free = Coupon.objects.create(
            organization=self.org,
            code="FREE100",
            discount_type="percentage",
            discount_value=100.00,
            share_type="percentage",
            share_value=10.00,
            sales_executive=exec_obj,
            is_active=True,
            valid_from=timezone.now(),
            valid_to=timezone.now() + timezone.timedelta(days=30)
        )

        # Create a 20% discount coupon for paid order
        coupon_discount = Coupon.objects.create(
            organization=self.org,
            code="SAVE20",
            discount_type="percentage",
            discount_value=20.00,
            share_type="fixed",
            share_value=50.00,
            sales_executive=exec_obj,
            is_active=True,
            valid_from=timezone.now(),
            valid_to=timezone.now() + timezone.timedelta(days=30)
        )

        checkout_url = reverse('create-razorpay-customer-order')

        # 1. Free plan checkout with coupon FREE100
        self.client.force_authenticate(user=self.customer_user)
        response = self.client.post(checkout_url, {
            'plan_id': plan.id,
            'coupon_code': 'FREE100'
        }, format='json')

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data['is_free_plan'])
        self.assertEqual(float(response.data['amount']), 0)

        # Verify CustomerMembership is active
        membership = CustomerMembership.objects.get(customer=customer)
        self.assertEqual(membership.status, 'Active')
        self.assertEqual(membership.payment_status, 'completed')
        self.assertTrue(membership.is_active)

        # Verify coupon count incremented
        coupon_free.refresh_from_db()
        self.assertEqual(coupon_free.used_count, 1)

        # Verify sales executive commission is logged
        sub_txn = SubscriptionTransaction.objects.filter(coupon=coupon_free).first()
        self.assertIsNotNone(sub_txn)
        self.assertEqual(sub_txn.final_amount, 0)
        self.assertEqual(sub_txn.original_amount, 1000.00)
        self.assertEqual(sub_txn.executive_commission, 0)

        # Clean memberships and transactions for paid test
        CustomerMembership.objects.all().delete()
        CustomerMembershipTransaction.objects.all().delete()
        SubscriptionTransaction.objects.all().delete()
        customer.is_active_member = False
        customer.save()

        # 2. Paid checkout with coupon SAVE20
        # This will call Razorpay Mock or try to create it. We can mock it or because it's a test client, 
        # it will make the Razorpay API call. Let's mock razorpay Client.order.create
        from unittest.mock import patch
        with patch('razorpay.Client') as mock_razorpay:
            instance = mock_razorpay.return_value
            instance.order.create.return_value = {
                "id": "order_paid_123",
                "status": "created",
                "amount": 80000
            }

            response = self.client.post(checkout_url, {
                'plan_id': plan.id,
                'coupon_code': 'SAVE20'
            }, format='json')

            self.assertEqual(response.status_code, status.HTTP_201_CREATED)
            self.assertFalse(response.data['is_free_plan'])
            self.assertEqual(response.data['order_id'], "order_paid_123")
            self.assertEqual(float(response.data['amount']), 800.00)

            # Verify transaction stored in status pending
            txn = CustomerMembershipTransaction.objects.get(order_id="order_paid_123")
            self.assertEqual(txn.status, "Pending")
            self.assertEqual(txn.coupon, coupon_discount)
            self.assertEqual(txn.amount, 800.00)
