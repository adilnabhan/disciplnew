# 🏋️ Unified Postman API Guide: Discipl Platform Complete Reference

This guide provides a single, unified reference documenting all **`GET`, `POST`, `PATCH`, and `DELETE`** API endpoints for the Workout Tracker, Gym Enquiry/Membership Requests, OTP Authentication, and Dropdown Dropdowns.

---

## 🛠️ Global Configuration
Set up these variables in your Postman environment:
*   **Base URL**: `https://discipl-backend-u0w9.onrender.com` (Live) or `http://127.0.0.1:8000` (Local)
*   **Authorization**: `Bearer {{Token}}` (Retrieve via OTP verification)
*   **X-Platform Headers**:
    *   `customer-app-android` (for Customer App users)
    *   `mentor-app-android` (for Trainer / Gym Owner / Mentor users)

---

## 🔑 1. OTP Authentication Flow

### 1.1: Request/Send OTP
Request a verification OTP for a specific mobile number.
*   **Method**: `POST`
*   **Path**: `/api/v1/user/send-otp/`
*   **Body (JSON)**:
    ```json
    {
      "mobile_number": "+919797979797",
      "process": "login", // Options: "login", "registration"
      "source": "customer-app-android" // Options: "customer-app-android", "mentor-app-android"
    }
    ```
    *Note: Master testing numbers that accept default OTP `'2222'` are: `+918590811546`, `+919400520374`, `+919797979797`, and `+919961333048`.*
*   **Response (200 OK)**:
    ```json
    {
      "id": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
      "message": "OTP sent successfully."
    }
    ```
    *(Store `id` as `{{otp_id}}` for verification).*

### 1.2: Verify OTP & Log In (Existing Users)
Verify the OTP to obtain user profile data and authentication tokens.
*   **Method**: `POST`
*   **Path**: `/api/v1/user/otp/verify/`
*   **Body (JSON)**:
    ```json
    {
      "otp_id": "{{otp_id}}",
      "otp_code": "2222"
    }
    ```
*   **Response (200 OK)**:
    ```json
    {
      "status": "success",
      "message": "OTP verified successfully.",
      "token": {
        "access": "eyJhbGciOi...",
        "refresh": "eyJhbGciOi..."
      },
      "user": {
        "id": 12,
        "name": "Rohan Dev",
        "mobile": "+919797979797",
        "role": "customer" // or "mentor", "admin"
      }
    }
    ```

---

## 🏢 2. Gym Enquiry & Membership Requests (Join Requests)

### 2.1: Submit Gym Enquiry / Membership Request (Customer)
A customer submits an enquiry to join a gym, requesting a specific plan.
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/membership-request/create/`
*   **Headers**: `X-Platform: customer-app-android`
*   **Body (JSON)**:
    ```json
    {
      "organization": 22, // ID of the Gym (Required)
      "membership_plan": 3, // ID of the requested plan (Optional)
      "notes": "I would like to inquire about personal training.", // (Optional)
      "payment_mode": "cash" // Preferences: "cash", "online", "offline" (Optional)
    }
    ```
*   **Response (201 Created)**:
    ```json
    {
      "id": 15,
      "customer": 12,
      "customer_name": "Rohan Dev",
      "organization": 22,
      "organization_name": "Iron Gym",
      "membership_plan": 3,
      "requested_plan_name": "Premium Plan",
      "status": "pending",
      "payment_mode": "cash",
      "notes": "I would like to inquire about personal training.",
      "requested_at": "2026-06-12T10:45:12.498Z"
    }
    ```

### 2.2: View My Enquiries / Request History (Customer)
List all membership requests submitted by the logged-in customer.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/membership-request/list/`
*   **Query Params (Optional)**: `status` (e.g. `pending`, `contacted`, `accepted`, `rejected`)
*   **Response (200 OK)**:
    ```json
    [
      {
        "id": 15,
        "customer": 12,
        "status": "pending",
        "notes": "I would like to inquire about personal training."
      }
    ]
    ```

### 2.3: List Gym Enquiries / Requests (Gym Owner/Mentor)
List all incoming customer membership requests for a specific gym location.
*   **Method**: `GET`
*   **Path**: `/api/v1/fitnesscenter/membership-requests/`
*   **Headers**: `X-Platform: mentor-app-android`
*   **Query Params**:
    *   `organization_id`: `22` (Required)
    *   `status`: `pending` (Optional)
*   **Response (200 OK - Paginated)**:
    ```json
    {
      "count": 1,
      "results": [
        {
          "id": 15,
          "type": "customer",
          "status": "pending",
          "notes": "I would like to inquire about personal training.",
          "membership_plan": { "id": 3, "name": "Premium Plan" },
          "requester": { "id": 12, "name": "Rohan Dev", "mobile": "+919797979797" }
        }
      ]
    }
    ```

### 2.4: Respond/Action on Request (Gym Owner/Mentor)
Update status to `"contacted"`, `"accepted"`, or `"rejected"`.

*   **Action A: Set to "contacted"**
    *   **Method**: `PATCH`
    *   **Path**: `/api/v1/fitnesscenter/membership-requests/15/action/`
    *   **Body (JSON)**:
        ```json
        {
          "status": "contacted",
          "contact_info": { "phone": "+919876543210", "email": "gym@example.com" },
          "gym_remarks": "We will call you shortly to discuss pricing."
        }
        ```
*   **Action B: Set to "accepted" (Start Membership)**
    *   **Method**: `PATCH`
    *   **Path**: `/api/v1/fitnesscenter/membership-requests/15/action/`
    *   **Body (JSON)**:
        ```json
        {
          "status": "accepted",
          "selected_plan": 3, // Plan ID to assign (Required)
          "start_date": "2026-06-12T00:00:00Z", // (Required)
          "end_date": "2026-07-12T00:00:00Z", // (Required)
          "amount": 2000.00,
          "discount": 500.00,
          "payment_mode": "cash"
        }
        ```
*   **Action C: Set to "rejected"**
    *   **Method**: `PATCH`
    *   **Path**: `/api/v1/fitnesscenter/membership-requests/15/action/`
    *   **Body (JSON)**:
        ```json
        {
          "status": "rejected",
          "gym_remarks": "No capacity slots available."
        }
        ```

---

## 🏋️ 3. Workout Tracker & Exercise Logging Flow

### 3.1: Get Workout Calendar Logs
Fetch workout session details and completion ticks for a specific day.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/workout-log/`
*   **Query Params**: `date=YYYY-MM-DD` (defaults to today)
*   **Response (200 OK)**:
    ```json
    [
      {
        "customer_workout_plan_id": 12,
        "plan_id": 4,
        "plan_name": "Full Body Split",
        "day_number": 3,
        "plan_day_id": 15,
        "plan_day_title": "Push Day A",
        "exercise_count": 5,
        "session_id": 104,
        "is_completed": true,
        "source": "trainer",
        "membership_status": "active",
        "is_primary": true
      }
    ]
    ```

### 3.2: Browse & Search Exercise Library
Fetch master list of exercises plus user's custom created exercises.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/exercises/`
*   **Query Params**: `search=Bench`, `muscle_group=Chest`
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

### 3.3: Create Custom Exercise (Private Library)
Add a new custom exercise into the user's private library list.
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/exercises/`
*   **Body (JSON)**:
    ```json
    {
      "name": "Dumbbell Incline Fly",
      "type": "strength",
      "primary_muscle_group": 1, // Chest Muscle ID
      "equipment": 1, // Dumbbell Equipment ID
      "video_url": "https://www.youtube.com/watch?v=ajdFIBnZsHk",
      "instructions": "Keep a slight bend in your elbows and focus on chest squeeze."
    }
    ```
*   **Response (201 Created)**: Returns the newly created Exercise object with its ID.

### 3.4: Start Workout Session
Start the session. You can pass a body with `customer_workout_plan_id` and `plan_day_id` to initialize from a pre-made template, or pass an empty body `{}` to start an ad-hoc empty session.
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/sessions/start/`
*   **Body (JSON)**:
    ```json
    {
      "customer_workout_plan_id": 12,
      "plan_day_id": 15,
      "title": "My Afternoon Chest Session" // Optional: custom session name
    }
    ```
*   **Response (200 OK / 201 Created)**:
    ```json
    {
      "id": 104,
      "title": "My Afternoon Chest Session",
      "plan_day": 15,
      "session_date": "2026-06-12",
      "status": "in_progress",
      "started_at": "2026-06-12T11:05:00Z",
      "completed_at": null,
      "logs": [
        {
          "id": 89,
          "workout_name": "Barbell Bench Press",
          "set_logs": [
            {
              "id": 412,
              "set_number": 1,
              "target_reps": 12,
              "target_weight": "60.00",
              "reps": 0,
              "weight_kg": "0.00",
              "is_completed": false
            }
          ]
        }
      ]
    }
    ```

### 3.5: Dynamically Add Exercise to Active Session
Add an exercise dynamically to your current session plan day using the `plan_day` ID.
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/my-plans/day/{{plan_day_id}}/exercises/`
*   **Body (JSON)**:
    ```json
    {
      "workout": 1, // Exercise ID
      "order_index": 2,
      "sets": [
        { "set_number": 1, "target_reps": 10, "target_weight": 20.0 }
      ]
    }
    ```

### 3.6: Log / Update a Set (Checkbox)
Mark a specific set log row as complete or update reps/weight.
*   **Method**: `PATCH`
*   **Path**: `/api/v1/customer/set-logs/{{set_log_id}}/`
*   **Body (JSON)**:
    ```json
    {
      "weight_kg": 65.0,
      "reps": 12,
      "is_completed": true
    }
    ```
*   **Response (200 OK)**: Returns the updated set log status.

### 3.7: Add a Set Dynamically
Add another set row to the exercise log.
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/workout-logs/{{workout_log_id}}/sets/`
*   **Body (JSON)**:
    ```json
    {
      "weight_kg": 70.0,
      "reps": 10
    }
    ```
*   **Response (201 Created)**: Returns the newly appended set row with its unique `id` and auto-incremented `set_number`.

### 3.8: Finish Workout Session (Title Required)
Finish the active workout session. The `title` key is strictly required to successfully complete the log.
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/sessions/{{session_id}}/finish/`
*   **Body (JSON)**:
    ```json
    {
      "title": "Chest & Triceps Focus Session"
    }
    ```
*   **Response (200 OK)**:
    ```json
    {
      "status": "success",
      "message": "Workout session completed.",
      "data": {
        "id": 104,
        "title": "Chest & Triceps Focus Session",
        "status": "completed",
        "completed_at": "2026-06-12T11:15:30Z"
      }
    }
    ```

---

## 🛠️ 4. Custom Workout Plan CRUD (User Custom Routine Builder)

For customers building and structuring their own routines from scratch.

### 4.1: List & Create Custom Plans
*   **Create Custom Plan**
    *   **Method**: `POST`
    *   **Path**: `/api/v1/customer/my-plans/`
    *   **Body (JSON)**:
        ```json
        {
          "plan_name": "My Custom HIIT Routine",
          "description": "My morning cardio and core workouts",
          "total_weeks": 1,
          "total_days": 3
        }
        ```
*   **List Custom Plans**
    *   **Method**: `GET`
    *   **Path**: `/api/v1/customer/my-plans/`

### 4.2: Retrieve / Update / Delete Custom Plan
*   **Retrieve Detail**: `GET /api/v1/customer/my-plans/{{plan_id}}/`
*   **Update details**: `PUT /api/v1/customer/my-plans/{{plan_id}}/`
*   **Delete plan**: `DELETE /api/v1/customer/my-plans/{{plan_id}}/`

### 4.3: List & Add Days to Custom Plan
*   **Add Day to Plan**
    *   **Method**: `POST`
    *   **Path**: `/api/v1/customer/my-plans/{{plan_id}}/days/`
    *   **Body (JSON)**:
        ```json
        {
          "day_number": 1,
          "title": "Push Day 1",
          "notes": "Chest focus"
        }
        ```
*   **List Days of Plan**: `GET /api/v1/customer/my-plans/{{plan_id}}/days/`

### 4.4: Retrieve / Update / Delete Day in Custom Plan
*   **Update Day details**: `PUT /api/v1/customer/my-plans/{{plan_id}}/days/{{day_id}}/`
*   **Delete Day**: `DELETE /api/v1/customer/my-plans/{{plan_id}}/days/{{day_id}}/`

### 4.5: Add / Remove Exercises in a Plan Day
*   **Add Exercise to Day**
    *   **Method**: `POST`
    *   **Path**: `/api/v1/customer/my-plans/day/{{day_id}}/exercises/`
    *   **Body (JSON)**:
        ```json
        {
          "workout": 1, // Exercise ID
          "order_index": 1,
          "notes": "Perform 3 sets of 10 reps",
          "sets": [
            { "set_number": 1, "target_reps": 10, "target_weight": 20.0 }
          ]
        }
        ```
*   **Remove Exercise from Day**: `DELETE /api/v1/customer/my-plans/day/{{day_id}}/exercises/{{exercise_id}}/`

---

## 📋 5. System Reference Dropdown Choices GET APIs
Use these to fetch lists of choice dropdown options when loading forms:

1.  **Muscle Groups List**: `GET /api/v1/trainer/muscle-groups/`
2.  **Equipment Types List**: `GET /api/v1/trainer/equipment/`
3.  **Exercise Types List**: `GET /api/v1/trainer/exercise-types/`
4.  **Common Injuries List**: `GET /api/v1/customer/common/injuries/`
5.  **Common Medical Conditions List**: `GET /api/v1/customer/common/medical-conditions/`
6.  **Profile Dropdown Constant Choices**: `GET /api/v1/customer/constant-choices/`
