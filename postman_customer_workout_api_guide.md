# 📋 customer App Workout API Integration Guide

This guide provides the complete list of endpoints, HTTP methods, request payloads, and response bodies for the customer workout modules in the mobile application.

---

## 🗺️ 1. Master Exercise Library

### 1.1: Browse Exercises
Search, filter, and paginate through the global exercise library.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/exercises/`
*   **Query Parameters**:
    *   `search` (Optional): Filter exercises by name (e.g. `bench`)
    *   `muscle_group` (Optional): Filter by primary muscle group ID or name
    *   `equipment` (Optional): Filter by equipment ID or name
*   **Response (200 OK)**:
    ```json
    {
      "count": 120,
      "next": "https://.../api/v1/customer/exercises/?page=2",
      "previous": null,
      "results": [
        {
          "id": 3,
          "name": "Barbell Bench Press",
          "description": "Lie on a flat bench...",
          "primary_muscle_group": {
            "id": 1,
            "name": "Chest"
          },
          "equipment": {
            "id": 2,
            "name": "Barbell"
          },
          "image": "https://s3.ap-southeast-1.wasabisys.com/discipl-habitoz/media/exercises/bench.png",
          "video_url": "https://..."
        }
      ]
    }
    ```

### 1.2: Get Exercise Details
Retrieve full specifications of a single exercise by ID or Name.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/exercises/<id>/` (or `/api/v1/customer/exercises/detail/?title=Barbell Bench Press`)
*   **Response (200 OK)**:
    ```json
    {
      "id": 3,
      "name": "Barbell Bench Press",
      "description": "Lie on a flat bench...",
      "instructions": "1. Set your feet flat...\n2. Unrack...",
      "primary_muscle_group": {
        "id": 1,
        "name": "Chest"
      },
      "equipment": {
        "id": 2,
        "name": "Barbell"
      },
      "image": "https://s3.ap-southeast-1.wasabisys.com/discipl-habitoz/media/exercises/bench.png",
      "video_url": "https://..."
    }
    ```

### 1.3: List Muscle Groups
Get list of all muscle groups for filtering options.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/muscle-groups/`
*   **Response (200 OK)**:
    ```json
    [
      { "id": 1, "name": "Chest" },
      { "id": 2, "name": "Back" }
    ]
    ```

### 1.4: List Equipment
Get list of all equipments.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/equipment/`
*   **Response (200 OK)**:
    ```json
    [
      { "id": 1, "name": "Dumbbell" },
      { "id": 2, "name": "Barbell" }
    ]
    ```

---

## 📅 2. Workout Calendar & Logs

### 2.1: Retrieve Workout Log for a Specific Date
Get the workout plan details, active sessions, completed sessions, and rest days for a calendar date.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/workout-log/`
*   **Query Parameters**:
    *   `date` (Required): format `YYYY-MM-DD` (e.g. `2026-06-20`)
*   **Response (200 OK)**:
    ```json
    [
      {
        "customer_workout_plan_id": 10,
        "plan_id": 5,
        "plan_name": "Hypertrophy Program",
        "day_number": 3,
        "total_days": 15,
        "plan_day_id": 42,
        "plan_day_title": "Push Day Focus",
        "is_rest_day": false,
        "exercise_count": 5,
        "session_id": 204,
        "is_completed": true,
        "source": "trainer",
        "membership_status": "active",
        "is_primary": true
      }
    ]
    ```

### 2.2: Fetch Assigned Plan Days
Get all days inside an assigned active plan program.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/workout-plans/<customer_workout_plan_id>/days/`
*   **Response (200 OK)**:
    ```json
    {
      "plan_id": 5,
      "plan_name": "Hypertrophy Program",
      "days": [
        {
          "id": 42,
          "day_number": 1,
          "title": "Push Day Focus",
          "notes": "Focus on progressive overload",
          "is_completed": true
        }
      ]
    }
    ```

### 2.3: Fetch Exercise Templates for a Plan Day
Retrieve templates/targets for exercises on a plan day before starting a session.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/plan-days/<plan_day_id>/`
*   **Response (200 OK)**:
    ```json
    {
      "id": 42,
      "title": "Push Day Focus",
      "exercises": [
        {
          "id": 110,
          "workout_id": 3,
          "workout_name": "Barbell Bench Press",
          "workout_image": "https://...",
          "order_index": 0,
          "sets": [
            { "set_number": 1, "target_reps": 12, "target_weight": 40.0, "rest_seconds": 60 }
          ]
        }
      ]
    }
    ```

---

## 🏋️ 3. Workout Sessions Lifecycle

### 3.1: Start a Workout Session
Starts a workout session (either from a plan day, from a preset template, or an ad-hoc session).
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/sessions/start/`
*   **Request Body**:
    ```json
    {
      "customer_workout_plan_id": 10,  // Option 1: Start from assigned plan day
      "plan_day_id": 42,
      "preset_id": 15,                 // Option 2: Start directly from a Preset (recommended)
      "date": "2026-06-20",
      "title": "Push Day Focus"        // Optional: custom session name
    }
    ```
*   **Response (201 Created)**:
    ```json
    {
      "id": 205,                       // Session ID
      "title": "Push Day Focus",
      "status": "in_progress",
      "session_date": "2026-06-20"
    }
    ```

### 3.2: Get Current Active Session
Retrieve details of any session currently marked as `in_progress`.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/sessions/active/`
*   **Response (200 OK)**:
    ```json
    {
      "id": 205,
      "title": "Push Day Focus",
      "session_date": "2026-06-20",
      "status": "in_progress",
      "logs": [
        {
          "id": 310, // WorkoutLog ID
          "workout": {
            "id": 3,
            "name": "Barbell Bench Press",
            "primary_muscle_group": "Chest"
          },
          "sets": [
            {
              "id": 810, // SetLog ID
              "set_number": 1,
              "reps": 12,
              "weight": 40.00,
              "is_completed": true
            }
          ]
        }
      ]
    }
    ```

### 3.3: Delete/Cancel Active Session
Abandon the current active session.
*   **Method**: `DELETE`
*   **Path**: `/api/v1/customer/sessions/active/`
*   **Response (204 No Content)**: Empty body. *(Safe to run even if no active session exists)*

### 3.4: Finish/Complete Session
Complete the active workout session, with the option to save the logs as a new Preset template.
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/sessions/<session_id>/finish/`
*   **Request Body**:
    ```json
    {
      "save_as_preset": true,          // Optional: saves logs as preset template
      "preset_title": "My Chest Routine" // Optional: custom name for the preset
    }
    ```
*   **Response (200 OK)**:
    ```json
    {
      "status": "completed",
      "completed_at": "2026-06-20T12:30:00Z",
      "preset_created": true,
      "preset_id": 15
    }
    ```

### 3.5: Toggle Rest Day
Mark or unmark a calendar day as a Rest Day (supported by bulk execution to prevent redundant requests).
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/sessions/rest-day/`
*   **Request Body (Bulk)**:
    ```json
    {
      "rest_days": [
        {
          "plan_day_id": 42,
          "date": "2026-06-21",
          "is_rest_day": true
        }
      ]
    }
    ```
*   **Response (200 OK)**:
    ```json
    {
      "success": true,
      "rest_days": [
        {
          "plan_day_id": 42,
          "session_id": 206,
          "status": "rest_day",
          "is_rest_day": true
        }
      ]
    }
    ```

---

## 📝 4. Session Set Logging

### 4.1: Add Set to Exercise Log
Add a new set to a tracked exercise in the current session.
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/workout-logs/<workout_log_id>/sets/`
*   **Request Body**:
    ```json
    {
      "set_number": 3,
      "reps": 10,
      "weight": 45.0,
      "is_completed": true
    }
    ```
*   **Response (201 Created)**: Returns the created set object.

### 4.2: Update Set Log Data
Modify repetition count, weight, or completion checkbox status of an existing set.
*   **Method**: `PUT` or `PATCH`
*   **Path**: `/api/v1/customer/set-logs/<set_log_id>/`
*   **Request Body**:
    ```json
    {
      "reps": 11,
      "weight": 47.5,
      "is_completed": true
    }
    ```
*   **Response (200 OK)**: Returns the updated set object.

### 4.3: Bulk Update/Overwrite Exercise Sets
Bulk replace/update sets for a tracked exercise. Recommended for saving offline states.
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/workout-logs/<workout_log_id>/sets/bulk/`
*   **Request Body**:
    ```json
    {
      "sets": [
        { "set_number": 1, "reps": 12, "weight": 40.0, "is_completed": true },
        { "set_number": 2, "reps": 10, "weight": 50.0, "is_completed": false }
      ]
    }
    ```
*   **Response (200 OK)**:
    ```json
    {
      "success": true,
      "sets_count": 2
    }
    ```

### 4.4: Swap Exercise inside Session
Swaps out a planned exercise for an alternative exercise.
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/exercises/swap/`
*   **Request Body**:
    ```json
    {
      "session_id": 205,
      "old_workout_id": 3,  // Bench Press
      "new_workout_id": 8   // Dumbbell Chest Press
    }
    ```
*   **Response (200 OK)**:
    ```json
    {
      "success": true,
      "message": "Exercise swapped successfully."
    }
    ```

---

## 🛠️ 5. Presets (Templates) API

*   **List Presets**: `GET /api/v1/customer/presets/`
*   **Create Preset**: `POST /api/v1/customer/presets/`
*   **Update Preset**: `PUT` / `PATCH` `/api/v1/customer/presets/<preset_id>/`
*   **Delete Preset**: `DELETE /api/v1/customer/presets/<preset_id>/`

*(Detailed specifications for the Presets endpoints are available in `postman_presets_guide.md`)*

---

## 📋 6. Custom Program & Plan Creator (CRUD)

If the customer wishes to design a complete multi-week/multi-day training plan program:

### 6.1: Create Workout Plan
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/my-plans/`
*   **Request Body**:
    ```json
    {
      "plan_name": "My Custom 3-Day Plan",
      "description": "Focusing on strength progression",
      "total_weeks": 4,
      "total_days": 12
    }
    ```
*   **Response (201 Created)**: Returns the newly created plan header details.

### 6.2: Add Plan Days
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/my-plans/<plan_id>/days/`
*   **Request Body**:
    ```json
    {
      "day_number": 1,
      "title": "Day 1 - Push Focus",
      "notes": "Light stretching beforehand"
    }
    ```
*   **Response (201 Created)**: Returns the day's record details.

### 6.3: Add Exercises to a Plan Day
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/my-plans/day/<day_id>/exercises/`
*   **Request Body**:
    ```json
    {
      "workout_id": 3,
      "order_index": 0,
      "sets": [
        { "set_number": 1, "reps": 10, "weight": 40.0 }
      ]
    }
    ```
*   **Response (201 Created)**: Returns the template details.
