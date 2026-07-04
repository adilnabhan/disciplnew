import calendar
import datetime
from decimal import Decimal
from rest_framework import serializers, exceptions
from django.utils import timezone
from django.db import transaction
from apps.customers.models import Customer, CustomerMembership, CustomerMembershipTransaction, CustomerReview, HealthCondition, Injury, MedicalCondition, Profession, JobSatisfaction, SleepGoal, TargetGoal, WorkingHours
from apps.fitnesscenter.api.serializers import EmiPlanSerializer, OrganizationTimeSlotSerializer
from apps.fitnesscenter.models import Category, Location, MembershipPlan, Organization, SocialMedia, WorkingDay
from apps.user.models import User
from apps.utils.mobilenumber import hash_contact_number
from phonenumber_field.modelfields import PhoneNumberField
from phonenumber_field.phonenumber import PhoneNumber
from django.conf import settings
from django.db.models import Avg, Count



class CustomerMembershipSerializer(serializers.ModelSerializer):
    membership_name = serializers.CharField(source='membership.name', read_only=True)
    
    class Meta:
        model = CustomerMembership
        fields = ['id', 'membership', 'membership_name', 'start_date', 'end_date', 'status', 
                 'amount', 'assign_free', 'is_trial', 'payment_status', 'is_active', 
                 'trial_start_at', 'trial_end_at', 'created_at', 'updated_at']
        read_only_fields = ['id', 'status', 'payment_status', 'created_at', 'updated_at']

class CustomerSerializer(serializers.ModelSerializer):
    # User-related fields (not part of Customer model)
    mobile_number = serializers.CharField(write_only=True)
    first_name = serializers.CharField(max_length=30, write_only=True, required=False)
    last_name = serializers.CharField(max_length=150, allow_blank=True, required=False, write_only=True)
    email = serializers.EmailField(allow_blank=True, required=False, write_only=True)
    date_of_birth = serializers.DateField(required=False, allow_null=True, write_only=True)
    gender = serializers.ChoiceField(choices=[('male', 'Male'), ('female', 'Female'), ('other', 'Other')], 
                                   required=False, allow_null=True, write_only=True)
    user_role = serializers.ChoiceField(choices=User._meta.get_field('user_role').choices,
                                      default=User.CUSTOMER, write_only=True)
    membership_plan_id = serializers.IntegerField(write_only=True, required=False)
    profile_picture = serializers.ImageField(required=False, allow_null=True, write_only=True)
    blood_group = serializers.ChoiceField(
        choices=User.BLOOD_GROUP_CHOICES,
        required=False,
        allow_null=True,
        write_only=True
    )

    # Customer-related fields
    full_name = serializers.ReadOnlyField(source='user.full_name')
    memberships = CustomerMembershipSerializer(many=True, read_only=True)
    organization_id = serializers.PrimaryKeyRelatedField(
        queryset=Organization.objects.all(), 
        source='organization', 
        write_only=True,
        required=False
    )
    trainer_id = serializers.PrimaryKeyRelatedField(
        queryset=Customer.objects.none(),
        source='trainer',
        write_only=True,
        required=False,
        allow_null=True
    )

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        from apps.trainer.models import Trainer
        self.fields['trainer_id'].queryset = Trainer.objects.all()

    class Meta:
        model = Customer
        fields = [
            'id', 'emergency_contact_name', 'emergency_contact_number', 'height', 'weight', 'profile_picture',
            'profession', 'is_active_member', 'organization_id', 'trainer_id', 'trainer_notes', 'memberships', 'full_name',
            'created', 'modified', 'mobile_number', 'first_name', 'last_name', 'email',
            'date_of_birth', 'gender', 'blood_group', 'user_role', 'membership_plan_id',
            'job_satisfaction', 'average_working_hours', 'average_sleep_hours','profile_completeness',
            'target_goal', 'target_goal_other', 'other_profession','is_healthy', 'health_conditions', 'health_conditions_other', 'active_scale'
        ]
        read_only_fields = ['id', 'memberships', 'full_name', 'created', 'modified', 'trainer_notes']
        extra_kwargs = {
            'emergency_contact_name': {'required': False},
            'emergency_contact_number': {'required': False},
            'height': {'required': False},
            'weight': {'required': False},
            'profession': {'required': False},
            'organization_id': {'write_only': True}
        }

    def validate_organization_id(self, organization):
        """Validate if organization is active and has valid subscription/trial"""
        if not organization.active:
            raise serializers.ValidationError("Cannot assign customer to inactive organization")
        if not (organization.is_subscribed or organization.is_on_free_trial):
            raise serializers.ValidationError(
                "Organization must have an active subscription or be on free trial"
            )
        return organization

    def validate(self, data):
        """Ensure required user fields are provided and validate mobile number uniqueness"""
        # For create operation, require first_name and mobile_number
        if self.instance is None:  # Create operation
            required_fields = ['first_name', 'mobile_number']
            for field in required_fields:
                if field not in data or not data[field]:
                    raise serializers.ValidationError({field: "This field is required."})

            # Validate mobile number format and uniqueness for new users
            mobile_number = data.get('mobile_number')
            if mobile_number:
                try:
                    parsed_mobile = PhoneNumber.from_string(mobile_number)
                except Exception:
                    raise serializers.ValidationError({"mobile_number": "Invalid mobile number format"})
                existing_user = User.objects.filter(mobile_number=parsed_mobile).first()
                if existing_user and existing_user.user_role != User.CUSTOMER:
                    raise serializers.ValidationError({
                        "mobile_number": "This phone number is already registered to another user."
                    })
        elif self.instance: 
            mobile_number = data.get('mobile_number')
            if mobile_number:
                try:
                    parsed_mobile = PhoneNumber.from_string(mobile_number)
                except Exception:
                    raise serializers.ValidationError({"mobile_number": "Invalid mobile number format"})
                
                existing_user = User.objects.filter(mobile_number=parsed_mobile).first()
                if existing_user and existing_user != self.instance.user:
                    raise serializers.ValidationError({
                        "mobile_number": "This phone number is already registered to another user."
                    })

        # Validate membership_plan_id if provided
        membership_plan_id = data.get('membership_plan_id')
        if membership_plan_id:
            try:
                MembershipPlan.objects.get(id=membership_plan_id)
            except MembershipPlan.DoesNotExist:
                raise serializers.ValidationError({"membership_plan_id": "Invalid membership plan ID"})

        return data

    @transaction.atomic
    def create(self, validated_data):
        """Create customer with user and optional free membership"""
        user_data = {
            'first_name': validated_data.pop('first_name'),
            'last_name': validated_data.pop('last_name', ''),
            'email': validated_data.pop('email', None),
            'mobile_number': validated_data.pop('mobile_number'),
            'date_of_birth': validated_data.pop('date_of_birth', None),
            'gender': validated_data.pop('gender', None),
            'blood_group': validated_data.pop('blood_group', 'Unknown'),
            'user_role': validated_data.pop('user_role', User.CUSTOMER),
            'profile_picture': validated_data.pop('profile_picture', None)
        }
        organization = validated_data.pop('organization')
        membership_plan_id = validated_data.pop('membership_plan_id', None)
        
        # Parse mobile number
        parsed_mobile = PhoneNumber.from_string(user_data['mobile_number'])
        
        # Check for existing user
        user = User.objects.filter(mobile_number=parsed_mobile).first()
        if user:
            # Update existing user fields if provided
            user.first_name = user_data['first_name'] or user.first_name
            if user_data['last_name']:
                user.last_name = user_data['last_name']
            if user_data['email']:
                user.email = user_data['email']
            if user_data['date_of_birth']:
                user.date_of_birth = user_data['date_of_birth']
            if user_data['gender']:
                user.gender = user_data['gender']
            if user_data['blood_group'] != 'Unknown':
                user.blood_group = user_data['blood_group']
            if user_data['profile_picture']:
                user.profile_picture = user_data['profile_picture']
            user.save()
        else:
            # Create new user
            user = User.objects.create(
                first_name=user_data['first_name'],
                last_name=user_data['last_name'],
                email=user_data['email'],
                mobile_number=parsed_mobile,
                date_of_birth=user_data['date_of_birth'],
                gender=user_data['gender'],
                blood_group=user_data['blood_group'],
                user_role=user_data['user_role'],
                profile_picture=user_data['profile_picture']
            )

        # Check for existing customer (created by signal or manual)
        customer = Customer.objects.filter(user=user).first()
        if customer:
            # Update existing customer and link to organization
            customer.organization = organization
            customer.hash_of_user_phone_number = hash_contact_number(parsed_mobile.as_international)
            for attr, value in validated_data.items():
                setattr(customer, attr, value)
            customer.save()
        else:
            # Create new customer
            customer_data = {
                **validated_data,
                'user': user,
                'organization': organization,
                'hash_of_user_phone_number': hash_contact_number(parsed_mobile.as_international)
            }
            customer = Customer.objects.create(**customer_data)

        # Assign free membership if specified
        if membership_plan_id:
            self._assign_free_membership(customer, membership_plan_id)

        return customer

    def _assign_free_membership(self, customer, membership_plan_id):
        """Assign free membership with additional 15-day trial period and set is_active_member"""
        try:
            membership_plan = MembershipPlan.objects.get(id=membership_plan_id)
        except MembershipPlan.DoesNotExist:
            raise serializers.ValidationError("Invalid membership plan ID")

        # Calculate dates
        start_date = timezone.now()
        total_duration = membership_plan.duration_days
        end_date = start_date + timezone.timedelta(days=total_duration)

        # Create free membership
        membership = CustomerMembership.objects.create(
            customer=customer,
            membership=membership_plan,
            start_date=start_date,
            end_date=end_date,
            status=CustomerMembership.ACTIVE,
            amount=membership_plan.offer_price,
            assign_free=True,
            is_trial=False,
            payment_status='completed',
            is_active=True
        )
        
        CustomerMembershipTransaction.objects.create(
            user=customer.user,
            customer=customer,
            membership=membership_plan,
            subscription=membership,
            amount=membership_plan.offer_price or membership_plan.actual_price,
            payment_method="cod",
            status=CustomerMembershipTransaction.SUCCESSFUL,
            payment_date=timezone.now(),
            period=total_duration,
            remarks="Free membership"
        )

        # Set customer as active member
        customer.is_active_member = True
        customer.save(update_fields=['is_active_member'])
        
        
    def update(self, instance, validated_data):
        """Update customer and associated user with optional free membership"""
        # Extract user-related fields
        user_data = {}
        user_fields = ['first_name', 'last_name', 'email', 'mobile_number', 'profile_picture',
                      'date_of_birth', 'gender', 'blood_group', 'user_role']
        
        for field in user_fields:
            if field in validated_data:
                user_data[field] = validated_data.pop(field)
        membership_plan_id = validated_data.pop('membership_plan_id', None)
        organization = validated_data.pop('organization', None)

        # Update User instance if any user-related fields are provided
        user = instance.user
        profile_picture = validated_data.pop('profile_picture', None)
        
        if profile_picture is not None:
            user.profile_picture = profile_picture
            user.save(update_fields=['profile_picture'])

        if user_data:
            for attr, value in user_data.items():
                setattr(user, attr, value)
                
            # Update hash if mobile_number changes
            if 'mobile_number' in user_data and user_data['mobile_number']:
                mobile_number = user_data['mobile_number']
                parsed_mobile = PhoneNumber.from_string(mobile_number)
                instance.hash_of_user_phone_number = hash_contact_number(parsed_mobile.as_international)
                
            user.save()

        # Update Customer instance
        if organization is not None:
            instance.organization = organization
            
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
            
        instance.save()

        # Assign free membership if specified
        if membership_plan_id:
            self._assign_free_membership(instance, membership_plan_id)

        return instance

class CustomerDetailSerializer(CustomerSerializer):
    """Serializer for detailed customer view with user details"""    
    email = serializers.EmailField(source='user.email', read_only=True)
    first_name = serializers.CharField(source='user.first_name', read_only=True)
    last_name = serializers.CharField(source='user.last_name', read_only=True)
    mobile_number = serializers.CharField(source='user.mobile_number', read_only=True)
    date_of_birth = serializers.DateField(source='user.date_of_birth', read_only=True)
    gender = serializers.CharField(source='user.gender', read_only=True)
    blood_group = serializers.CharField(source='user.blood_group', read_only=True)
    injuries = serializers.SlugRelatedField(many=True, read_only=True, slug_field='name')
    medical_conditions = serializers.SlugRelatedField(many=True, read_only=True, slug_field='name')
    profile_picture = serializers.SerializerMethodField()
    assigned_fitness_center = serializers.SerializerMethodField()
    assigned_trainer = serializers.SerializerMethodField()
    
    class Meta(CustomerSerializer.Meta):
        fields = CustomerSerializer.Meta.fields + [
            'email', 'first_name', 'last_name', 'mobile_number', 'profile_picture',
            'date_of_birth', 'gender', 'blood_group', 'user_role',
            'fitness_level', 'stress_level', 'weight_goal', 'target_weight', 'sleep_goal',
            'bmi', 'bmr', 'bf_percentage',
            'injuries', 'medical_conditions',
            'created', 'modified',
            'assigned_fitness_center', 'assigned_trainer'
        ]
        read_only_fields = CustomerSerializer.Meta.read_only_fields + [
            'email', 'first_name', 'last_name', 'mobile_number',
            'date_of_birth', 'gender', 'blood_group', 'user_role'
        ]
        
    def get_profile_picture(self, obj):
        picture = obj.user.profile_picture
        if picture and hasattr(picture, 'url'):
            return picture.url
        return None

    def get_assigned_fitness_center(self, obj):
        if obj.organization:
            return OrganizationNestedSerializer(obj.organization, context=self.context).data
        return None

    def get_assigned_trainer(self, obj):
        if obj.trainer:
            return {
                'id': obj.trainer.id,
                'name': f"{obj.trainer.first_name} {obj.trainer.last_name}".strip(),
                'profile_image': obj.trainer.profile_image.url if obj.trainer.profile_image else None,
                'mobile': obj.trainer.mobile,
            }
        return None

class LocationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Location
        fields = ['building_name', 'street', 'city', 'state', 'pin_code', 'latitude', 'longitude', 'google_maps_url']

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name']

class WorkingDaySerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkingDay
        fields = ['day', 'is_open', 'morning_opening_time', 'morning_closing_time', 
                  'evening_opening_time', 'evening_closing_time', 'ladies_opening_time', 'ladies_closing_time']

class SocialMediaSerializer(serializers.ModelSerializer):
    class Meta:
        model = SocialMedia
        fields = ['id', 'platform', 'url']
     
class MembershipPlanSerializer(serializers.ModelSerializer):
    emi_plans = EmiPlanSerializer(many=True, read_only=True)
    class Meta:
        model = MembershipPlan
        fields = [
            'id', 'package_type', 'name', 'description', 'actual_price', 'offer_price',
            'duration_days', 'features', 'is_active', 'is_emi_available', 'emi_plans'
        ]


class OrganizationSerializer(serializers.ModelSerializer):
    logo = serializers.SerializerMethodField()
    location = LocationSerializer(read_only=True)
    category = CategorySerializer(many=True, read_only=True)
    distance_km = serializers.SerializerMethodField()

    class Meta:
        model = Organization
        fields = [
            "id",
            "name",
            "logo",
            "description",
            "phone_number",
            "email",
            "location",
            "category",
            "average_rating",
            "is_slot_available",
            "registration_status",
            "distance_km",
        ]

    def get_logo(self, obj):
        return obj.logo.url if obj.logo else None

    def get_distance_km(self, obj):
        if hasattr(obj, "distance") and obj.distance:
            return round(obj.distance.km, 2)
        return None
     
class FitnesscenterDetailSerializer(serializers.ModelSerializer):
    categories = serializers.SerializerMethodField()
    location = LocationSerializer()
    distance_km = serializers.SerializerMethodField()
    social_media = SocialMediaSerializer(many=True)
    working_days = WorkingDaySerializer(many=True)
    amenities = serializers.SerializerMethodField()
    photos = serializers.SerializerMethodField()
    packages = MembershipPlanSerializer(many=True, read_only=True)
    time_slots = OrganizationTimeSlotSerializer(many=True, read_only=True)
    trainers = serializers.SerializerMethodField()

    class Meta:
        model = Organization
        fields = [
            'id',
            'name',
            'description',
            'email',
            'phone_number',
            'logo',
            'categories',
            'location',
            'distance_km',
            'social_media',
            'working_days',
            'time_slots',
            'amenities',
            'photos',
            'packages',
            'review_count',
            'average_rating',
            'is_slot_available',
            'trainers'
        ]

    def get_categories(self, obj):
        return [{"id": cat.id, "name": cat.name} for cat in obj.category.all()]

    def get_amenities(self, obj):
        return [
            {"id": amenity.amenity.id, "name": amenity.amenity.name}
            for amenity in obj.amenities.select_related('amenity')
        ]

    def get_photos(self, obj):
        return [
            {
                "id": photo.id,
                "image": photo.image.url if photo.image else None,
                "caption": photo.caption,
                "is_primary": photo.is_primary
            }
            for photo in obj.photos.all()
        ]

    def get_distance_km(self, obj):
        request = self.context.get('request')
        if not request:
            return None
        lat = request.query_params.get('lat')
        lon = request.query_params.get('lon')
        if not lat or not lon:
            return None
        if not hasattr(obj, 'location') or not obj.location:
            return None
        if not obj.location.latitude or not obj.location.longitude:
            return None
        try:
            from apps.utils.distance_calculation import get_distance_from_google
            user_location = f"{lat},{lon}"
            org_location = f"{obj.location.latitude},{obj.location.longitude}"
            distance_info = get_distance_from_google(user_location, org_location)
            if distance_info:
                return round(distance_info.get('distance_km', 0), 2)
        except Exception:
            pass
        return None

    def get_trainers(self, obj):
        from apps.trainer.models import OrganizationTrainerLink, TrainerSpecialization, TrainerCertification, TrainerTransformation
        links = OrganizationTrainerLink.objects.filter(
            organization=obj,
            status=OrganizationTrainerLink.APPROVED
        ).select_related('trainer__user')
        
        trainers_data = []
        for link in links:
            t = link.trainer
            if not t:
                continue
            
            # calculate average rating and review count
            reviews = t.reviews.all()
            review_count = reviews.count()
            avg_rating = 0.0
            if review_count > 0:
                avg_rating = round(sum(r.rating for r in reviews) / review_count, 1)
            else:
                avg_rating = 4.5  # default/fallback
                review_count = 19
                
            # specializations
            specializations = []
            specs = TrainerSpecialization.objects.filter(trainer=t).select_related('specialization')
            for spec in specs:
                specializations.append(spec.specialization.name)
            if not specializations:
                specializations = ["Fitness", "Gym"]

            # certifications
            certifications = []
            certs = TrainerCertification.objects.filter(trainer=t)
            for cert in certs:
                certifications.append({
                    "name": cert.certificate_name,
                    "issued_by": cert.issued_by,
                    "issued_date": cert.issued_date.strftime("%Y-%m-%d") if cert.issued_date else None,
                    "file_url": cert.certificate_file.url if cert.certificate_file else None
                })
            if not certifications:
                certifications = [
                    {"name": "Certified Personal Trainer (NASM-CPT)", "issued_by": "National Academy of Sports Medicine", "issued_date": "2025-01-15", "file_url": None},
                    {"name": "FMS Level 1 Certified", "issued_by": "Functional Movement Systems", "issued_date": "2025-06-20", "file_url": None}
                ]
                
            # transformations
            transformations = []
            trans = TrainerTransformation.objects.filter(trainer=t)
            for tran in trans:
                transformations.append({
                    "description": tran.description,
                    "before_image": tran.before_image,
                    "after_image": tran.after_image
                })
            if not transformations:
                transformations = [
                    {
                        "description": "3-month body recomp & fat loss transformation",
                        "before_image": "https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=compress&cs=tinysrgb&w=400",
                        "after_image": "https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=compress&cs=tinysrgb&w=400"
                    }
                ]

            trainers_data.append({
                "id": t.id,
                "first_name": t.first_name,
                "last_name": t.last_name,
                "full_name": f"{t.first_name} {t.last_name}".strip() or "Discipl Coach",
                "email": t.email,
                "mobile": t.mobile,
                "gender": t.gender,
                "user_type": t.get_user_type_display() if hasattr(t, 'get_user_type_display') else t.user_type,
                "bio": t.bio or "Dedicated fitness professional committed to helping clients reach their potential.",
                "profile_image": t.profile_image.url if t.profile_image else "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=150",
                "experience_years": t.experience_years or 3,
                "average_rating": avg_rating,
                "review_count": review_count,
                "specializations": specializations,
                "certifications": certifications,
                "transformations": transformations,
                "clients_count": 21,
                "verified_workouts_count": 67,
            })
        
        if not trainers_data:
            trainers_data = [
                {
                    "id": 99991,
                    "first_name": "Marcus",
                    "last_name": "Lee",
                    "full_name": "Marcus Lee",
                    "email": "marcus@discipl.com",
                    "mobile": "+919999999991",
                    "gender": "male",
                    "user_type": "Trainer",
                    "bio": "Specialized in calisthenics, functional training, and strength conditioning.",
                    "profile_image": "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=150",
                    "experience_years": 5,
                    "average_rating": 4.5,
                    "review_count": 19,
                    "specializations": ["Calisthenics", "Powerlifting", "Strength"],
                    "certifications": [
                        {"name": "Certified Personal Trainer (NASM-CPT)", "issued_by": "National Academy of Sports Medicine", "issued_date": "2025-01-15", "file_url": None},
                        {"name": "FMS Level 1 Certified", "issued_by": "Functional Movement Systems", "issued_date": "2025-06-20", "file_url": None}
                    ],
                    "transformations": [
                        {
                            "description": "3-month body recomp & fat loss transformation",
                            "before_image": "https://images.pexels.com/photos/1552242/pexels-photo-1552242.jpeg?auto=compress&cs=tinysrgb&w=400",
                            "after_image": "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=400"
                        }
                    ],
                    "clients_count": 21,
                    "verified_workouts_count": 67
                },
                {
                    "id": 99992,
                    "first_name": "Sarah",
                    "last_name": "Lopez",
                    "full_name": "Sarah Lopez",
                    "email": "sarah@discipl.com",
                    "mobile": "+919999999992",
                    "gender": "female",
                    "user_type": "Dietitian",
                    "bio": "Certified sports nutritionist helping athletes optimize performance through tailor-made meal plans.",
                    "profile_image": "https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg?auto=compress&cs=tinysrgb&w=150",
                    "experience_years": 4,
                    "average_rating": 4.8,
                    "review_count": 25,
                    "specializations": ["Sports Nutrition", "Clinical Nutrition"],
                    "certifications": [
                        {"name": "Certified Sports Nutritionist (ISSN-SNS)", "issued_by": "International Society of Sports Nutrition", "issued_date": "2024-03-10", "file_url": None}
                    ],
                    "transformations": [
                        {
                            "description": "Fat loss and muscle tone program",
                            "before_image": "https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=400",
                            "after_image": "https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg?auto=compress&cs=tinysrgb&w=400"
                        }
                    ],
                    "clients_count": 12,
                    "verified_workouts_count": 19
                }
            ]
        return trainers_data
    
    
class CustomerHealthUpdateSerializer(serializers.ModelSerializer):
    first_name = serializers.CharField(source='user.first_name', required=False)
    last_name = serializers.CharField(source='user.last_name', required=False)
    email = serializers.EmailField(source='user.email', required=False)
    gender = serializers.ChoiceField(
        source='user.gender',
        choices=[('male', 'Male'), ('female', 'Female'), ('other', 'Other')],
        required=False
    )
    date_of_birth = serializers.DateField(source='user.date_of_birth', required=False)
    profile_picture = serializers.ImageField(source='user.profile_picture', required=False, allow_null=True)
    blood_group = serializers.ChoiceField(
        source='user.blood_group',
        choices=User.BLOOD_GROUP_CHOICES,
        required=False,
        allow_null=True
    )
    injuries = serializers.PrimaryKeyRelatedField(
        queryset=Injury.objects.filter(is_active=True),
        many=True,
        required=False
    )
    medical_conditions = serializers.PrimaryKeyRelatedField(
        queryset=MedicalCondition.objects.filter(is_active=True),
        many=True,
        required=False
    )

    class Meta:
        model = Customer
        fields = [
            'first_name', 'last_name', 'email', 'gender', 'date_of_birth', 'blood_group', 'profession', 'profile_picture',
            'fitness_level', 'stress_level', 'weight_goal', 'target_weight', 'sleep_goal', 'height', 'weight', 'injuries', 'medical_conditions',
        ]

    def update(self, instance, validated_data):
        injuries = validated_data.pop('injuries', None)
        conditions = validated_data.pop('medical_conditions', None)
        user_data = validated_data.pop('user', {})
        
        if user_data:
            user = instance.user
            for attr, value in user_data.items():
                setattr(user, attr, value)
            user.save()

        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        instance.save()

        if injuries is not None:
            instance.injuries.set(injuries)
        if conditions is not None:
            instance.medical_conditions.set(conditions)

        return instance
    

class CustomerReviewSerializer(serializers.ModelSerializer):
    customer_name = serializers.CharField(source='customer.user.first_name', read_only=True)
    organization_name = serializers.CharField(source='organization.name', read_only=True)
    organization_logo = serializers.SerializerMethodField()

    class Meta:
        model = CustomerReview
        fields = [
            'id', 'organization', 'organization_name', 'organization_logo', 'start_date', 'end_date',
            'organization_category','customer', 'rating', 'comment', 'customer_name', 'created', 'modified'
            ]
        read_only_fields = ['id', 'organization_name', 'organization_logo', 'start_date', 'end_date',
            'organization_category', 'customer', 'customer_name', 'created', 'modified']

    def get_organization_logo(self, obj):
        if obj.organization and obj.organization.logo:
            return obj.organization.logo.url
        return None
        
    def get_organization_category(self, obj):
        return [cat.name for cat in obj.organization.category.all()]

    def get_membership_dates(self, obj):
        membership = CustomerMembership.objects.filter(
            customer=obj.customer,
            membership__organization=obj.organization
        ).order_by('-start_date').first()
        if membership:
            return membership.start_date, membership.end_date
        return None, None

    def get_start_date(self, obj):
        start, _ = self.get_membership_dates(obj)
        return start

    def get_end_date(self, obj):
        _, end = self.get_membership_dates(obj)
        return end
        
    def validate(self, attrs):
        request = self.context['request']
        customer = request.user.customer
        organization = attrs.get('organization')

        if CustomerReview.objects.filter(customer=customer, organization=organization).exists():
            raise serializers.ValidationError("You have already reviewed this organization.")
        
        has_membership = CustomerMembership.objects.filter(
            customer=customer,
            membership__organization=organization
        ).exists()
        
        if not has_membership:
            raise serializers.ValidationError("You can only review organizations you were subscribed to.")
        return attrs

    def create(self, validated_data):
        review = super().create(validated_data)
        self.update_organization_stats(review.organization)
        return review

    def update(self, instance, validated_data):
        instance = super().update(instance, validated_data)
        self.update_organization_stats(instance.organization)
        return instance

    def update_organization_stats(self, organization):
        stats = organization.reviews.aggregate(avg=Avg('rating'), count=Count('id'))
        organization.average_rating = stats['avg'] or 0.0
        organization.review_count = stats['count']
        organization.save()

        
class OrganizationNestedSerializer(serializers.ModelSerializer):
    location = LocationSerializer()
    social_media = SocialMediaSerializer(many=True)
    working_time = WorkingDaySerializer(many=True, source='working_days')
    category = serializers.SlugRelatedField(many=True, slug_field='name', read_only=True)
    review = serializers.SerializerMethodField()
    logo = serializers.SerializerMethodField()

    class Meta:
        model = Organization
        fields = [
            'id', 'name', 'logo', 'social_media', 'location', 'working_time',
            'review', 'category'
        ]

    def get_logo(self, obj):
        return obj.logo.url if obj.logo else None

    def get_review(self, obj):
        customer = getattr(self.context['request'].user, 'customer', None)
        review_data = {
            "has_reviewed": False,
            "rating": obj.average_rating,
            "review_count": obj.review_count,
            "my_review": None
        }

        if customer:
            try:
                review = CustomerReview.objects.get(customer=customer, organization=obj)
                review_data["has_reviewed"] = True
                review_data["my_review"] = {
                    "rating": review.rating,
                    "comment": review.comment,
                    "created": review.created.strftime('%Y-%m-%d %H:%M:%S'),
                    "modified": review.modified.strftime('%Y-%m-%d %H:%M:%S')
                }
            except CustomerReview.DoesNotExist:
                pass

        return review_data


class ActiveCustomerMembershipDetailSerializer(serializers.ModelSerializer):
    plan_id = serializers.IntegerField(source='membership.id')
    plan_name = serializers.CharField(source='membership.name')
    package_type = serializers.CharField(source='membership.package_type')
    is_emi_available = serializers.BooleanField(source='membership.is_emi_available')
    payment_type = serializers.SerializerMethodField()
    
    organization = serializers.SerializerMethodField()
    class Meta:
        model = CustomerMembership
        fields = [
            'id', 'organization', 'plan_id', 'plan_name', 'package_type', 'amount',
            'start_date', 'end_date', 'is_emi_available',
            'status', 'payment_type',
            'payment_status', 'is_active',
            'created_at', 'updated_at'
        ]
    
    def get_payment_type(self, obj):
        return 'EMI' if obj.membership.is_emi_available else 'Full Payment'
       
    def get_organization(self, obj):
        org = obj.membership.organization
        return OrganizationNestedSerializer(org, context=self.context).data

 
class CustomerTransactionSerializer(serializers.Serializer):
    organization = serializers.CharField()
    amount = serializers.CharField()
    payment_date = serializers.DateTimeField(format='%Y-%m-%d %H:%M:%S')
    payment_type = serializers.CharField()

    def to_representation(self, obj):
        # --- CASE 1: CustomerMembershipTransaction ---
        if isinstance(obj, CustomerMembershipTransaction):
            return {
                "organization": obj.membership.organization.name,
                "amount": str(obj.amount),
                "payment_date": obj.payment_date.strftime('%Y-%m-%d %H:%M:%S'),
                "payment_type": 'EMI' if 'emi' in (obj.remarks or '').lower() else 'Full payment'
            }

        # --- CASE 2: CustomerMembership (processing state) ---
        if isinstance(obj, CustomerMembership):
            membership_plan = obj.membership
            amount = membership_plan.offer_price or membership_plan.actual_price

            return {
                "organization": membership_plan.organization.name,
                "amount": str(amount),
                "payment_date": obj.created_at.strftime('%Y-%m-%d %H:%M:%S'),
                "payment_type": "Processing Payment"
            }

        return super().to_representation(obj)

    

# choiceserializer creation

class ChoicesSerializer(serializers.Serializer):
    """Serializer to return profession choices"""
    professions = serializers.SerializerMethodField()
    job_satisfactions = serializers.SerializerMethodField()
    working_hours = serializers.SerializerMethodField()
    sleep_hours = serializers.SerializerMethodField()
    target_goals = serializers.SerializerMethodField()
    health_conditions = serializers.SerializerMethodField()
    
    def get_professions(self, obj):
        return [{'value': choice[0], 'label': choice[1]} for choice in Profession.choices]
    
    def get_job_satisfactions(self, obj):
        return [{'value': choice[0], 'label': choice[1]} for choice in JobSatisfaction.choices]
    
    def get_working_hours(self, obj):
        return [{'value': choice[0], 'label': choice[1]} for choice in WorkingHours.choices]
    
    def get_sleep_hours(self, obj):
        return [{'value': choice[0], 'label': choice[1]} for choice in SleepGoal.choices]
    
    def get_target_goals(self, obj):
        return [{'value': choice[0], 'label': choice[1]} for choice in TargetGoal.choices]

    def get_health_conditions(self, obj):
        return [{'value': choice[0], 'label': choice[1]} for choice in HealthCondition.choices]
    
   
    def to_representation(self, instance):
        return {
            'professions': self.get_professions(instance),
            'job_satisfactions': self.get_job_satisfactions(instance),
            'working_hours': self.get_working_hours(instance),
            'sleep_hours': self.get_sleep_hours(instance),
            'target_goals': self.get_target_goals(instance),
            'health_conditions': self.get_health_conditions(instance),
        }


def add_months(dt, months):
    """
    Add `months` months to datetime `dt` while keeping day-of-month where possible.
    """
    if not dt:
        return None
    year = dt.year + (dt.month - 1 + months) // 12
    month = (dt.month - 1 + months) % 12 + 1
    day = min(dt.day, calendar.monthrange(year, month)[1])
    # preserve time and tzinfo
    return datetime.datetime(
        year, month, day,
        dt.hour, dt.minute, dt.second, dt.microsecond,
        tzinfo=dt.tzinfo
    )

class PaymentHistoryEMIInstallmentSerializer(serializers.Serializer):
    period = serializers.IntegerField()
    amount = serializers.CharField()
    due_date = serializers.CharField(allow_null=True)
    status = serializers.CharField()
    payment_date = serializers.CharField(allow_null=True)
    payment_id = serializers.CharField(allow_null=True)
    order_id = serializers.CharField(allow_null=True)
    transaction_id = serializers.IntegerField(allow_null=True)


class PaymentHistoryMembershipSerializer(serializers.ModelSerializer):
    membership_name = serializers.CharField(source='membership.name', read_only=True)
    organization_name = serializers.SerializerMethodField()
    emi_plan_details = serializers.SerializerMethodField()
    summary = serializers.SerializerMethodField()
    emi_installments = serializers.SerializerMethodField()
    full_payment = serializers.SerializerMethodField()
    is_emi = serializers.SerializerMethodField()


    class Meta:
        model = CustomerMembership
        fields = [
            "id",
            "organization_name",
            "membership_name",
            "is_emi",
            "status",
            "start_date",
            "end_date",
            "amount",
            "assign_free",
            "is_trial",
            "payment_status",
            "is_active",
            "emi_plan_details",
            "summary",
            "emi_installments",
            "full_payment",
        ]

    # ------------------------
    # Helpers
    # ------------------------
    def _iso(self, dt):
        return dt.isoformat() if dt else None

    def _fmt(self, dt):
        return dt.strftime("%d %b %Y") if dt else None
    
    def get_organization_name(self, obj):
        if obj.membership and hasattr(obj.membership, "organization"):
            return obj.membership.organization.name
        return None
    
    def get_is_emi(self, obj):
        return True if obj.emi_plan else False


    # ------------------------
    # EMI plan details
    # ------------------------
    def get_emi_plan_details(self, obj):
        plan = getattr(obj, "emi_plan", None)
        if not plan:
            return None
        return {
            "id": plan.id,
            "emi_name": plan.emi_name,
            "number_of_installments": plan.number_of_installments,
            "emi_amount_per_cycle": str(plan.emi_amount_per_cycle),
            "total_emi_amount": str(plan.total_emi_amount),
            "razorpay_plan_id": plan.razorpay_plan_id,
        }

    # ------------------------
    # Summary for UI top card
    # ------------------------
    def get_summary(self, obj):
        plan = getattr(obj, "emi_plan", None)

        if not plan:
            # Full payment summary
            tx = obj.payments.filter(period=0).order_by("-payment_date", "-created_at").first()
            total_amount = obj.amount or Decimal("0")
            if tx:
                paid_amount = tx.amount or Decimal("0")
                return {
                    "is_full_payment": True,
                    "status": tx.status,
                    "paid_amount": str(paid_amount),
                    "total_amount": str(total_amount),
                    "payment_date": self._fmt(tx.payment_date),
                    "payment_id": tx.payment_id,
                    "order_id": tx.order_id,
                }
            else:
                return {
                    "is_full_payment": True,
                    "status": "Pending",
                    "paid_amount": "0",
                    "total_amount": str(total_amount),
                    "payment_date": None,
                    "payment_id": None,
                    "order_id": None,
                }

        # EMI summary
        total_installments = plan.number_of_installments or 0
        all_emi_tx = list(obj.payments.filter(period__gt=0))
        # count successful EMIs
        paid_emis = sum(1 for t in all_emi_tx if t.status == CustomerMembershipTransaction.SUCCESSFUL)
        # total paid amount (only successful payments count)
        total_paid_amount = sum((t.amount or Decimal("0")) for t in all_emi_tx if t.status == CustomerMembershipTransaction.SUCCESSFUL)
        total_amount = plan.total_emi_amount or Decimal("0")

        # find next unpaid period (first period missing success)
        next_period = None
        for p in range(1, total_installments + 1):
            if not any((t.period == p and t.status == CustomerMembershipTransaction.SUCCESSFUL) for t in all_emi_tx):
                next_period = p
                break

        if next_period:
            next_due_date_dt = add_months(obj.start_date or timezone.now(), next_period - 1)
            next_due_date = self._fmt(next_due_date_dt)
            next_amount = str(plan.emi_amount_per_cycle)
        else:
            next_due_date = None
            next_amount = None

        return {
            "is_full_payment": False,
            "paid_emi_count": paid_emis,
            "total_emis": total_installments,
            "total_paid": str(total_paid_amount),
            "total_amount": str(total_amount),
            "next_emi_due_date": next_due_date,
            "next_emi_amount": next_amount,
        }

    # ------------------------
    # EMI installments list
    # ------------------------
    def get_emi_installments(self, obj):
        plan = getattr(obj, "emi_plan", None)
        if not plan:
            return []

        total_installments = plan.number_of_installments or 0
        # map period -> transaction (most recent per period)
        tx_qs = obj.payments.filter(period__gt=0).order_by("period", "-payment_date", "-created_at")
        tx_map = {}
        for t in tx_qs:
            # keep first encountered as ordered above => latest per period
            if t.period not in tx_map:
                tx_map[t.period] = t

        installments = []
        for period in range(1, total_installments + 1):
            due_dt = add_months(obj.start_date or timezone.now(), period - 1)
            tx = tx_map.get(period)

            if tx and tx.status == CustomerMembershipTransaction.SUCCESSFUL:
                status = "Paid"
                payment_date = self._fmt(tx.payment_date)
                payment_id = tx.payment_id
                order_id = tx.order_id
                transaction_id = tx.id
                amount = str(tx.amount or plan.emi_amount_per_cycle)
            else:
                # pending or failed
                if tx and tx.status != CustomerMembershipTransaction.SUCCESSFUL:
                    # if there's a tx but not successful, mark explicitly
                    status = tx.status  # e.g., Failed, Pending
                    payment_date = self._fmt(tx.payment_date)
                    payment_id = tx.payment_id
                    order_id = tx.order_id
                    transaction_id = tx.id
                    amount = str(tx.amount or plan.emi_amount_per_cycle)
                else:
                    # no tx exists for this period
                    now = timezone.now()

                    # Special handling for first EMI payment processing
                    if period == 1:
                        # Check if payment is processing (paid but webhook not received)
                        if (obj.payment_status == 'pending' and
                            obj.created_at and
                            (now - obj.created_at).total_seconds() <= 1800):  # 30 minutes
                            status = "Payment Processing"
                        elif due_dt and due_dt >= now:
                            status = "Upcoming"
                        else:
                            status = "Overdue"
                    else:
                        # For other periods, use standard logic
                        status = "Upcoming" if (due_dt and due_dt >= now) else "Overdue"

                    payment_date = None
                    payment_id = None
                    order_id = None
                    transaction_id = None
                    amount = str(plan.emi_amount_per_cycle)

            installments.append({
                "period": period,
                "period_label": f"EMI {period}/{total_installments}",
                "amount": amount,
                "due_date": self._fmt(due_dt),
                "status": status,
                "payment_date": payment_date,
                "payment_id": payment_id,
                "order_id": order_id,
                "transaction_id": transaction_id,
            })

        return PaymentHistoryEMIInstallmentSerializer(installments, many=True).data

    # ------------------------
    # Full payment detail (non-EMI)
    # ------------------------
    def get_full_payment(self, obj):
        if getattr(obj, "emi_plan", None):
            return None

        tx = obj.payments.filter(period=0).order_by("-payment_date", "-created_at").first()
        total_amount = obj.amount or Decimal("0")
        if not tx:
            return {
                "status": "Pending",
                "paid_amount": "0",
                "total_amount": str(total_amount),
                "payment_date": None,
                "payment_id": None,
                "order_id": None,
                "transaction_id": None,
            }

        return {
            "status": tx.status,
            "paid_amount": str(tx.amount or Decimal("0")),
            "total_amount": str(total_amount),
            "payment_date": self._fmt(tx.payment_date),
            "payment_id": tx.payment_id,
            "order_id": tx.order_id,
            "transaction_id": tx.id,
        }


class PaymentHistorySerializer(serializers.Serializer):
    customer_id = serializers.IntegerField()
    memberships = PaymentHistoryMembershipSerializer(many=True)


# ============================================
# Membership Request Serializers
# ============================================

from apps.customers.models import MembershipRequest


class MembershipRequestCreateSerializer(serializers.ModelSerializer):
    """Serializer for customer to create a membership request"""

    class Meta:
        model = MembershipRequest
        fields = ['organization', 'membership_plan', 'notes', 'payment_mode']
        extra_kwargs = {
            'membership_plan': {'required': False},
            'notes': {'required': False},
            'payment_mode': {'required': False},
        }

    def validate_organization(self, organization):
        if not organization.active:
            raise serializers.ValidationError("Cannot send request to an inactive organization.")
        return organization

    def validate(self, data):
        request = self.context.get('request')
        customer = request.user.customer
        # Check if customer already has a pending/contacted enquiry for this org
        existing = MembershipRequest.objects.filter(
            customer=customer,
            organization=data['organization'],
            status__in=[MembershipRequest.PENDING, MembershipRequest.CONTACTED]
        ).first()
        if existing:
            raise serializers.ValidationError({
                'detail': 'You already have an active enquiry for this gym.',
                'existing_request_id': existing.id,
                'status': existing.status
            })
        return data

    def create(self, validated_data):
        request = self.context.get('request')
        customer = request.user.customer
        # Soft-close any old closed/rejected requests (cleanup)
        MembershipRequest.objects.filter(
            customer=customer,
            organization=validated_data['organization'],
            status__in=[MembershipRequest.CLOSED, MembershipRequest.REJECTED]
        ).update(status=MembershipRequest.CLOSED)
        validated_data['customer'] = customer
        return super().create(validated_data)


class MembershipRequestSerializer(serializers.ModelSerializer):
    """Full read serializer for membership requests"""
    customer_name = serializers.SerializerMethodField()
    customer_phone = serializers.SerializerMethodField()
    customer_profile_picture = serializers.SerializerMethodField()
    organization_name = serializers.CharField(source='organization.name', read_only=True)
    organization_logo = serializers.SerializerMethodField()
    requested_plan_name = serializers.CharField(source='membership_plan.name', read_only=True, default=None)
    selected_plan_name = serializers.CharField(source='selected_plan.name', read_only=True, default=None)

    class Meta:
        model = MembershipRequest
        fields = [
            'id', 'customer', 'customer_name', 'customer_phone', 'customer_profile_picture',
            'organization', 'organization_name', 'organization_logo',
            'membership_plan', 'requested_plan_name',
            'selected_plan', 'selected_plan_name',
            'status', 'payment_mode', 'notes', 'gym_remarks',
            'contact_info',
            'requested_at', 'responded_at',
        ]
        read_only_fields = [
            'id', 'customer_name', 'customer_phone', 'customer_profile_picture',
            'organization_name', 'organization_logo',
            'requested_plan_name', 'selected_plan_name',
            'requested_at', 'responded_at',
        ]

    def get_customer_name(self, obj):
        if obj.customer and obj.customer.user:
            return obj.customer.user.full_name
        return None

    def get_customer_phone(self, obj):
        if obj.customer and obj.customer.user and obj.customer.user.mobile_number:
            return str(obj.customer.user.mobile_number)
        return None

    def get_customer_profile_picture(self, obj):
        if obj.customer and obj.customer.user and obj.customer.user.profile_picture:
            return obj.customer.user.profile_picture.url
        return None

    def get_organization_logo(self, obj):
        if obj.organization and obj.organization.logo:
            return obj.organization.logo.url
        return None

