from rest_framework import serializers
from apps.trainer.models import (
    TrainerSubscriptionPlan,
    MuscleGroup, Equipment, WorkoutGroup, Workout, WorkoutMuscle,
    WorkoutPlan, WorkoutPlanWeek, WorkoutPlanDay, WorkoutPlanExercise,
    ExerciseSetTemplate, CustomerWorkoutPlan, WorkoutSession,
    WorkoutLog, ExerciseSetLog, PRRecord,
)


class MuscleGroupSerializer(serializers.ModelSerializer):
    class Meta:
        model = MuscleGroup
        fields = ['id', 'name', 'icon']


class EquipmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Equipment
        fields = ['id', 'name']


class WorkoutGroupSerializer(serializers.ModelSerializer):
    plan_count = serializers.IntegerField(source='plans.count', read_only=True)
    source = serializers.CharField(read_only=True)
    organization_name = serializers.CharField(source='organization.name', read_only=True)

    class Meta:
        model = WorkoutGroup
        fields = ['id', 'name', 'name_internal', 'type', 'plan_count', 'source', 'organization', 'organization_name', 'created_at']
        read_only_fields = ['created_at']


class WorkoutSerializer(serializers.ModelSerializer):
    primary_muscle_group_name = serializers.CharField(source='primary_muscle_group.name', read_only=True)
    equipment_name = serializers.CharField(source='equipment.name', read_only=True)
    is_global = serializers.BooleanField(read_only=True)
    type = serializers.CharField(required=False, allow_null=True, allow_blank=True)

    class Meta:
        model = Workout
        fields = [
            'id', 'name', 'description', 'type', 'track_by',
            'primary_muscle_group', 'primary_muscle_group_name',
            'equipment', 'equipment_name', 'video_url', 'thumbnail',
            'instructions', 'status', 'is_global', 'created_at',
        ]
        read_only_fields = ['created_at']


class ExerciseSetTemplateSerializer(serializers.ModelSerializer):
    class Meta:
        model = ExerciseSetTemplate
        fields = ['id', 'set_number', 'target_reps', 'target_weight', 'rest_seconds']


class WorkoutPlanExerciseSerializer(serializers.ModelSerializer):
    workout_detail = WorkoutSerializer(source='workout', read_only=True)
    sets = ExerciseSetTemplateSerializer(many=True, read_only=True)
    effective_video_url = serializers.SerializerMethodField()

    class Meta:
        model = WorkoutPlanExercise
        fields = ['id', 'plan_day', 'workout', 'workout_detail', 'video_url', 'effective_video_url', 'order_index', 'notes', 'sets']
        read_only_fields = ['plan_day']

    def get_effective_video_url(self, obj):
        return obj.video_url or obj.workout.video_url


class WorkoutPlanDaySerializer(serializers.ModelSerializer):
    exercises = WorkoutPlanExerciseSerializer(many=True, read_only=True)
    exercise_count = serializers.IntegerField(source='exercises.count', read_only=True)

    class Meta:
        model = WorkoutPlanDay
        fields = ['id', 'day_number', 'title', 'notes', 'exercise_count', 'exercises']


class WorkoutPlanWeekSerializer(serializers.ModelSerializer):
    days = WorkoutPlanDaySerializer(many=True, read_only=True)

    class Meta:
        model = WorkoutPlanWeek
        fields = ['id', 'week_number', 'title', 'days']


class WorkoutPlanSerializer(serializers.ModelSerializer):
    exercise_count = serializers.SerializerMethodField()
    group_name = serializers.CharField(source='group.name', read_only=True)
    source = serializers.CharField(read_only=True)
    organization_name = serializers.CharField(source='organization.name', read_only=True)

    class Meta:
        model = WorkoutPlan
        fields = [
            'id', 'plan_name', 'plan_name_internal', 'description',
            'group', 'group_name', 'total_weeks', 'total_days',
            'exercise_count', 'status', 'source', 'organization', 'organization_name', 'created_at',
        ]
        read_only_fields = ['created_at']

    def get_exercise_count(self, obj):
        return WorkoutPlanExercise.objects.filter(plan_day__plan=obj).count()


class WorkoutPlanDetailSerializer(WorkoutPlanSerializer):
    weeks = WorkoutPlanWeekSerializer(many=True, read_only=True)
    days = WorkoutPlanDaySerializer(many=True, read_only=True)

    class Meta(WorkoutPlanSerializer.Meta):
        fields = WorkoutPlanSerializer.Meta.fields + ['weeks', 'days']


class CustomerWorkoutPlanSerializer(serializers.ModelSerializer):
    plan_name = serializers.CharField(source='plan.plan_name', read_only=True)

    class Meta:
        model = CustomerWorkoutPlan
        fields = ['id', 'customer', 'trainer', 'plan', 'plan_name', 'title', 'start_date', 'status', 'created_at']
        read_only_fields = ['created_at']


class ExerciseSetLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = ExerciseSetLog
        fields = ['id', 'set_number', 'reps', 'weight_kg', 'previous_weight_kg']


class WorkoutLogSerializer(serializers.ModelSerializer):
    set_logs = ExerciseSetLogSerializer(many=True)
    workout_name = serializers.CharField(source='plan_exercise.workout.name', read_only=True)

    class Meta:
        model = WorkoutLog
        fields = ['id', 'plan_exercise', 'workout_name', 'notes', 'logged_at', 'set_logs']
        read_only_fields = ['logged_at']

    def create(self, validated_data):
        set_logs_data = validated_data.pop('set_logs')
        log = WorkoutLog.objects.create(**validated_data)
        for s in set_logs_data:
            ExerciseSetLog.objects.create(workout_log=log, **s)
        return log


class PRRecordSerializer(serializers.ModelSerializer):
    workout_name = serializers.CharField(source='workout.name', read_only=True)

    class Meta:
        model = PRRecord
        fields = ['id', 'workout', 'workout_name', 'value', 'unit', 'verified_at', 'created_at']
        read_only_fields = ['created_at']


class TrainerSubscriptionPlanSerializer(serializers.ModelSerializer):
    price = serializers.DecimalField(source='discounted_price', max_digits=10, decimal_places=2)
    amount = serializers.DecimalField(source='discounted_price', max_digits=10, decimal_places=2)
    is_free_plan = serializers.SerializerMethodField()

    class Meta:
        model = TrainerSubscriptionPlan
        fields = [
            'id', 'name', 'plan_type', 'regular_price', 'discounted_price',
            'price', 'amount', 'total_cost', 'savings', 'period',
            'description', 'features', 'is_free_plan',
        ]

    def get_is_free_plan(self, obj):
        return (obj.total_cost or obj.discounted_price) == 0


from apps.trainer.models import OrganizationTrainerLink


class OrganizationTrainerLinkSerializer(serializers.ModelSerializer):
    trainer_name = serializers.SerializerMethodField()
    trainer_type = serializers.CharField(source='trainer.user_type', read_only=True)
    organization_name = serializers.CharField(source='organization.name', read_only=True)

    class Meta:
        model = OrganizationTrainerLink
        fields = [
            'id', 'trainer', 'trainer_name', 'trainer_type',
            'organization', 'organization_name',
            'status', 'requested_at', 'responded_at', 'rejection_reason',
        ]
        read_only_fields = ['status', 'requested_at', 'responded_at', 'rejection_reason']

    def get_trainer_name(self, obj):
        return f"{obj.trainer.first_name} {obj.trainer.last_name}".strip()
