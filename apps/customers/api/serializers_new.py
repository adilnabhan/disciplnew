from rest_framework import serializers
from apps.customers.models import Customer
from apps.customers.body_models import WeightLog, BodyMeasurementLog, ProgressPhoto
from apps.customers.nutrition_models import Food, FoodLog, WaterLog
from apps.customers.achievement_models import Badge, EarnedBadge, CustomerPoints
from apps.customers.community_models import CommunityPost, CommunityLike, CommunityComment

# ==========================================
# BODY & MEASUREMENTS SERIALIZERS
# ==========================================

class WeightLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = WeightLog
        fields = ['id', 'weight_kg', 'logged_at', 'created_at']
        read_only_fields = ['id', 'created_at']

class BodyMeasurementLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = BodyMeasurementLog
        fields = ['id', 'neck_cm', 'chest_cm', 'biceps_cm', 'waist_cm', 'hips_cm', 'thighs_cm', 'logged_at', 'created_at']
        read_only_fields = ['id', 'created_at']

class ProgressPhotoSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProgressPhoto
        fields = ['id', 'photo', 'photo_type', 'logged_at', 'created_at']
        read_only_fields = ['id', 'created_at']

# ==========================================
# NUTRITION & NUTRITIONAL LOGS
# ==========================================

class FoodSerializer(serializers.ModelSerializer):
    class Meta:
        model = Food
        fields = ['id', 'name', 'calories', 'protein', 'carbs', 'fat', 'fiber', 'serving_size', 'is_global']
        read_only_fields = ['id']

class FoodLogSerializer(serializers.ModelSerializer):
    food_details = FoodSerializer(source='food', read_only=True)
    
    class Meta:
        model = FoodLog
        fields = ['id', 'food', 'food_details', 'meal_type', 'servings', 'logged_at', 'created_at']
        read_only_fields = ['id', 'created_at']

class WaterLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = WaterLog
        fields = ['id', 'amount_ml', 'logged_at', 'created_at']
        read_only_fields = ['id', 'created_at']

# ==========================================
# ACHIEVEMENTS & POINTS
# ==========================================

class BadgeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Badge
        fields = ['id', 'name', 'description', 'icon_url', 'xp_reward', 'coin_reward']
        read_only_fields = ['id']

class EarnedBadgeSerializer(serializers.ModelSerializer):
    badge_details = BadgeSerializer(source='badge', read_only=True)

    class Meta:
        model = EarnedBadge
        fields = ['id', 'badge', 'badge_details', 'earned_at']
        read_only_fields = ['id', 'earned_at']

class CustomerPointsSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomerPoints
        fields = ['id', 'xp', 'coins', 'streak_days', 'last_active_date', 'updated_at']
        read_only_fields = ['id', 'updated_at']

# ==========================================
# COMMUNITY SERIALIZERS
# ==========================================

class CommunityLikeSerializer(serializers.ModelSerializer):
    customer_name = serializers.CharField(source='customer.user.username', read_only=True)
    customer_pic = serializers.CharField(source='customer.user.profile_picture', read_only=True)

    class Meta:
        model = CommunityLike
        fields = ['id', 'customer', 'customer_name', 'customer_pic', 'created_at']
        read_only_fields = ['id', 'created_at']

class CommunityCommentSerializer(serializers.ModelSerializer):
    customer_name = serializers.CharField(source='customer.user.username', read_only=True)
    customer_pic = serializers.CharField(source='customer.user.profile_picture', read_only=True)

    class Meta:
        model = CommunityComment
        fields = ['id', 'comment_text', 'customer', 'customer_name', 'customer_pic', 'created_at']
        read_only_fields = ['id', 'created_at']

class CommunityPostSerializer(serializers.ModelSerializer):
    likes_count = serializers.SerializerMethodField()
    comments_count = serializers.SerializerMethodField()
    has_liked = serializers.SerializerMethodField()
    customer_name = serializers.CharField(source='customer.user.username', read_only=True)
    customer_pic = serializers.CharField(source='customer.user.profile_picture', read_only=True)
    comments = CommunityCommentSerializer(many=True, read_only=True)

    class Meta:
        model = CommunityPost
        fields = ['id', 'post_type', 'caption', 'media_url', 'created_at', 'likes_count', 'comments_count', 'has_liked', 'customer_name', 'customer_pic', 'comments']
        read_only_fields = ['id', 'created_at']

    def get_likes_count(self, obj):
        return obj.likes.count()

    def get_comments_count(self, obj):
        return obj.comments.count()

    def get_has_liked(self, obj):
        request = self.context.get('request')
        if request and request.user and not request.user.is_anonymous:
            try:
                customer = request.user.customer
                return obj.likes.filter(customer=customer).exists()
            except Exception:
                pass
        return False
