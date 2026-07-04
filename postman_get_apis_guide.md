# 🔍 Postman API Guide: GET Endpoints Reference

This guide documents all available **`GET` API endpoints** for the Workout Tracker and Gym Enquiry/Membership Request modules on the **Discipl** platform.

---

## 🛠️ Global Configuration
*   **Base URL**: `https://discipl-backend-u0w9.onrender.com` (Live) or `http://127.0.0.1:8000` (Local)
*   **Authorization**: `Bearer {{Token}}`
*   **X-Platform Headers**:
    *   `customer-app-android` (for Customer App requests)
    *   `mentor-app-android` (for Gym Owners / Trainers / Mentors)

---

## 🏋️ 1. Workout Tracker & Exercise GET APIs

### 1.1: Browse & Search Exercises
Fetch all master exercises plus the user's custom exercises. Supports filtering by name, muscle group, and type.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/exercises/`
*   **Headers**:
    *   `Authorization`: `Bearer {{CustomerToken}}`
    *   `X-Platform`: `customer-app-android`
*   **Query Parameters (Optional)**:
    *   `search`: Filter by name (e.g. `Bench`)
    *   `muscle_group`: Filter by muscle name (e.g. `Chest`)
    *   `type`: Filter by exercise type (e.g. `strength`)
    *   `custom_only`: Filter to return only user-created exercises (excluding global default exercises) if set to `true` (e.g. `?custom_only=true`)
*   **Response (200 OK)**:
    ```json
    [
      {
        "id": 1,
        "name": "Barbell Bench Press",
        "type": "strength",
        "muscle_group": "Chest",
        "equipment": "Barbell",
        "video_url": "https://www.youtube.com/watch?v=gRVjAtPip0Y"
      }
    ]
    ```

### 1.2: Get Workout Calendar Logs
Fetch workout session details and status for a specific date (defaults to today's date).
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/workout-log/`
*   **Headers**: `Authorization: Bearer {{CustomerToken}}`
*   **Query Parameters (Optional)**:
    *   `date`: Date string in `YYYY-MM-DD` format (defaults to current server date)
*   **Response (200 OK)**:
    ```json
    [
      {
        "customer_workout_plan_id": 12,
        "plan_id": 4,
        "plan_name": "Full Body Split",
        "day_number": 3,
        "total_days": 7,
        "plan_day_id": 15,
        "plan_day_title": "Push Day A",
        "exercise_count": 5,
        "session_id": 104,
        "is_completed": true,
        "source": "trainer", // "customer", "trainer", or "gym"
        "membership_status": "active", // "active", "none", "expired"
        "is_primary": true
      }
    ]
    ```

### 1.3: List Assigned Plan Days
List all days under an assigned customer workout plan.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/workout-plans/{{customer_workout_plan_id}}/days/`
*   **Headers**: `Authorization: Bearer {{CustomerToken}}`
*   **Response (200 OK)**:
    ```json
    {
      "plan_id": 4,
      "plan_name": "Full Body Split",
      "total_days": 7,
      "days": [
        {
          "plan_day_id": 15,
          "day_number": 1,
          "title": "Push Day A",
          "exercise_count": 5,
          "is_completed": true,
          "is_current": false,
          "session_id": 104
        }
      ]
    }
    ```

### 1.4: Get Plan Day Details
Fetch the exercise templates and metadata for a specific plan day.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/plan-days/{{plan_day_id}}/`
*   **Headers**: `Authorization: Bearer {{CustomerToken}}`
*   **Response (200 OK)**:
    ```json
    {
      "plan_day_id": 15,
      "day_number": 1,
      "title": "Push Day A",
      "exercise_count": 1,
      "exercises": [
        {
          "id": 1,
          "workout": {
            "id": 1,
            "name": "Barbell Bench Press",
            "type": "strength",
            "primary_muscle_group": 1,
            "equipment": 2,
            "video_url": "https://www.youtube.com/watch?v=gRVjAtPip0Y"
          },
          "order_index": 1,
          "notes": "3 sets with progressive overload",
          "sets": [
            {
              "id": 25,
              "set_number": 1,
              "target_reps": 15,
              "target_weight": "10.00"
            }
          ]
        }
      ]
    }
    ```

### 1.5: List User's Custom Workout Plans
Fetch all custom workout plans created by the customer.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/my-plans/`
*   **Headers**: `Authorization: Bearer {{CustomerToken}}`
*   **Response (200 OK)**:
    ```json
    [
      {
        "id": 8,
        "plan_name": "My Custom HIIT Routine",
        "description": "My morning cardio and core workouts",
        "total_weeks": 1,
        "total_days": 3,
        "created_at": "2026-06-12T10:45:12.498Z"
      }
    ]
    ```

### 1.6: Get Details of a Custom Workout Plan
Retrieve details of a single custom workout plan.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/my-plans/{{plan_id}}/`
*   **Headers**: `Authorization: Bearer {{CustomerToken}}`
*   **Response (200 OK)**:
    ```json
    {
      "id": 8,
      "plan_name": "My Custom HIIT Routine",
      "description": "My morning cardio and core workouts",
      "total_weeks": 1,
      "total_days": 3
    }
    ```

### 1.7: List Days of a Custom Workout Plan
Fetch all days assigned to a custom plan.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/my-plans/{{plan_id}}/days/`
*   **Headers**: `Authorization: Bearer {{CustomerToken}}`
*   **Response (200 OK)**:
    ```json
    [
      {
        "id": 21,
        "day_number": 1,
        "title": "Push Day 1",
        "notes": "Focus on chest and triceps"
      }
    ]
    ```

---

## 🏢 2. Gym Enquiry & Membership Request GET APIs

### 2.1: View My Membership Requests (Customer Side)
Retrieve the list of membership and join requests submitted by the logged-in customer.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/membership-request/list/`
*   **Headers**:
    *   `Authorization`: `Bearer {{CustomerToken}}`
    *   `X-Platform`: `customer-app-android`
*   **Query Parameters (Optional)**:
    *   `status`: Filter by status (e.g. `pending`, `contacted`, `accepted`, `rejected`)
*   **Response (200 OK)**:
    ```json
    [
      {
        "id": 15,
        "customer": 12,
        "customer_name": "Rohan Dev",
        "customer_phone": "+919400520374",
        "customer_profile_picture": "http://127.0.0.1:8000/media/profiles/profile.png",
        "organization": 22,
        "organization_name": "Iron Gym",
        "organization_logo": "http://127.0.0.1:8000/media/logos/gym_logo.png",
        "membership_plan": 3,
        "requested_plan_name": "Premium Plan",
        "selected_plan": null,
        "selected_plan_name": null,
        "status": "pending",
        "payment_mode": "cash",
        "notes": "I would like to inquire about personal training and a discount.",
        "gym_remarks": null,
        "contact_info": null,
        "requested_at": "2026-06-12T10:45:12.498Z",
        "responded_at": null
      }
    ]
    ```

### 2.2: List Incoming Enquiries / Requests (Gym Owner/Mentor Side)
Retrieve incoming requests for a specific organization/gym.
*   **Method**: `GET`
*   **Path**: `/api/v1/fitnesscenter/membership-requests/`
*   **Headers**:
    *   `Authorization`: `Bearer {{MentorToken}}`
    *   `X-Platform`: `mentor-app-android`
*   **Query Parameters**:
    *   `organization_id`: `22` (Required)
    *   `status`: `pending` (Optional)
    *   `type`: `customer` (Optional: filters only `customer` or `trainer` requests)
*   **Response (200 OK - Paginated)**:
    ```json
    {
      "count": 1,
      "next": null,
      "previous": null,
      "results": [
        {
          "id": 15,
          "type": "customer",
          "status": "pending",
          "requested_at": "2026-06-12T10:45:12.498Z",
          "responded_at": null,
          "notes": "I would like to inquire about personal training and a discount.",
          "gym_remarks": null,
          "membership_plan": {
            "id": 3,
            "name": "Premium Plan"
          },
          "requester": {
            "id": 12,
            "name": "Rohan Dev",
            "mobile": "+919400520374",
            "profile_image": "http://127.0.0.1:8000/media/profiles/profile.png"
          }
        }
      ]
    }
    ```

---

## 📋 3. Static/Dropdown Reference Dropdown GET APIs

To populate options in forms (e.g. muscles, equipment, types, injuries, medical conditions):

1.  **Muscle Groups Dropdown**:
    *   `GET /api/v1/trainer/muscle-groups/` (Returns all muscle groups)
2.  **Equipment Dropdown**:
    *   `GET /api/v1/trainer/equipment/` (Returns all equipment types)
3.  **Exercise Types Dropdown**:
    *   `GET /api/v1/trainer/exercise-types/` (Returns exercise types)
4.  **Injuries Choice List**:
    *   `GET /api/v1/customer/common/injuries/` (Returns common injuries list)
5.  **Medical Conditions Choice List**:
    *   `GET /api/v1/customer/common/medical-conditions/` (Returns common medical conditions list)
6.  **Profile Dropdown Constant Choices**:
    *   `GET /api/v1/customer/constant-choices/` (Returns system choice tuples)
