# Postman API Guide: Workouts & Training Plans

This guide documents the two primary workout plan flows in the **Discipl** platform:
1. **Flow A**: Mentor/Trainer creates a workout plan and assigns it to a gym customer.
2. **Flow B**: Customer creates their own individual workout plan.

---

## 🛠️ Global Configuration

Set up these variables and headers in Postman for all requests:
- **Base URL**: `https://discipl-backend-u0w9.onrender.com` (Live) or `http://127.0.0.1:8000` (Local)
- **Common Headers**:
  - `Content-Type`: `application/json`
  - `X-Platform`: `customer-app-android` *(for Customer App)* or `mentor-app-android` *(for Mentor/Trainer App)*

---

## 🔑 Authentication Guide

Use the master OTP numbers to authenticate and receive Bearer tokens.

### A. Authenticate as Mentor / Trainer
To create trainer workout plans, the user must have role **35 (MENTOR_TRAINER)** so a `Trainer` profile is active.

#### 1. Request OTP (Mentor)
- **Method**: `POST`
- **Path**: `/api/v1/user/send-otp/`
- **Headers**:
  - `X-Platform`: `mentor-app-android`
- **Body**:
  ```json
  {
    "mobile_number": "+919797979797",
    "process": "registration",
    "source": "mentor-app-android"
  }
  ```

#### 2. Verify OTP & Upgrade Role to 35 (Mentor Onboarding)
- **Method**: `POST`
- **Path**: `/api/v1/user/onboarding/`
- **Headers**:
  - `X-Platform`: `mentor-app-android`
- **Body**:
  ```json
  {
    "otp_id": "<OTP_ID_FROM_PREVIOUS_STEP>",
    "otp": "2222",
    "mobile_number": "+919797979797",
    "first_name": "TestMentor",
    "last_name": "RenderTest",
    "user_role": "35",
    "process": "registration",
    "source": "mentor-app-android"
  }
  ```
- **Response**: Keep the `"access"` token. Set it as your Postman Environment Variable `{{MentorToken}}`.

---

### B. Authenticate as Customer
Use the dedicated live customer testing profile.

#### 1. Request OTP (Customer)
- **Method**: `POST`
- **Path**: `/api/v1/user/send-otp/`
- **Headers**:
  - `X-Platform`: `customer-app-android`
- **Body**:
  ```json
  {
    "mobile_number": "+919400520374",
    "process": "login",
    "source": "customer-app-android"
  }
  ```

#### 2. Verify OTP (Customer)
- **Method**: `POST`
- **Path**: `/api/v1/user/otp/verify/`
- **Headers**:
  - `X-Platform`: `customer-app-android`
- **Body**:
  ```json
  {
    "otp_id": "<OTP_ID_FROM_PREVIOUS_STEP>",
    "mobile_number": "+919400520374",
    "otp": "2222",
    "source": "customer-app-android",
    "process": "login"
  }
  ```
- **Response**: Keep the `"access"` token. Set it as your Postman Environment Variable `{{CustomerToken}}`.

---

## 🏋️ Flow A: Mentor/Trainer Workout Plan Assignment

Follow this sequence to create a plan as a Trainer, structure days/exercises, and assign it to a client.

### Step A.1: Create Trainer Workout Plan
Initialize a template program.
- **Method**: `POST`
- **Path**: `/api/v1/trainer/workout-plans/`
- **Headers**:
  - `Authorization`: `Bearer {{MentorToken}}` 
  - `X-Platform`: `mentor-app-android`
- **Body**:
  ```json
  {
    "plan_name": "Mentor Power Strength Plan",
    "description": "A high intensity strength building plan",
    "total_weeks": 2,
    "total_days": 6
  }
  ```
- **Response**: Save the returned `"id"` (e.g., `3`) as `{{PlanID}}`.

### Step A.2: Add Day to Workout Plan
- **Method**: `POST`
- **Path**: `/api/v1/trainer/workout-plans/{{PlanID}}/days/`
- **Headers**:
  - `Authorization`: `Bearer {{MentorToken}}`
  - `X-Platform`: `mentor-app-android`
- **Body**:
  ```json
  {
    "day_number": 1,
    "title": "Push Day 1",
    "notes": "Focus on explosive pressing power"
  }
  ```
- **Response**: Save the returned `"id"` as `{{DayID}}`.

### Step A.3: Add Exercise to Workout Plan Day
Add an exercise (e.g., exercise ID `1` which is Barbell Bench Press) with specific template instructions.
- **Method**: `POST`
- **Path**: `/api/v1/trainer/plan-days/{{DayID}}/exercises/`
- **Headers**:
  - `Authorization`: `Bearer {{MentorToken}}`
  - `X-Platform`: `mentor-app-android`
- **Body**:
  ```json
  {
    "workout": 1,
    "video_url": "https://www.youtube.com/watch?v=gRVjAtPip0Y",
    "order_index": 1,
    "notes": "Control the negative and push explosively"
  }
  ```

### Step A.4: Assign Workout Plan to Customer
Assign this plan to Customer ID `17`.
- **Method**: `POST`
- **Path**: `/api/v1/trainer/workout-plans/{{PlanID}}/assign/`
- **Headers**:
  - `Authorization`: `Bearer {{MentorToken}}`
  - `X-Platform`: `mentor-app-android`
- **Body**:
  ```json
    {
      "customer_id": 17
    }
  ```
- **Response**: Save the returned `"id"` as `{{cwp_id}}` (CustomerWorkoutPlan link ID).

---

## 🧑‍💻 Flow B: Customer Individual Workout Plan Creation

Follow this sequence for customers to build and manage their own plans.

### Step B.1: Browse Exercises
Browse exercises from the global library to add to a custom plan.
- **Method**: `GET`
- **Path**: `/api/v1/customer/exercises/?search=Bench&muscle_group=Chest`
- **Headers**:
  - `Authorization`: `Bearer {{CustomerToken}}`
  - `X-Platform`: `customer-app-android`

### Step B.2: Create a Custom Workout Plan
- **Method**: `POST`
- **Path**: `/api/v1/customer/my-plans/`
- **Headers**:
  - `Authorization`: `Bearer {{CustomerToken}}`
  - `X-Platform`: `customer-app-android`
- **Body**:
  ```json
  {
    "plan_name": "My Custom HIIT Routine",
    "description": "My morning cardio and core workouts",
    "total_weeks": 1,
    "total_days": 3
  }
  ```
- **Response**: Save the returned `"id"` as `{{CustPlanID}}`.

### Step B.3: Add Day to Custom Workout Plan
- **Method**: `POST`
- **Path**: `/api/v1/customer/my-plans/{{CustPlanID}}/days/`
- **Headers**:
  - `Authorization`: `Bearer {{CustomerToken}}`
  - `X-Platform`: `customer-app-android`
- **Body**:
  ```json
  {
    "day_number": 1,
    "title": "HIIT Day 1",
    "notes": "Keep the heart rate high"
  }
  ```
- **Response**: Save the returned `"id"` as `{{CustDayID}}`.

### Step B.4: Add Exercise to Custom Workout Plan Day
Add an exercise (e.g. exercise ID `23` which is Burpees) to the custom day.
- **Method**: `POST`
- **Path**: `/api/v1/customer/my-plans/day/{{CustDayID}}/exercises/`
- **Headers**:
  - `Authorization`: `Bearer {{CustomerToken}}`
  - `X-Platform`: `customer-app-android`
- **Body**:
  ```json
  {
    "workout": 23,
    "video_url": "https://www.youtube.com/watch?v=TU8QYVW0gDU",
    "order_index": 1,
    "notes": "No rest between reps"
  }
  ```

### Step B.5: List Customer's Own Custom Workout Plans
- **Method**: `GET`
- **Path**: `/api/v1/customer/my-plans/`
- **Headers**:
  - `Authorization`: `Bearer {{CustomerToken}}`
  - `X-Platform`: `customer-app-android`

---

## 📅 Flow C: Customer Viewing & Executing Workouts

Customers can view assigned plans (from Mentor or Customer) and track logs.

### Step C.1: View Customer Workout Calendar (Assigned Plans)
Retrieve all active plans for a specific date (defaults to today).
- **Method**: `GET`
- **Path**: `/api/v1/customer/workout-log/?date=2026-06-05`
- **Headers**:
  - `Authorization`: `Bearer {{CustomerToken}}`
  - `X-Platform`: `customer-app-android`

### Step C.2: Get Plan Days (Assigned by Mentor)
Retrieve structural plan days of the assigned trainer plan.
- **Method**: `GET`
- **Path**: `/api/v1/customer/workout-plans/{{cwp_id}}/days/`
- **Headers**:
  - `Authorization`: `Bearer {{CustomerToken}}`
  - `X-Platform`: `customer-app-android`
