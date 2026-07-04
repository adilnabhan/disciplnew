# 🏋️ Postman API Guide: Gym Enquiry & Membership Requests (Join Requests)

This guide documents the API endpoints for managing customer enquiries and membership requests at fitness centers.

---

## 🛠️ Global Configuration
Set up these variables in your Postman environment:
*   **Base URL**: `https://discipl-backend-u0w9.onrender.com` (Live) or `http://127.0.0.1:8000` (Local)
*   **X-Platform Headers**:
    *   `customer-app-android` (for Customer App enquiries)
    *   `mentor-app-android` (for Gym Owners / Mentors to list and accept requests)

---

## 🧑‍💻 1. Customer Side (Enquiries & Join Requests)

### Step 1.1: Submit a Gym Enquiry / Request Membership
A customer submits an enquiry to a fitness center, optionally choosing a specific plan, payment mode preference, and adding notes.
*   **Method**: `POST`
*   **Path**: `/api/v1/customer/membership-request/create/`
*   **Headers**:
    *   `Authorization`: `Bearer {{CustomerToken}}`
    *   `X-Platform`: `customer-app-android`
*   **Body (JSON)**:
    ```json
    {
      "organization": 22, // ID of the Gym/Fitness Center (Required)
      "membership_plan": 3, // ID of the requested plan (Optional)
      "notes": "I would like to inquire about personal training and a discount.", // (Optional)
      "payment_mode": "cash" // Preferences: "cash", "online", "offline" (Optional)
    }
    ```
*   **Response (201 Created)**:
    ```json
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
    ```

### Step 1.2: View My Enquiries / Request History
List all enquiries made by the currently logged-in customer.
*   **Method**: `GET`
*   **Path**: `/api/v1/customer/membership-request/list/`
*   *   **Query Params (Optional)**: `status` (e.g. `pending`, `contacted`, `accepted`, `rejected`)
*   **Headers**:
    *   `Authorization`: `Bearer {{CustomerToken}}`
    *   `X-Platform`: `customer-app-android`
*   **Response (200 OK)**:
    ```json
    [
      {
        "id": 15,
        "customer": 12,
        "customer_name": "Rohan Dev",
        ...
        "status": "pending"
      }
    ]
    ```

---

## 🏢 2. Gym / Fitness Center Side (Manager Flow)

### Step 2.1: List Gym Enquiries / Requests
List all incoming customer membership requests and trainer link requests.
*   **Method**: `GET`
*   **Path**: `/api/v1/fitnesscenter/membership-requests/`
*   **Headers**:
    *   `Authorization`: `Bearer {{MentorToken}}`
    *   `X-Platform`: `mentor-app-android`
*   **Query Params**:
    *   `organization_id`: `22` (Required)
    *   `status`: `pending` (Optional: filter by status)
    *   `type`: `customer` (Optional: filter only `customer` requests or `trainer` requests)
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

### Step 2.2: Handle / Respond to Enquiry (Action)
Update status of the request to `"contacted"`, `"accepted"`, or `"rejected"`.

#### Option A: Set to "contacted" (Send gym contact info)
*   **Method**: `PATCH`
*   **Path**: `/api/v1/fitnesscenter/membership-requests/15/action/`
*   **Body (JSON)**:
    ```json
    {
      "status": "contacted",
      "contact_info": {
        "phone": "+919876543210",
        "email": "gym@example.com",
        "whatsapp": "+919876543210"
      },
      "gym_remarks": "We will call you shortly to discuss pricing."
    }
    ```

#### Option B: Set to "accepted" (Approve & start membership)
*   **Method**: `PATCH`
*   **Path**: `/api/v1/fitnesscenter/membership-requests/15/action/`
*   **Body (JSON)**:
    ```json
    {
      "status": "accepted",
      "selected_plan": 3, // The Plan ID to assign (Required on accept)
      "start_date": "2026-06-12T00:00:00Z", // Required on accept
      "end_date": "2026-07-12T00:00:00Z", // Required on accept
      "amount": 2000.00, // Custom negotiated price (Optional: falls back to plan price)
      "discount": 500.00, // (Optional)
      "payment_mode": "cash", // "cash", "online", "offline" (Optional)
      "transaction_number": "TXN_CASH_012", // (Optional)
      "gym_remarks": "Offered ₹500 discount for 1 month"
    }
    ```

#### Option C: Set to "rejected" (Decline request)
*   **Method**: `PATCH`
*   **Path**: `/api/v1/fitnesscenter/membership-requests/15/action/`
*   **Body (JSON)**:
    ```json
    {
      "status": "rejected",
      "gym_remarks": "We have no available capacity/slots at the moment."
    }
    ```
*   **Response (200 OK)**:
    ```json
    {
      "status": "success",
      "message": "Membership request has been accepted.",
      "data": {
        "id": 15,
        "customer": 12,
        "customer_name": "Rohan Dev",
        "customer_phone": "+919400520374",
        "customer_profile_picture": "http://127.0.0.1:8000/media/profiles/profile.png",
        "membership_plan": 3,
        "requested_plan_name": "Premium Plan",
        "selected_plan": 3,
        "selected_plan_name": "Premium Plan",
        "status": "accepted",
        "payment_mode": "cash",
        "notes": "I would like to inquire about personal training and a discount.",
        "gym_remarks": "Offered ₹500 discount for 1 month",
        "contact_info": null,
        "accepted_amount": "2000.00",
        "discount_amount": "500.00",
        "start_date": "2026-06-12T00:00:00Z",
        "end_date": "2026-07-12T00:00:00Z",
        "transaction_number": "TXN_CASH_012",
        "requested_at": "2026-06-12T10:45:12.498Z",
        "responded_at": "2026-06-12T10:50:33.123Z"
      }
    }
    ```
