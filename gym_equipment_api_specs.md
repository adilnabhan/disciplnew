# 📝 Backend API Specifications: Gym-Specific Equipment & Database-Driven Substitution

Hey Team, here is the exact API specification to implement the **Gym-Specific Equipment Check** and **Local Database-Driven Exercise Swap** (no third-party AI APIs required).

---

## 🏢 1. Gym Equipment Inventory APIs

These endpoints manage the association between an **Organization (Gym)** and the **Equipment** they have physically available.

### 1.1 List Gym Equipment
Retrieve the list of equipment available at a specific gym branch.
*   **Method**: `GET`
*   **Path**: `/api/v1/fitnesscenter/gym-equipments/`
*   **Query Parameters**:
    *   `organization_id` (integer, Required): ID of the gym.
*   **Sample Response (200 OK)**:
    ```json
    {
      "organization_id": 22,
      "organization_name": "Iron Gym",
      "available_equipment": [
        { "id": 1, "name": "Dumbbell" },
        { "id": 2, "name": "Barbell" },
        { "id": 5, "name": "Cable Machine" }
      ]
    }
    ```

### 1.2 Update Gym Equipment Inventory
Allows a gym owner or mentor to save/update what equipment they have in their facility.
*   **Method**: `POST`
*   **Path**: `/api/v1/fitnesscenter/gym-equipments/update/`
*   **Headers**: `Authorization: Bearer {{MentorToken}}`
*   **Body (JSON)**:
    ```json
    {
      "organization_id": 22,
      "equipment_ids": [1, 2, 5, 8] // Array of Equipment IDs to associate
    }
    ```
*   **Sample Response (200 OK)**:
    ```json
    {
      "status": "success",
      "message": "Gym equipment inventory updated successfully.",
      "total_count": 4
    }
    ```

---

## 💻 2. Local Database-Driven Exercise Substitution API (No External AI Needed)

This endpoint handles the exercise swaps locally using database queries matching target muscle groups and gym equipment.

### 2.1 Request Exercise Substitutions
Suggest alternative exercises from the database that target the same muscle group but only require equipment currently available at the user's gym.
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/exercises/swap/`
*   **Headers**: `Authorization: Bearer {{CustomerToken}}`
*   **Body (JSON)**:
    ```json
    {
      "original_exercise_id": 14, // ID of the exercise they cannot perform
      "organization_id": 22       // Gym ID to look up available inventory
    }
    ```

#### Django Backend Implementation Logic:
```python
# 1. Fetch the original exercise's primary muscle group
original_exercise = Workout.objects.get(id=original_exercise_id)
muscle_group_id = original_exercise.primary_muscle_group_id

# 2. Get the list of active/available equipment IDs at this gym organization
available_equipment_ids = GymEquipment.objects.filter(
    organization_id=organization_id,
    is_functional=True
).values_list('equipment_id', flat=True)

# 3. Query exercises targeting the same muscle group that only use available equipment
substitutes = Workout.objects.filter(
    primary_muscle_group_id=muscle_group_id,
    equipment_id__in=available_equipment_ids
).exclude(id=original_exercise_id)[:3]

# 4. Serialize and return the result
```

*   **Sample Response (200 OK)**:
    ```json
    [
      {
        "id": 105,
        "name": "Dumbbell Bench Press",
        "description": "Chest press using dumbbells",
        "type": "strength",
        "primary_muscle_group": 1,
        "primary_muscle_group_name": "Chest",
        "equipment": 1,
        "equipment_name": "Dumbbell",
        "video_url": "https://www.youtube.com/watch?v=...",
        "instructions": "Lie flat on a bench and press dumbbells upward."
      },
      {
        "id": 182,
        "name": "Low-to-High Cable Fly",
        "description": "Cable fly targeting upper chest",
        "type": "strength",
        "primary_muscle_group": 1,
        "primary_muscle_group_name": "Chest",
        "equipment": 5,
        "equipment_name": "Cable Machine",
        "video_url": "https://www.youtube.com/watch?v=...",
        "instructions": "Bring handles together in an upward arc."
      }
    ]
    ```
