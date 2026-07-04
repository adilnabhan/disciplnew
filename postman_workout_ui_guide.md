# 🏋️ Postman API Guide: Workout Plan & Log Tracking (UI Flow Mapping)

This guide maps the specific UI designs you provided to the Django backend endpoints in the **Discipl** platform:
1. **First Design**: Log Workout Session & Track/Update Sets (checking off sets, adding dynamic sets, custom session naming/finish title).
2. **Second Design**: Create a Custom Exercise (Workout Name, Muscle, Type, Equipment, Video URL).

---

## 🛠️ Global Configuration
Set up these variables in your Postman environment:
*   **Base URL**: `https://discipl-backend-u0w9.onrender.com` (Live) or `http://127.0.0.1:8000` (Local)
*   **X-Platform Headers**: 
    *   `customer-app-android` (for logging workouts and building custom plans)
    *   `mentor-app-android` (for creating exercises as a trainer)
*   **Auth Tokens**: Retrieve `{{CustomerToken}}` or `{{TrainerToken}}` via OTP verification.

---

## 📋 1. Create Exercise Flow (Second UI Screen)
This maps directly to the form shown in your **Create new Workout / Create Exercise** screen. Both trainers and customers can now create private exercises that will show up in their respective libraries.

### Step 1.1: Fetch Reference Data (Dropdown Choices)
To populate the dropdown fields in the UI, make these `GET` requests:
1.  **Muscle Dropdown**:
    *   **Method**: `GET`
    *   **Path**: `/api/v1/trainer/muscle-groups/` (For trainers) or `/api/v1/customer/exercises/` (Search filter lists)
2.  **Equipment Dropdown**:
    *   **Method**: `GET`
    *   **Path**: `/api/v1/trainer/equipment/`
3.  **Exercise Type Dropdown**:
    *   **Method**: `GET`
    *   **Path**: `/api/v1/trainer/exercise-types/`

### Step 1.2: Submit the Exercise Form
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/exercises/` (For Customer App) or `/api/v1/trainer/exercises/` (For Trainer App)
*   **Headers**:
    *   `Authorization`: `Bearer {{Token}}`
    *   `X-Platform`: `customer-app-android` (or `mentor-app-android`)
*   **Body (JSON)**:
    ```json
    {
      "name": "Barbell Bench Press",
      "description": "Chest press on a flat barbell bench",
      "type": "strength",
      "primary_muscle_group": 1,
      "equipment": 2,
      "video_url": "https://www.youtube.com/watch?v=gRVjAtPip0Y",
      "instructions": "Keep feet flat on the floor, grip the bar slightly wider than shoulder width."
    }
    ```
*   **Response**: Returns the created Exercise object with its new `"id"`. It is now in the user's private library.

---

## 🧑‍💻 2. Create Custom Workout Plan ("Our Own" Flow)
For a customer building their own routine.

### Step 2.1: Create Workout Plan
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/my-plans/`
*   **Headers**:
    *   `Authorization`: `Bearer {{CustomerToken}}`
    *   `X-Platform`: `customer-app-android`
*   **Body (JSON)**:
    ```json
    {
      "plan_name": "My Custom HIIT Routine",
      "description": "My morning cardio and core workouts",
      "total_weeks": 1,
      "total_days": 3
    }
    ```
*   **Response**: Save the returned `"id"` as `{{CustPlanID}}`.

### Step 2.2: Add Day to Custom Workout Plan
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/my-plans/{{CustPlanID}}/days/`
*   **Headers**: `Authorization: Bearer {{CustomerToken}}`
*   **Body (JSON)**:
    ```json
    {
      "day_number": 1,
      "title": "Push Day 1",
      "notes": "Focus on chest and triceps"
    }
    ```
*   **Response**: Save the returned `"id"` as `{{CustDayID}}`.

### Step 2.3: Add Exercise to Day (Pre-Populated Sets)
Add an exercise to the day and initialize the template sets:
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/my-plans/day/{{CustDayID}}/exercises/`
*   **Headers**: `Authorization: Bearer {{CustomerToken}}`
*   **Body (JSON)**:
    ```json
    {
      "workout": 1,
      "video_url": "https://www.youtube.com/watch?v=gRVjAtPip0Y",
      "order_index": 1,
      "notes": "3 sets with progressive overload",
      "sets": [
        { "set_number": 1, "target_reps": 15, "target_weight": 10.0 },
        { "set_number": 2, "target_reps": 15, "target_weight": 10.0 },
        { "set_number": 3, "target_reps": 15, "target_weight": 12.5 }
      ]
    }
    ```

---

## 📅 3. Logging & Executing Workouts (First UI Screen)
This maps directly to your **Workout Session / Set Logging** table screen.

### Step 3.1: Start the Workout Session
Initialize the active session for the selected plan day (creates logs and pre-populates previous records/templates). You can optionally pass a custom session title.
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/sessions/start/`
*   **Headers**:
    *   `Authorization`: `Bearer {{CustomerToken}}`
    *   `X-Platform`: `customer-app-android`
*   **Body (JSON)**:
    ```json
    {
      "customer_workout_plan_id": 1, 
      "plan_day_id": 2,
      "title": "Chest & Triceps Day" // Optional: custom session name
    }
    ```
    *(Note: You can also send an **empty body** `{}` to start an empty workout session. The API will automatically initialize an ad-hoc custom workout plan and day for you).*
*   **Response**: Returns the workout session with initialized `logs`, its `"title"`, and the associated `"plan_day"` ID. Each exercise log contains `set_logs` with unique `id`s for each set row.

### Step 3.2: Dynamically Add Exercise to Active Session
When starting an empty workout session (or during an active session) and clicking the **Add Exercise** button to select an exercise from your library:
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/my-plans/day/{{plan_day_id}}/exercises/`
*   **Headers**: `Authorization: Bearer {{CustomerToken}}`
*   **Body (JSON)**:
    ```json
    {
      "workout": 1, // The exercise ID from the library
      "order_index": 1,
      "sets": [
        { "set_number": 1, "target_reps": 10, "target_weight": 20.0 }
      ]
    }
    ```
*   **Response**: Automatically syncs and adds a new `WorkoutLog` and `ExerciseSetLog` directly into your active session. You can then check/edit the sets.

### Step 3.3: Log/Check a Set (Checking the row checkmark)
When the user clicks the checkbox for a set row:
*   **Method**: `PATCH`
*   **Path**: `/api/v1/customer/set-logs/{{set_log_id}}/`
*   **Headers**: `Authorization: Bearer {{CustomerToken}}`
*   **Body (JSON)**:
    ```json
    {
      "weight_kg": 10.0,
      "reps": 15,
      "is_completed": true
    }
    ```
*   **Response**: Returns the updated `is_completed: true` status.

### Step 3.4: Dynamic Set Addition (Tapping "+ Add a Set" button)
When the user taps the "+ Add a Set" button:
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/workout-logs/{{workout_log_id}}/sets/`
*   **Headers**: `Authorization: Bearer {{CustomerToken}}`
*   **Body (JSON)**:
    ```json
    {
      "weight_kg": 12.5,
      "reps": 15
    }
    ```
*   **Response**: Returns the new `set_log` with its `id` and `set_number` (automatically incremented). When checked, update it via `PATCH` (Step 3.3).

### Step 3.5: Finish Workout Session (Entering Title - REQUIRED)
Submit when the user completes their workout session. The custom title is **required** to finish the session.
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/sessions/{{session_id}}/finish/`
*   **Headers**: `Authorization: Bearer {{CustomerToken}}`
*   **Body (JSON)**:
    ```json
    {
      "title": "Chest/ Barbell/ Volume- Reps" // REQUIRED: Custom session title entered on finish
    }
    ```
*   **Response**: Returns the updated session including the finalized `"title"` and status `"completed"`.
