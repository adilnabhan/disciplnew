from django.urls import path
from .views import (
    TrainerViewSet,
    TrainerBasicDetailsView,
    TrainerExperienceView,
    TrainerLocationView,
    TrainerBankAccountView,
    TrainerCertificationUploadView,
    SpecializationListView,
    TrainerPlanView,
    TrainerPlanDetailView,
    TrainerRecognitionView,
    TrainerWorkExperienceView,
    TrainerPreferenceView,
    TrainerLocationPreferenceView,
    TrainerLanguagePreferenceView,
    LanguageListView,
    TrainerPayRangeView,
    TrainerSocialLinkView,
    TrainerSubscriptionPurchaseView
)

urlpatterns = [

    # Trainer CRUD
    path('trainers/', TrainerViewSet.as_view({
        'get': 'list',
        'post': 'create'
    })),
    
    path('trainers/<int:pk>/', TrainerViewSet.as_view({
        'get': 'retrieve',
        'put': 'update',
        'delete': 'destroy'
    })),

    # Onboarding APIs
    path('trainers/basic-details/', TrainerBasicDetailsView.as_view()),
    path("trainers/experience/", TrainerExperienceView.as_view()),
    path("trainers/certifications/", TrainerCertificationUploadView.as_view()),
    path("specializations/", SpecializationListView.as_view()),
    path('trainers/recognitions/', TrainerRecognitionView.as_view()),
    path('trainers/workexperience/', TrainerWorkExperienceView.as_view()),
    path('trainers/experiences/', TrainerExperienceView.as_view()),
    path('trainers/preferences/', TrainerPreferenceView.as_view()),
    path('trainers/location-preferences/', TrainerLocationPreferenceView.as_view()),
    path('trainers/languages/', TrainerLanguagePreferenceView.as_view()),
    path('trainers/pay-range/', TrainerPayRangeView.as_view()),
    path('trainers/social-links/', TrainerSocialLinkView.as_view()),
    path('trainers/location/', TrainerLocationView.as_view()),
    path('trainers/bank-account/', TrainerBankAccountView.as_view()),
    path('languages/', LanguageListView.as_view()),

    # Trainer Plans
    path('plans/', TrainerPlanView.as_view()),
    path('trainers/plans/', TrainerPlanView.as_view()),
    path('trainers/plans/<int:plan_id>/', TrainerPlanDetailView.as_view()),
    path('trainers/subscription/', TrainerSubscriptionPurchaseView.as_view()),
]