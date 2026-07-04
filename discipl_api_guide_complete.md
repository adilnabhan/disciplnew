# Discipl API Integration Guide: Complete Backend & Workout Flow

This comprehensive guide documents all backend features and API endpoints verified and operational on the **Render live environment** (`https://discipl-backend-u0w9.onrender.com`). Use this guide to synchronize frontend integration across the customer and mentor/trainer apps.

---

## 🛠️ Global Configuration

Configure these parameters in your frontend networking layer or Postman environment:
- **Live Base URL**: `https://discipl-backend-u0w9.onrender.com`
- **Local Base URL**: `http://127.0.0.1:8000`
- **Common Headers**:
  - `Content-Type`: `application/json`
  - `X-Platform`: `customer-app-android` *(Customer)* or `mentor-app-android` *(Mentor/Trainer)* or `vendor-app-android` *(Vendor)*

### 🔑 Testing Credentials (Bypassing SMS)
For the following phone numbers, the system bypasses SMS OTP and uses a default master OTP of `'2222'`:
*   **Mentor (Trainer)**: `+919797979797`
*   **Customer (Client)**: `+919400520374`
*   **Other Master Numbers**: `+918590811546`, `+919961333048`

---

## 🔑 Part 1: Authentication & Onboarding Flow

### 1.1 Request OTP
- **Method**: `POST`
- **Path**: `/api/v1/user/send-otp/`
- **Headers**:
  - `X-Platform`: `<platform_code>` (e.g., `customer-app-android` or `mentor-app-android`)
- **Body (JSON)**:
  ```json
  {
    "mobile_number": "+919400520374",
    "process": "login",
    "source": "customer-app-android"
  }
  ```
- **Expected Response (201)**:
  ```json
  {
    "id": "e0a29f8c-e6cc-4613-bbad-953e3fa2db88",
    "mobile_number": "+919400520374",
    "process": "login",
    "source": "customer-app-android",
    "otp": "2222"
  }
  ```

### 1.2 Verify OTP (Standard Login)
- **Method**: `POST`
- **Path**: `/api/v1/user/otp/verify/`
- **Headers**:
  - `X-Platform`: `<platform_code>`
- **Body (JSON)**:
  ```json
  {
    "otp_id": "e0a29f8c-e6cc-4613-bbad-953e3fa2db88",
    "mobile_number": "+919400520374",
    "otp": "2222",
    "source": "customer-app-android",
    "process": "login"
  }
  ```
- **Expected Response (200)**: Returns Bearer token in `"access"`.

### 1.3 OTP Verification / Role Upgrade (Onboarding)
Use this endpoint to register a new user or upgrade an existing user's role (e.g. setting role to `35` to enable Trainer/Mentor profile).
- **Method**: `POST`
- **Path**: `/api/v1/user/onboarding/`
- **Headers**:
  - `X-Platform`: `<platform_code>`
- **Body (JSON)**:
  ```json
  {
    "otp_id": "<OTP_UUID>",
    "otp": "2222",
    "mobile_number": "+919797979797",
    "first_name": "TestMentor",
    "last_name": "RenderTest",
    "user_role": "35",
    "process": "registration",
    "source": "mentor-app-android"
  }
  ```
- **Expected Response (201)**: Returns access and refresh tokens along with user profile metadata.

---

## 🏋️ Part 2: Trainer / Mentor Workout Plan Flow (Flow A)

This flow is utilized by Trainer users (`user_role = 35` or `36`) to create programs, specify training days and exercises, and assign them directly to customers.

### 2.1 Create Trainer Workout Plan
- **Method**: `POST`
- **Path**: `/api/v1/trainer/workout-plans/`
- **Headers**:
  - `Authorization`: `Bearer {{MentorToken}}`
  - `X-Platform`: `mentor-app-android`
- **Body (JSON)**:
  ```json
  {
    "plan_name": "Mentor Power Strength Plan",
    "description": "A high intensity strength building plan",
    "total_weeks": 2,
    "total_days": 6
  }
  ```
- **Expected Response (201)**:
  ```json
  {
    "id": 3,
    "plan_name": "Mentor Power Strength Plan",
    "plan_name_internal": null,
    "description": "A high intensity strength building plan",
    "group": null,
    "total_weeks": 2,
    "total_days": 6,
    "exercise_count": 0,
    "status": true,
    "source": "trainer",
    "organization": null,
    "created_at": "2026-06-05T10:45:12.498327Z"
  }
  ```

### 2.2 Add Day to Workout Plan
- **Method**: `POST`
- **Path**: `/api/v1/trainer/workout-plans/{{PlanID}}/days/`
- **Headers**:
  - `Authorization`: `Bearer {{MentorToken}}`
  - `X-Platform`: `mentor-app-android`
- **Body (JSON)**:
  ```json
  {
    "day_number": 1,
    "title": "Push Day 1",
    "notes": "Focus on explosive pressing power"
  }
  ```
- **Expected Response (201)**:
  ```json
  {
    "id": 1,
    "day_number": 1,
    "title": "Push Day 1",
    "notes": "Focus on explosive pressing power",
    "exercise_count": 0,
    "exercises": []
  }
  ```

### 2.3 Add Exercise to Workout Plan Day
Add a specific exercise from the master library to a day.
- **Method**: `POST`
- **Path**: `/api/v1/trainer/plan-days/{{DayID}}/exercises/`
- **Headers**:
  - `Authorization`: `Bearer {{MentorToken}}`
  - `X-Platform`: `mentor-app-android`
- **Body (JSON)**:
  ```json
  {
    "workout": 1,
    "video_url": "https://www.youtube.com/watch?v=gRVjAtPip0Y",
    "order_index": 1,
    "notes": "Control the negative"
  }
  ```
- **Expected Response (201)**:
  ```json
  {
    "id": 1,
    "plan_day": 1,
    "workout": 1,
    "video_url": "https://www.youtube.com/watch?v=gRVjAtPip0Y",
    "effective_video_url": "https://www.youtube.com/watch?v=gRVjAtPip0Y",
    "order_index": 1,
    "notes": "Control the negative",
    "sets": []
  }
  ```

### 2.4 Assign Workout Plan to Customer
- **Method**: `POST`
- **Path**: `/api/v1/trainer/workout-plans/{{PlanID}}/assign/`
- **Headers**:
  - `Authorization`: `Bearer {{MentorToken}}`
  - `X-Platform`: `mentor-app-android`
- **Body (JSON)**:
  ```json
  {
    "customer_id": 17
  }
  ```
- **Expected Response (201)**:
  ```json
  {
    "id": 3,
    "customer": 17,
    "trainer": 4,
    "plan": 3,
    "plan_name": "Mentor Power Strength Plan",
    "start_date": "2026-06-05",
    "status": "active",
    "created_at": "2026-06-05T10:45:16.435411Z"
  }
  ```

---

## 🧑‍💻 Part 3: Customer Individual Workout Plan Flow (Flow B)

This flow is used by Customer accounts (`user_role = CUSTOMER`) to browse the workout library and build their own custom workout templates.

### 3.1 Browse Master Exercise Library
- **Method**: `GET`
- **Path**: `/api/v1/customer/exercises/?search=Bench&muscle_group=Chest`
- **Headers**:
  - `Authorization`: `Bearer {{CustomerToken}}`
  - `X-Platform`: `customer-app-android`
- **Expected Response (200)**:
  ```json
  [
    {
      "id": 1,
      "name": "Barbell Bench Press",
      "type": "strength",
      "muscle_group": "Chest",
      "equipment": "Barbell",
      "video_url": null
    }
  ]
  ```

### 3.2 Create Customer Custom Plan
- **Method**: `POST`
- **Path**: `/api/v1/customer/my-plans/`
- **Headers**:
  - `Authorization`: `Bearer {{CustomerToken}}`
  - `X-Platform`: `customer-app-android`
- **Body (JSON)**:
  ```json
  {
    "plan_name": "My Custom HIIT Routine",
    "description": "My morning cardio and core workouts",
    "total_weeks": 1,
    "total_days": 3
  }
  ```
- **Expected Response (201)**:
  ```json
  {
    "id": 2,
    "plan_name": "My Custom HIIT Routine",
    "description": "My morning cardio and core workouts",
    "program_goal": null,
    "difficulty_level": null,
    "total_weeks": 1,
    "total_days": 3
  }
  ```

### 3.3 Add Day to Customer Plan
- **Method**: `POST`
- **Path**: `/api/v1/customer/my-plans/{{CustPlanID}}/days/`
- **Headers**:
  - `Authorization`: `Bearer {{CustomerToken}}`
  - `X-Platform`: `customer-app-android`
- **Body (JSON)**:
  ```json
  {
    "day_number": 1,
    "title": "HIIT Day 1",
    "notes": "Keep the heart rate high"
  }
  ```
- **Expected Response (201)**:
  ```json
  {
    "id": 2,
    "day_number": 1,
    "title": "HIIT Day 1",
    "notes": "Keep the heart rate high",
    "exercise_count": 0,
    "exercises": []
  }
  ```

### 3.4 Add Exercise to Customer Plan Day
- **Method**: `POST`
- **Path**: `/api/v1/customer/my-plans/day/{{CustDayID}}/exercises/`
- **Headers**:
  - `Authorization`: `Bearer {{CustomerToken}}`
  - `X-Platform`: `customer-app-android`
- **Body (JSON)**:
  ```json
  {
    "workout": 23,
    "video_url": "https://www.youtube.com/watch?v=TU8QYVW0gDU",
    "order_index": 1,
    "notes": "No rest between reps"
  }
  ```
- **Expected Response (201)**:
  ```json
  {
    "id": 2,
    "workout": 23,
    "workout_name": "Burpees",
    "muscle": "Abs",
    "equipment": "Bodyweight",
    "video_url": "https://www.youtube.com/watch?v=TU8QYVW0gDU",
    "order_index": 1,
    "notes": "No rest between reps",
    "sets": []
  }
  ```

### 3.5 List Customer's Personal Workout Plans
- **Method**: `GET`
- **Path**: `/api/v1/customer/my-plans/`
- **Headers**:
  - `Authorization`: `Bearer {{CustomerToken}}`
  - `X-Platform`: `customer-app-android`
- **Expected Response (200)**: Lists all personal plans with `"source": "customer"`.

---

## 📅 Part 4: Customer Workout Execution & Logging APIs

These endpoints are used by customers to view, track, and complete workout plans active on their calendar.

### 4.1 View Customer Workout Calendar
Lists both assigned plans from mentors and self-created custom plans.
- **Method**: `GET`
- **Path**: `/api/v1/customer/workout-log/?date=2026-06-05`
- **Headers**:
  - `Authorization`: `Bearer {{CustomerToken}}`
  - `X-Platform`: `customer-app-android`
- **Expected Response (200)**:
  ```json
  [
    {
      "customer_workout_plan_id": 2,
      "plan_id": 2,
      "plan_name": "My Custom HIIT Routine",
      "day_number": 1,
      "total_days": 3,
      "plan_day_id": 2,
      "plan_day_title": "HIIT Day 1",
      "exercise_count": 1,
      "session_id": null,
      "is_completed": false,
      "source": "customer",
      "membership_status": "active",
      "is_primary": true
    },
    {
      "customer_workout_plan_id": 3,
      "plan_id": 3,
      "plan_name": "Mentor Power Strength Plan",
      "day_number": 1,
      "total_days": 6,
      "plan_day_id": 3,
      "plan_day_title": "Push Day 1",
      "exercise_count": 1,
      "session_id": null,
      "is_completed": false,
      "source": "trainer",
      "membership_status": "active",
      "is_primary": false
    }
  ]
  ```

### 4.2 View Assigned Plan Days (Mentor Assigned Plan)
- **Method**: `GET`
- **Path**: `/api/v1/customer/workout-plans/{{cwp_id}}/days/`
- **Headers**:
  - `Authorization`: `Bearer {{CustomerToken}}`
  - `X-Platform`: `customer-app-android`
- **Expected Response (200)**:
  ```json
  {
    "plan_id": 3,
    "plan_name": "Mentor Power Strength Plan",
    "total_days": 6,
    "days": [
      {
        "plan_day_id": 3,
        "day_number": 1,
        "title": "Push Day 1",
        "exercise_count": 1,
        "is_completed": false,
        "is_current": true,
        "session_id": null
      }
    ]
  }
  ```

---

## 🕒 Part 5: Dynamic Time Slots Verification (Gym Owners)

Gym owners (or mentors) can set special operating hours (such as Ramzan slots) using an active date range. The system automatically computes and returns `is_currently_active: true` when fetched within that range.

### 5.1 Update Gym Time Slots
- **Method**: `PATCH`
- **Path**: `/api/v1/fitnesscenter/organization/{{ORG_ID}}/update/`
- **Headers**:
  - `Authorization`: `Bearer {{MentorToken}}`
  - `X-Platform`: `vendor-app-android`
- **Body (JSON)**:
  ```json
  {
    "time_slots": [
      {
        "name": "Ramzan Early Night Slot",
        "start_time": "19:00:00",
        "end_time": "21:00:00",
        "start_date": "2026-06-01",
        "end_date": "2026-06-30"
      }
    ]
  }
  ```

### 5.2 Retrieve Gym Profile
- **Method**: `GET`
- **Path**: `/api/v1/fitnesscenter/organization/{{ORG_ID}}/`
- **Headers**:
  - `Authorization`: `Bearer {{MentorToken}}`
- **Expected Response (200)**:
  ```json
  {
    "success": true,
    "result": {
      "id": 22,
      "name": "Yesterday Testing Gym",
      "time_slots": [
        {
          "id": 5,
          "name": "Ramzan Early Night Slot",
          "start_time": "19:00:00",
          "end_time": "21:00:00",
          "start_date": "2026-06-01",
          "end_date": "2026-06-30",
          "is_currently_active": true
        }
      ]
    }
  }
  ```

---

## 🤝 Part 6: Trainer Direct Add & Email Sync

Allow gym owners to directly invite a trainer by mobile number. If the trainer exists in the database under a different email, their email is automatically synchronized and updated.

### 6.1 Direct Add / Invite Trainer
- **Method**: `POST`
- **Path**: `/api/v1/fitnesscenter/trainer-requests/add/`
- **Headers**:
  - `Authorization`: `Bearer {{MentorToken}}`
- **Body (JSON)**:
  ```json
  {
    "organization_id": 22,
    "mobile": "+919999999123",
    "first_name": "John",
    "last_name": "Trainer",
    "email": "john.new_email@example.com"
  }
  ```
- **Expected Response (200)**:
  ```json
  {
    "status": "success",
    "message": "John Trainer added to organization.",
    "trainer_id": 12,
    "link_id": 34,
    "is_new_account": false
  }
  ```

---

## 👥 Part 7: Staff Management (Admin Only)

Org staff creation is restricted to Admin/Superuser tokens. Standard Mentor logins will receive a `403 Forbidden` response.

### 7.1 Create / Update Organization Staff
- **Method**: `POST`
- **Path**: `/api/v1/fitnesscenter/organization/create-staff/`
- **Headers**:
  - `Authorization`: `Bearer {{AdminToken}}`
- **Body (JSON)**:
  ```json
  {
    "organization_id": 22,
    "username": "yesterday_staff_editor",
    "password": "SecureStaffPass@123",
    "first_name": "TestStaff",
    "last_name": "Yesterday",
    "email": "staff_updated@example.com"
  }
  ```
- **Expected Response (200)**:
  ```json
  {
    "success": true,
    "message": "User and OrgStaff created/updated successfully.",
    "user_id": 42
  }
  ```
