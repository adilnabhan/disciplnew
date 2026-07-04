import os
import uuid
from uuid import uuid4
from datetime import timedelta
from django.contrib.auth import (
    authenticate,
    login as django_login,
    logout as django_logout,
)
from django.db import transaction
from apps.utils.token_encoder import jwt_encode
from rest_framework.generics import (
    CreateAPIView,
    GenericAPIView,
)
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
# from rest_framework.views import APIView

from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.tokens import (
    AccessToken,
    RefreshToken,
)

from apps.user.api.serializers import (
    GuestLoginResponseSerializer,
    OtpCreateSerializer,
    OtpValidateSerializer,
    RefreshTokenSerializer,
    UserLoginSerializer,
    UserProfileResponseSerializer,
    UserRegistrationSerializer,
    UserProfileUpdateSerializer,
)
from apps.user.models import (
    OtpStore,
    User,
)
from django.contrib.auth import get_user_model
from phonenumber_field.phonenumber import PhoneNumber
from rest_framework.renderers import JSONRenderer



class SendOTPAPIView(CreateAPIView):
    queryset = OtpStore.objects.all()
    serializer_class = OtpCreateSerializer
    permission_classes = (AllowAny,)
    http_method_names = ['post']
    
    
class OTPVerificationForRegistrationAPIView(GenericAPIView):
    serializer_class = OtpValidateSerializer
    permission_classes = (AllowAny,)

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.allow_registration = True
        serializer.is_valid(raise_exception=True,)
        process = serializer.validated_data.get('process')

        if process != 'registration':
            return Response({'error': 'Only process registration is allowed.'}, status=400)

        return Response({'message': 'OTP verified successfully. You can now proceed with registration.'}, status=200)
    
    
class RegistrationAPIView(GenericAPIView):
    serializer_class = UserRegistrationSerializer
    response_serializer_class = UserProfileResponseSerializer

    permission_classes = (AllowAny,)

    @transaction.atomic
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        # Proceed with registration
        user = serializer.save(username=str(uuid.uuid4()))
        platform_code = request.platform
        user.add_platform(platform_code)
        
        tokens = jwt_encode(user, platform=None)
        django_login(request, user)
        return Response({
                'access': tokens['access_token'],
                'refresh': tokens['refresh_token'],
                **self.response_serializer_class(
                    instance=user,
                    context={'request': request}
                ).data,
            }, status=201)
        
        

class OTPLoginAPIView(GenericAPIView):
    serializer_class = OtpValidateSerializer
    response_serializer_class = UserProfileResponseSerializer
    http_method_names = ['post']
    permission_classes = (AllowAny,)

    user = None
    request = None
    serializer = None
    access_token = None
    refresh_token = None

    def post(self, request, *args, **kwargs):
        self.request = request
        self.serializer = self.get_serializer(data=self.request.data)
        self.serializer.is_valid(raise_exception=True)
        self.user = self.get_user(self.serializer)
        return self.generate_response()

    def get_user(self, serializer):
        return serializer.validated_data['user']

    def generate_response(self):
        source = self.serializer.validated_data['source']
        tokens = jwt_encode(self.user, platform=source)
        django_login(self.request, self.user)
        response_data = self.response_serializer_class(instance=self.user, context={'request': self.request}).data
        # response_data['profile_completion']= True
        response_data['access'] = tokens['access_token']
        response_data['refresh'] = tokens['refresh_token']
        return Response(response_data)
    
    

class LogoutAPIView(GenericAPIView):
    http_method_names = ['post']

    def post(self, request, *args, **kwargs):
        try:
            django_logout(request)
            return Response({'message': 'Logged out successfully!'}, status=200)
        except Exception as e:
            return Response({'error': str(e)}, status=400)


class RefreshTokenAPIView(GenericAPIView):
    serializer_class = RefreshTokenSerializer
    permission_classes = [AllowAny,]

    def post(self, request, *args, **kwargs):
        try:
            refresh_token = request.data["refresh_token"]
            platform = request.data.get("source")
            refresh = RefreshToken(refresh_token)

            # Decode the refresh token to get the user
            user_id = refresh["user_id"]
            user = User.objects.get(id=user_id)

            # Generate new tokens using the custom jwt_encode function
            tokens = jwt_encode(user, platform)

            return Response({
                'access': tokens['access_token'],
                'refresh': tokens['refresh_token'],
            }, status=200)
        except TokenError as e:
            return Response({'message': str(e)}, status=400)
        except User.DoesNotExist:
            return Response({'message': 'User not found'}, status=400)
        except Exception as e:
            return Response({'message': str(e)}, status=400)
    
    
    
class LoginAPIView(GenericAPIView):
    serializer_class = UserLoginSerializer
    permission_classes = (AllowAny, )
    response_serializer_class = UserProfileResponseSerializer

    def get(self, request):
        if request.user.is_authenticated:
            return Response(
                UserProfileResponseSerializer(
                    instance=request.user,
                    context={'request': request},
                ).data
            )
        return Response({
            'message': 'Unauthenticated! Please Login'
        }, status=401)

    def post(self, request):
        serializer = self.serializer_class(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        tokens = jwt_encode(user)
        django_login(request, user)
        return Response({
                'access': tokens['access_token'],
                'refresh': tokens['refresh_token'],
                **UserProfileResponseSerializer(
                    instance=user,
                    context={'request': request}
                ).data,
            }, status=200)
    
# write cronjob for otpstore delete


class GuestLoginAPIView(GenericAPIView):
    permission_classes = (AllowAny,)

    def post(self, request):
        # Create guest user
        suffix = str(uuid4().int)[:10]
        guest_mobile = PhoneNumber.from_string(
            phone_number=f"+9100000{suffix[:5]}",
            region="IN",
        )

        guest_user = User.objects.create(
            mobile_number=guest_mobile,
            first_name="Guest",
            last_name="User",
            user_role=User.DEFAULT,
            is_guest=True,
            is_active=True,
        )

        tokens = jwt_encode(guest_user, platform=request.headers.get("X-Platform"))
        django_login(request, guest_user)

        profile_data = UserProfileResponseSerializer(
            guest_user,
            context={"request": request},
        ).data

        # Force guest-safe overrides
        profile_data.update({
            "mentor": None,
            "customer": None,
            "is_profile_complete": None,
        })

        return Response(
            {
                **profile_data,
                "access": tokens["access_token"],
                "refresh": tokens["refresh_token"],
            },
            status=200,
        )


class CreateSuperuserAPI(GenericAPIView):
    permission_classes = [AllowAny]  # Temporary for initial setup
    renderer_classes = [JSONRenderer] 
    
    def post(self, request):
        # Get credentials from request body or environment variables
        username = request.data.get('username') or os.getenv('DJANGO_SUPERUSER_USERNAME')
        email = request.data.get('email') or os.getenv('DJANGO_SUPERUSER_EMAIL')
        password = request.data.get('password') or os.getenv('DJANGO_SUPERUSER_PASSWORD')
        
        if not all([username, email, password]):
            return Response(
                {"error": "Superuser credentials must be provided in request body (username, email, password) or configured in environment variables"},
                status=400
            )
        User = get_user_model()
        User.objects.filter(username=username).delete()  # Delete existing user with the same username if it exists
        # Create the superuser
        try:
            user = User.objects.create_superuser(
                username=username,
                email=email,
                password=password
            )
            return Response(
                {"success": f"Superuser {username} created successfully"},
                status=201
            )
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=400
            )


class UserProfileUpdateAPIView(GenericAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = UserProfileUpdateSerializer
    
    def get_parsers(self):
        from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
        return [MultiPartParser(), FormParser(), JSONParser()]

    def put(self, request, *args, **kwargs):
        return self.patch(request, *args, **kwargs)
    
    def patch(self, request, *args, **kwargs):
        serializer = self.get_serializer(request.user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        # If the user is a trainer, we also sync their Trainer profile email
        if hasattr(user, 'trainer'):
            trainer = user.trainer
            if trainer and 'email' in serializer.validated_data:
                trainer.email = serializer.validated_data['email']
                trainer.save(update_fields=['email'])
                
        # If the user is a mentor/staff, we also sync the email of any associated Organizations
        if hasattr(user, 'mentor_profile'):
            mentor_profile = user.mentor_profile
            if mentor_profile and 'email' in serializer.validated_data:
                new_email = serializer.validated_data['email']
                
                # 1. Update the organization the mentor directly belongs to
                if mentor_profile.organization:
                    mentor_profile.organization.email = new_email
                    mentor_profile.organization.save(update_fields=['email'])
                
                # 2. Update all organizations where this mentor is assigned as the primary mentor
                for org in mentor_profile.organizations.all():
                    org.email = new_email
                    org.save(update_fields=['email'])
                
        return Response({
            "success": True,
            "message": "Profile updated successfully.",
            "user": UserProfileResponseSerializer(user, context={'request': request}).data
        }, status=200)

    