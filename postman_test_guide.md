# Postman API Verification Guide

This guide provides step-by-step instructions to verify the backend features implemented recently on the Render live environment:
1. **Dynamic Time Slots** (with Active Date Range and `is_currently_active` status)
2. **Trainer Direct Add & Email Updates** (handles existing user email updates)
3. **Staff Creation & Email Updates** (only accessible by Admin/Superuser roles)

---

## 🛠️ Global Configuration
Before starting, ensure you set up these parameters in your Postman environment or request headers:
- **Base URL**: `https://discipl-backend-u0w9.onrender.com`
- **Headers**:
  - `Content-Type`: `application/json`
  - `X-Platform`: `mentor-app-android` (or `vendor-app-android` for trainer endpoints)
  - `Authorization`: `Bearer <YOUR_ACCESS_TOKEN>`

---

## 1. Dynamic Time Slots Verification

This feature introduces `start_date`, `end_date`, and a dynamic `is_currently_active` flag computed on-the-fly.

### Step 1.1: Update Gym Time Slots (POST/PATCH)
This updates the organization's operating hours and Ramzan/Special slots.

- **Method**: `PATCH`
- **URL**: `{{BaseURL}}/api/v1/fitnesscenter/organization/{{ORG_ID}}/update/`
- **Headers**:
  - `Authorization`: `Bearer <MENTOR_ACCESS_TOKEN>`
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
    },
    {
      "name": "Ramzan Midnight Special",
      "start_time": "23:00:00",
      "end_time": "01:00:00",
      "start_date": "2026-06-01",
      "end_date": "2026-06-30"
    }
  ]
}
```

### Step 1.2: Retrieve Gym Profile & Check Status (GET)
Check if the returned time slots compute the correct `is_currently_active` boolean value based on today's date.

- **Method**: `GET`
- **URL**: `{{BaseURL}}/api/v1/fitnesscenter/organization/{{ORG_ID}}/`
- **Headers**:
  - `Authorization`: `Bearer <MENTOR_ACCESS_TOKEN>`
- **Expected Response (Snippet)**:
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

## 2. Trainer Direct Add & Email Updates

This feature allows a gym mentor to directly add a trainer. If the trainer already exists with a different email, it automatically updates their email address under the hood.

> [!NOTE]
> To test the email update flow, you must add the trainer to two different gyms sequentially using the same mobile number. A trainer cannot be linked to the same gym twice.

### Step 2.1: Initial Direct Add (Gym A)
Create the trainer account with their initial email.

- **Method**: `POST`
- **URL**: `{{BaseURL}}/api/v1/fitnesscenter/trainer-requests/add/`
- **Headers**:
  - `Authorization`: `Bearer <MENTOR_ACCESS_TOKEN>`
- **Body (JSON)**:
```json
{
  "organization_id": {{GYM_A_ID}},
  "mobile": "+919999999123",
  "first_name": "John",
  "last_name": "Trainer",
  "email": "john.initial@example.com"
}
```
- **Expected Response**:
```json
{
  "status": "success",
  "message": "John Trainer added to Gym A.",
  "trainer_id": 12,
  "link_id": 34,
  "is_new_account": true
}
```

### Step 2.2: Subsequent Direct Add with New Email (Gym B)
Link the same trainer to a different gym and verify their email updates to the new address.

- **Method**: `POST`
- **URL**: `{{BaseURL}}/api/v1/fitnesscenter/trainer-requests/add/`
- **Headers**:
  - `Authorization`: `Bearer <MENTOR_ACCESS_TOKEN>`
- **Body (JSON)**:
```json
{
  "organization_id": {{GYM_B_ID}},
  "mobile": "+919999999123",
  "first_name": "John",
  "last_name": "Trainer",
  "email": "john.updated@example.com"
}
```
- **Expected Response**:
```json
{
  "status": "success",
  "message": "John Trainer added to Gym B.",
  "trainer_id": 12,
  "link_id": 35,
  "is_new_account": false
}
```

---

## 3. Staff Creation & Email Updates

Staff creation is restricted to **Admin/Superuser** accounts. Mentors will receive a `403 Forbidden` error.

> [!IMPORTANT]
> To test this, you must run the request using an Admin/Superuser access token.

### Step 3.1: Create Staff (First Time)
Create a new staff user linked to an organization.

- **Method**: `POST`
- **URL**: `{{BaseURL}}/api/v1/fitnesscenter/organization/create-staff/`
- **Headers**:
  - `Authorization`: `Bearer <ADMIN_SUPERUSER_TOKEN>`
- **Body (JSON)**:
```json
{
  "organization_id": {{ORG_ID}},
  "username": "yesterday_staff_editor",
  "password": "SecureStaffPass@123",
  "first_name": "TestStaff",
  "last_name": "Yesterday",
  "email": "staff_initial@example.com"
}
```
- **Expected Response**:
```json
{
  "success": true,
  "message": "User and OrgStaff created successfully.",
  "user_id": 42
}
```

### Step 3.2: Subsequent Staff Creation (Email Update)
Re-run the same request (same username) but with a different email address to test the email update functionality.

- **Method**: `POST`
- **URL**: `{{BaseURL}}/api/v1/fitnesscenter/organization/create-staff/`
- **Headers**:
  - `Authorization`: `Bearer <ADMIN_SUPERUSER_TOKEN>`
- **Body (JSON)**:
```json
{
  "organization_id": {{ORG_ID}},
  "username": "yesterday_staff_editor",
  "password": "SecureStaffPass@123",
  "first_name": "TestStaff",
  "last_name": "Yesterday",
  "email": "staff_updated@example.com"
}
```
- **Expected Response**:
```json
{
  "success": true,
  "message": "User and OrgStaff updated successfully.",
  "user_id": 42
}
```

---

## 4. User Profile Update (PATCH)
 
This endpoint allows any authenticated user (e.g., Mentors, Gym Owners, Trainers, Customers) to update their own profile fields directly while logged in.
 
> [!TIP]
> **Automatic Email Sync for Mentors / Staff**: If the authenticated user is a **Mentor** (or has a `mentor_profile`), changing their profile email will automatically synchronize and update the email of any associated gym/organization (`Organization.email`) that they belong to or manage.
 
- **Method**: `PATCH`
- **URL**: `{{BaseURL}}/api/v1/user/profile/update/`
- **Headers**:
  - `Authorization`: `Bearer <LOGGED_IN_USER_TOKEN>`
- **Body (JSON)**:
```json
{
  "email": "my_new_email@example.com",
  "first_name": "UpdatedFirstName",
  "last_name": "UpdatedLastName",
  "gender": "male",
  "date_of_birth": "1995-10-15"
}
```
 
**Expected Response (200):**
```json
{
  "success": true,
  "message": "Profile updated successfully.",
  "user": {
    "id": 459,
    "first_name": "UpdatedFirstName",
    "last_name": "UpdatedLastName",
    "mobile_number": "+919999999999",
    "email": "my_new_email@example.com",
    "blood_group": "Unknown",
    "last_login": "2026-06-05T09:09:11Z",
    "role": "Mentor",
    "user_role": 20,
    "mentor": {
      "id": 12,
      "name": "UpdatedFirstName",
      "organization": {
        "id": 5,
        "name": "Test Gym Name",
        "profile_completeness": 80
      }
    }
  }
}
```
 
---
 
## 5. Verification on Render (Gym / Organization Email Sync)
To verify that the email update propagates correctly to the organization:
1. Log in with the Mentor user credentials to get their access token.
2. Call `PATCH /api/v1/user/profile/update/` to change the email.
3. Retrieve the organization profile via `GET /api/v1/fitnesscenter/organization/{{ORG_ID}}/` or check the Django Admin panel under **Organizations**.
4. Confirm that the gym's email now displays the updated email address.
