# 🚀 Postman Testing Guide: Gym Equipment & Database Exercise Substitution

This guide walks you through testing the new gym-specific equipment mapping and local exercise substitution endpoints in Postman.

---

## 🛠️ Step 1: List Gym Equipment (GET)

Use this request to see what equipment is currently available at a specific gym.

*   **Method**: `GET`
*   **URL**: `{{baseUrl}}/api/v1/fitnesscenter/gym-equipments/?organization_id=22`
*   **Headers**:
    *   `Authorization`: `Bearer {{CustomerToken}}`
    *   `X-Platform`: `customer-app-android`

#### Postman Setup:
1.  Set the request type to `GET`.
2.  Paste the URL and replace `22` with your gym's organization ID.
3.  Add the `Authorization` header under the **Headers** tab.
4.  Click **Send**.

---

## ⚙️ Step 2: Update Gym Equipment Inventory (POST)

Use this request to simulate a gym owner changing or setting up their gym's available equipment list.

*   **Method**: `POST`
*   **URL**: `{{baseUrl}}/api/v1/fitnesscenter/gym-equipments/update/`
*   **Headers**:
    *   `Authorization`: `Bearer {{MentorToken}}`
    *   `Content-Type`: `application/json`
*   **Body** (Select **raw** and set format to **JSON**):
    ```json
    {
      "organization_id": 22,
      "equipment_ids": [1, 2, 5, 8] // IDs representing Dumbbells, Barbells, Cables, Bench, etc.
    }
    ```

#### Postman Setup:
1.  Set the request type to `POST`.
2.  Go to the **Body** tab, select **raw**, choose **JSON** in the dropdown.
3.  Paste the JSON body above.
4.  Click **Send** and verify you get a `200 OK` success response.

---

## 🔄 Step 3: Test Local Exercise Swap/Substitution (POST)

Use this request to test swapping an exercise when equipment is missing.

*   **Method**: `POST`
*   **URL**: `{{baseUrl}}/api/v1/customer/exercises/swap/`
*   **Headers**:
    *   `Authorization`: `Bearer {{CustomerToken}}`
    *   `Content-Type`: `application/json`
    *   `X-Platform`: `customer-app-android`
*   **Body** (Select **raw** and set format to **JSON**):
    ```json
    {
      "original_exercise_id": 14, // ID of an exercise (e.g., Barbell Bench Press)
      "organization_id": 22       // The Gym ID
    }
    ```

#### Postman Setup:
1.  Set the request type to `POST`.
2.  Go to the **Body** tab, select **raw**, choose **JSON** in the dropdown.
3.  Enter the JSON body containing the ID of the exercise you want to substitute and the Gym's ID.
4.  Click **Send** and verify that the backend returns up to 3 exercises targeting the same muscle group using only the equipment IDs (`[1, 2, 5, 8]`) saved in Step 2.
