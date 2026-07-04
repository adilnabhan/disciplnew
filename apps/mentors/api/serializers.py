
from rest_framework import serializers
from django.contrib.auth import get_user_model
from apps.mentors.models import MentorProfile, TrainerCertificate
from apps.fitnesscenter.models import Category, Organization
from phonenumber_field.serializerfields import PhoneNumberField

from apps.user.models import User
from apps.utils.mobilenumber import hash_contact_number



class TrainerCertificateSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrainerCertificate
        fields = ['id', 'certificate', 'uploaded_at']
        
        
class CategorySerializer(serializers.ModelSerializer):
    logo = serializers.SerializerMethodField()

    class Meta:
        model = Category
        fields = ['id', 'name', 'logo', 'status_string']

    def get_logo(self, obj):
        return obj.logo.url if obj.logo else None


class TrainerSerializer(serializers.ModelSerializer):
    organization_id = serializers.PrimaryKeyRelatedField(
        queryset=Organization.objects.all(),
        source='mentor_profile.organization',
        write_only=True
    )
    experience = serializers.CharField(source='mentor_profile.experience', required=False, allow_blank=True)
    designation = serializers.CharField(source='mentor_profile.designation', required=False, allow_blank=True)
    emergency_contact = serializers.CharField(source='mentor_profile.emergency_contact', required=False, allow_blank=True)
    address_proof = serializers.FileField(source='mentor_profile.address_proof', required=False, allow_null=True)
    trainer_certificates = serializers.ListField(
        child=serializers.FileField(),
        write_only=True,
        required=False
    )
    categories = serializers.ListField(
        child=serializers.PrimaryKeyRelatedField(queryset=Category.objects.all()),
        write_only=True,
        required=False,
        source='categories_list'
    )

    profile_picture = serializers.SerializerMethodField()
    certificates = TrainerCertificateSerializer(source='mentor_profile.trainer_certificates', many=True, read_only=True)
    category_data = CategorySerializer(source='mentor_profile.categories', many=True, read_only=True)
    mobile_number = PhoneNumberField()
    
    class Meta:
        model = User
        fields = [
            'id', 'first_name', 'last_name', 'mobile_number', 'email', 'organization_id', 'experience', 'emergency_contact', 'gender', 'blood_group',
            'date_of_birth', 'address_proof', 'trainer_certificates', 'certificates', 'designation', 'profile_picture', 'categories', 'user_role', 'category_data'
        ]
        extra_kwargs = {
            'email': {'required': False, 'allow_blank': True},
        }

    def get_profile_picture(self, obj):
        return obj.profile_picture.url if obj.profile_picture else None
        
    def validate_user_role(self, value):
        if value not in [
            User.MENTOR, 
            User.MENTOR_STAFF, 
            User.MENTOR_ACCOUNTS, 
            User.MENTOR_TRAINER
        ]:
            raise serializers.ValidationError("Invalid user role for a mentor profile.")
        return value

    def validate_mobile_number(self, value):
        if self.instance:
            # On update, exclude current instance
            if User.objects.exclude(id=self.instance.id).filter(mobile_number=value).exists():
                raise serializers.ValidationError("A user with this mobile number already exists.")
        # On create: allow duplicates — we handle linking in .create()
        return value

    def create(self, validated_data):
        mentor_data = validated_data.pop('mentor_profile', {})
        files = validated_data.pop('trainer_certificates', [])
        categories = validated_data.pop('categories_list', None)
        
        organization = mentor_data.get('organization')
        if not organization:
            raise serializers.ValidationError({"message": "Organization is required."})
        
        if not (organization.is_subscribed or organization.is_on_free_trial):
            raise serializers.ValidationError({"message": "Cannot assign trainer to an unsubscribed or non-trial organization."})

        # --- B5 Fix: Handle existing trainer with same mobile number ---
        mobile_number = validated_data.get('mobile_number')
        existing_user = User.objects.filter(mobile_number=mobile_number).first()
        if existing_user:
            # Update basic info on the existing user
            for field in ['first_name', 'last_name', 'email', 'gender', 'blood_group', 'date_of_birth']:
                if field in validated_data:
                    setattr(existing_user, field, validated_data[field])
            existing_user.user_role = User.MENTOR_TRAINER
            existing_user.save()
            existing_user.create_profile()

            # Ensure MentorProfile is linked to the org
            from apps.mentors.models import MentorProfile
            mentor, _ = MentorProfile.objects.get_or_create(user=existing_user)
            mentor.organization = organization
            mentor.designation = MentorProfile.TRAINER
            for attr, value in mentor_data.items():
                if attr != 'organization':
                    setattr(mentor, attr, value)
            mentor.save()

            # Create/Resolve OrganizationTrainerLink
            from apps.trainer.models import Trainer, OrganizationTrainerLink
            trainer_profile = Trainer.objects.filter(user=existing_user).first()
            if not trainer_profile and existing_user.mobile_number:
                trainer_profile = Trainer.objects.filter(mobile=existing_user.mobile_number.as_international).first()
            if not trainer_profile and existing_user.email:
                trainer_profile = Trainer.objects.filter(email=existing_user.email).first()

            if not trainer_profile:
                trainer_profile = Trainer.objects.create(
                    user=existing_user,
                    user_type='trainer',
                    first_name=existing_user.first_name,
                    last_name=existing_user.last_name,
                    email=existing_user.email,
                    mobile=existing_user.mobile_number.as_international if existing_user.mobile_number else None
                )
            else:
                if not trainer_profile.user:
                    trainer_profile.user = existing_user
                    trainer_profile.save()

            OrganizationTrainerLink.objects.get_or_create(
                trainer=trainer_profile,
                organization=organization,
                defaults={'status': OrganizationTrainerLink.APPROVED, 'invited_by_org': True}
            )
            if categories:
                mentor.categories.set(categories)
            for file in files:
                from apps.mentors.models import TrainerCertificate
                TrainerCertificate.objects.create(mentor_profile=mentor, certificate=file)
            return existing_user
        # --- End B5 Fix ---

        if 'user_role' not in validated_data:
            validated_data['user_role'] = User.MENTOR_TRAINER

        user = User.objects.create(**validated_data)
        user.refresh_from_db() 
                
        hash_phone = hash_contact_number(user.mobile_number.as_international)

        mentor = user.mentor_profile
        mentor.hash_of_user_phone_number = hash_phone
        
        if 'designation' not in mentor_data:
            if user.user_role == User.MENTOR_TRAINER:
                mentor.designation = MentorProfile.TRAINER
            elif user.user_role == User.MENTOR:
                mentor.designation = MentorProfile.ADMIN
            elif user.user_role == User.MENTOR_ACCOUNTS:
                mentor.designation = MentorProfile.ACCOUNTS

        print(categories, '*************')
        for attr, value in mentor_data.items():
            setattr(mentor, attr, value)
        mentor.save()

        if user.user_role == User.MENTOR_TRAINER:
            from apps.trainer.models import Trainer, OrganizationTrainerLink
            trainer_profile, _ = Trainer.objects.get_or_create(
                user=user,
                defaults={
                    'user_type': 'trainer',
                    'first_name': user.first_name,
                    'last_name': user.last_name,
                    'email': user.email,
                    'mobile': user.mobile_number.as_international if user.mobile_number else None
                }
            )
            OrganizationTrainerLink.objects.get_or_create(
                trainer=trainer_profile,
                organization=organization,
                defaults={'status': OrganizationTrainerLink.APPROVED, 'invited_by_org': True}
            )
        
        if categories:
            mentor.categories.set(categories)

        for file in files:
            TrainerCertificate.objects.create(mentor_profile=mentor, certificate=file)

        return user

    def update(self, instance, validated_data):
        mentor_data = validated_data.pop('mentor_profile', {})
        files = validated_data.pop('trainer_certificates', [])

        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        mentor = getattr(instance, 'mentor_profile', None)
        if mentor:
            for attr, value in mentor_data.items():
                setattr(mentor, attr, value)
            mentor.save()

            for file in files:
                TrainerCertificate.objects.create(mentor_profile=mentor, certificate=file)

        return instance


class OrganizationSerializer(serializers.ModelSerializer):
    logo = serializers.SerializerMethodField()

    class Meta:
        model = Organization
        fields = ['id', 'name', 'category', 'email', 'phone_number', 'logo']

    def get_logo(self, obj):
        return obj.logo.url if obj.logo else None

class TrainerCertificateSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrainerCertificate
        fields = ['id', 'certificate', 'uploaded_at']

class MentorProfileReadSerializer(serializers.ModelSerializer):
    organization = OrganizationSerializer()
    categories = CategorySerializer(many=True)
    class Meta:
        model = MentorProfile
        fields = [ 'id','organization', 'experience', 'designation', 'emergency_contact', 'address_proof', 'categories']

class TrainerReadSerializer(serializers.ModelSerializer):
    mentor_profile = MentorProfileReadSerializer(read_only=True)
    certificates = TrainerCertificateSerializer(source='mentor_profile.trainer_certificates', many=True, read_only=True)
    profile_picture = serializers.SerializerMethodField()
    assigned_clients_count = serializers.SerializerMethodField()
    today_assigned_clients_count = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id', 'first_name', 'last_name', 'mobile_number', 'email', 'gender', 'blood_group',
            'date_of_birth', 'mentor_profile', 'certificates', 'profile_picture',
            'assigned_clients_count', 'today_assigned_clients_count'
        ]

    def get_profile_picture(self, obj):
        return obj.profile_picture.url if obj.profile_picture else None

    def get_assigned_clients_count(self, obj):
        from apps.customers.models import Customer
        trainer_profile = getattr(obj, 'trainer_profile', None)
        if trainer_profile:
            return Customer.objects.filter(trainer=trainer_profile).count()
        return 0

    def get_today_assigned_clients_count(self, obj):
        from apps.customers.models import Customer
        from django.utils import timezone
        trainer_profile = getattr(obj, 'trainer_profile', None)
        if trainer_profile:
            today = timezone.localdate()
            return Customer.objects.filter(
                trainer=trainer_profile,
                trainer_assigned_at__date=today
            ).count()
        return 0
