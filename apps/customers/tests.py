from rest_framework.test import APITestCase
from django.urls import reverse
from django.contrib.auth import get_user_model
from apps.customers.models import Customer
from apps.customers.body_models import WeightLog
from apps.customers.nutrition_models import Food, FoodLog, WaterLog
from apps.customers.community_models import CommunityPost
from apps.customers.achievement_models import Badge, EarnedBadge, CustomerPoints

User = get_user_model()

class CustomerFeaturesTestCase(APITestCase):
    def setUp(self):
        # Create user
        self.user = User.objects.create_user(
            username="testuser",
            password="testpassword",
            mobile_number="+919999999999",
            user_role=45 # Customer role
        )
        
        # Retrieve auto-created customer and update fields
        if hasattr(self.user, 'customer'):
            self.customer = self.user.customer
            self.customer.height = 180.0
            self.customer.weight = 75.0
            self.customer.active_scale = 5
            self.customer.weight_goal = "Maintain"
            self.customer.save()
        else:
            self.customer = Customer.objects.create(
                user=self.user,
                height=180.0,
                weight=75.0,
                active_scale=5,
                weight_goal="Maintain"
            )
            
        # Auth client
        self.client.login(username="testuser", password="testpassword")
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer mock_token", HTTP_X_PLATFORM="customer-app-android")
        self.client.force_authenticate(user=self.user)

    def test_calorie_summary(self):
        url = reverse('calorie-summary')
        response = self.client.get(url)
        print("DEBUG RESPONSE:", response.status_code, response.data if hasattr(response, 'data') else response.content)
        self.assertEqual(response.status_code, 200)
        self.assertIn('bmr', response.data)
        self.assertIn('target_calories', response.data)

    def test_food_logging(self):
        # Create food
        food = Food.objects.create(name="Apple", calories=95, serving_size="1 medium")
        
        # Get list
        url_list = reverse('food-list')
        resp = self.client.get(url_list, {"q": "Apple"})
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(len(resp.data), 1)

        # Log food
        url_log = reverse('food-log')
        log_data = {
            "food": food.id,
            "meal_type": "snack",
            "servings": 1.5
        }
        resp_log = self.client.post(url_log, log_data)
        self.assertEqual(resp_log.status_code, 201)
        self.assertEqual(FoodLog.objects.filter(customer=self.customer).count(), 1)

    def test_water_logging(self):
        url = reverse('water-log')
        resp = self.client.post(url, {"amount_ml": 500})
        self.assertEqual(resp.status_code, 201)
        self.assertEqual(WaterLog.objects.filter(customer=self.customer).count(), 1)

    def test_weight_logging(self):
        url = reverse('weight-history')
        resp = self.client.post(url, {"weight_kg": 76.5})
        self.assertEqual(resp.status_code, 201)
        self.assertEqual(WeightLog.objects.filter(customer=self.customer).count(), 1)
        self.customer.refresh_from_db()
        self.assertEqual(float(self.customer.weight), 76.5)

    def test_community_feed(self):
        # Create post
        post = CommunityPost.objects.create(
            customer=self.customer,
            post_type="custom",
            caption="Morning workout done!"
        )
        
        # Get feed
        url_feed = reverse('community-feed')
        resp = self.client.get(url_feed)
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(len(resp.data), 1)

        # Like post
        url_like = reverse('community-post-like', kwargs={"post_id": post.id})
        resp_like = self.client.post(url_like)
        self.assertEqual(resp_like.status_code, 200)
        self.assertTrue(resp_like.data['liked'])

        # Comment post
        url_comment = reverse('community-post-comment', kwargs={"post_id": post.id})
        resp_comment = self.client.post(url_comment, {"comment_text": "Nice work!"})
        self.assertEqual(resp_comment.status_code, 201)

    def test_achievements(self):
        # Create points & badges
        points = CustomerPoints.objects.create(customer=self.customer, xp=100, coins=20)
        badge = Badge.objects.create(name="First Workout", description="Completed your first workout", xp_reward=50)
        EarnedBadge.objects.create(customer=self.customer, badge=badge)

        url = reverse('achievements-summary')
        resp = self.client.get(url)
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.data['points']['xp'], 100)
        self.assertEqual(len(resp.data['earned_badges']), 1)

    def test_reports(self):
        url_daily = reverse('daily-report')
        resp_daily = self.client.get(url_daily)
        self.assertEqual(resp_daily.status_code, 200)
        self.assertIn('bmi_category', resp_daily.data)

        url_export = reverse('export-report')
        resp_export = self.client.get(url_export)
        self.assertEqual(resp_export.status_code, 200)
        self.assertEqual(resp_export['Content-Type'], 'text/csv')

    def test_bmi_bmr_view(self):
        url = reverse('customer-bmi-bmr')
        response = self.client.get(url)
        print("BMI BMR RESP:", response.status_code, response.data if hasattr(response, 'data') else response.content)
        self.assertEqual(response.status_code, 200)
        self.assertIn('bmi', response.data)
        self.assertIn('bmr', response.data)
        self.assertIn('tdee', response.data)
        self.assertIn('goal_calories', response.data)

    def test_workout_summary_view(self):
        url = reverse('customer-workout-summary')
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)
        self.assertIn('total_workouts', response.data)
        self.assertIn('total_volume', response.data)
        self.assertIn('total_duration_minutes', response.data)
