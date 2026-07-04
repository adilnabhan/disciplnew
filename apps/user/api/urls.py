from django.urls import path, include
from .views import *

urlpatterns = [
    
    
    path('send-otp/', SendOTPAPIView.as_view(), name='send_otp'),
    path('otp/verify/', OTPLoginAPIView.as_view(), name='otp_verify'), #login with otp
    
    # onboarding
    path('otp/verification/registration/', OTPVerificationForRegistrationAPIView.as_view(), name='verify_otp_registration'), #otp verification for registration
    path('onboarding/', RegistrationAPIView.as_view(), name='authentication.registration'),
    
    path('logout/', LogoutAPIView.as_view(), name='authentication.logout'),
    path('token/refresh/', RefreshTokenAPIView.as_view(), name='authentication.token_refresh'),
    
    
    # username and password
    path('login/', LoginAPIView.as_view(), name='authentication.rest_login'),

    path('login/guest/', GuestLoginAPIView.as_view(), name='authentication.rest_login'),

    #create superuser
    path('create-superuser/', CreateSuperuserAPI.as_view(), name='create-superuser'),

    # profile update
    path('profile/update/', UserProfileUpdateAPIView.as_view(), name='user-profile-update'),
]