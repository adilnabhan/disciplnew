# 🖥️ UI Integration: Dashboard Connection Guide for Workout Logs & Join Requests

This guide explains how the front-end components connect to the backend APIs to display **Completed Sessions** (workout calendar logs) and **Pending Requests** (membership enquiries).

---

## 🏋️ 1. Workout Tracker: Completed vs. Pending Sessions

### 1.1 Fetching Workout Status for a Given Date
The dashboard calendar and daily workout details card should query the workout calendar logs API.

*   **API Endpoint**: `GET /api/v1/customer/workout-log/`
*   **Query Parameters**:
    *   `date`: Date string in `YYYY-MM-DD` format (defaults to the current date).
*   **Sample Response**:
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
        "source": "trainer",
        "membership_status": "active",
        "is_primary": true
      }
    ]
    ```

### 1.2 UI Mapping Logic
For each day on the calendar or the daily overview widget:
1.  **Completed Session (Completed Design)**:
    *   **Condition**: `session_id !== null && is_completed === true`
    *   **UI Treatment**: Show a filled checkmark (e.g. Green Tick), duration/summary stats, and a read-only list of performed sets.
2.  **In-Progress Session**:
    *   **Condition**: `session_id !== null && is_completed === false`
    *   **UI Treatment**: Show an "In Progress" or "Resume" button that navigates directly to the live workout tracker screen.
3.  **Pending / Not Started (Pending Workout)**:
    *   **Condition**: `session_id === null`
    *   **UI Treatment**: Show a "Start Workout" or "Track Workout" action button.
4.  **Rest Day / No Plan**:
    *   **Condition**: The API returns an empty array `[]` for that date.
    *   **UI Treatment**: Display a placeholder indicating "Rest Day" or "No workouts scheduled".

---

## 🏢 2. Gym Enquiries: Pending Membership Requests

### 2.1 Fetching Membership / Gym Requests (Customer-side)
To display a "Pending Enquiries" list or warning card on the customer homepage, retrieve all join requests.

*   **API Endpoint**: `GET /api/v1/customer/membership-request/list/`
*   **Query Parameters (Optional)**:
    *   `status`: Filter by status (e.g. `?status=pending`)
*   **Sample Response**:
    ```json
    [
      {
        "id": 15,
        "organization_name": "Iron Gym",
        "requested_plan_name": "Premium Plan",
        "status": "pending",
        "requested_at": "2026-06-12T10:45:12.498Z"
      }
    ]
    ```

### 2.2 UI Mapping Logic
1.  **Pending Request Card (Pending Design)**:
    *   **Condition**: Any item in the array has `"status": "pending"`.
    *   **UI Treatment**: Show a status banner or card under the home header:
        > ⏳ **Join Request Pending** at **Iron Gym** for the **Premium Plan** (Requested on June 12, 2026).
2.  **Contacted Request Card**:
    *   **Condition**: Request has `"status": "contacted"`.
    *   **UI Treatment**: Show a card with the gym's response:
        > 📞 **Iron Gym Contacted You**: *"We will call you shortly to discuss pricing."* (Contact: gym@example.com).
3.  **Accepted Request (Subscribed State)**:
    *   **Condition**: Once a request status changes to `"accepted"`, the user has an active membership.
    *   **Alternate API**: You can also query the main customer homepage endpoint:
        *   `GET /api/v1/customer/customer-homepage/`
        *   Checks `is_subscribed: true` and renders the active membership plan information card.
