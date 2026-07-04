from django.utils import timezone
import json
import re
from rest_framework import serializers
from django.contrib.gis.geos import Point
from apps.customers.models import Customer, CustomerMembership, CustomerMembershipTransaction, CustomerReview
from apps.fitnesscenter.models import (
    BankAccountDetails, Category, MembershipPlan, Organization, Location, WorkingDay, Amenity,
    organizationAmenity, OrganizationPhoto, SocialMedia, EmiPlan, OrganizationTimeSlot
)
from django.db import transaction
from decimal import Decimal
from datetime import datetime

from apps.mentors.models import MentorProfile
from apps.subscription.models import OrganizationSubscriptionsDetails
from apps.utils.create_razorpay_plan import create_razorpay_plan


class LocationSerializer(serializers.ModelSerializer):
    latitude = serializers.FloatField(required=False, allow_null=True)
    longitude = serializers.FloatField(required=False, allow_null=True)
    building_name = serializers.CharField(
        min_length=3,
        error_messages={
            "min_length": "Building name must be at least 3 characters."
        }
    )

    street = serializers.CharField(
        min_length=3,
        error_messages={
            "min_length": "Street must be at least 3 characters."
        }
    )
    class Meta:
        model = Location
        fields = ['building_name' , 'street', 'city', 'state', 'pin_code', 'latitude', 'longitude', 'google_maps_url']


class WorkingDaySerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkingDay
        fields = ['day', 'is_open', 'morning_opening_time', 'morning_closing_time', 
                  'evening_opening_time', 'evening_closing_time', 'ladies_opening_time', 'ladies_closing_time']


class SocialMediaSerializer(serializers.ModelSerializer):
    class Meta:
        model = SocialMedia
        fields = ['id', 'platform', 'url']


class OrganizationTimeSlotSerializer(serializers.ModelSerializer):
    is_currently_active = serializers.ReadOnlyField()

    class Meta:
        model = OrganizationTimeSlot
        fields = ['id', 'name', 'start_time', 'end_time', 'is_active', 'start_date', 'end_date', 'is_currently_active']


class OrganizationCreateSerializer(serializers.ModelSerializer):
    location = LocationSerializer(required=False)
    working_days = WorkingDaySerializer(many=True, required=False)
    amenities = serializers.ListField(child=serializers.IntegerField(), required=False)
    social_media = SocialMediaSerializer(many=True, required=False)
    categories = serializers.ListField(child=serializers.IntegerField(), required=True)

    class Meta:
        model = Organization
        fields = [
            'name', 'categories', 'description', 'email', 'phone_number',
            'location', 'working_days', 'amenities', 'social_media', 'logo','profile_completeness'
        ]
        
    def to_internal_value(self, data):
        parsed_data = {}
        request = self.context['request']
        for file_key in request.FILES:
            parsed_data[file_key] = request.FILES[file_key]
        for key, value in data.items():
            if key in request.FILES:
                continue
            if '[' in key and ']' in key:
                base_key = key.split('[')[0]
                if base_key not in parsed_data:
                    parsed_data[base_key] = []
                if key.count('[') == 2:
                    parts = key.split('[')
                    outer_idx = int(parts[1].split(']')[0])
                    inner_field = parts[2].split(']')[0]
                    while len(parsed_data[base_key]) <= outer_idx:
                        parsed_data[base_key].append({})
                    
                    parsed_data[base_key][outer_idx][inner_field] = value
                else:
                    parsed_data[base_key].append(value)
            else:
                parsed_data[key] = value
        location_fields = [k for k in data if k.startswith('location.')]
        if location_fields:
            parsed_data['location'] = {}
            for field in location_fields:
                _, subfield = field.split('.', 1)
                val = data[field]
                parsed_data['location'][subfield] = None if val == "" else val
                
        if 'social_media' in parsed_data:
            sm = parsed_data['social_media']
            if sm in ["", "null", None]:
                parsed_data['social_media'] = []
            elif isinstance(sm, str):
                try:
                    import json
                    parsed_data['social_media'] = json.loads(sm)
                    if not isinstance(parsed_data['social_media'], list):
                        parsed_data['social_media'] = []
                except Exception:
                    parsed_data['social_media'] = []

        return super().to_internal_value(parsed_data)

    def validate(self, data):
        request = self.context.get('request')
        mentor = self.context.get('mentor')
        errors = {}
        required_fields = ['name', 'categories', 'email', 'phone_number']
        for field in required_fields:
            if not data.get(field):
                errors[field] = f"{field.replace('_', ' ').capitalize()} is required."

        # if mentor and Organization.objects.filter(mentor=mentor).exists():
        #     errors['organization'] = "Mentor is allowed to create only one organization."
        # Categories validation
        if 'categories' in data:
            if not isinstance(data['categories'], list):
                errors['categories'] = "Must be a list of category IDs."
            else:
                try:
                    data['categories'] = [int(cat) for cat in data['categories']]
                except (ValueError, TypeError):
                    errors['categories'] = "All categories must be integers."
        if errors:
            raise serializers.ValidationError(errors)

        return data

    def create(self, validated_data):
        request = self.context.get('request')
        mentor = self.context.get('mentor')
        print(mentor, '%11154564')
        # If already a MentorProfile instance, use it directly
        if isinstance(mentor, MentorProfile):
            print('YES')
            mentor_profile = mentor
        else:
            mentor_profile = getattr(mentor, 'mentor_profile', None)
        
        if mentor_profile is None:
            raise serializers.ValidationError({"mentor": "Mentor profile not found for this user."})


        
        categories_data = validated_data.pop('categories', [])
        location_data = validated_data.pop('location', None)
        working_days_data = validated_data.pop('working_days', [])
        amenities_data = validated_data.pop('amenities', [])
        social_media_data = validated_data.pop('social_media', [])

        with transaction.atomic():

            # Create organization
            organization = Organization.objects.create(
                mentor=mentor_profile,
                **validated_data
            )            
            if mentor_profile:
                mentor_profile.organization = organization
                mentor_profile.save()
            
            organization.category.set(categories_data)

            # Add location
            if location_data:
                lat = location_data.pop('latitude', None)
                lng = location_data.pop('longitude', None)
                if lat is not None:
                    location_data['latitude'] = Decimal(str(lat))
                if lng is not None:
                    location_data['longitude'] = Decimal(str(lng))
                
                # Create Point if both lat and lng exist
                point = None
                if lat and lng:
                    point = Point(float(lng), float(lat))
                Location.objects.create(organization=organization, location=point, **location_data)

            # Add working days
            working_day_objects = []
            for wd in working_days_data:
                working_day_objects.append(WorkingDay(
                    organization=organization,
                    day=wd['day'],
                    is_open=wd.get('is_open'),
                    morning_opening_time=wd.get('morning_opening_time'),
                    morning_closing_time=wd.get('morning_closing_time'),
                    evening_opening_time=wd.get('evening_opening_time'),
                    evening_closing_time=wd.get('evening_closing_time'),
                    ladies_opening_time=wd.get('ladies_opening_time'),
                    ladies_closing_time=wd.get('ladies_closing_time'),
                ))
            
            WorkingDay.objects.bulk_create(working_day_objects)
            # WorkingDay.objects.bulk_create([
            #     WorkingDay(organization=organization, **wd) for wd in working_days_data
            # ])

            # Add amenities
            if amenities_data:
                existing_amenities = Amenity.objects.filter(id__in=amenities_data)
                amenities = existing_amenities | Amenity.objects.filter(id__in=amenities_data)
                organizationAmenity.objects.bulk_create([
                    organizationAmenity(organization=organization, amenity=amenity) for amenity in amenities
                ])

            # Add social media links
            SocialMedia.objects.bulk_create([
                SocialMedia(organization=organization, **sm) for sm in social_media_data
            ])

            # Upload photos
            for i, photo in enumerate(request.FILES.getlist("photos")):
                OrganizationPhoto.objects.create(
                    organization=organization,
                    image=photo,
                    caption=f"Photo {i+1}",
                    is_primary=(i == 0)
                )

        return organization
    
class EmiPlanSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmiPlan
        fields = ('id', 'number_of_installments', 'emi_amount_per_cycle')
        read_only_fields = ['id', 'total_emi_amount', 'emi_name', 'razorpay_plan_id']

    # def to_representation(self, instance):
    #     return [instance.number_of_installments, instance.emi_amount_per_cycle]

class MembershipPlanSerializer(serializers.ModelSerializer):
    package_type = serializers.ChoiceField(choices=MembershipPlan.PACKAGE_TYPE_CHOICES, required=False)
    emi_plans = EmiPlanSerializer(many=True, required=False)

    class Meta:
        model = MembershipPlan
        fields = (
            'id', 'organization', 'package_type', 'name', 'description', 'actual_price', 'offer_price', 'duration_days',
            'features', 'is_active', 'is_emi_available', 'emi_plans'
        )
        read_only_fields = ['id']
        
    def validate(self, attrs):
        package_type = attrs.get('package_type')
        organization = attrs.get('organization')
        name = attrs.get('name')
        
        if 'is_active' not in attrs:
            attrs['is_active'] = True
            
        if attrs['is_active'] and organization and package_type:
            existing = MembershipPlan.objects.filter(
                organization=organization,
                package_type=package_type,
                is_active=True
            )
            if self.instance:
                existing = existing.exclude(pk=self.instance.pk)
            if existing.exists():
                raise serializers.ValidationError({
                    "name": "An active plan with this Package already exists for the organization."
                })
        
        if not attrs.get('duration_days') and package_type:
            default_durations = {
                MembershipPlan.MONTHLY: 30,
                MembershipPlan.QUARTERLY: 90,
                MembershipPlan.HALF_YEARLY: 180,
                MembershipPlan.YEARLY: 365,
            }
            attrs['duration_days'] = default_durations.get(package_type, 0)

        if attrs.get('is_emi_available') and not attrs.get('emi_plans'):
            raise serializers.ValidationError({
                "emi_plans": "EMI plans must be provided if is_emi_available is True."
            })
        return attrs

    def create(self, validated_data):
        with transaction.atomic():
            emi_plans_data = validated_data.pop('emi_plans', [])

            # Step 1: Create the main MembershipPlan instance
            main_plan = MembershipPlan.objects.create(**validated_data)
            
            # Step 2: Create the associated EmiPlan instances
            for emi_data in emi_plans_data:
                # Create the EmiPlan instance
                EmiPlan.objects.create(membership_plan=main_plan, **emi_data)
            return main_plan

    def update(self, instance, validated_data):
        with transaction.atomic():
            emi_plans_data = validated_data.pop('emi_plans', [])
            
            # Update the main MembershipPlan instance
            instance = super().update(instance, validated_data)
            
            # Handle related EMI plans
            if instance.is_emi_available:
                # Delete old EMI plans that are no longer in the request
                emi_plans_ids = [emi_plan['id'] for emi_plan in emi_plans_data if 'id' in emi_plan]
                EmiPlan.objects.filter(membership_plan=instance).exclude(id__in=emi_plans_ids).delete()
                
                for emi_data in emi_plans_data:
                    emi_id = emi_data.get('id', None)
                    if emi_id:
                        # Update existing EmiPlan
                        emi_plan = EmiPlan.objects.get(id=emi_id, membership_plan=instance)
                        for attr, value in emi_data.items():
                            setattr(emi_plan, attr, value)
                        emi_plan.save()
                    else:
                       # Create new EmiPlan
                        EmiPlan.objects.create(membership_plan=instance, **emi_data)
            else:
                # If EMI not available, delete all related EMI plans
                instance.emi_plans.all().delete()

            return instance
    
    

class OrganizationDetailSerializer(serializers.ModelSerializer):
    location = LocationSerializer()
    working_days = WorkingDaySerializer(many=True)
    social_media = SocialMediaSerializer(many=True)
    amenities = serializers.SerializerMethodField()
    categories = serializers.SerializerMethodField()
    photos = serializers.SerializerMethodField()
    packages = MembershipPlanSerializer(many=True, read_only=True)
    subscription_details = serializers.SerializerMethodField()
    time_slots = OrganizationTimeSlotSerializer(many=True, read_only=True)
    trainers = serializers.SerializerMethodField()
    logo = serializers.SerializerMethodField()

    class Meta:
        model = Organization
        fields = [
            'id', 'name', 'description', 'email', 'phone_number',
            'is_public', 'active', 'is_subscribed', 'take_free_trial', 'is_on_free_trial',
            'location', 'working_days', 'time_slots', 'social_media',
            'amenities', 'categories', 'photos', 'packages', 'subscription_details', 'birthday_wish_message', 'anniversary_wish_message', 'logo',
            'review_count', 'average_rating', 'is_slot_available', 'trainers'
        ]

    def get_logo(self, obj):
        return obj.logo.url if obj.logo else None


    def get_amenities(self, obj):
        return [
            {"id": amenity.amenity.id, "name": amenity.amenity.name}
            for amenity in obj.amenities.select_related('amenity')
        ]

    def get_categories(self, obj):
        return [{"id": cat.id, "name": cat.name} for cat in obj.category.all()]

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
        
    
    def get_subscription_details(self, obj):
        subscription = obj.subscriptions.filter(
            status__in=[OrganizationSubscriptionsDetails.ACTIVE, OrganizationSubscriptionsDetails.TRIAL],
            
        ).order_by('-start_date').first()
        
        if not subscription:
            return None
            
        return {
            "id": str(subscription.id),
            "plan": {
                "id": subscription.plan.id,
                "name": subscription.plan.name,
                "price": str(subscription.plan.discounted_price),
                "period": subscription.plan.period,
            },
            "status": subscription.status,
            "start_date": subscription.start_date,
            "end_date": subscription.end_date,
            "trial_start_at": subscription.trial_start_at,
            "trial_end_at": subscription.trial_end_at,
            "days_remaining": subscription.days_remaining,
            "is_active_now": subscription.is_active_now,
            "is_trial_now": subscription.is_trial_now,
            "auto_renew": subscription.auto_renew,
            "payment_status": subscription.payment_status,
            "last_payment_date": subscription.last_payment_date,
            "next_due_date": subscription.next_due_date,
        }

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
            
        return trainers_data


# class OrganizationUpdateSerializer(serializers.ModelSerializer):
#     location = LocationSerializer(required=False)
#     working_days = WorkingDaySerializer(many=True, required=False)
#     services = serializers.ListField(child=serializers.CharField(), required=False)
#     amenities = serializers.ListField(child=serializers.IntegerField(), required=False)
#     social_media = SocialMediaSerializer(many=True, required=False)
#     categories = serializers.ListField(child=serializers.IntegerField(), required=False)

#     class Meta:
#         model = Organization
#         fields = [
#             'name', 'categories', 'description', 'email', 'phone_number',
#             'location', 'working_days', 'services', 'amenities', 'social_media'
#         ]

#     def update(self, instance, validated_data):
#         location_data = validated_data.pop('location', None)
#         working_days_data = validated_data.pop('working_days', None)
#         services_data = validated_data.pop('services', None)
#         amenities_data = validated_data.pop('amenities', None)
#         social_media_data = validated_data.pop('social_media', None)
#         categories_data = validated_data.pop('categories', None)

#         # Update the Organization fields
#         for attr, value in validated_data.items():
#             setattr(instance, attr, value)
#         instance.save()

#         # Update the categories
#         if categories_data is not None:
#             instance.category.set(categories_data)

#         # Update or create location
#         if location_data:
#             Location.objects.update_or_create(
#                 organization=instance,
#                 defaults={**location_data}
#             )

#         # Update working days
#         if working_days_data is not None:
#             instance.working_days.all().delete()  # Remove existing days
#             WorkingDay.objects.bulk_create([
#                 WorkingDay(organization=instance, **day) for day in working_days_data
#             ])

#         # Update services
#         if services_data is not None:
#             instance.services.all().delete()  # Remove existing services
#             Service.objects.bulk_create([
#                 Service(organization=instance, name=name) for name in services_data
#             ])

#         # Update amenities
#         if amenities_data is not None:
#             instance.amenities.all().delete()  # Remove existing amenities
#             amenities = Amenity.objects.filter(id__in=amenities_data)
#             instance.amenities.set(amenities)  # Set the new amenities

#         # Update social media links
#         if social_media_data is not None:
#             for sm in social_media_data:
#                 platform = sm.get('platform')
#                 url = sm.get('url')
#                 if platform and url:
#                     SocialMedia.objects.update_or_create(
#                         organization=instance,
#                         platform=platform,
#                         defaults={'url': url}
#                     )

#         return instance


class CustomerListSerializer(serializers.ModelSerializer):
    name = serializers.SerializerMethodField()
    mobile_number = serializers.SerializerMethodField()
    active_plan = serializers.SerializerMethodField()
    joined_date = serializers.DateTimeField(source='created', format="%Y-%m-%d")
    profile_picture = serializers.SerializerMethodField()

    class Meta:
        model = Customer
        fields = ['id', 'name', 'mobile_number', 'profile_picture', 'joined_date', 'active_plan']

    def get_profile_picture(self, obj):
        pic = obj.user.profile_picture if obj.user else None
        return pic.url if pic else None

    def get_name(self, obj):
        user = obj.user
        if not user:
            return None

        # If full_name is a field, return it
        if hasattr(user, "full_name") and not callable(user.full_name):
            return user.full_name

        # Otherwise use Django's get_full_name()
        return user.get_full_name()


    def get_mobile_number(self, obj):
        # Access mobile_number directly through the user relationship
        return str(obj.user.mobile_number) if obj.user and obj.user.mobile_number else None
    def get_active_plan(self, obj):
        membership = CustomerMembership.objects.filter(
            customer=obj,
            status=CustomerMembership.ACTIVE
        ).order_by('-start_date').first()

        if membership:
            return {
                "id": membership.membership.id,
                "plan_name": membership.membership.name,
                "start_date": membership.start_date,
                "end_date": membership.end_date,
                "status": membership.status
            }
        return None


class TrainerListSerializer(serializers.ModelSerializer):
    name = serializers.SerializerMethodField() 
    user_id = serializers.CharField(source='user.id', read_only=True)
    mobile_number = serializers.CharField(source='user.mobile_number', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)
    created = serializers.DateTimeField(source='user.created', format="%Y-%m-%d", read_only=True)
    profile_picture = serializers.SerializerMethodField()
    categories = serializers.SerializerMethodField()

    class Meta:
        model = MentorProfile
        fields = ['id', 'user_id', 'name', 'mobile_number', 'email', 'designation', 'created', 'profile_picture', 'categories']

    def get_profile_picture(self, obj):
        pic = obj.user.profile_picture if obj.user else None
        return pic.url if pic else None

    def get_categories(self, obj):
        return [cat.name for cat in obj.categories.all()]
    
    def get_name(self, obj):
        return obj.user.get_full_name() if obj.user else None



class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name']


class OrganizationPhotoSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrganizationPhoto
        fields = ['id', 'image', 'caption', 'is_primary']


class AmenitySerializer(serializers.ModelSerializer):
    class Meta:
        model = Amenity
        fields = ['id', 'name']
        

class OrganizationPhotoUpdateSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(required=False)
    image = serializers.ImageField(required=False)

    class Meta:
        model = OrganizationPhoto
        fields = ['id', 'image', 'caption', 'is_primary']

        
class OrganizationUpdateSerializer(serializers.ModelSerializer):
    social_media = SocialMediaSerializer(many=True, required=False)
    location = LocationSerializer(required=False)
    photos = OrganizationPhotoSerializer(many=True, required=False)
    categories = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.all(), many=True, source='category'
    )
    amenities = serializers.ListField(
        child=serializers.IntegerField(), write_only=True
    )
    time_slots = OrganizationTimeSlotSerializer(many=True, required=False)

    class Meta:
        model = Organization
        fields = [
            'id', 'name', 'description', 'email', 'phone_number', 'logo',
            'categories', 'amenities', 'social_media', 'location', 'photos', 'anniversary_wish_message', 'birthday_wish_message', 'profile_completeness',
            'time_slots'
        ]

    def update(self, instance, validated_data):
        request = self.context.get("request") if self.context else None

        # --- Social Media ---
        social_media_data = validated_data.pop('social_media', None)
        print(social_media_data, 'data')
        if not social_media_data or all(not bool(entry) for entry in social_media_data):
            raw_dict = {}
            for key, value in request.data.items():
                if key.startswith("social_media["):
                    match = re.match(r"social_media\[(\d+)]\[(\w+)]", key)
                    if match:
                        index, sub_key = match.groups()
                        raw_dict.setdefault(index, {})[sub_key] = value
            social_media_data = list(raw_dict.values())
            print("Rebuilt social_media_data from form-data:", social_media_data)
        if social_media_data:
            incoming_platforms = {
                entry.get('platform'): entry for entry in social_media_data if 'platform' in entry
            }
            existing_links = {sm.platform: sm for sm in instance.social_media.all()}

            # Update existing
            for platform, sm in existing_links.items():
                if platform in incoming_platforms:
                    new_url = incoming_platforms[platform].get('url')
                    if new_url and sm.url != new_url:
                        sm.url = new_url
                        sm.save()

            # Create new
            for platform, entry in incoming_platforms.items():
                if platform not in existing_links:
                    SocialMedia.objects.create(
                        organization=instance,
                        platform=platform,
                        url=entry.get('url')
                    )

                    
        # --- Handle location ---
        location_data = validated_data.pop('location', None)
        if location_data:
            location_instance, _ = Location.objects.get_or_create(organization=instance)
            for attr, value in location_data.items():
                setattr(location_instance, attr, value)
            location_instance.save()
            
        # --- Handle new photo uploads ---
        if request:
            files = getattr(request, 'FILES', None)
            if files:
                for image_file in files.getlist('photos'):
                    OrganizationPhoto.objects.create(
                        organization=instance,
                        image=image_file
                    )

        # --- Handle photo deletions ---
        photos_to_delete = None
        if request:
            photos_to_delete = request.data.get('photos_to_delete')
        print(photos_to_delete, 'photos_to_deletephotos_to_delete')
        if photos_to_delete:
            try:
                if isinstance(photos_to_delete, str):
                    photo_ids = json.loads(photos_to_delete)
                elif isinstance(photos_to_delete, list):
                    photo_ids = photos_to_delete
                else:
                    raise serializers.ValidationError({"photos_to_delete": "Invalid format. Must be list or JSON string."})

                OrganizationPhoto.objects.filter(
                    id__in=photo_ids, organization=instance
                ).delete()
            except json.JSONDecodeError:
                raise serializers.ValidationError({"photos_to_delete": "Invalid JSON list of IDs"})
    
        # --- Handle amenities add/remove by IDs ---
        incoming_amenities = request.data.get('amenities')
        amenities_to_delete = request.data.get('amenities_to_delete')

        if amenities_to_delete:
            try:
                if isinstance(amenities_to_delete, str):
                    amenities_to_delete = json.loads(amenities_to_delete)
                organizationAmenity.objects.filter(
                    organization=instance,
                    amenity_id__in=amenities_to_delete
                ).delete()
            except json.JSONDecodeError:
                raise serializers.ValidationError({"amenities_to_delete": "Invalid JSON list of IDs"})

        if incoming_amenities:
            try:
                if isinstance(incoming_amenities, str):
                    incoming_amenities = json.loads(incoming_amenities)
                if not isinstance(incoming_amenities, list):
                    raise serializers.ValidationError({"amenities": "Must be a list of amenity IDs"})

                valid_amenity_ids = set(Amenity.objects.filter(id__in=incoming_amenities).values_list('id', flat=True))

                invalid_ids = set(incoming_amenities) - valid_amenity_ids
                if invalid_ids:
                    raise serializers.ValidationError({
                        "amenities": f"Invalid amenity IDs: {list(invalid_ids)}"
                    })

                existing_amenity_ids = set(
                    instance.amenities.values_list('amenity_id', flat=True)
                )
                for amenity_id in valid_amenity_ids:
                    if amenity_id not in existing_amenity_ids:
                        organizationAmenity.objects.create(
                            organization=instance,
                            amenity_id=amenity_id
                        )

            except json.JSONDecodeError:
                raise serializers.ValidationError({"amenities": "Invalid JSON list of IDs"})
            
        # --- Handle categories update ---
        incoming_category_ids = request.data.get('categories')
        if incoming_category_ids:
            try:
                if isinstance(incoming_category_ids, str):
                    incoming_category_ids = json.loads(incoming_category_ids)
                if not isinstance(incoming_category_ids, list):
                    raise serializers.ValidationError({"categories": "Must be a list of category IDs"})

                valid_category_ids = set(Category.objects.filter(id__in=incoming_category_ids).values_list('id', flat=True))
                invalid_ids = set(incoming_category_ids) - valid_category_ids
                if invalid_ids:
                    raise serializers.ValidationError({
                        "categories": f"Invalid category IDs: {list(invalid_ids)}"
                    })

                instance.category.set(valid_category_ids)

            except json.JSONDecodeError:
                raise serializers.ValidationError({"categories": "Invalid JSON list of IDs"})
            
        
        # --- Handle working days update ---
        incoming_working_days = request.data.get('working_days')
        if incoming_working_days:
            try:
                if isinstance(incoming_working_days, str):
                    incoming_working_days = json.loads(incoming_working_days)

                if not isinstance(incoming_working_days, list):
                    raise serializers.ValidationError({"working_days": "Must be a list of working day objects"})

                allowed_days = {day[0] for day in WorkingDay.DAY_CHOICES}
                incoming_day_map = {entry['day']: entry for entry in incoming_working_days}

                invalid_days = set(incoming_day_map.keys()) - allowed_days
                if invalid_days:
                    raise serializers.ValidationError({
                        "working_days": f"Invalid day keys: {list(invalid_days)}"
                    })

                existing_days = {wd.day: wd for wd in instance.working_days.all()}

                for day_code, entry in incoming_day_map.items():
                    fields = {
                        'is_open': entry.get('is_open', False),
                        'morning_opening_time': entry.get('morning_opening_time'),
                        'morning_closing_time': entry.get('morning_closing_time'),
                        'evening_opening_time': entry.get('evening_opening_time'),
                        'evening_closing_time': entry.get('evening_closing_time'),
                        'ladies_opening_time': entry.get('ladies_opening_time'),
                        'ladies_closing_time': entry.get('ladies_closing_time'),
                    }

                    if day_code in existing_days:
                        wd = existing_days[day_code]
                        for attr, val in fields.items():
                            setattr(wd, attr, val)
                        wd.save()
                    else:
                        WorkingDay.objects.create(
                            organization=instance,
                            day=day_code,
                            **fields
                        )

            except json.JSONDecodeError:
                raise serializers.ValidationError({"working_days": "Invalid JSON format"})

        # --- Handle time slots update ---
        incoming_time_slots = request.data.get('time_slots')
        if incoming_time_slots:
            try:
                if isinstance(incoming_time_slots, str):
                    incoming_time_slots = json.loads(incoming_time_slots)

                if not isinstance(incoming_time_slots, list):
                    raise serializers.ValidationError({"time_slots": "Must be a list of time slot objects"})

                # or better, handle them as a collection.
                
                existing_slots_ids = set(instance.time_slots.values_list('id', flat=True))
                incoming_slots_with_ids = [s for s in incoming_time_slots if s.get('id')]
                incoming_ids = {s['id'] for s in incoming_slots_with_ids}
                
                # Delete slots not in incoming
                instance.time_slots.exclude(id__in=incoming_ids).delete()
                
                for slot_data in incoming_time_slots:
                    slot_id = slot_data.get('id')
                    fields = {
                        'name': slot_data.get('name'),
                        'start_time': slot_data.get('start_time'),
                        'end_time': slot_data.get('end_time'),
                        'is_active': slot_data.get('is_active', True),
                        'start_date': slot_data.get('start_date') or None,
                        'end_date': slot_data.get('end_date') or None,
                    }
                    if slot_id and slot_id in existing_slots_ids:
                        OrganizationTimeSlot.objects.filter(id=slot_id).update(**fields)
                    else:
                        OrganizationTimeSlot.objects.create(organization=instance, **fields)

            except json.JSONDecodeError:
                raise serializers.ValidationError({"time_slots": "Invalid JSON format"})

        # --- Other fields ---
        skip_fields = {'amenities', 'categories', 'location', 'social_media', 'photos', 'time_slots'}
        for attr, value in validated_data.items():
            if attr in skip_fields:
                continue
            setattr(instance, attr, value)

        instance.save()
        return instance
    

class OrganizationSubscriptionStatusSerializer(serializers.ModelSerializer):
    class Meta:
        model = Organization
        fields = ['id', 'is_subscribed']
        read_only_fields = ['id', 'is_subscribed']
        
        
class CustomerReviewListSerializer(serializers.ModelSerializer):
    customer_name = serializers.SerializerMethodField()
    profile_picture = serializers.SerializerMethodField()

    class Meta:
        model = CustomerReview
        fields = ['id', 'rating', 'comment', 'created', 'customer_name', 'profile_picture']

    def get_customer_name(self, obj):
        user = obj.customer.user
        return f"{user.first_name} {user.last_name}" if user else "Unknown"

    def get_profile_picture(self, obj):
        user = obj.customer.user if obj.customer else None
        if user and user.profile_picture:
            return user.profile_picture.url
        return None
    


class CustomerMembershipExpirationSerializer(serializers.ModelSerializer):
    customer_details = CustomerListSerializer(source='customer')
    days_until_expire = serializers.SerializerMethodField()

    class Meta:
        model = CustomerMembership
        fields = [
            'id', 'customer_details','end_date', 'days_until_expire'
        ]

    def get_days_until_expire(self, obj):
        # Calculate the actual difference in days
        if obj.end_date:
            time_difference = obj.end_date - timezone.now()
            # Convert timedelta to an integer number of days
            return time_difference.days
        return 0
    

class BankAccountDetailsSerializer(serializers.ModelSerializer):
    # This field will be supplied by the view, so it's read-only in the response,
    # but the view will ensure it's set on POST/PATCH.
    date_of_birth = serializers.DateField(
        input_formats=["%Y/%m/%d"],
        format="%Y/%m/%d"
    )
    organization_id = serializers.IntegerField(source='organization.id', read_only=True)
    
    class Meta:
        model = BankAccountDetails
        fields = (
            'id', 'organization', 'organization_id', 'account_holder_name',
            'account_number', 'ifsc_code', 'bank_name', 'branch_name', 'business_type', 'pan_number',
            'date_of_birth'
        )
        read_only_fields = ['id', 'organization', 'organization_id']

class CustomerTransactionListSerializer(serializers.ModelSerializer):
    customer_name = serializers.CharField(
        source="customer.user.full_name", read_only=True
    )
    membership_name = serializers.CharField(
        source="membership.name", read_only=True
    )
    platform_fee = serializers.SerializerMethodField()
    platform_fee_percentage = serializers.SerializerMethodField()
    total_amount = serializers.SerializerMethodField()
    settlement_time = serializers.SerializerMethodField()

    class Meta:
        model = CustomerMembershipTransaction
        fields = [
            "id",
            "customer_name",
            "membership_name",
            "amount",
            "status",
            "payment_method",
            "payment_date",
            "order_id",
            "payment_id",
            "created_at",
            "platform_fee",
            "platform_fee_percentage",
            "total_amount",
            "settlement_time",
        ]

    def get_platform_fee(self, obj):
        """
        Calculate platform fee: max(4% of payment, MIN_PLATFORM_FEE)
        """
        from decimal import Decimal, ROUND_HALF_UP
        from django.conf import settings

        if not obj.amount:
            return "0.00"

        payment_amount = Decimal(str(obj.amount))

        # Calculate 4% of payment amount
        percentage_fee = (payment_amount * Decimal('0.04')).quantize(
            Decimal('0.01'), rounding=ROUND_HALF_UP
        )

        # Minimum platform fee from settings (defaults to ₹4)
        min_fee = Decimal(str(getattr(settings, 'MIN_PLATFORM_FEE', 4.00)))

        # Platform fee is the maximum of 4% and minimum fee
        platform_fee = max(percentage_fee, min_fee)

        return str(platform_fee)

    def get_platform_fee_percentage(self, obj):
        """
        Calculate platform fee percentage relative to payment amount
        """
        from decimal import Decimal, ROUND_HALF_UP

        if not obj.amount or obj.amount == 0:
            return "0.00"

        platform_fee = Decimal(self.get_platform_fee(obj))
        payment_amount = Decimal(str(obj.amount))

        # Calculate percentage: (platform_fee / amount) * 100
        percentage = (platform_fee / payment_amount * Decimal('100')).quantize(
            Decimal('0.01'), rounding=ROUND_HALF_UP
        )

        return str(percentage)

    def get_total_amount(self, obj):
        """
        Calculate total amount after deducting platform fee (gym's share)
        Total = Payment Amount - Platform Fee
        """
        from decimal import Decimal

        if not obj.amount:
            return "0.00"

        payment_amount = Decimal(str(obj.amount))
        platform_fee = Decimal(self.get_platform_fee(obj))

        total_amount = payment_amount - platform_fee

        return str(total_amount)

    def get_settlement_time(self, obj):
        """
        Return settlement time message (Razorpay standard settlement message)
        """
        return "Settlements happen on T+2 working days, where T is the day of transaction.(Working days do not include second and fourth Saturdays, Sundays and bank holidays)"
class CouponValidateSerializer(serializers.Serializer):
    code = serializers.CharField()


# ============================================
# Gym-side Membership Request Serializers
# ============================================

from apps.customers.models import MembershipRequest


class GymMembershipRequestListSerializer(serializers.ModelSerializer):
    """Serializer for gym to view membership requests"""
    customer_name = serializers.SerializerMethodField()
    customer_phone = serializers.SerializerMethodField()
    customer_profile_picture = serializers.SerializerMethodField()
    requested_plan_name = serializers.CharField(
        source='membership_plan.name', read_only=True, default=None
    )
    selected_plan_name = serializers.CharField(
        source='selected_plan.name', read_only=True, default=None
    )

    class Meta:
        model = MembershipRequest
        fields = [
            'id', 'customer', 'customer_name', 'customer_phone',
            'customer_profile_picture',
            'membership_plan', 'requested_plan_name',
            'selected_plan', 'selected_plan_name',
            'status', 'payment_mode', 'notes', 'gym_remarks',
            'contact_info',
            'accepted_amount', 'discount_amount',
            'start_date', 'end_date', 'transaction_number',
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


class GymMembershipRequestActionSerializer(serializers.Serializer):
    """Serializer for gym accept/reject/contact action on a membership request"""
    status = serializers.ChoiceField(
        choices=[('accepted', 'Accepted'), ('rejected', 'Rejected'), ('contacted', 'Contacted')]
    )
    selected_plan = serializers.PrimaryKeyRelatedField(
        queryset=MembershipPlan.objects.all(),
        required=False,
        allow_null=True
    )
    gym_remarks = serializers.CharField(required=False, allow_blank=True)

    # Contact info — gym shares how the customer can reach them
    contact_info = serializers.JSONField(
        required=False, allow_null=True,
        help_text='e.g. {"phone": "9876543210", "email": "gym@example.com", "whatsapp": "9876543210"}'
    )

    # New fields for gym to set on accept
    amount = serializers.DecimalField(
        max_digits=10, decimal_places=2, required=False, allow_null=True
    )
    discount = serializers.DecimalField(
        max_digits=10, decimal_places=2, required=False, allow_null=True, default=0
    )
    start_date = serializers.DateTimeField(required=False, allow_null=True)
    end_date = serializers.DateTimeField(required=False, allow_null=True)
    transaction_number = serializers.CharField(
        required=False, allow_blank=True, allow_null=True
    )
    payment_mode = serializers.ChoiceField(
        choices=[('cash', 'Cash'), ('online', 'Online'), ('offline', 'Offline')],
        required=False, default='cash'
    )

    def validate(self, data):
        if data['status'] == 'accepted' and not data.get('selected_plan'):
            raise serializers.ValidationError(
                {"selected_plan": "A plan must be selected when accepting a request."}
            )
        if data['status'] == 'accepted':
            if not data.get('start_date'):
                raise serializers.ValidationError(
                    {"start_date": "Start date is required when accepting a request."}
                )
            if not data.get('end_date'):
                raise serializers.ValidationError(
                    {"end_date": "End date is required when accepting a request."}
                )
        if data['status'] == 'contacted' and not data.get('contact_info'):
            raise serializers.ValidationError(
                {"contact_info": "Contact info is required when choosing to contact the customer."}
            )
        return data


# ============================================
# Direct Gym (Organization) Creation - No Mentor Required
# ============================================

class DirectGymCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating a gym (Organization) directly without a mentor/user."""
    location = LocationSerializer(required=False)
    working_days = WorkingDaySerializer(many=True, required=False)
    amenities = serializers.ListField(child=serializers.IntegerField(), required=False)
    social_media = SocialMediaSerializer(many=True, required=False)
    categories = serializers.ListField(child=serializers.IntegerField(), required=True)

    class Meta:
        model = Organization
        fields = [
            'name', 'categories', 'description', 'email', 'phone_number',
            'location', 'working_days', 'amenities', 'social_media', 'logo',
        ]

    def validate(self, data):
        errors = {}
        required_fields = ['name', 'categories', 'email', 'phone_number']
        for field in required_fields:
            if not data.get(field):
                errors[field] = f"{field.replace('_', ' ').capitalize()} is required."

        if 'categories' in data:
            if not isinstance(data['categories'], list):
                errors['categories'] = "Must be a list of category IDs."
            else:
                try:
                    data['categories'] = [int(cat) for cat in data['categories']]
                except (ValueError, TypeError):
                    errors['categories'] = "All categories must be integers."

        if errors:
            raise serializers.ValidationError(errors)

        return data

    def create(self, validated_data):
        categories_data = validated_data.pop('categories', [])
        location_data = validated_data.pop('location', None)
        working_days_data = validated_data.pop('working_days', [])
        amenities_data = validated_data.pop('amenities', [])
        social_media_data = validated_data.pop('social_media', [])

        with transaction.atomic():
            # Create organization WITHOUT mentor
            organization = Organization.objects.create(**validated_data)

            # Set categories
            organization.category.set(categories_data)

            # Add location
            if location_data:
                from django.contrib.gis.geos import Point
                lat = location_data.pop('latitude', None)
                lng = location_data.pop('longitude', None)
                if lat is not None:
                    location_data['latitude'] = Decimal(str(lat))
                if lng is not None:
                    location_data['longitude'] = Decimal(str(lng))
                point = None
                if lat and lng:
                    point = Point(float(lng), float(lat))
                Location.objects.create(organization=organization, location=point, **location_data)

            # Add working days
            if working_days_data:
                WorkingDay.objects.bulk_create([
                    WorkingDay(
                        organization=organization,
                        day=wd['day'],
                        is_open=wd.get('is_open'),
                        morning_opening_time=wd.get('morning_opening_time'),
                        morning_closing_time=wd.get('morning_closing_time'),
                        evening_opening_time=wd.get('evening_opening_time'),
                        evening_closing_time=wd.get('evening_closing_time'),
                        ladies_opening_time=wd.get('ladies_opening_time'),
                        ladies_closing_time=wd.get('ladies_closing_time'),
                    ) for wd in working_days_data
                ])

            # Add amenities
            if amenities_data:
                existing_amenities = Amenity.objects.filter(id__in=amenities_data)
                organizationAmenity.objects.bulk_create([
                    organizationAmenity(organization=organization, amenity=amenity)
                    for amenity in existing_amenities
                ])

            # Add social media links
            if social_media_data:
                SocialMedia.objects.bulk_create([
                    SocialMedia(organization=organization, **sm)
                    for sm in social_media_data
                ])

            # Upload photos from request
            request = self.context.get('request')
            if request:
                for i, photo in enumerate(request.FILES.getlist("photos")):
                    OrganizationPhoto.objects.create(
                        organization=organization,
                        image=photo,
                        caption=f"Photo {i+1}",
                        is_primary=(i == 0),
                    )

        return organization


class GymListSerializer(serializers.ModelSerializer):
    """Serializer for listing gyms publicly."""
    categories = serializers.SerializerMethodField()
    location = serializers.SerializerMethodField()
    mentor_name = serializers.SerializerMethodField()
    logo = serializers.SerializerMethodField()

    class Meta:
        model = Organization
        fields = [
            'id', 'name', 'description', 'email', 'phone_number',
            'logo', 'slug', 'active', 'is_public', 'registration_status',
            'categories', 'location', 'mentor_name',
            'review_count', 'average_rating',
            'created_at',
        ]

    def get_logo(self, obj):
        return obj.logo.url if obj.logo else None

    def get_categories(self, obj):
        return [{"id": cat.id, "name": cat.name} for cat in obj.category.all()]

    def get_location(self, obj):
        loc = getattr(obj, 'location', None)
        if loc:
            return {
                "city": loc.city,
                "state": loc.state,
                "building_name": loc.building_name,
            }
        return None

    def get_mentor_name(self, obj):
        if obj.mentor and obj.mentor.user:
            return obj.mentor.user.get_full_name()
        return None


# ============================================================
# Promotional Banner Serializers
# ============================================================

from apps.fitnesscenter.models import PromotionalBanner

class PromotionalBannerSerializer(serializers.ModelSerializer):
    organization_name = serializers.CharField(source='organization.name', read_only=True)
    trainer_name = serializers.CharField(source='trainer.first_name', read_only=True)

    class Meta:
        model = PromotionalBanner
        fields = [
            'id', 'organization', 'organization_name', 'trainer', 'trainer_name',
            'title', 'image', 'image_url', 'banner_type', 'target_screen',
            'external_link', 'is_active', 'created_at', 'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at']


# ============================================================
# Affiliate Marketing Serializers
# ============================================================

from apps.user.models import SalesExecutive, Coupon, SubscriptionTransaction

class SalesExecutiveSerializer(serializers.ModelSerializer):
    organization_name = serializers.CharField(source='organization.name', read_only=True)
    total_coupons = serializers.SerializerMethodField()
    total_commission_earned = serializers.SerializerMethodField()
    total_commission_pending = serializers.SerializerMethodField()

    class Meta:
        model = SalesExecutive
        fields = [
            'id', 'organization', 'organization_name', 'name', 'phone', 'email',
            'is_active', 'created_at',
            'total_coupons', 'total_commission_earned', 'total_commission_pending'
        ]
        read_only_fields = ['created_at']

    def get_total_coupons(self, obj):
        return obj.coupons.count()

    def get_total_commission_earned(self, obj):
        from django.db.models import Sum
        total = SubscriptionTransaction.objects.filter(
            sales_executive=obj
        ).aggregate(total=Sum('executive_commission'))['total']
        return float(total or 0)

    def get_total_commission_pending(self, obj):
        from django.db.models import Sum
        total = SubscriptionTransaction.objects.filter(
            sales_executive=obj,
            commission_paid=False
        ).aggregate(total=Sum('executive_commission'))['total']
        return float(total or 0)


class CouponSerializer(serializers.ModelSerializer):
    organization_name = serializers.CharField(source='organization.name', read_only=True)
    sales_executive_name = serializers.CharField(source='sales_executive.name', read_only=True)
    is_expired = serializers.SerializerMethodField()
    remaining_usage = serializers.SerializerMethodField()

    class Meta:
        model = Coupon
        fields = [
            'id', 'organization', 'organization_name', 'code',
            'discount_type', 'discount_value',
            'sales_executive', 'sales_executive_name',
            'share_type', 'share_value',
            'max_usage', 'used_count', 'remaining_usage',
            'valid_from', 'valid_to', 'is_expired',
            'is_active', 'created_at'
        ]
        read_only_fields = ['created_at', 'used_count']

    def get_is_expired(self, obj):
        from django.utils import timezone
        if obj.valid_to:
            return timezone.now() > obj.valid_to
        return False

    def get_remaining_usage(self, obj):
        if obj.max_usage:
            return max(0, obj.max_usage - obj.used_count)
        return None  # Unlimited


class SubscriptionTransactionSerializer(serializers.ModelSerializer):
    user_name = serializers.CharField(source='user.get_full_name', read_only=True)
    plan_name = serializers.SerializerMethodField()
    coupon_code = serializers.CharField(source='coupon.code', read_only=True)
    executive_name = serializers.CharField(source='sales_executive.name', read_only=True)

    class Meta:
        model = SubscriptionTransaction
        fields = [
            'id', 'plan', 'plan_name', 'membership_plan', 'user', 'user_name',
            'coupon', 'coupon_code',
            'sales_executive', 'executive_name',
            'original_amount', 'discount_amount', 'final_amount',
            'executive_commission', 'commission_paid', 'commission_paid_date',
            'payment_reference', 'created_at'
        ]
        read_only_fields = ['created_at']

    def get_plan_name(self, obj):
        if obj.plan:
            return obj.plan.name
        if obj.membership_plan:
            return obj.membership_plan.name
        return None


class AffiliateDashboardSerializer(serializers.Serializer):
    """Read-only serializer for the affiliate dashboard summary."""
    total_executives = serializers.IntegerField()
    total_active_coupons = serializers.IntegerField()
    total_coupon_usage = serializers.IntegerField()
    total_revenue_via_coupons = serializers.FloatField()
    total_commission_earned = serializers.FloatField()
    total_commission_pending = serializers.FloatField()
    total_commission_paid = serializers.FloatField()
    top_executives = SalesExecutiveSerializer(many=True)
    top_coupons = CouponSerializer(many=True)


class MarkCommissionPaidSerializer(serializers.Serializer):
    """Serializer for marking commissions as paid."""
    transaction_ids = serializers.ListField(
        child=serializers.IntegerField(),
        min_length=1,
        help_text="List of SubscriptionTransaction IDs to mark as paid"
    )

