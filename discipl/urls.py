"""
URL configuration for discipl project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import include, path
from django.conf import settings
from django.conf.urls.static import static
import os
from django.http import JsonResponse
from django.views.decorators.cache import never_cache
from django.utils import timezone
from apps.user.models import User


@never_cache  # <- added to prevent caching of the response
def health_check(request):
    #it is used for render.com to check if the server is alive and running 
    try:
        User.objects.exists()  # Returns boolean without loading data
        return JsonResponse({
            "status": "ok", 
            "db": "active",
            "server_time": timezone.now().isoformat()},status=200)
    except Exception as e:
        return JsonResponse({
            "status": "error", 
            "db": str(e),
            "server_time": timezone.now().isoformat()}, status=500)


@never_cache
def debug_workout(request):
    try:
        from apps.trainer.workout_models import Workout, MuscleGroup, Equipment, GymWorkoutOverride, ProgramGoal, DifficultyLevel
        from django.core.management import call_command

        seed_requested = request.GET.get('seed') == 'true'
        output_msg = ""
        if seed_requested:
            call_command('seed_workout_library')
            output_msg = "Seeding command executed."

        return JsonResponse({
            "status": "success",
            "seed_executed": seed_requested,
            "message": output_msg,
            "counts": {
                "Workout": Workout.objects.count(),
                "Workout_Active": Workout.objects.filter(status=True).count(),
                "MuscleGroup": MuscleGroup.objects.count(),
                "Equipment": Equipment.objects.count(),
                "GymWorkoutOverride": GymWorkoutOverride.objects.count(),
                "ProgramGoal": ProgramGoal.objects.count(),
                "DifficultyLevel": DifficultyLevel.objects.count()
            }
        }, status=200)
    except Exception as e:
        return JsonResponse({
            "status": "error",
            "error": str(e)
        }, status=500)


@never_cache
def server_time_api(request):
    import pytz
    from django.utils import timezone
    from django.conf import settings
    
    utc_now = timezone.now()
    tz_name = getattr(settings, 'TIME_ZONE', 'Asia/Kolkata')
    try:
        local_tz = pytz.timezone(tz_name)
    except Exception:
        local_tz = pytz.timezone('Asia/Kolkata')
        tz_name = 'Asia/Kolkata'
        
    local_now = utc_now.astimezone(local_tz)
    
    return JsonResponse({
        "server_time": utc_now.strftime('%Y-%m-%dT%H:%M:%SZ'),
        "server_date": local_now.strftime('%Y-%m-%d'),
        "timezone": tz_name
    }, status=200)


urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/debug-workout/', debug_workout, name='debug_workout'),
    path(
        "api/v1/",
        include(
            [
                path('server-time/', server_time_api, name='server_time'),
                path('user/', include('apps.user.api.urls')),
                path('fitnesscenter/', include('apps.fitnesscenter.api.urls')),
                path('subscription/', include('apps.subscription.api.urls')),
                path('customer/', include('apps.customers.api.urls')),
                path('mentor/', include('apps.mentors.api.urls')),
                path('trainer/', include('apps.trainer.urls')),
                path('trainer/', include('apps.trainer.api.urls')),
                path('communication/', include('apps.communication.api.urls')),
            ]
        )
    ),path('health-check/', health_check, name='health_check'),  # Health check endpoint
]
if settings.DEBUG:
    urlpatterns.extend(
        [
            *static(
                settings.STATIC_URL,
                document_root=os.path.join(
                    settings.BASE_DIR, settings.STATICFILES_DIRS[0]
                ),
            ),
            *static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT),
        ]
    )
