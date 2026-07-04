from rest_framework import serializers
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
    TrainerPlan
)
from apps.utils.create_razorpay_plan import create_razorpay_plan

class TrainerBasicSerializer(serializers.ModelSerializer):

    class Meta:
        model = Trainer
        fields = [
            "id",
            "user_type",
            "first_name",
            "last_name",
            "email",
            "mobile",
            "gender",
            "date_of_birth",
            "experience_years",
            "bio",
            "profile_image",
            "profile_step"
        ]
        read_only_fields = ["profile_step", "mobile"]
        extra_kwargs = {
            'mobile': {'required': False, 'read_only': True},
            'first_name': {'required': False},
            'last_name': {'required': False},
            'email': {'required': False},
        }

    def validate_mobile(self, value):
        qs = Trainer.objects.filter(mobile=value)
        if self.instance:
            qs = qs.exclude(pk=self.instance.pk)
        if qs.exists():
            # Return existing trainer's data — handled in create via get_or_create
            pass
        return value

    def create(self, validated_data):
        otp = self.context.get('otp')
        user = self.context.get('user') or (otp.user if otp and otp.user else None)

        if not user:
            from apps.user.models import User
            from phonenumber_field.phonenumber import PhoneNumber
            mobile = str(otp.mobile_number)
            user_type = validated_data.get('user_type', 'trainer')
            user_role = User.MENTOR_TRAINER if user_type == 'trainer' else User.MENTOR_DIETITIAN
            phone_number = PhoneNumber.from_string(mobile)
            user, _ = User.objects.get_or_create(
                mobile_number=phone_number,
                defaults={
                    'email': validated_data.get('email'),
                    'first_name': validated_data.get('first_name'),
                    'last_name': validated_data.get('last_name'),
                    'gender': validated_data.get('gender'),
                    'date_of_birth': validated_data.get('date_of_birth'),
                    'user_role': user_role,
                    'username': str(phone_number)
                }
            )

        mobile = str(otp.mobile_number) if otp else str(user.mobile_number)
        mobile = mobile if mobile else None
        existing = Trainer.objects.filter(user=user).first()
        if existing:
            return self.update(existing, validated_data)

        trainer = Trainer.objects.create(user=user, mobile=mobile, **validated_data)
        trainer.profile_step = 2
        trainer.save(update_fields=['profile_step'])
        return trainer

    def update(self, instance, validated_data):
        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        if instance.user:
            instance.user.first_name = validated_data.get('first_name', instance.user.first_name)
            instance.user.last_name = validated_data.get('last_name', instance.user.last_name)
            instance.user.email = validated_data.get('email', instance.user.email)
            instance.user.gender = validated_data.get('gender', instance.user.gender)
            instance.user.date_of_birth = validated_data.get('date_of_birth', instance.user.date_of_birth)

            # Sync user_role with user_type to prevent role/type mismatch
            if 'user_type' in validated_data:
                from apps.user.models import User
                user_type = validated_data['user_type']
                expected_role = User.MENTOR_TRAINER if user_type == 'trainer' else User.MENTOR_DIETITIAN
                if instance.user.user_role != expected_role:
                    instance.user.user_role = expected_role

            instance.user.save()

        instance.profile_step = max(instance.profile_step, 2)
        instance.save()

        return instance
    
class TrainerExperienceSerializer(serializers.Serializer):

    experience_years = serializers.IntegerField()
    bio = serializers.CharField()
    specializations = serializers.ListField(
        child=serializers.IntegerField()
    )

class TrainerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Trainer
        fields = "__all__"


class SpecializationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Specialization
        fields = "__all__"


class TrainerSpecializationSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrainerSpecialization
        fields = "__all__"


class TrainerCertificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrainerCertification
        fields = "__all__"


class TrainerPortfolioSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrainerPortfolio
        fields = "__all__"


class TrainerTransformationSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrainerTransformation
        fields = "__all__"


class LanguageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Language
        fields = "__all__"


class TrainerLanguageSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrainerLanguage
        fields = "__all__"


class TrainerSocialLinkSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrainerSocialLink
        fields = "__all__"


class LocationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Location
        fields = "__all__"


class TrainerBankAccountSerializer(serializers.ModelSerializer):

    class Meta:
        model = TrainerBankAccount
        fields = "__all__"
        read_only_fields = [
            "razorpay_account_id",
            "razorpay_product_id",
            "razorpay_stakeholder_id",
            "razorpay_account_status"
        ]

    def create(self, validated_data):
        bank = TrainerBankAccount.objects.create(**validated_data)

        # call razorpay account creation
        response = create_trainer_linked_account(
            bank.trainer,
            bank
        )

        bank.razorpay_account_id = response.get("account_id")
        bank.razorpay_product_id = response.get("product_id")
        bank.razorpay_account_status = response.get("razorpay_account_status")

        bank.save()

        return bank


class TrainerPlanSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrainerPlan
        fields = "__all__"

class TrainerDetailSerializer(serializers.ModelSerializer):

    specializations = TrainerSpecializationSerializer(many=True, read_only=True)
    certifications = TrainerCertificationSerializer(many=True, read_only=True)
    portfolios = TrainerPortfolioSerializer(many=True, read_only=True)
    transformations = TrainerTransformationSerializer(many=True, read_only=True)
    languages = TrainerLanguageSerializer(many=True, read_only=True)
    plans = TrainerPlanSerializer(many=True, read_only=True)
    locations = LocationSerializer(many=True, read_only=True)
    is_plan_purchased = serializers.SerializerMethodField()
    active_subscription = serializers.SerializerMethodField()

    class Meta:
        model = Trainer
        fields = "__all__"

    def get_is_plan_purchased(self, obj):
        from apps.trainer.models import TrainerSubscription
        return TrainerSubscription.objects.filter(
            trainer=obj, status=TrainerSubscription.ACTIVE
        ).exists()

    def get_active_subscription(self, obj):
        from apps.trainer.models import TrainerSubscription
        sub = TrainerSubscription.objects.filter(
            trainer=obj, status=TrainerSubscription.ACTIVE
        ).select_related('plan').first()
        if not sub:
            return None
        return {
            'plan_name': sub.plan.name,
            'plan_type': sub.plan.plan_type,
            'start_date': sub.start_date,
            'end_date': sub.end_date,
            'status': sub.status,
        }