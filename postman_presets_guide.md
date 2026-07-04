# 📋 Backend API Specifications: Workout Presets (Templates)

This document provides the complete API specifications for the *Workout Presets* feature, allowing the Flutter developer to understand the backend models, active endpoints, and payload structures.

---

## 💡 Clarification on Title Handling ("fetch title from that particular data")

When starting a workout from a preset:
1. The frontend retrieves the list of presets via `GET /api/v1/customer/presets/`.
2. Each preset has its own name stored in the `title` attribute (which maps to `plan_name` in the database).
3. When the user clicks *Start Workout* on a specific preset card, the frontend reads the `title` of that selected preset object and passes it to the `title` field in the request body of `POST /api/v1/customer/sessions/start/`.
4. This ensures that the active session is initialized with the correct template name automatically.

---

## 🗄️ 1. Django Database Schema

Here is the actual Django database model structure mapped to the preset concepts on the platform:

```python
from django.db import models
from apps.customers.models import Customer
from apps.trainer.workout_models import Workout

# 1. WorkoutPreset maps to WorkoutPlan (with is_preset=True)
class WorkoutPlan(models.Model):
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE, null=True, blank=True, related_name='created_workout_plans')
    plan_name = models.CharField(max_length=255)  # Serves as the Preset "title"
    description = models.TextField(blank=True, null=True)
    total_weeks = models.IntegerField(default=1)
    total_days = models.IntegerField(null=True, blank=True)
    status = models.BooleanField(default=True)
    is_preset = models.BooleanField(default=False)  # True for presets
    created_at = models.DateTimeField(auto_now_add=True)

# 2. Grouping container required for plans and exercises
class WorkoutPlanDay(models.Model):
    plan = models.ForeignKey(WorkoutPlan, on_delete=models.CASCADE, related_name='days', null=True, blank=True)
    day_number = models.IntegerField()  # Usually 1 for single-day presets
    title = models.CharField(max_length=255, blank=True, null=True)

# 3. PresetExercise maps to WorkoutPlanExercise
class WorkoutPlanExercise(models.Model):
    plan_day = models.ForeignKey(WorkoutPlanDay, on_delete=models.CASCADE, related_name='exercises')
    workout = models.ForeignKey(Workout, on_delete=models.CASCADE)  # Master Exercise Reference
    order_index = models.IntegerField(default=0)
    notes = models.TextField(blank=True, null=True)

# 4. PresetSet maps to ExerciseSetTemplate
class ExerciseSetTemplate(models.Model):
    plan_exercise = models.ForeignKey(WorkoutPlanExercise, on_delete=models.CASCADE, related_name='sets')
    set_number = models.IntegerField()
    target_reps = models.IntegerField(null=True, blank=True)  # maps to 'reps'
    target_weight = models.DecimalField(max_digits=6, decimal_places=2, null=True, blank=True)  # maps to 'weight'
    rest_seconds = models.IntegerField(default=60)
```

---

## 🗺️ 2. API Endpoints Reference

### 2.1: List All Presets
Retrieve a list of all workout templates created by the logged-in customer.
*   *Method*: `GET`
*   *Path*: `/api/v1/customer/presets/`
*   *Headers*:
    *   `Authorization`: `Bearer <token>`
    *   `X-Platform`: `customer-app-android`
*   *Response (200 OK)*:
    ```json
    [
      {
        "id": 12,
        "title": "Strength Chest Workout",
        "plan_name": "Strength Chest Workout",
        "created_at": "2026-06-20T12:00:00Z",
        "exercises": [
          {
            "id": 45,
            "workout_id": 3,
            "name": "Barbell Bench Press",
            "muscle_group": "Chest",
            "order_index": 0,
            "sets": [
              { "set_number": 1, "reps": 12, "weight": 40.0, "target_reps": 12, "target_weight": 40.0, "rest_seconds": 60 },
              { "set_number": 2, "reps": 10, "weight": 50.0, "target_reps": 10, "target_weight": 50.0, "rest_seconds": 60 }
            ],
            "workout": 3,
            "workout_name": "Barbell Bench Press",
            "muscle": "Chest",
            "equipment": "Barbell",
            "video_url": "https://...",
            "notes": "Keep core tight"
          }
        ]
      }
    ]
    ```

### 2.2: Create a Preset
Create a new routine template.
*   *Method*: `POST`
*   *Path*: `/api/v1/customer/presets/`
*   *Headers*:
    *   `Content-Type`: `application/json`
    *   `Authorization`: `Bearer <token>`
*   *Request Body (Create from Scratch)*:
    ```json
    {
      "title": "Strength Chest Workout",
      "exercises": [
        {
          "workout_id": 3,
          "order_index": 0,
          "sets": [
            { "set_number": 1, "reps": 12, "weight": 40.0 },
            { "set_number": 2, "reps": 10, "weight": 50.0 }
          ]
        }
      ]
    }
    ```
*   *Request Body (Save from Completed Session)*:
    If the user has just finished an active session and wants to save it as a preset:
    ```json
    {
      "session_id": 204,
      "preset_title": "Leg Day Burner",
      "description": "Saved from workout session"
    }
    ```
*   *Response (201 Created)*: Returns the complete created preset object (same structure as GET response).

### 2.3: Update / Edit Preset
Modify an existing preset's title, exercises, or target reps/weights.
*   *Method*: `PUT` or `PATCH`
*   *Path*: `/api/v1/customer/presets/<preset_id>/`
*   *Headers*:
    *   `Content-Type`: `application/json`
    *   `Authorization`: `Bearer <token>`
*   *Request Body*:
    ```json
    {
      "title": "Strength Push Routine",
      "exercises": [
        {
          "workout_id": 3,
          "order_index": 0,
          "sets": [
            { "set_number": 1, "reps": 8, "weight": 60.0 },
            { "set_number": 2, "reps": 8, "weight": 65.0 }
          ]
        }
      ]
    }
    ```
*   *Response (200 OK)*: Returns the updated preset object.

### 2.4: Delete Preset
Remove a preset template.
*   *Method*: `DELETE`
*   *Path*: `/api/v1/customer/presets/<preset_id>/`
*   *Headers*:
    *   `Authorization`: `Bearer <token>`
*   *Response (204 No Content)*: Empty response indicating success.
