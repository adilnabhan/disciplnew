from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from django.db.models import Sum
from datetime import date, timedelta
import csv
from django.http import HttpResponse

from apps.customers.models import Customer
from apps.customers.body_models import WeightLog, BodyMeasurementLog, ProgressPhoto
from apps.customers.nutrition_models import Food, FoodLog, WaterLog
from apps.customers.achievement_models import Badge, EarnedBadge, CustomerPoints
from apps.customers.community_models import CommunityPost, CommunityLike, CommunityComment
from apps.trainer.workout_models import WorkoutSession, WorkoutLog, ExerciseSetLog

from apps.customers.api.serializers_new import (
    WeightLogSerializer,
    BodyMeasurementLogSerializer,
    ProgressPhotoSerializer,
    FoodSerializer,
    FoodLogSerializer,
    WaterLogSerializer,
    BadgeSerializer,
    EarnedBadgeSerializer,
    CustomerPointsSerializer,
    CommunityPostSerializer,
    CommunityCommentSerializer
)

# Helper to calculate TDEE & Target Calories
def get_customer_calorie_targets(customer):
    bmr = float(customer.bmr) if customer.bmr else 1500.0
    active_scale = customer.active_scale or 5
    
    # Map active scale to TDEE multiplier
    if active_scale <= 2:
        multiplier = 1.2
    elif active_scale <= 5:
        multiplier = 1.375
    elif active_scale <= 7:
        multiplier = 1.55
    elif active_scale <= 9:
        multiplier = 1.725
    else:
        multiplier = 1.9
        
    tdee = bmr * multiplier
    
    # Adjust for weight goal
    goal = (customer.weight_goal or '').lower()
    if 'lose' in goal:
        target = tdee - 500
    elif 'gain' in goal:
        target = tdee + 500
    else:
        target = tdee
        
    return round(bmr, 1), round(tdee, 1), round(target, 1)

# ==========================================
# 1. CALORIE SUMMARY & TARGETS
# ==========================================

class CalorieSummaryView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            customer = request.user.customer
        except Customer.DoesNotExist:
            return Response({'detail': 'Customer profile not found.'}, status=404)

        today = timezone.localdate()
        
        # Calculate Targets
        bmr, tdee, target_calories = get_customer_calorie_targets(customer)
        
        # Calories Consumed Today
        consumed = FoodLog.objects.filter(
            customer=customer, 
            logged_at=today
        ).aggregate(
            total=Sum('servings')
        )['total'] or 0.0
        
        # Map servings to food calories
        food_logs = FoodLog.objects.filter(customer=customer, logged_at=today)
        consumed_calories = sum(float(log.food.calories) * float(log.servings) for log in food_logs)
        
        # Calories Burned Today (workouts completed today)
        completed_sessions = WorkoutSession.objects.filter(
            customer=customer,
            session_date=today,
            status='completed'
        )
        burned_calories = 0.0
        for session in completed_sessions:
            # Base burn
            session_burn = 250.0
            # Weight lifted bonus
            logs = WorkoutLog.objects.filter(session=session)
            for log in logs:
                sets = ExerciseSetLog.objects.filter(workout_log=log, is_completed=True)
                for s in sets:
                    weight = float(s.weight_kg) if s.weight_kg else 0.0
                    reps = s.reps or 0
                    session_burn += weight * reps * 0.05
            burned_calories += session_burn
            
        # Water Logged Today
        water_ml = WaterLog.objects.filter(
            customer=customer,
            logged_at=today
        ).aggregate(
            total=Sum('amount_ml')
        )['total'] or 0
        
        # Remaining
        remaining = target_calories - consumed_calories + burned_calories
        
        # Streak & XP (mock steps as 6500)
        points, _ = CustomerPoints.objects.get_or_create(customer=customer)
        
        return Response({
            "bmr": bmr,
            "tdee": tdee,
            "target_calories": target_calories,
            "consumed_calories": round(consumed_calories, 1),
            "burned_calories": round(burned_calories, 1),
            "remaining_calories": round(remaining, 1),
            "water_ml": water_ml,
            "steps": 6500,
            "streak": points.streak_days
        })

# ==========================================
# 2. FOOD & WATER LOGGING
# ==========================================

class FoodListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        query = request.query_params.get('q', '')
        foods = Food.objects.filter(name__icontains=query)
        serializer = FoodSerializer(foods, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = FoodSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(is_global=False)
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)

class FoodLogView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        date_str = request.query_params.get('date')
        logged_date = date.fromisoformat(date_str) if date_str else timezone.localdate()
        logs = FoodLog.objects.filter(customer=request.user.customer, logged_at=logged_date)
        serializer = FoodLogSerializer(logs, many=True)
        return Response(serializer.data)

    def post(self, request):
        try:
            customer = request.user.customer
        except Customer.DoesNotExist:
            return Response({'detail': 'Customer profile not found.'}, status=404)

        serializer = FoodLogSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(customer=customer)
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)

class FoodLogDeleteView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, pk):
        try:
            log = FoodLog.objects.get(pk=pk, customer=request.user.customer)
            log.delete()
            return Response(status=204)
        except FoodLog.DoesNotExist:
            return Response(status=404)

class WaterLogView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        date_str = request.query_params.get('date')
        logged_date = date.fromisoformat(date_str) if date_str else timezone.localdate()
        logs = WaterLog.objects.filter(customer=request.user.customer, logged_at=logged_date)
        serializer = WaterLogSerializer(logs, many=True)
        return Response(serializer.data)

    def post(self, request):
        try:
            customer = request.user.customer
        except Customer.DoesNotExist:
            return Response({'detail': 'Customer profile not found.'}, status=404)

        serializer = WaterLogSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(customer=customer)
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)

# ==========================================
# 3. WEIGHT & MEASUREMENTS
# ==========================================

class WeightLogView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        logs = WeightLog.objects.filter(customer=request.user.customer).order_by('-logged_at')
        serializer = WeightLogSerializer(logs, many=True)
        return Response(serializer.data)

    def post(self, request):
        try:
            customer = request.user.customer
        except Customer.DoesNotExist:
            return Response({'detail': 'Customer profile not found.'}, status=404)

        serializer = WeightLogSerializer(data=request.data)
        if serializer.is_valid():
            weight_log = serializer.save(customer=customer)
            # Update Customer profile weight
            customer.weight = weight_log.weight_kg
            customer.save()
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)

class BodyMeasurementLogView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        logs = BodyMeasurementLog.objects.filter(customer=request.user.customer).order_by('-logged_at')
        serializer = BodyMeasurementLogSerializer(logs, many=True)
        return Response(serializer.data)

    def post(self, request):
        try:
            customer = request.user.customer
        except Customer.DoesNotExist:
            return Response({'detail': 'Customer profile not found.'}, status=404)

        serializer = BodyMeasurementLogSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(customer=customer)
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)

class ProgressPhotoView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        photos = ProgressPhoto.objects.filter(customer=request.user.customer).order_by('-logged_at')
        serializer = ProgressPhotoSerializer(photos, many=True)
        return Response(serializer.data)

    def post(self, request):
        try:
            customer = request.user.customer
        except Customer.DoesNotExist:
            return Response({'detail': 'Customer profile not found.'}, status=404)

        serializer = ProgressPhotoSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(customer=customer)
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)

# ==========================================
# 4. COMMUNITY FEED
# ==========================================

class CommunityFeedView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            customer = request.user.customer
        except AttributeError:
            return Response({'detail': 'Customer profile not found.'}, status=404)

        if customer.organization:
            posts = CommunityPost.objects.filter(customer__organization=customer.organization).order_by('-created_at')
        else:
            posts = CommunityPost.objects.filter(customer__organization__isnull=True).order_by('-created_at')

        serializer = CommunityPostSerializer(posts, many=True, context={'request': request})
        return Response(serializer.data)

class CommunityPostCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            customer = request.user.customer
        except Customer.DoesNotExist:
            return Response({'detail': 'Customer profile not found.'}, status=404)

        serializer = CommunityPostSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(customer=customer)
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)

class CommunityPostLikeView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, post_id):
        try:
            customer = request.user.customer
            post = CommunityPost.objects.get(id=post_id)
        except (Customer.DoesNotExist, CommunityPost.DoesNotExist):
            return Response({'detail': 'Not found.'}, status=404)

        like_qs = CommunityLike.objects.filter(post=post, customer=customer)
        if like_qs.exists():
            like_qs.delete()
            return Response({"liked": False})
        else:
            CommunityLike.objects.create(post=post, customer=customer)
            return Response({"liked": True})

class CommunityPostCommentView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, post_id):
        try:
            customer = request.user.customer
            post = CommunityPost.objects.get(id=post_id)
        except (Customer.DoesNotExist, CommunityPost.DoesNotExist):
            return Response({'detail': 'Not found.'}, status=404)

        comment_text = request.data.get('comment_text')
        if not comment_text:
            return Response({'comment_text': 'This field is required.'}, status=400)

        comment = CommunityComment.objects.create(post=post, customer=customer, comment_text=comment_text)
        serializer = CommunityCommentSerializer(comment)
        return Response(serializer.data, status=201)

# ==========================================
# 5. ACHIEVEMENTS & POINTS
# ==========================================

class AchievementsSummaryView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            customer = request.user.customer
        except Customer.DoesNotExist:
            return Response({'detail': 'Customer profile not found.'}, status=404)

        points, _ = CustomerPoints.objects.get_or_create(customer=customer)
        earned = EarnedBadge.objects.filter(customer=customer)
        
        points_data = CustomerPointsSerializer(points).data
        earned_data = EarnedBadgeSerializer(earned, many=True).data
        
        # Load all available badges
        badges = Badge.objects.all()
        badges_data = BadgeSerializer(badges, many=True).data

        return Response({
            "points": points_data,
            "earned_badges": earned_data,
            "all_badges": badges_data
        })

# ==========================================
# 6. REPORTS & BMR/BMI ANALYSIS
# ==========================================

def get_reports_summary_data(customer, days=7):
    today = timezone.localdate()
    start_date = today - timedelta(days=days)
    
    # Calorie log history
    food_logs = FoodLog.objects.filter(customer=customer, logged_at__range=[start_date, today])
    daily_calories = {}
    for log in food_logs:
        date_str = str(log.logged_at)
        daily_calories[date_str] = daily_calories.get(date_str, 0.0) + float(log.food.calories) * float(log.servings)
        
    # Weight log history
    weight_logs = WeightLog.objects.filter(customer=customer, logged_at__range=[start_date, today]).order_by('logged_at')
    weights = {str(log.logged_at): float(log.weight_kg) for log in weight_logs}
    
    # Calculate current BMI & BMR
    bmi = float(customer.bmi) if customer.bmi else 0.0
    bmr = float(customer.bmr) if customer.bmr else 0.0
    
    # Generate BMR/BMI analysis
    bmi_category = "Unknown"
    bmi_analysis = "Please configure your height/weight to view BMI analysis."
    if bmi > 0:
        if bmi < 18.5:
            bmi_category = "Underweight"
            bmi_analysis = "Your BMI is underweight. Consider working with your trainer to design a muscle-gain workout plan and caloric surplus diet."
        elif bmi < 25.0:
            bmi_category = "Normal"
            bmi_analysis = "Great job! Your BMI falls within the healthy, normal range. Focus on maintaining consistency and strength."
        elif bmi < 30.0:
            bmi_category = "Overweight"
            bmi_analysis = "Your BMI falls in the overweight range. Consider keeping a caloric deficit, adding HIIT or cardio, and tracking food macros."
        else:
            bmi_category = "Obese"
            bmi_analysis = "Your BMI falls in the obese range. We suggest building a sustainable long-term caloric deficit plan and regular cardio training."

    return {
        "calories_history": daily_calories,
        "weight_history": weights,
        "current_bmi": bmi,
        "current_bmr": bmr,
        "bmi_category": bmi_category,
        "bmi_analysis": bmi_analysis
    }

class DailyReportView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            customer = request.user.customer
        except Customer.DoesNotExist:
            return Response({'detail': 'Customer profile not found.'}, status=404)

        data = get_reports_summary_data(customer, days=1)
        return Response(data)

class WeeklyReportView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            customer = request.user.customer
        except Customer.DoesNotExist:
            return Response({'detail': 'Customer profile not found.'}, status=404)

        data = get_reports_summary_data(customer, days=7)
        return Response(data)

class MonthlyReportView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            customer = request.user.customer
        except Customer.DoesNotExist:
            return Response({'detail': 'Customer profile not found.'}, status=404)

        data = get_reports_summary_data(customer, days=30)
        return Response(data)

# Export Report (CSV format download)
class ExportReportView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            customer = request.user.customer
        except Customer.DoesNotExist:
            return Response({'detail': 'Customer profile not found.'}, status=404)

        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = f'attachment; filename="discipl_fitness_report_{date.today()}.csv"'

        writer = csv.writer(response)
        writer.writerow(['Discipl Fitness Progress Report'])
        writer.writerow(['Customer Name', customer.user.full_name if customer.user else 'Unknown'])
        writer.writerow(['Report Date', date.today()])
        writer.writerow([])
        
        # BMR / BMI
        bmi = float(customer.bmi) if customer.bmi else 0.0
        bmr = float(customer.bmr) if customer.bmr else 0.0
        writer.writerow(['Health Analytics'])
        writer.writerow(['BMR (Basal Metabolic Rate)', f"{bmr} kcal"])
        writer.writerow(['BMI (Body Mass Index)', bmi])
        writer.writerow([])

        # Weight logs
        writer.writerow(['Weight Progress Log'])
        writer.writerow(['Date', 'Weight (kg)'])
        w_logs = WeightLog.objects.filter(customer=customer).order_by('logged_at')
        for log in w_logs:
            writer.writerow([log.logged_at, log.weight_kg])
        writer.writerow([])

        # Nutrition logs
        writer.writerow(['Nutrition Log (Last 30 Days)'])
        writer.writerow(['Date', 'Food Name', 'Meal Type', 'Servings', 'Calories per serving'])
        f_logs = FoodLog.objects.filter(customer=customer, logged_at__gte=timezone.localdate() - timedelta(days=30)).order_by('logged_at')
        for log in f_logs:
            writer.writerow([log.logged_at, log.food.name, log.meal_type, log.servings, log.food.calories])

        return response


class CustomerBmrBmiView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            customer = request.user.customer
        except AttributeError:
            return Response({'error': 'Customer profile not found.'}, status=404)

        bmr, tdee, target = get_customer_calorie_targets(customer)
        bmi = float(customer.bmi) if customer.bmi else 0.0
        bmi_cat = customer.bmi_category or "Unknown"

        return Response({
            'bmi': bmi,
            'bmi_category': bmi_cat,
            'bmr': bmr,
            'tdee': tdee,
            'goal_calories': target,
            'weight_kg': float(customer.weight) if customer.weight else None,
            'height_m': float(customer.height) / 100.0 if customer.height else None,
            'weight_goal': customer.weight_goal or "maintain"
        })


class CustomerWorkoutSummaryView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            customer = request.user.customer
        except AttributeError:
            return Response({'error': 'Customer profile not found.'}, status=404)

        sessions = WorkoutSession.objects.filter(customer=customer, status='completed')
        total_workouts = sessions.count()

        # Calculate total sets, reps, volume, duration, and calories burned
        total_sets = 0
        total_reps = 0
        total_volume = 0.0
        total_duration_minutes = 0.0
        total_calories_burned = 0.0

        for session in sessions:
            if session.completed_at and session.started_at:
                duration_mins = (session.completed_at - session.started_at).total_seconds() / 60.0
                total_duration_minutes += duration_mins
            else:
                total_duration_minutes += 30.0 # Default fallback

            set_logs = ExerciseSetLog.objects.filter(workout_log__session=session, is_completed=True)
            for s in set_logs:
                total_sets += 1
                reps = s.reps or 0
                weight = float(s.weight_kg) if s.weight_kg else 0.0
                total_reps += reps
                total_volume += reps * weight

        total_calories_burned = total_duration_minutes * 6.0

        return Response({
            'total_workouts': total_workouts,
            'total_sets': total_sets,
            'total_reps': total_reps,
            'total_volume': round(total_volume, 2),
            'total_duration_minutes': round(total_duration_minutes, 1),
            'total_calories_burned': round(total_calories_burned, 1)
        })
