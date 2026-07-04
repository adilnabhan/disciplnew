from django.urls import path, include

from apps.fitnesscenter.api.views import (
    BankAccountDetailsViewSet, CustomerListAPIView, CustomerPaymentsAPIView,
    OrganizationUpcomingRenewalApiView, MembershipPlanViewSet, OrganizationBasedUserGetAPIView,
    OrganizationCreateAPIView, OrganizationDetailAPIView,
    OrganizationHomeAPIView, OrganizationReviewListAPIView, OrganizationSubscriptionStatusAPIView,
    OrganizationUpdateAPIView, TrainersListAPIView, get_amenities, get_categories,
    ExpiringMembershipsAPIView, OrganizationPhotoDeleteAPIView, CouponValidationAPIView,
    GymMembershipRequestListView, GymMembershipRequestActionView,
    DirectGymCreateAPIView, GymListAPIView, GymDetailAPIView,
    GymTrainerRequestListView, GymTrainerRequestActionView,
    GymTrainerSearchView, GymInviteTrainerView, GymDirectAddTrainerView,
    GymWorkoutLibraryView, GymWorkoutLibraryDetailView,
    GymWorkoutPlanListCreateView, GymWorkoutPlanDetailView,
    GymWorkoutGroupListCreateView, OrganizationBulkPhotoUploadAPIView,
    CreateOrgStaffAPIView, ListOrgStaffAPIView,
    PromotionalBannerListCreateAPIView, PromotionalBannerDetailAPIView,
    AdvancedReportsAPIView,
    # Affiliate Marketing
    SalesExecutiveListCreateAPIView, SalesExecutiveDetailAPIView,
    CouponListCreateAPIView, CouponDetailAPIView,
    AffiliateDashboardAPIView, AffiliateTransactionListAPIView,
    MarkCommissionPaidAPIView,
    # Gym Equipment
    GymEquipmentListView, GymEquipmentUpdateView,
    OwnerDashboardView,
)

from apps.fitnesscenter.api.webhooks import razorpay_account_webhook
from rest_framework.routers import DefaultRouter


router = DefaultRouter()
router.register(r'membership-plans', MembershipPlanViewSet, basename='membership-plan')
router.register(r'bank-details', BankAccountDetailsViewSet, basename='bank-details')


urlpatterns = [
    # Webhooks
    path('webhooks/razorpay/account/', razorpay_account_webhook, name='razorpay-account-webhook'),

    # common apis
    path('categories/', get_categories, name='all-categories'),
    path('amenities/', get_amenities, name='all-amenity'),
    path('home/', OrganizationHomeAPIView.as_view(), name='organization-home'),
    path('customers/', CustomerListAPIView.as_view(), name='customers-list'),
    path('customer_renewals/', OrganizationUpcomingRenewalApiView.as_view(), name='customerrenewal-list'),
    path('trainers/', TrainersListAPIView.as_view(), name='trsiners-list'),
    path('expiring-memberships/', ExpiringMembershipsAPIView.as_view(), name='mentor-expiring-memberships'),
    path(
        'customer-payments/',
        CustomerPaymentsAPIView.as_view(),
        name='customer-payments'
    ),

    path('organization/', include([
        path('create/', OrganizationCreateAPIView.as_view(), name='organization-create'),
        path('<int:id>/', OrganizationDetailAPIView.as_view(), name='organization-detail'),
        path('<int:pk>/update/', OrganizationUpdateAPIView.as_view({'put': 'update', 'patch': 'partial_update'}), name='organization-update'),
        path('list/', OrganizationBasedUserGetAPIView.as_view(), name='organization-get'),
        path('<int:id>/subscription-status/', OrganizationSubscriptionStatusAPIView.as_view(), name='organization-subscription-status'),
        path('<int:org_id>/reviews/', OrganizationReviewListAPIView.as_view(), name='organization-reviews'),
        path('photos/<int:photo_id>/delete/', OrganizationPhotoDeleteAPIView.as_view(), name='organization-photo-delete'),
        path('photos/bulk-upload/', OrganizationBulkPhotoUploadAPIView.as_view(), name='organization-bulk-photo-upload'),

        # Staff user management (restricted admin access)
        path('create-staff/', CreateOrgStaffAPIView.as_view(), name='organization-create-staff'),
        path('staff-list/', ListOrgStaffAPIView.as_view(), name='organization-staff-list'),

    ])),
    path('coupon/validate/', CouponValidationAPIView.as_view(), name='coupon-validate'),

    # Membership Request endpoints (gym-side)
    path('membership-requests/', GymMembershipRequestListView.as_view(), name='gym-membership-request-list'),
    path('membership-requests/<int:pk>/action/', GymMembershipRequestActionView.as_view(), name='gym-membership-request-action'),

    # Trainer Join Request endpoints (gym-side)
    path('trainer-requests/', GymTrainerRequestListView.as_view(), name='gym-trainer-request-list'),
    path('trainer-requests/<int:link_id>/action/', GymTrainerRequestActionView.as_view(), name='gym-trainer-request-action'),
    path('trainer-requests/search/', GymTrainerSearchView.as_view(), name='gym-trainer-search'),
    path('trainer-requests/invite/', GymInviteTrainerView.as_view(), name='gym-trainer-invite'),
    path('trainer-requests/add/', GymDirectAddTrainerView.as_view(), name='gym-trainer-direct-add'),

    # Workout Library (Gym-side)
    path('workout-library/', GymWorkoutLibraryView.as_view(), name='gym-workout-library'),
    path('workout-library/<int:pk>/', GymWorkoutLibraryDetailView.as_view(), name='gym-workout-library-detail'),

    # Workout Plans (Gym-side)
    path('workout-groups/', GymWorkoutGroupListCreateView.as_view(), name='gym-workout-groups'),
    path('workout-plans/', GymWorkoutPlanListCreateView.as_view(), name='gym-workout-plans'),
    path('workout-plans/<int:pk>/', GymWorkoutPlanDetailView.as_view(), name='gym-workout-plan-detail'),

    # Dynamic Promotional Banners
    path('banners/', PromotionalBannerListCreateAPIView.as_view(), name='promotional-banner-list-create'),
    path('banners/<int:pk>/', PromotionalBannerDetailAPIView.as_view(), name='promotional-banner-detail'),

    # Advanced Reports & Analytics
    path('reports/', AdvancedReportsAPIView.as_view(), name='advanced-reports'),

    # Affiliate Marketing
    path('affiliate/', include([
        path('dashboard/', AffiliateDashboardAPIView.as_view(), name='affiliate-dashboard'),
        path('transactions/', AffiliateTransactionListAPIView.as_view(), name='affiliate-transactions'),
        path('mark-paid/', MarkCommissionPaidAPIView.as_view(), name='affiliate-mark-paid'),
    ])),
    path('sales-executives/', SalesExecutiveListCreateAPIView.as_view(), name='sales-executive-list-create'),
    path('sales-executives/<int:pk>/', SalesExecutiveDetailAPIView.as_view(), name='sales-executive-detail'),
    path('coupons/', CouponListCreateAPIView.as_view(), name='coupon-list-create'),
    path('coupons/<int:pk>/', CouponDetailAPIView.as_view(), name='coupon-detail'),

    # Direct Gym (Organization) CRUD - No Auth Required
    path('gym/', include([
        path('create/', DirectGymCreateAPIView.as_view(), name='gym-direct-create'),
        path('list/', GymListAPIView.as_view(), name='gym-list'),
        path('<int:gym_id>/', GymDetailAPIView.as_view(), name='gym-detail'),
    ])),

    # Gym Equipment Inventory
    path('gym-equipments/', GymEquipmentListView.as_view(), name='gym-equipment-list'),
    path('gym-equipments/update/', GymEquipmentUpdateView.as_view(), name='gym-equipment-update'),
    path('owner/dashboard/', OwnerDashboardView.as_view(), name='owner-dashboard'),

    *router.urls,
]