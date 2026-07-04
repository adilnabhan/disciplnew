from rest_framework import viewsets
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from .models import (
    Trainer,
    Specialization,
    TrainerSpecialization,
    TrainerCertification,
    TrainerPortfolio,
    TrainerTransformation,
    Language,
    TrainerLanguage,
    TrainerSocialLink,
    Location,
    TrainerBankAccount,
    TrainerPlan,
    TrainerExperience,
    TrainerLocationPreference,
    TrainerSubscription
)

from .serializers import (
    TrainerSerializer,
    TrainerBasicSerializer,
    SpecializationSerializer,
    TrainerSpecializationSerializer,
    TrainerCertificationSerializer,
    TrainerPortfolioSerializer,
    TrainerTransformationSerializer,
    LanguageSerializer,
    TrainerLanguageSerializer,
    TrainerSocialLinkSerializer,
    LocationSerializer,
    TrainerBankAccountSerializer,
    TrainerPlanSerializer,
    TrainerDetailSerializer
)

from .utils import create_trainer_linked_account

def get_trainer_from_request(request):
    if request.user and request.user.is_authenticated:
        return Trainer.objects.filter(user=request.user).first()
    return None

class TrainerBasicDetailsView(APIView):

    def post(self, request):
        from apps.user.models import OtpStore, User
        from rest_framework_simplejwt.authentication import JWTAuthentication

        # 1. Try JWT token first
        user = None
        try:
            result = JWTAuthentication().authenticate(request)
            if result:
                user, _ = result
        except Exception:
            pass

        # 2. Fall back to otp_id
        otp = None
        if not user:
            otp_id = request.data.get('otp_id')
            if otp_id:
                otp = OtpStore.objects.filter(id=otp_id).select_related('user').first()
                if not otp:
                    return Response({'error': 'Invalid OTP ID'}, status=status.HTTP_400_BAD_REQUEST)
                
                if not otp.verified_at:
                    otp_val = request.data.get('otp')
                    if not otp_val:
                        return Response({'error': 'OTP has not been verified yet'}, status=status.HTTP_400_BAD_REQUEST)
                    
                    is_valid, error = OtpStore.validate_otp(otp_id, otp.mobile_number, otp_val)
                    if not is_valid:
                        return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)
                    
                    otp.refresh_from_db()
                
                user = otp.user

            # 3. No user yet — create from OTP mobile
            if not user and otp:
                user_type = request.data.get('user_type', 'trainer')
                user_role = User.MENTOR_TRAINER if user_type == 'trainer' else User.MENTOR_DIETITIAN
                user, created = User.objects.get_or_create(
                    mobile_number=otp.mobile_number,
                    defaults={
                        'username': str(otp.mobile_number),
                        'user_role': user_role,
                        'first_name': request.data.get('first_name', ''),
                        'last_name': request.data.get('last_name', ''),
                        'email': request.data.get('email', ''),
                    }
                )
                
                # If user already existed, update role to match requested user_type
                if not created and user.user_role != user_role:
                    user.user_role = user_role
                    user.save(update_fields=['user_role'])
                
                otp.user = user
                otp.save(update_fields=['user'])

        if not user:
            return Response({'error': 'Authorization token or a valid otp_id is required'}, status=status.HTTP_400_BAD_REQUEST)

        # Always update user_role to match the requested user_type
        user_type = request.data.get('user_type', 'trainer')
        expected_role = User.MENTOR_TRAINER if user_type == 'trainer' else User.MENTOR_DIETITIAN
        if user.user_role not in (expected_role,):
            user.user_role = expected_role
            user.save(update_fields=['user_role'])

        data = request.data.copy()
        data['mobile'] = str(otp.mobile_number) if otp else str(user.mobile_number)
        # Fill missing fields from the authenticated user
        if not data.get('first_name'):
            data['first_name'] = user.first_name
        if not data.get('last_name'):
            data['last_name'] = user.last_name or ''
        if not data.get('email'):
            data['email'] = user.email or ''
        if data.get('gender'):
            data['gender'] = data['gender'].lower()

        serializer = TrainerBasicSerializer(data=data, context={'otp': otp, 'user': user})
        if serializer.is_valid():
            trainer = serializer.save()
            from apps.utils.token_encoder import jwt_encode
            tokens = jwt_encode(user)
            return Response({
                **serializer.data,
                'access': tokens['access_token'],
                'refresh': tokens['refresh_token'],
            }, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


    def get(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)
        return Response(TrainerBasicSerializer(trainer).data)

    def put(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        serializer = TrainerBasicSerializer(
            trainer,
            data=request.data,
            partial=True
        )

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class TrainerExperienceView(APIView):
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)
        return Response({
            "experience_years": trainer.experience_years,
            "bio": trainer.bio,
            "specializations": list(
                TrainerSpecialization.objects.filter(trainer=trainer)
                .values('specialization__id', 'specialization__name')
            ),
            "certifications": TrainerCertificationSerializer(
                TrainerCertification.objects.filter(trainer=trainer), many=True
            ).data,
        })

    def post(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        try:
            # 1. Update Basic Experience Fields
            experience_years = request.data.get("experience_years")
            if experience_years is not None:
                trainer.experience_years = experience_years
                
            bio = request.data.get("bio")
            if bio is not None:
                trainer.bio = bio
            
            trainer.save()

            # 2. Update Specializations (supports JSON array, form list, or comma-string)
            specializations = request.data.get("specializations", [])
            if isinstance(specializations, str):
                try:
                    import json
                    specializations = json.loads(specializations)
                    if not isinstance(specializations, list):
                        specializations = [specializations]
                except Exception:
                    specializations = [specializations]
            if not isinstance(specializations, list):
                specializations = [specializations] if specializations else []

            if specializations:
                TrainerSpecialization.objects.filter(trainer=trainer).delete()
                valid_spec_ids = list(Specialization.objects.filter(
                    id__in=specializations
                ).values_list('id', flat=True))
                for spec_id in valid_spec_ids:
                    TrainerSpecialization.objects.create(trainer=trainer, specialization_id=spec_id)
            else:
                valid_spec_ids = []

            # 3. Handle Certificates (Combined Upload) — only available via multipart
            certificate_files = request.FILES.getlist('certificate_files') or request.FILES.getlist('certificate_file')
            certificate_names = (
                request.data.getlist('certificate_names') if hasattr(request.data, 'getlist')
                else request.data.get('certificate_names', [])
            ) or (
                request.data.getlist('certificate_name') if hasattr(request.data, 'getlist')
                else request.data.get('certificate_name', [])
            )
            if isinstance(certificate_names, str):
                certificate_names = [certificate_names]

            created_certs = []
            for i, cert_file in enumerate(certificate_files):
                name = certificate_names[i] if i < len(certificate_names) else cert_file.name
                cert = TrainerCertification.objects.create(
                    trainer=trainer,
                    certificate_name=name,
                    certificate_file=cert_file
                )
                created_certs.append(cert.id)

            return Response({
                "message": "Experience and certificates saved",
                "certificate_ids": created_certs,
                "missing_specializations": list(set(map(int, specializations)) - set(valid_spec_ids)) if specializations else []
            })
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

class TrainerCertificationUploadView(APIView):

    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        file = request.FILES.get("certificate_file")
        certificate_name = request.data.get("certificate_name")

        cert, created = TrainerCertification.objects.get_or_create(
            trainer=trainer,
            certificate_name=certificate_name,
            defaults={'certificate_file': file}
        )
        if not created and file:
            cert.certificate_file = file
            cert.save(update_fields=['certificate_file'])

        return Response({"id": cert.id})

class SpecializationListView(APIView):

    def get(self, request):
        user_type = request.query_params.get('user_type', 'trainer')
        data = Specialization.objects.filter(user_type=user_type)
        serializer = SpecializationSerializer(data, many=True)
        return Response(serializer.data)

class TrainerRecognitionView(APIView):
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)
        return Response(TrainerTransformationSerializer(
            TrainerTransformation.objects.filter(trainer=trainer), many=True
        ).data)

    def post(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        # Support both single upload and multiple uploads
        if hasattr(request.data, 'getlist'):
            descriptions = request.data.getlist('description')
            images_from = request.FILES.getlist('image_from')
            images_to = request.FILES.getlist('image_to')
        else:
            descriptions = request.data.get('description', [])
            if isinstance(descriptions, str):
                descriptions = [descriptions]
            images_from = []
            images_to = []

        # If zero-length but single fields exist (for non-list form data)
        if not descriptions and request.data.get('description'):
            descriptions = [request.data.get('description')]
        if not images_from and request.FILES.get('image_from'):
            images_from = [request.FILES.get('image_from')]
        if not images_to and request.FILES.get('image_to'):
            images_to = [request.FILES.get('image_to')]

        created_ids = []
        # We iterate based on the maximum number of items provided
        count = max(len(descriptions), len(images_from), len(images_to))
        
        for i in range(count):
            desc = descriptions[i] if i < len(descriptions) else ""
            img_from = images_from[i] if i < len(images_from) else None
            img_to = images_to[i] if i < len(images_to) else None
            
            recognition = TrainerTransformation.objects.create(
                trainer=trainer,
                description=desc,
                before_image=img_from,
                after_image=img_to
            )
            created_ids.append(recognition.id)

        return Response({
            "ids": created_ids, 
            "message": f"Successfully saved {len(created_ids)} recognitions"
        })

    def put(self, request, recognition_id):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        recognition = TrainerTransformation.objects.get(id=recognition_id, trainer=trainer)

        if request.data.get("description"):
            recognition.description = request.data.get("description")

        if request.FILES.get("image_from"):
            recognition.before_image = request.FILES.get("image_from")

        if request.FILES.get("image_to"):
            recognition.after_image = request.FILES.get("image_to")

        recognition.save()

        return Response({"id": recognition.id, "message": "Recognition updated"})

    def delete(self, request, recognition_id):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        recognition = TrainerTransformation.objects.get(id=recognition_id, trainer=trainer)
        recognition.delete()

        return Response({"message": "Recognition deleted"}, status=status.HTTP_204_NO_CONTENT)

class TrainerWorkExperienceView(APIView):

    def get(self, request):
        from .serializers import TrainerExperienceSerializer as WorkExpSerializer
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)
        from .models import TrainerExperience
        experiences = TrainerExperience.objects.filter(trainer=trainer)
        from rest_framework import serializers as drf_serializers
        data = list(experiences.values(
            'id', 'organization_name', 'designation',
            'start_date', 'end_date', 'currently_working', 'description'
        ))
        return Response(data)

    def post(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        experiences = request.data if isinstance(request.data, list) else [request.data]

        TrainerExperience.objects.filter(trainer=trainer).delete()
        created = []
        for exp in experiences:
            obj = TrainerExperience.objects.create(
                trainer=trainer,
                organization_name=exp.get("organization_name"),
                designation=exp.get("designation"),
                start_date=exp.get("start_date"),
                end_date=exp.get("end_date"),
                currently_working=exp.get("currently_working", False),
                description=exp.get("description")
            )
            created.append(obj.id)

        return Response({"ids": created, "message": "Work experiences saved"})

    def put(self, request, experience_id):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        experience = TrainerExperience.objects.get(id=experience_id, trainer=trainer)

        experience.organization_name = request.data.get("organization_name", experience.organization_name)
        experience.designation = request.data.get("designation", experience.designation)
        experience.start_date = request.data.get("start_date", experience.start_date)
        experience.end_date = request.data.get("end_date", experience.end_date)
        experience.currently_working = request.data.get("currently_working", experience.currently_working)
        experience.description = request.data.get("description", experience.description)

        experience.save()

        return Response({"id": experience.id, "message": "Experience updated"})

    def delete(self, request, experience_id):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        experience = TrainerExperience.objects.get(id=experience_id, trainer=trainer)
        experience.delete()

        return Response({"message": "Experience deleted"}, status=status.HTTP_204_NO_CONTENT)

class TrainerPreferenceView(APIView):

    def get(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)
        return Response({
            "is_freelancer": trainer.is_freelancer,
            "join_gym": trainer.join_gym,
            "event_collaborator": trainer.event_collaborator,
        })

    def put(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        trainer.is_freelancer = request.data.get("is_freelancer", trainer.is_freelancer)
        trainer.join_gym = request.data.get("join_gym", trainer.join_gym)
        trainer.event_collaborator = request.data.get("event_collaborator", trainer.event_collaborator)

        trainer.save()

        return Response({"message": "Preferences updated"})

class TrainerPayRangeView(APIView):

    def get(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)
        return Response({
            "expected_pay_min": trainer.expected_pay_min,
            "expected_pay_max": trainer.expected_pay_max,
        })

    def put(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        trainer.expected_pay_min = request.data.get("expected_pay_min", trainer.expected_pay_min)
        trainer.expected_pay_max = request.data.get("expected_pay_max", trainer.expected_pay_max)

        trainer.save()

        return Response({"message": "Pay range updated"})

class TrainerLocationPreferenceView(APIView):

    def get(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)
        return Response(list(trainer.location_preferences.values('id', 'location_name')))

    def post(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        locations = request.data if isinstance(request.data, list) else [request.data]

        TrainerLocationPreference.objects.filter(trainer=trainer).delete()
        created = []
        for loc in locations:
            obj = TrainerLocationPreference.objects.create(
                trainer=trainer,
                location_name=loc.get("location_name") if isinstance(loc, dict) else loc
            )
            created.append(obj.id)

        return Response({"ids": created, "message": "Location preferences saved"})

    def delete(self, request, location_id):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        location_pref = TrainerLocationPreference.objects.get(id=location_id, trainer=trainer)
        location_pref.delete()

        return Response({"message": "Location preference deleted"}, status=status.HTTP_204_NO_CONTENT)

class TrainerLanguagePreferenceView(APIView):

    def get(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)
        return Response(TrainerLanguageSerializer(
            TrainerLanguage.objects.filter(trainer=trainer), many=True
        ).data)

    def post(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        language_id = request.data.get("language_id")

        trainer_lang, _ = TrainerLanguage.objects.get_or_create(
            trainer=trainer,
            language_id=language_id
        )

        return Response({"id": trainer_lang.id, "message": "Language added"})

    def delete(self, request, language_id):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        trainer_lang = TrainerLanguage.objects.get(id=language_id, trainer=trainer)
        trainer_lang.delete()

        return Response({"message": "Language deleted"}, status=status.HTTP_204_NO_CONTENT)

class LanguageListView(APIView):

    def get(self, request):
        languages = Language.objects.all()
        serializer = LanguageSerializer(languages, many=True)
        return Response(serializer.data)

class TrainerSocialLinkView(APIView):

    def get(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)
        social_link = TrainerSocialLink.objects.filter(trainer=trainer).first()
        return Response(TrainerSocialLinkSerializer(social_link).data if social_link else {})

    def put(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        social_link, created = TrainerSocialLink.objects.get_or_create(trainer=trainer)

        social_link.website = request.data.get("website", social_link.website)
        social_link.whatsapp = request.data.get("whatsapp", social_link.whatsapp)
        social_link.instagram = request.data.get("instagram", social_link.instagram)
        social_link.facebook = request.data.get("facebook", social_link.facebook)
        social_link.youtube = request.data.get("youtube", social_link.youtube)

        social_link.save()

        return Response({"message": "Social links updated"})

class TrainerLocationView(APIView):

    def get(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)
        location = Location.objects.filter(trainer=trainer).first()
        return Response(LocationSerializer(location).data if location else {})

    def put(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        location, created = Location.objects.get_or_create(trainer=trainer)

        location.street = request.data.get("street", location.street)
        location.area = request.data.get("area", location.area)
        location.city = request.data.get("city", location.city)
        location.state = request.data.get("state", location.state)
        location.country = request.data.get("country", location.country) or 'India'
        location.pincode = request.data.get("pincode", location.pincode)
        location.latitude = request.data.get("latitude", location.latitude)
        location.longitude = request.data.get("longitude", location.longitude)

        location.save()

        return Response({"message": "Location updated"})

class TrainerBankAccountView(APIView):

    def get(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)
        bank_account = TrainerBankAccount.objects.filter(trainer=trainer).first()
        return Response(TrainerBankAccountSerializer(bank_account).data if bank_account else {})

    def put(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        serializer = TrainerBankAccountSerializer(data=request.data)

        if serializer.is_valid():
            bank_account, created = TrainerBankAccount.objects.get_or_create(trainer=trainer)
            for attr, value in serializer.validated_data.items():
                setattr(bank_account, attr, value)
            bank_account.save()

            response = create_trainer_linked_account(trainer, bank_account)

            bank_account.razorpay_account_id = response.get("account_id")
            bank_account.razorpay_product_id = response.get("product_id")
            bank_account.razorpay_stakeholder_id = response.get("razorpay_stakeholder_id")
            bank_account.razorpay_account_status = response.get("activation_status")
            bank_account.save()

            return Response({"message": "Bank account saved and Razorpay account created"})

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class TrainerPlanView(APIView):

    def get(self, request):
        trainer = get_trainer_from_request(request)
        if trainer:
            plans = TrainerPlan.objects.filter(trainer=trainer)
        else:
            plans = TrainerPlan.objects.all()
        serializer = TrainerPlanSerializer(plans, many=True)
        return Response(serializer.data)

    def post(self, request):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        packages = request.data if isinstance(request.data, list) else [request.data]
        created_plans = []
        
        for pkg in packages:
            plan_data = pkg.copy()
            plan_data['trainer'] = trainer.id
            serializer = TrainerPlanSerializer(data=plan_data)
            if serializer.is_valid():
                created_plans.append(serializer.save())
            else:
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        response_data = TrainerPlanSerializer(created_plans, many=True).data
        return Response({"message": "Packages saved successfully", "plans": response_data}, status=status.HTTP_201_CREATED)


class TrainerPlanDetailView(APIView):

    def put(self, request, plan_id):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)
        try:
            plan = TrainerPlan.objects.get(id=plan_id, trainer=trainer)
        except TrainerPlan.DoesNotExist:
            return Response({"error": "Plan not found"}, status=status.HTTP_404_NOT_FOUND)
        serializer = TrainerPlanSerializer(plan, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, plan_id):
        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)
        try:
            plan = TrainerPlan.objects.get(id=plan_id, trainer=trainer)
        except TrainerPlan.DoesNotExist:
            return Response({"error": "Plan not found"}, status=status.HTTP_404_NOT_FOUND)
        plan.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

class TrainerSubscriptionPurchaseView(APIView):

    def post(self, request):
        from apps.trainer.models import TrainerSubscriptionPlan
        import razorpay
        from django.conf import settings

        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        plan_id = request.data.get("plan_id")
        try:
            plan = TrainerSubscriptionPlan.objects.get(id=plan_id)
        except TrainerSubscriptionPlan.DoesNotExist:
            return Response({"error": "Plan not found"}, status=status.HTTP_404_NOT_FOUND)

        client = razorpay.Client(auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET))

        order = client.order.create({
            "amount": int(plan.discounted_price * 100),
            "currency": "INR",
            "payment_capture": 1
        })

        subscription = TrainerSubscription.objects.create(
            trainer=trainer,
            plan=plan,
            paid_amount=plan.discounted_price,
            razorpay_order_id=order["id"],
            status=TrainerSubscription.PENDING
        )

        return Response({
            "order_id": order["id"],
            "amount": plan.discounted_price,
            "subscription_id": subscription.id
        })

    def put(self, request):
        from django.utils import timezone

        trainer = get_trainer_from_request(request)
        if not trainer:
            return Response({"error": "Trainer not found"}, status=status.HTTP_404_NOT_FOUND)

        subscription_id = request.data.get("subscription_id")
        razorpay_payment_id = request.data.get("razorpay_payment_id")

        try:
            subscription = TrainerSubscription.objects.get(id=subscription_id, trainer=trainer)
        except TrainerSubscription.DoesNotExist:
            return Response({"error": "Subscription not found"}, status=status.HTTP_404_NOT_FOUND)

        subscription.razorpay_payment_id = razorpay_payment_id
        subscription.payment_status = 'completed'
        subscription.status = TrainerSubscription.ACTIVE
        subscription.start_date = timezone.now()
        subscription.end_date = subscription.start_date + timezone.timedelta(days=30 * subscription.plan.period)
        subscription.save()

        return Response({"message": "Subscription activated"})

class TrainerViewSet(viewsets.ModelViewSet):
    queryset = Trainer.objects.all()
    serializer_class = TrainerSerializer

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return TrainerDetailSerializer
        return TrainerSerializer

    def get_object(self):
        queryset = self.filter_queryset(self.get_queryset())
        lookup_url_kwarg = self.lookup_url_kwarg or self.lookup_field
        lookup_value = self.kwargs[lookup_url_kwarg]
        
        # Cast to int for Postgres type safety
        try:
            lookup_id = int(lookup_value)
        except (ValueError, TypeError):
            return super().get_object()

        # 1. Try by Trainer Profile ID
        obj = queryset.filter(id=lookup_id).first()
        if obj:
            return obj
            
        # 2. Try by User ID (fallback for Flutter team)
        obj = queryset.filter(user_id=lookup_id).first()
        if obj:
            return obj
        
        return super().get_object()


class SpecializationViewSet(viewsets.ModelViewSet):
    queryset = Specialization.objects.all()
    serializer_class = SpecializationSerializer


class TrainerSpecializationViewSet(viewsets.ModelViewSet):
    queryset = TrainerSpecialization.objects.all()
    serializer_class = TrainerSpecializationSerializer


class TrainerCertificationViewSet(viewsets.ModelViewSet):
    queryset = TrainerCertification.objects.all()
    serializer_class = TrainerCertificationSerializer


class TrainerPortfolioViewSet(viewsets.ModelViewSet):
    queryset = TrainerPortfolio.objects.all()
    serializer_class = TrainerPortfolioSerializer


class TrainerTransformationViewSet(viewsets.ModelViewSet):
    queryset = TrainerTransformation.objects.all()
    serializer_class = TrainerTransformationSerializer


class LanguageViewSet(viewsets.ModelViewSet):
    queryset = Language.objects.all()
    serializer_class = LanguageSerializer


class TrainerLanguageViewSet(viewsets.ModelViewSet):
    queryset = TrainerLanguage.objects.all()
    serializer_class = TrainerLanguageSerializer


class TrainerSocialLinkViewSet(viewsets.ModelViewSet):
    queryset = TrainerSocialLink.objects.all()
    serializer_class = TrainerSocialLinkSerializer


class LocationViewSet(viewsets.ModelViewSet):
    queryset = Location.objects.all()
    serializer_class = LocationSerializer


class TrainerBankAccountViewSet(viewsets.ModelViewSet):
    queryset = TrainerBankAccount.objects.all()
    serializer_class = TrainerBankAccountSerializer


class TrainerPlanViewSet(viewsets.ModelViewSet):
    queryset = TrainerPlan.objects.all()
    serializer_class = TrainerPlanSerializer