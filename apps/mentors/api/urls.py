from django.urls import path, include
from rest_framework.routers import DefaultRouter

from apps.mentors.api.views import TrainerViewSet


router = DefaultRouter()
router.register('trainers', TrainerViewSet, basename='trainer')

urlpatterns = [
    path('', include(router.urls)),
]
    