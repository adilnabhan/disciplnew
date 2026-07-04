# Discipl Customer App - API Integration Guide

This guide describes all endpoints, HTTP methods, headers, request bodies, and responses for **Workouts**, **Presets**, and the **Calendar** APIs. Share this directly with the Flutter team to ensure correct integration.

---

## 🔑 Base Configurations & Headers

* **Base URL**: `https://discipl-backend.onrender.com`
* **Common Headers**:
  ```http
  Authorization: Bearer <your_jwt_access_token>
  Content-Type: application/json
  X-Platform: customer-app-android  (or customer-app-ios)
  ```

---

## 🏃 1. Workout Session Flow

This section details how to start, modify, track, and complete a live workout session.

### 1.1 Start a Workout Session
Starts a new active session. If a session is already `in_progress`, this endpoint returns the existing session instead of creating a duplicate.

* **URL**: `/api/v1/customer/sessions/start/`
* **Method**: `POST`
* **Request Body (Ad-hoc Session)**:
  ```json
  {
    "title": "My Afternoon Bench Workout"
  }
  ```
* **Request Body (Starting from a Preset/Plan Day)**:
  ```json
  {
    "plan_day_id": 147
  }
  ```
* **Success Response (HTTP 200/201)**:
  ```json
  {
    "session_id": 155,
    "title": "My Afternoon Bench Workout",
    "status": "in_progress",
    "session_date": "2026-06-18",
    "plan_day_id": 180,
    "customer_workout_plan_id": 12
  }
  ```

---

### 1.2 Get Active Workout Session
Retrieves the workout session currently in progress, including all its exercise logs and set logs.

* **URL**: `/api/v1/customer/sessions/active/`
* **Method**: `GET`
* **Success Response (HTTP 200)**:
  ```json
  {
    "session_id": 155,
    "title": "My Afternoon Bench Workout",
    "status": "in_progress",
    "session_date": "2026-06-18",
    "exercises": [
      {
        "workout_log_id": 412,
        "workout_id": 1,
        "name": "Barbell Bench Press",
        "muscle_group": "Chest",
        "order_index": 1,
        "sets": [
          {
            "set_log_id": 1024,
            "set_number": 1,
            "reps": null,
            "weight": null,
            "previous_weight": 40.0,
            "is_completed": false
          }
        ]
      }
    ]
  }
  ```

---

### 1.3 Add Exercise(s) to Active Session
Adds one or more exercises to the active session. If the session was started from a preset template, the backend automatically clones the day to prevent editing the master template.

* **URL**: `/api/v1/customer/sessions/active/exercises/`
* **Method**: `POST`
* **Request Body (Add multiple)**:
  ```json
  {
    "workout_ids": [1, 2]
  }
  ```
* **Request Body (Add single)**:
  ```json
  {
    "workout_id": 1
  }
  ```
* **Success Response (HTTP 200)**:
  ```json
  {
    "detail": "Exercises added to active session successfully."
  }
  ```

---

### 1.4 Delete Exercise from Active Session
Removes an exercise (and all its set logs) from the current active session.

* **URL**: `/api/v1/customer/sessions/active/exercises/<workout_log_id>/`
* **Method**: `DELETE`
* **Success Response (HTTP 204)**:
  *(No content)*

---

### 1.5 Add a Set to an Exercise Log
Adds a new set line to an exercise log.

* **URL**: `/api/v1/customer/workout-logs/<workout_log_id>/sets/`
* **Method**: `POST`
* **Request Body**:
  ```json
  {
    "reps": 10,
    "weight_kg": 50.0,
    "is_completed": true
  }
  ```
* **Success Response (HTTP 201)**:
  ```json
  {
    "id": 1025,
    "set_number": 2,
    "reps": 10,
    "weight_kg": 50.0,
    "is_completed": true
  }
  ```

---

### 1.6 Update / Edit a Set Log
Edits an existing set's reps, weight, or completion status.

* **URL**: `/api/v1/customer/set-logs/<set_log_id>/`
* **Method**: `PATCH` (or `PUT`)
* **Request Body**:
  ```json
  {
    "reps": 12,
    "weight_kg": 52.5,
    "is_completed": true
  }
  ```
* **Success Response (HTTP 200)**:
  ```json
  {
    "id": 1025,
    "set_number": 2,
    "reps": 12,
    "weight_kg": 52.5,
    "is_completed": true
  }
  ```

---

### 1.7 Finish a Workout Session
Completes the workout session and optionally saves it as a reusable preset template.

* **URL**: `/api/v1/customer/sessions/<session_id>/finish/`
* **Method**: `POST`
* **Request Body**:
  ```json
  {
    "title": "Completed Bench Press Workout",
    "save_as_preset": true,
    "preset_title": "My Go-To Chest Day"
  }
  ```
* **Success Response (HTTP 200)**:
  ```json
  {
    "session_id": 155,
    "status": "completed",
    "title": "Completed Bench Press Workout",
    "preset_id": 161
  }
  ```
  *(Note: If `save_as_preset` is `true`, the preset is created under the customer's account, and the original ad-hoc `WorkoutPlan` in Django Admin is cleaned up and renamed from "My Session" to "Completed Bench Press Workout").*

---

## 💾 2. Presets Management APIs

Presets are custom templates created by the user. If the user doesn't have any presets, the `GET` endpoint initializes default ones.

### 2.1 List All Presets
* **URL**: `/api/v1/customer/presets/`
* **Method**: `GET`
* **Success Response (HTTP 200)**:
  ```json
  [
    {
      "id": 160,
      "title": "My Go-To Chest Day",
      "created_at": "2026-06-18T10:47:08Z",
      "exercises": [
        {
          "id": 157,
          "workout_id": 1,
          "name": "Barbell Bench Press",
          "muscle_group": "Chest",
          "order_index": 1,
          "sets": [
            { "set_number": 1, "reps": 12, "weight": 40.0 },
            { "set_number": 2, "reps": 10, "weight": 50.0 }
          ]
        }
      ]
    }
  ]
  ```

---

### 2.2 Create a Preset Directly (Custom Design)
Allows the user to build a preset plan day from scratch without performing it first.

* **URL**: `/api/v1/customer/presets/`
* **Method**: `POST`
* **Request Body**:
  ```json
  {
    "title": "Directly Created Preset Plan",
    "description": "Optional details about the preset",
    "exercises": [
      {
        "workout_id": 1,
        "order_index": 1,
        "sets": [
          { "set_number": 1, "reps": 10, "weight": 60.0 },
          { "set_number": 2, "reps": 8, "weight": 70.0 }
        ]
      }
    ]
  }
  ```
* **Success Response (HTTP 201)**:
  *(Returns the created preset object similar to List Presets)*

---

### 2.3 Create a Preset from a Completed Session
Alternative way to convert a completed workout history log into a template preset.

* **URL**: `/api/v1/customer/presets/`
* **Method**: `POST`
* **Request Body**:
  ```json
  {
    "session_id": 155,
    "preset_title": "Copy of Completed Session"
  }
  ```
* **Success Response (HTTP 201)**:
  *(Returns the created preset object)*

---

### 2.4 Retrieve a Specific Preset Detail
* **URL**: `/api/v1/customer/presets/<preset_id>/`
* **Method**: `GET`
* **Success Response (HTTP 200)**:
  *(Returns details of the requested preset)*

---

### 2.5 Update a Preset
Modifies the title, description, exercises, or set templates of a preset.

* **URL**: `/api/v1/customer/presets/<preset_id>/`
* **Method**: `PUT` (or `PATCH`)
* **Request Body**: Same format as direct creation (2.2)
* **Success Response (HTTP 200)**:
  *(Returns updated preset)*

---

### 2.6 Delete a Preset
* **URL**: `/api/v1/customer/presets/<preset_id>/`
* **Method**: `DELETE`
* **Success Response (HTTP 204)**:
  *(No content)*

---

## 📅 3. Calendar & Rest Days

Used to check scheduled/logged workouts and toggle rest days on the calendar grid.

### 3.1 Get Workout Calendar Log
Retrieves the user's logged or scheduled workouts for a specific date.

* **URL**: `/api/v1/customer/workout-log/?date=2026-06-18`
* **Method**: `GET`
* **Success Response (HTTP 200)**:
  ```json
  [
    {
      "customer_workout_plan_id": 12,
      "plan_id": 160,
      "plan_name": "My Go-To Chest Day",
      "day_number": 1,
      "total_days": 1,
      "plan_day_id": 180,
      "plan_day_title": "My Go-To Chest Day",
      "is_rest_day": false,
      "exercise_count": 1,
      "session_id": 155,
      "is_completed": true,
      "source": "customer",
      "membership_status": "active",
      "is_primary": true
    }
  ]
  ```

---

### 3.2 Get All Rest Days
Retrieves all logged rest days.

* **URL**: `/api/v1/customer/sessions/rest-day/`
* **Method**: `GET`
* **Success Response (HTTP 200)**:
  ```json
  [
    {
      "session_id": 156,
      "customer_workout_plan_id": 12,
      "plan_day_id": 180,
      "date": "2026-06-17",
      "is_rest_day": true,
      "title": "Rest Day"
    }
  ]
  ```

---

### 3.3 Toggle a Rest Day on the Calendar
Adds or removes a rest day for a specific date.

* **URL**: `/api/v1/customer/sessions/rest-day/`
* **Method**: `POST`
* **Request Body**:
  ```json
  {
    "customer_workout_plan_id": 12,
    "plan_day_id": 180,
    "date": "2026-06-18",
    "is_rest_day": true
  }
  ```
* **Success Response (HTTP 200)**:
  ```json
  {
    "session_id": 156,
    "status": "rest_day",
    "is_rest_day": true
  }
  ```

---

## 📝 4. Custom Workout Plans (Drafts) APIs

These endpoints allow customers to build, edit, and manage custom workout plans (often referred to as draft plans) with multiple days, exercises, and set templates.

### 4.1 List Custom Workout Plans
* **URL**: `/api/v1/customer/my-plans/`
* **Method**: `GET`
* **Success Response (HTTP 200)**:
  ```json
  [
    {
      "id": 45,
      "plan_name": "My Custom Strength Plan",
      "description": "Chest and Triceps split",
      "total_weeks": 1,
      "total_days": 1,
      "created_at": "2026-06-18T12:00:00Z"
    }
  ]
  ```

### 4.2 Create a Custom Workout Plan
* **URL**: `/api/v1/customer/my-plans/`
* **Method**: `POST`
* **Request Body**:
  ```json
  {
    "plan_name": "My Custom Strength Plan",
    "description": "Chest and Triceps split",
    "total_weeks": 1,
    "total_days": 1
  }
  ```
* **Success Response (HTTP 201)**:
  ```json
  {
    "id": 45,
    "plan_name": "My Custom Strength Plan",
    "description": "Chest and Triceps split",
    "total_weeks": 1,
    "total_days": 1,
    "created_at": "2026-06-18T12:00:00Z"
  }
  ```

### 4.3 Get Specific Plan Details
* **URL**: `/api/v1/customer/my-plans/<plan_id>/`
* **Method**: `GET`
* **Success Response (HTTP 200)**:
  ```json
  {
    "id": 45,
    "plan_name": "My Custom Strength Plan",
    "description": "Chest and Triceps split",
    "total_weeks": 1,
    "total_days": 1,
    "created_at": "2026-06-18T12:00:00Z",
    "days": [
      {
        "id": 142,
        "day_number": 1,
        "title": "Day 1",
        "exercise_count": 0,
        "exercises": []
      }
    ]
  }
  ```

### 4.4 Update a Plan (Title / Description)
* **URL**: `/api/v1/customer/my-plans/<plan_id>/`
* **Method**: `PATCH` (or `PUT`)
* **Request Body**:
  ```json
  {
    "plan_name": "Updated Custom Strength Plan"
  }
  ```
* **Success Response (HTTP 200)**:
  ```json
  {
    "id": 45,
    "plan_name": "Updated Custom Strength Plan",
    "description": "Chest and Triceps split",
    "total_weeks": 1,
    "total_days": 1,
    "created_at": "2026-06-18T12:00:00Z"
  }
  ```

### 4.5 Delete a Plan
* **URL**: `/api/v1/customer/my-plans/<plan_id>/`
* **Method**: `DELETE`
* **Success Response (HTTP 204)**:
  *(No content - Soft deletes plan and cancels associated assignments)*

### 4.6 List Plan Days
* **URL**: `/api/v1/customer/my-plans/<plan_id>/days/`
* **Method**: `GET`
* **Success Response (HTTP 200)**:
  ```json
  [
    {
      "id": 142,
      "day_number": 1,
      "title": "Day 1",
      "exercise_count": 0,
      "exercises": []
    }
  ]
  ```

### 4.7 Create Plan Day
* **URL**: `/api/v1/customer/my-plans/<plan_id>/days/`
* **Method**: `POST`
* **Request Body**:
  ```json
  {
    "day_number": 2,
    "title": "Day 2"
  }
  ```
* **Success Response (HTTP 201)**:
  ```json
  {
    "id": 143,
    "day_number": 2,
    "title": "Day 2",
    "exercise_count": 0,
    "exercises": []
  }
  ```

### 4.8 Update Plan Day Title
* **URL**: `/api/v1/customer/my-plans/<plan_id>/days/<day_id>/`
* **Method**: `PUT` (or `PATCH`)
* **Request Body**:
  ```json
  {
    "title": "Push Day"
  }
  ```
* **Success Response (HTTP 200)**:
  ```json
  {
    "id": 143,
    "day_number": 2,
    "title": "Push Day",
    "exercise_count": 0,
    "exercises": []
  }
  ```

### 4.9 Delete Plan Day
* **URL**: `/api/v1/customer/my-plans/<plan_id>/days/<day_id>/`
* **Method**: `DELETE`
* **Success Response (HTTP 204)**:
  *(No content)*

### 4.10 List Exercises in Plan Day
* **URL**: `/api/v1/customer/my-plans/day/<day_id>/exercises/`
* **Method**: `GET`
* **Success Response (HTTP 200)**:
  ```json
  [
    {
      "id": 890,
      "workout": 1,
      "workout_name": "Barbell Bench Press",
      "muscle": "Chest",
      "equipment": "Barbell",
      "video_url": "",
      "order_index": 1,
      "notes": "",
      "sets": [
        {
          "id": 1205,
          "set_number": 1,
          "target_reps": 10,
          "target_weight": 50.0,
          "rest_seconds": 60
        }
      ]
    }
  ]
  ```

### 4.11 Add Exercise (and Set Templates) to Plan Day
* **URL**: `/api/v1/customer/my-plans/day/<day_id>/exercises/`
* **Method**: `POST`
* **Request Body**:
  ```json
  {
    "workout": 1,
    "order_index": 1,
    "notes": "Keep chest tight",
    "sets": [
      {
        "set_number": 1,
        "target_reps": 10,
        "target_weight": 50.0,
        "rest_seconds": 60
      }
    ]
  }
  ```
* **Success Response (HTTP 201)**:
  ```json
  {
    "id": 890,
    "workout": 1,
    "workout_name": "Barbell Bench Press",
    "muscle": "Chest",
    "equipment": "Barbell",
    "video_url": "",
    "order_index": 1,
    "notes": "Keep chest tight",
    "sets": [
      {
        "id": 1205,
        "set_number": 1,
        "target_reps": 10,
        "target_weight": 50.0,
        "rest_seconds": 60
      }
    ]
  }
  ```

### 4.12 Edit Exercise in Plan Day
* **URL**: `/api/v1/customer/my-plans/day/<day_id>/exercises/<exercise_id>/`
* **Method**: `PUT` (or `PATCH`)
* **Request Body**:
  ```json
  {
    "notes": "Drive through heels"
  }
  ```
* **Success Response (HTTP 200)**:
  *(Returns updated exercise object)*

### 4.13 Delete Exercise from Plan Day
* **URL**: `/api/v1/customer/my-plans/day/<day_id>/exercises/<exercise_id>/`
* **Method**: `DELETE`
* **Success Response (HTTP 204)**:
  *(No content)*

