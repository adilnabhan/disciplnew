from datetime import timedelta

from django.conf import settings
from django.core.exceptions import ValidationError
from django.contrib.auth import authenticate
from django.utils import timezone
from rest_framework import serializers

from phonenumber_field.serializerfields import PhoneNumberField

from apps.user.models import (
    OtpStore,
    User,
)


class RefreshTokenSerializer(serializers.Serializer):
    refresh_token = serializers.CharField(required=True)
    platform = serializers.CharField(default='system', required=False)

class OtpCreateSerializer(serializers.ModelSerializer):
    id = serializers.UUIDField(read_only=True)
    otp = serializers.CharField(read_only=True)
    mobile_number = PhoneNumberField()
    source = serializers.CharField(required=True)
    app_signature = serializers.CharField(required=False, allow_blank=True, allow_null=True, write_only=True)

    def validate_source(self, source):
        expected_values = [s[0] for s in OtpStore.SOURCE_CHOICES]
        # Also allow generic names
        expected_values += ['mentor', 'customer', 'vendor', 'admin']
        if source not in expected_values:
            expected_values = ', '.join(set(expected_values))
            raise serializers.ValidationError(f'Source must be one of {expected_values}')
        return source

    def validate_process(self, process):
        expected_values = [process[0] for process in OtpStore.PROCESS_CHOICES]
        if process not in expected_values:
            expected_values = ', '.join(expected_values)
            raise serializers.ValidationError(f'Process must be one of {expected_values}')
        return process

    def validate_mobile_number(self, mobile_number):
        supporting_country_codes = [code for (country, code) in settings.DICIPLE_ISD_CODES]
        isd_code = '+' + str(mobile_number.country_code)
        is_valid = isd_code in supporting_country_codes
        if not is_valid:
            supporting_country_codes = ', '.join(supporting_country_codes)
            raise serializers.ValidationError(f'We are currently not supporting this country right now. [{supporting_country_codes}]')
        return mobile_number

    def validate(self, attrs):
        request = self.context.get('request')
        mobile_number = attrs.get('mobile_number')
        
        # Fallback to request.platform (from X-Platform header) if source not in body
        source = attrs.get('source')
        if not source and request and hasattr(request, 'platform'):
            source = request.platform
            attrs['source'] = source
        
        if not source:
            raise serializers.ValidationError({'source': 'This field is required.'})

        processes = [attrs.get('process')]

        is_pending_user = User.objects.filter(mobile_number=mobile_number).first()
        if is_pending_user:
            role = is_pending_user.user_role 
            is_mentor_app = 'mentor' in source
            is_customer_app = 'customer-app' in source
            if is_mentor_app and role not in User.MENTOR_ROLES:
                raise serializers.ValidationError(
                    'You cannot login or register to this platform since you already has a customer account on this number'
                )
            if is_customer_app and role != User.CUSTOMER:
                raise serializers.ValidationError(
                    'You cannot login or register to this platform since you already has a mentor account on this number')

        if attrs['process'] == 'login':
            processes += ['registration']
        elif attrs['process'] == 'registration' and is_pending_user:
            # Switch to login internally, even if user passed 'registration'
            print('YES')
            processes += ['login']
            attrs['process'] = 'login'
        print(attrs['process'])
        last_otp = OtpStore.objects.filter(
                mobile_number=mobile_number,
                process__in=processes,
                source=source,
        ).last()
        print(f'{last_otp=}')
        if last_otp:
            delay = timedelta(seconds=settings.OTP_RESENT_DELAY_SECONDS)
            next_otp_time = last_otp.created_at + delay
            print(f'{last_otp=} | {delay=} | {next_otp_time=} | delay = {(next_otp_time - last_otp.created_at).seconds}')
            if next_otp_time > timezone.now():
                remaining_time = (next_otp_time - timezone.now()).seconds
                raise serializers.ValidationError(
                    'You need to wait for {} seconds to send another otp'.format(remaining_time)
                )
        return attrs

    class Meta:
        model = OtpStore
        fields = ['id', 'mobile_number', 'process', 'source', 'otp', 'app_signature']

    def create(self, validated_data):
        mobile_number = validated_data['mobile_number']
        process = validated_data['process']
        source = validated_data['source']
        signature = validated_data.get('app_signature', '')
        otp_instance = OtpStore.generate_otp(mobile_number, process, source, signature=signature or '')
        return otp_instance
    
    
class OtpValidateSerializerMixin(serializers.Serializer):
    otp_id = serializers.UUIDField(write_only=True, required=True)
    mobile_number = serializers.CharField(write_only=True, required=True)
    otp = serializers.CharField(write_only=True, required=True)

    allow_registration = False

    def validate(self, data):
        otp_id = data.get('otp_id')
        mobile_number = data.get('mobile_number')
        otp = data.get('otp')

        is_valid, error = OtpStore.validate_otp(otp_id, mobile_number, otp)
        if not is_valid:
            raise serializers.ValidationError(error)

        otp_instance = OtpStore.objects.filter(id=otp_id).select_related('user').last()
        user = otp_instance.user
        if not self.allow_registration and not user:
            raise serializers.ValidationError('User with this mobile number does not exist!')
        if user and user.user_role:
            if (
                ('mentor' in data['source'] and user.user_role not in User.MENTOR_ROLES)
                or ('customer' in data['source'] and user.user_role not in [User.CUSTOMER])
                or ('admin' in data['source'] and user.user_role not in User.ADMIN_ROLES)
            ):
                raise serializers.ValidationError('{} cannot login to this platform.'.format(user.role_label()))
            data['user'] = user
        return data


class OtpValidateSerializer(serializers.ModelSerializer, OtpValidateSerializerMixin):
    source = serializers.CharField(required=True)
    class Meta:
        model = OtpStore
        fields = ['otp_id', 'mobile_number', 'process', 'source', 'otp']
        
        

class UserRegistrationSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(allow_null=True, allow_blank=True, required=False)
    first_name = serializers.CharField(allow_blank=False, allow_null=False, required=True)
    last_name = serializers.CharField(allow_blank=True, allow_null=True, required=False)
    mobile_number = PhoneNumberField(required=False)
    process = serializers.ChoiceField(choices=OtpStore.PROCESS_CHOICES)
    source = serializers.CharField(required=True)
    meta = serializers.DictField(write_only=True, required=False, allow_null=True)
    otp_id = serializers.UUIDField(required=True, write_only=True)
    otp = serializers.CharField(required=False, write_only=True)
    user_role = serializers.CharField(allow_blank=False, allow_null=False, required=True)
    profile_image = serializers.ImageField(required=False, allow_null=True, write_only=True)

    class Meta:
        model = User
        fields = [
            'mobile_number',
            'email',
            'first_name',
            'last_name',
            'meta',
            'source',
            'process',
            'otp_id',
            'otp',
            'profile_picture',
            'profile_image',
            'user_role',
            'date_of_birth',
            'gender',
        ]

    # Added comment to force re-deployment trigger
    def validate_mobile_number(self, mobile_number):
        # Allow existing users to register again for role upgrades
        return mobile_number

    def validate_email(self, email):
        if not email:
            return email
        # Allow existing emails for role upgrades
        return email.strip()

    def validate_first_name(self, first_name):
        MINIMUM_FIRST_NAME_LENGTH = 3
        if len(first_name) < MINIMUM_FIRST_NAME_LENGTH:
            raise serializers.ValidationError(f'First Name must have minimum of {MINIMUM_FIRST_NAME_LENGTH} characters.')
        return first_name.strip()

    def validate(self, attrs):
        attrs = super().validate(attrs)
        otp_id = attrs.get('otp_id')
        source = attrs['source']

        otp_instance = OtpStore.objects.filter(id=otp_id).last()
        if not otp_instance:
             raise serializers.ValidationError({'otp_id': 'Invalid OTP ID'})

        if not otp_instance.verified_at:
            otp_val = attrs.get('otp')
            if not otp_val:
                raise serializers.ValidationError({'otp_id': 'OTP has not been verified yet and no otp provided in request.'})
            
            # Auto-verify
            is_valid, error = OtpStore.validate_otp(otp_id, attrs.get('mobile_number') or otp_instance.mobile_number, otp_val)
            if not is_valid:
                raise serializers.ValidationError({'otp': error})
            
            otp_instance.refresh_from_db()

        # Fill mobile_number from OTP if not provided
        if not attrs.get('mobile_number'):
            attrs['mobile_number'] = otp_instance.mobile_number

        return attrs

    def create(self, validated_data):
        request = self.context.get('request')
        source = validated_data.get('source')
        meta_data = validated_data.pop('meta', {})
        
        # Pop profile_image and map to profile_picture if present
        profile_img = validated_data.pop('profile_image', None)
        if profile_img and 'profile_picture' not in validated_data:
            validated_data['profile_picture'] = profile_img
            
        fields_to_be_removed = ['otp_id', 'process', 'source', 'otp']
        for field in fields_to_be_removed:
            validated_data.pop(field, None)

        # Return existing user if mobile already registered
        existing = User.objects.filter(mobile_number=validated_data['mobile_number']).first()
        if existing:
            update_fields = []
            role_changed = False
            
            if 'user_role' in validated_data and str(existing.user_role) != str(validated_data['user_role']):
                existing.user_role = validated_data['user_role']
                update_fields.append('user_role')
                role_changed = True

            if 'profile_picture' in validated_data:
                existing.profile_picture = validated_data['profile_picture']
                update_fields.append('profile_picture')

            for field in ['first_name', 'last_name', 'email', 'gender', 'date_of_birth']:
                if field in validated_data:
                    setattr(existing, field, validated_data[field])
                    update_fields.append(field)

            if update_fields:
                existing.save(update_fields=update_fields)

            # Create missing profile records when role changes
            # (e.g., upgrading to trainer role 35/36 needs Trainer + MentorProfile)
            if role_changed:
                existing.create_profile()

            return existing

        user = User(**validated_data)
        if source and 'mentor' in source:
            try:
                role_int = int(user.user_role)
            except (ValueError, TypeError):
                role_int = None
            if role_int not in User.MENTOR_ROLES:
                user.user_role = User.MENTOR
        elif source and 'customer' in source:
            user.user_role = User.CUSTOMER
        user.save()
        user.create_profile()

        if user.user_role == User.CUSTOMER:
            from apps.customers.signals import CustomerRegistrationService
            CustomerRegistrationService.update_customer(user, meta_data)
        return user

    def update(self, instance, validated_data):
        raise NotImplementedError()
    
    

class UserProfileResponseSerializer(serializers.ModelSerializer):
    role = serializers.CharField(read_only=True)
    mentor = serializers.SerializerMethodField()
    customer = serializers.SerializerMethodField()
    trainer = serializers.SerializerMethodField()
    warnings = serializers.SerializerMethodField()
    is_profile_complete = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id',
            'first_name',
            'last_name',
            'mobile_number',
            'email',
            'blood_group',
            'last_login',
            'role',
            'user_role',
            'mentor',
            'customer',
            'trainer',
            'profile_picture',
            'warnings',
            'is_profile_complete',
            'is_guest',
        ]

    def get_mentor(self, instance):
        from apps.mentors.models import MentorProfile
        mentor_profile = MentorProfile.objects.filter(user=instance).first()
        if not mentor_profile:
            return None
        org = mentor_profile.organization
        return {
            'id': mentor_profile.id,
            'name': mentor_profile.user.first_name,
            'organization': {
                'id': org.id,
                'name': org.name,
                "profile_completeness": org.profile_completeness
            } if org else None
        }


    def get_trainer(self, instance):
        from apps.trainer.models import Trainer
        trainer = Trainer.objects.filter(user=instance).first()
        if not trainer:
            return None
        return {
            'id': trainer.id,
            'user_type': trainer.user_type,
            'profile_step': trainer.profile_step,
        }

    def get_customer(self, instance):
        from apps.customers.models import Customer
        customer = Customer.objects.filter(user=instance).first()
        if not customer:
            return None

        return {
            'id': customer.id,
            "is_active_member": customer.is_active_member,
            "profile_completeness": customer.profile_completeness,
            "organization_id": customer.organization_id,
        }

    def get_warnings(self, instance):
        out = []
        return out
    
    def validate_blood_group(self, value):
        if value not in dict(User.BLOOD_GROUP_CHOICES).keys():
            raise ValidationError("Invalid blood group value.")
        return value
    
    def get_is_profile_complete(self, instance):
        if instance.user_role in User.MENTOR_ROLES:
            try:
                mentor = instance.mentor_profile
                return mentor.designation in ['admin', 'trainer'] and mentor.organization is not None
            except Exception:
                return False
        return None
    
class UserLoginSerializer(serializers.Serializer):
    username = serializers.CharField(required=True)
    password = serializers.CharField(required=True)

    def validate(self, data):
        user = authenticate(self.context['request'], **data)
        if not user:
            raise serializers.ValidationError("Incorrect username or password.")
        data['user'] = user
        return data


class GuestLoginResponseSerializer(serializers.Serializer):
    # user profile fields (flattened)
    id = serializers.IntegerField()
    first_name = serializers.CharField(allow_blank=True, required=False)
    last_name = serializers.CharField(allow_blank=True, required=False)
    mobile_number = serializers.CharField(allow_null=True)
    email = serializers.EmailField(allow_null=True)
    blood_group = serializers.CharField()
    last_login = serializers.DateTimeField(allow_null=True)
    mentor = serializers.JSONField(allow_null=True)
    customer = serializers.JSONField(allow_null=True)
    profile_picture = serializers.ImageField(allow_null=True)
    warnings = serializers.ListField()
    is_profile_complete = serializers.BooleanField(allow_null=True)

    # tokens
    access = serializers.CharField()
    refresh = serializers.CharField()


class UserProfileUpdateSerializer(serializers.ModelSerializer):
    profile_image = serializers.ImageField(write_only=True, required=False, allow_null=True)

    class Meta:
        model = User
        fields = [
            'first_name',
            'last_name',
            'email',
            'blood_group',
            'date_of_birth',
            'gender',
            'profile_picture',
            'profile_image',
        ]
        extra_kwargs = {
            'first_name': {'required': False},
            'last_name': {'required': False},
            'email': {'required': False},
            'blood_group': {'required': False},
            'date_of_birth': {'required': False},
            'gender': {'required': False},
            'profile_picture': {'required': False, 'allow_null': True},
        }

    def to_internal_value(self, data):
        # Support both 'profile_picture' and 'profile_image'
        if 'profile_image' in data and 'profile_picture' not in data:
            data = data.copy()
            data['profile_picture'] = data['profile_image']
        return super().to_internal_value(data)