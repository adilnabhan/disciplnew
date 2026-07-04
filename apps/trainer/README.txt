TRAINER MODULE API DOCUMENTATION
=================================

BASE URL: /api/trainer/

NOTE: This module handles both TRAINERS and DIETITIANS
- Trainers have user_type='trainer' and User.MENTOR_TRAINER role (35)
- Dietitians have user_type='dietitian' and User.MENTOR_DIETITIAN role (36)

=================================
TRAINER CRUD OPERATIONS
=================================

1. LIST ALL TRAINERS
   GET /trainers/
   Response: List of all trainers and dietitians

2. CREATE TRAINER
   POST /trainers/
   Body: Trainer data
   Response: Created trainer object

3. GET TRAINER DETAILS
   GET /trainers/{pk}/
   Response: Complete trainer profile with all related data:
   - Basic information
   - Specializations
   - Certifications
   - Work experiences
   - Portfolios
   - Transformations/Recognitions
   - Languages
   - Plans
   - Locations
   - Social links

4. UPDATE TRAINER
   PUT /trainers/{pk}/
   Body: Updated trainer data
   Response: Updated trainer object

5. DELETE TRAINER
   DELETE /trainers/{pk}/
   Response: 204 No Content

=================================
ONBOARDING APIS
=================================

6. TRAINER/DIETITIAN BASIC DETAILS
   POST /trainers/basic-details/
   Body: {
     "user_type": "trainer|dietitian",
     "first_name": "string",
     "last_name": "string",
     "email": "string",
     "mobile": "string",
     "gender": "male|female|other",
     "date_of_birth": "YYYY-MM-DD",
     "profile_image": "file"
   }
   Note: user_type determines User role (trainer=35, dietitian=36)
   Response: Created trainer with profile_step=2 and linked User account

   PUT /trainers/{trainer_id}/basic-details/
   Body: Same as POST (partial update supported)
   Response: Updated trainer details

7. TRAINER EXPERIENCE & SPECIALIZATIONS
   POST /trainers/{trainer_id}/experience/
   Body: {
     "experience_years": integer,
     "bio": "string",
     "specializations": [1, 2, 3]
   }
   Response: {"message": "Experience details saved"}

8. GET SPECIALIZATIONS LIST
   GET /specializations/?user_type=trainer|dietitian
   Query Params:
   - user_type: Filter by 'trainer' or 'dietitian' (default: 'trainer')
   Response: List of specializations for the specified user type

9. UPLOAD CERTIFICATION
   POST /trainers/{trainer_id}/certifications/
   Content-Type: multipart/form-data
   Body: {
     "certificate_name": "string",
     "certificate_file": file
   }
   Response: {"id": certification_id}

=================================
WORK EXPERIENCE APIS
=================================

10. ADD WORK EXPERIENCE
    POST /trainers/{trainer_id}/workexperience/
    Body: {
      "organization_name": "string",
      "designation": "string",
      "start_date": "YYYY-MM-DD",
      "end_date": "YYYY-MM-DD",
      "currently_working": boolean,
      "description": "string"
    }
    Response: {"id": experience_id, "message": "Experience added"}

11. UPDATE WORK EXPERIENCE
    PUT /trainers/{trainer_id}/workexperience/{experience_id}/
    Body: Same as POST
    Response: {"id": experience_id, "message": "Experience updated"}

12. DELETE WORK EXPERIENCE
    DELETE /trainers/{trainer_id}/workexperience/{experience_id}/
    Response: {"message": "Experience deleted"}

=================================
RECOGNITION/TRANSFORMATION APIS
=================================

13. ADD RECOGNITION
    POST /trainers/{trainer_id}/recognitions/
    Content-Type: multipart/form-data
    Body: {
      "description": "string",
      "image_from": file,
      "image_to": file
    }
    Response: {"id": recognition_id}

14. UPDATE RECOGNITION
    PUT /trainers/{trainer_id}/recognitions/{recognition_id}/
    Content-Type: multipart/form-data
    Body: Same as POST (all fields optional)
    Response: {"id": recognition_id, "message": "Recognition updated"}

15. DELETE RECOGNITION
    DELETE /trainers/{trainer_id}/recognitions/{recognition_id}/
    Response: {"message": "Recognition deleted"}

=================================
PREFERENCES APIS
=================================

16. UPDATE WORK PREFERENCES
    PUT /trainers/{trainer_id}/preferences/
    Body: {
      "is_freelancer": boolean,
      "join_gym": boolean,
      "event_collaborator": boolean
    }
    Response: {"message": "Preferences updated"}

17. UPDATE PAY RANGE
    PUT /trainers/{trainer_id}/pay-range/
    Body: {
      "expected_pay_min": decimal,
      "expected_pay_max": decimal
    }
    Response: {"message": "Pay range updated"}

=================================
LOCATION PREFERENCE APIS
=================================

18. ADD LOCATION PREFERENCE
    POST /trainers/{trainer_id}/location-preferences/
    Body: {
      "location_name": "string"
    }
    Response: {"id": location_pref_id, "message": "Location preference added"}

19. DELETE LOCATION PREFERENCE
    DELETE /trainers/{trainer_id}/location-preferences/{location_id}/
    Response: {"message": "Location preference deleted"}

=================================
LANGUAGE APIS
=================================

20. GET ALL LANGUAGES
    GET /languages/
    Response: List of all available languages

21. ADD TRAINER LANGUAGE
    POST /trainers/{trainer_id}/languages/
    Body: {
      "language_id": integer
    }
    Response: {"id": trainer_lang_id, "message": "Language added"}

22. DELETE TRAINER LANGUAGE
    DELETE /trainers/{trainer_id}/languages/{language_id}/
    Response: {"message": "Language deleted"}

=================================
SOCIAL MEDIA APIS
=================================

23. UPDATE SOCIAL LINKS
    PUT /trainers/{trainer_id}/social-links/
    Body: {
      "website": "string",
      "whatsapp": "string",
      "instagram": "string",
      "facebook": "string",
      "youtube": "string"
    }
    Note: All fields are optional and accept null
    Response: {"message": "Social links updated"}

=================================
LOCATION APIS
=================================

24. UPDATE TRAINER LOCATION
    PUT /trainers/{trainer_id}/location/
    Body: {
      "street": "string",
      "area": "string",
      "city": "string",
      "state": "string",
      "country": "string",
      "pincode": "string",
      "latitude": decimal,
      "longitude": decimal
    }
    Response: {"message": "Location updated"}

=================================
BANK ACCOUNT APIS
=================================

25. ADD BANK ACCOUNT
    PUT /trainers/{trainer_id}/bank-account/
    Body: {
      "account_holder_name": "string",
      "account_number": "string",
      "ifsc_code": "string",
      "pan_number": "string",
      "business_type": "string"
    }
    Note: This also creates Razorpay route account
    Response: {"message": "Bank account added and Razorpay account created"}

=================================
SUBSCRIPTION APIS
=================================

26. GET DISCIPL PLANS
    GET /plans/
    Response: List of available Discipl subscription plans

27. PURCHASE SUBSCRIPTION
    POST /trainers/{trainer_id}/subscription/
    Body: {
      "plan_id": "uuid"
    }
    Response: {
      "order_id": "razorpay_order_id",
      "amount": decimal,
      "subscription_id": integer
    }

28. CONFIRM SUBSCRIPTION PAYMENT
    PUT /trainers/{trainer_id}/subscription/
    Body: {
      "subscription_id": integer,
      "razorpay_payment_id": "string"
    }
    Response: {"message": "Subscription activated"}

=================================
NOTES
=================================

- All endpoints require authentication (except public lists)
- trainer_id refers to the Trainer model primary key
- File uploads use multipart/form-data content type
- All other requests use application/json content type
- Dates should be in YYYY-MM-DD format
- Decimal values for currency should have 2 decimal places
- Boolean values: true/false
- Null values are accepted for optional fields

USER TYPES:
- "trainer": Creates User with MENTOR_TRAINER role (35)
- "dietitian": Creates User with MENTOR_DIETITIAN role (36)

SPECIALIZATIONS:
- Trainers and dietitians have separate specialization lists
- Use ?user_type=trainer or ?user_type=dietitian to filter
- Each specialization is tagged with user_type field

=================================
ERROR RESPONSES
=================================

400 Bad Request: Invalid data or validation errors
404 Not Found: Resource not found
500 Internal Server Error: Server error

Error Response Format:
{
  "field_name": ["error message"],
  "razorpay_error": "error message"
}
