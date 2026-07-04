from django.urls import path
from .views import (
    MuscleGroupListView,
    EquipmentListView,
    WorkoutTypesView,
    WorkoutListCreateView,
    WorkoutDetailView,
    WorkoutGroupListCreateView,
    WorkoutGroupDetailView,
    WorkoutPlanListCreateView,
    WorkoutPlanDetailView,
    WorkoutPlanDayListCreateView,
    WorkoutPlanDayDetailView,
    PlanDayExerciseListCreateView,
    PlanDayExerciseDetailView,
    ReorderPlanDayExercisesView,
    AssignWorkoutPlanView,
    WorkoutLogCreateView,
    CustomerWorkoutHistoryView,
    PRRecordListCreateView,
    TrainerSubscriptionPlansView,
    TrainerLinkRequestView,
    OrganizationLinkRequestsView,
    TrainerDashboardView,
    TrainerCustomerListView,
    TrainerClientDetailView,
    TrainerReviewView,
    TrainerPublicProfileView,
    TrainerAllReviewsView,
    TrainerWorkoutOverrideView,
    TrainerReportsView,
)

urlpatterns = [
    # Reports
    path('reports/', TrainerReportsView.as_view(), name='trainer-reports'),

    # Dashboard
    path('dashboard/', TrainerDashboardView.as_view(), name='trainer-dashboard'),

    # Public profile
    path('trainers/<int:trainer_id>/public-profile/', TrainerPublicProfileView.as_view(), name='trainer-public-profile'),

    # Reviews
    path('trainers/<int:trainer_id>/reviews/', TrainerReviewView.as_view(), name='trainer-review'),
    path('trainers/<int:trainer_id>/reviews/all/', TrainerAllReviewsView.as_view(), name='trainer-all-reviews'),

    # Subscription plans
    path('subscription-plans/', TrainerSubscriptionPlansView.as_view(), name='trainer-subscription-plans'),

    # Organization link requests (trainer side)
    path('link-requests/', TrainerLinkRequestView.as_view(), name='trainer-link-request'),

    # Organization link requests (org side)
    path('organizations/<int:organization_id>/link-requests/', OrganizationLinkRequestsView.as_view(), name='org-link-requests'),
    path('organizations/<int:organization_id>/link-requests/<int:link_id>/', OrganizationLinkRequestsView.as_view(), name='org-link-request-action'),

    # Reference data
    path('muscle-groups/', MuscleGroupListView.as_view()),
    path('equipment/', EquipmentListView.as_view()),
    path('exercise-types/', WorkoutTypesView.as_view()),

    # Exercises
    path('exercises/', WorkoutListCreateView.as_view()),
    path('exercises/<int:pk>/', WorkoutDetailView.as_view()),
    path('exercises/<int:workout_id>/override/', TrainerWorkoutOverrideView.as_view()),

    # Workout Groups (single-day / multi-day)
    path('workout-groups/', WorkoutGroupListCreateView.as_view()),
    path('workout-groups/<int:pk>/', WorkoutGroupDetailView.as_view()),

    # Workout Plans
    path('workout-plans/', WorkoutPlanListCreateView.as_view()),
    path('workout-plans/<int:pk>/', WorkoutPlanDetailView.as_view()),
    path('workout-plans/<int:plan_id>/assign/', AssignWorkoutPlanView.as_view()),

    # Plan Days (multi-day plans)
    path('workout-plans/<int:plan_id>/days/', WorkoutPlanDayListCreateView.as_view()),
    path('workout-plans/<int:plan_id>/days/<int:day_id>/', WorkoutPlanDayDetailView.as_view()),

    # Exercises within a day
    path('plan-days/<int:day_id>/exercises/', PlanDayExerciseListCreateView.as_view()),
    path('plan-days/<int:day_id>/exercises/<int:exercise_id>/', PlanDayExerciseDetailView.as_view()),
    path('plan-days/<int:day_id>/exercises/reorder/', ReorderPlanDayExercisesView.as_view()),

    # Customers at trainer's gym
    path('customers/', TrainerCustomerListView.as_view()),
    path('customers/<int:customer_id>/', TrainerClientDetailView.as_view()),

    # Workout Logs
    path('workout-logs/', WorkoutLogCreateView.as_view()),
    path('customers/<int:customer_id>/workout-history/', CustomerWorkoutHistoryView.as_view()),

    # PR Records / General Stats
    path('customers/<int:customer_id>/pr-records/', PRRecordListCreateView.as_view()),
]
