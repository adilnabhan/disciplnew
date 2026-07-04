from django.urls import path, include
from rest_framework.routers import DefaultRouter

from apps.customers.api.views import ActiveCustomerMembershipAPIView, CustomerCreateView, CustomerDetailView, CustomerHomePageAPIView, CustomerMembershipOrganizationListAPIView, CustomerMembershipRequestListView, CustomerPaymentDetailHistoryAPIView, CustomerPaymentHistoryAPIView, CustomerReviewViewSet, CustomerUpdateView, MembershipRequestCreateView, NearestFitnessCenterListAPIView, OrganizationDetailAPIView, OrganizationMembershipPlansAPIView, UpdateCustomerHealthAPIView, get_injuries, get_medical_conditions, ChoicesAPIView
from apps.customers.api.workout_views import (
    CustomerExerciseBrowseView,
    CustomerExerciseSwapView,
    CustomerWorkoutCalendarView,
    CustomerAssignedPlanDaysView,
    CustomerPlanDayDetailView,
    StartWorkoutSessionView,
    UpdateSetLogView,
    AddSetToLogView,
    BulkUpdateWorkoutLogSetsView,
    FinishWorkoutSessionView,
    CustomerWorkoutPlanListCreateView,
    CustomerWorkoutPlanDetailView as CustomerWorkoutPlanDetailCRUDView,
    CustomerPlanDayListCreateView,
    CustomerPlanDayEditDeleteView,
    CustomerDayExerciseListCreateView,
    CustomerDayExerciseDetailView,
    ActiveWorkoutSessionView,
    AddExerciseToActiveSessionView,
    RemoveExerciseFromActiveSessionView,
    CustomerMuscleGroupListView,
    CustomerEquipmentListView,
    CustomerExerciseDetailView,
    ToggleRestDayView,
    WorkoutSessionDetailView,
    CustomerPresetListCreateView,
    CustomerPresetDetailView,
    CustomerAssignedWorkoutListView,
    CustomerAssignedWorkoutDetailView,
    CustomerAssignedWorkoutSessionView,
    CustomerOwnWorkoutHistoryView,
)
from apps.customers.api.views_new import (
    CalorieSummaryView,
    FoodListView,
    FoodLogView,
    FoodLogDeleteView,
    WaterLogView,
    WeightLogView,
    BodyMeasurementLogView,
    ProgressPhotoView,
    CommunityFeedView,
    CommunityPostCreateView,
    CommunityPostLikeView,
    CommunityPostCommentView,
    AchievementsSummaryView,
    DailyReportView,
    WeeklyReportView,
    MonthlyReportView,
    ExportReportView,
    CustomerBmrBmiView,
    CustomerWorkoutSummaryView
)


router = DefaultRouter()
router.register(r'reviews', CustomerReviewViewSet, basename='customer-review')

urlpatterns = [
    path('', include(router.urls)),
    path('common/', include([
        path('injuries/', get_injuries, name='all-injuries'),
        path('medical-conditions/', get_medical_conditions, name='all-medical-conditions'),
    ])),
    path('manage/', include([
        path('create/', CustomerCreateView.as_view(), name='customer-create'),
        path('<int:pk>/', CustomerDetailView.as_view(), name='customer-detail'),
        path('<int:pk>/update/', CustomerUpdateView.as_view(), name='customer-update'),
        path('profile/health/', UpdateCustomerHealthAPIView.as_view(), name='update-customer-health'),
        path('<int:customer_id>/active-membership/', ActiveCustomerMembershipAPIView.as_view(), name='customer-active-membership'),
    ])),
    path('nearest/', include([
        path('fitnesscenter/', NearestFitnessCenterListAPIView.as_view(), name='nearest-fitnesscenter'),
        path('fitnesscenter/<int:id>/', OrganizationDetailAPIView.as_view(), name='nearest-fitnesscenter-detail')
    ])),
    path('membership-plans/<int:organization_id>/', OrganizationMembershipPlansAPIView.as_view(), name='organization-membership-plans'),
    path('membership-org/', CustomerMembershipOrganizationListAPIView.as_view(), name='all-membership-org'),
    path('payment-history/', CustomerPaymentHistoryAPIView.as_view(), name='customer-payment-history'),
    path('payment-detail-history/', CustomerPaymentDetailHistoryAPIView.as_view(), name='customer-payment-detail-history'),
    path('customer-homepage/', CustomerHomePageAPIView.as_view(), name='customer-homepage'),

    
    path('constant-choices/', ChoicesAPIView.as_view(), name='profession-choices'),

    # Workout Log (existing - read/session)
    path('exercises/', CustomerExerciseBrowseView.as_view(), name='customer-exercise-browse'),
    path('exercises/detail/', CustomerExerciseDetailView.as_view(), name='customer-exercise-detail'),
    path('exercises/detail', CustomerExerciseDetailView.as_view()),
    path('exercises/detail/<str:title>/', CustomerExerciseDetailView.as_view(), name='customer-exercise-detail-by-title'),
    path('exercises/detail/<str:title>', CustomerExerciseDetailView.as_view()),
    path('exercises/<int:pk>/', CustomerExerciseDetailView.as_view(), name='customer-exercise-detail-by-id'),
    path('exercises/<int:pk>', CustomerExerciseDetailView.as_view()),
    path('exercises/swap/', CustomerExerciseSwapView.as_view(), name='customer-exercise-swap'),
    path('workout-log/', CustomerWorkoutCalendarView.as_view()),
    path('workout-calendar/', CustomerWorkoutCalendarView.as_view()),
    path('workout-plans/<int:cwp_id>/days/', CustomerAssignedPlanDaysView.as_view()),
    path('plan-days/<int:plan_day_id>/', CustomerPlanDayDetailView.as_view()),
    path('sessions/start/', StartWorkoutSessionView.as_view()),
    path('sessions/active/', ActiveWorkoutSessionView.as_view()),
    path('sessions/active/exercises/', AddExerciseToActiveSessionView.as_view()),
    path('sessions/active/exercises/<int:log_id>/', RemoveExerciseFromActiveSessionView.as_view()),
    path('sessions/rest-day/', ToggleRestDayView.as_view()),
    path('sessions/<int:session_id>/', WorkoutSessionDetailView.as_view()),
    path('sessions/<int:session_id>/finish/', FinishWorkoutSessionView.as_view()),
    path('set-logs/<int:set_log_id>/', UpdateSetLogView.as_view()),
    path('workout-logs/<int:log_id>/', RemoveExerciseFromActiveSessionView.as_view()),
    path('workout-logs/<int:log_id>/sets/', AddSetToLogView.as_view()),
    path('workout-logs/<int:log_id>/sets/bulk/', BulkUpdateWorkoutLogSetsView.as_view(), name='bulk-update-log-sets'),
    path('muscle-groups/', CustomerMuscleGroupListView.as_view()),
    path('equipment/', CustomerEquipmentListView.as_view()),
    path('presets/', CustomerPresetListCreateView.as_view(), name='customer-presets'),
    path('presets/<int:preset_id>/', CustomerPresetDetailView.as_view(), name='customer-preset-detail'),

    # Assigned Workouts
    path('assigned-workouts/', CustomerAssignedWorkoutListView.as_view()),
    path('assigned-workouts/<int:cwp_id>/', CustomerAssignedWorkoutDetailView.as_view()),
    path('assigned-workouts/<int:cwp_id>/start-session/', CustomerAssignedWorkoutSessionView.as_view()),

    # Workout History
    path('workout-history/', CustomerOwnWorkoutHistoryView.as_view()),

    # Customer Workout Plan CRUD (NEW)
    path('my-plans/', CustomerWorkoutPlanListCreateView.as_view(), name='customer-plan-list-create'),
    path('my-plans/<int:plan_id>/', CustomerWorkoutPlanDetailCRUDView.as_view(), name='customer-plan-detail'),
    path('my-plans/<int:plan_id>/days/', CustomerPlanDayListCreateView.as_view(), name='customer-plan-days'),
    path('my-plans/<int:plan_id>/days/<int:day_id>/', CustomerPlanDayEditDeleteView.as_view(), name='customer-plan-day-detail'),
    path('my-plans/day/<int:day_id>/exercises/', CustomerDayExerciseListCreateView.as_view(), name='customer-day-exercises'),
    path('my-plans/day/<int:day_id>/exercises/<int:exercise_id>/', CustomerDayExerciseDetailView.as_view(), name='customer-day-exercise-detail'),

    # Membership Request endpoints
    path('membership-request/', include([
        path('create/', MembershipRequestCreateView.as_view(), name='membership-request-create'),
        path('list/', CustomerMembershipRequestListView.as_view(), name='membership-request-list'),
    ])),

    # New Customer Features (Calorie, Nutrition, Body, Community, Achievements, Reports)
    path('calorie-summary/', CalorieSummaryView.as_view(), name='calorie-summary'),
    path('food/', FoodListView.as_view(), name='food-list'),
    path('food-log/', FoodLogView.as_view(), name='food-log'),
    path('food-log/<int:pk>/', FoodLogDeleteView.as_view(), name='food-log-delete'),
    path('water-log/', WaterLogView.as_view(), name='water-log'),
    path('weight-history/', WeightLogView.as_view(), name='weight-history'),
    path('measurements/', BodyMeasurementLogView.as_view(), name='measurements'),
    path('progress-photos/', ProgressPhotoView.as_view(), name='progress-photos'),
    path('community/feed/', CommunityFeedView.as_view(), name='community-feed'),
    path('community/posts/', CommunityPostCreateView.as_view(), name='community-post-create'),
    path('community/posts/<int:post_id>/like/', CommunityPostLikeView.as_view(), name='community-post-like'),
    path('community/posts/<int:post_id>/comment/', CommunityPostCommentView.as_view(), name='community-post-comment'),
    path('achievements/', AchievementsSummaryView.as_view(), name='achievements-summary'),
    path('reports/daily/', DailyReportView.as_view(), name='daily-report'),
    path('reports/weekly/', WeeklyReportView.as_view(), name='weekly-report'),
    path('reports/monthly/', MonthlyReportView.as_view(), name='monthly-report'),
    path('reports/export/', ExportReportView.as_view(), name='export-report'),
    path('bmi-bmr/', CustomerBmrBmiView.as_view(), name='customer-bmi-bmr'),
    path('workout-summary/', CustomerWorkoutSummaryView.as_view(), name='customer-workout-summary'),
]
