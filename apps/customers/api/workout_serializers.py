from rest_framework import serializers
from apps.trainer.models import (
    CustomerWorkoutPlan, WorkoutPlan, WorkoutPlanDay, WorkoutPlanExercise,
    ExerciseSetTemplate, WorkoutSession, WorkoutLog, ExerciseSetLog,
)


class CustomerExerciseSetLogSerializer(serializers.ModelSerializer):
    target_reps = serializers.SerializerMethodField()
    target_weight = serializers.SerializerMethodField()
    previous = serializers.SerializerMethodField()

    class Meta:
        model = ExerciseSetLog
        fields = ['id', 'set_number', 'reps', 'weight_kg', 'previous_weight_kg', 'previous', 'is_completed', 'target_reps', 'target_weight', 'input_type', 'value']

    def to_representation(self, instance):
        ret = super().to_representation(instance)
        
        # Convert reps: if None, keep None, else convert to int
        if ret.get('reps') is not None:
            try:
                ret['reps'] = int(ret['reps'])
            except (ValueError, TypeError):
                ret['reps'] = None
        else:
            ret['reps'] = None
        
        # Convert weight_kg: if None, keep None, else convert to float
        if ret.get('weight_kg') is not None:
            try:
                ret['weight_kg'] = float(ret['weight_kg'])
            except (ValueError, TypeError):
                ret['weight_kg'] = None
        else:
            ret['weight_kg'] = None

        # Convert previous_weight_kg: if None, use "no data", else convert to float
        if ret.get('previous_weight_kg') is not None:
            try:
                ret['previous_weight_kg'] = float(ret['previous_weight_kg'])
            except (ValueError, TypeError):
                ret['previous_weight_kg'] = "no data"
        else:
            ret['previous_weight_kg'] = "no data"

        return ret

    def get_target_reps(self, obj):
        try:
            template = obj.workout_log.plan_exercise.sets.filter(set_number=obj.set_number).first()
            return int(template.target_reps) if template and template.target_reps is not None else None
        except Exception:
            return None

    def get_target_weight(self, obj):
        try:
            template = obj.workout_log.plan_exercise.sets.filter(set_number=obj.set_number).first()
            return float(template.target_weight) if template and template.target_weight is not None else None
        except Exception:
            return None

    def get_previous(self, obj):
        try:
            from apps.customers.api.workout_views import _get_previous_set_logs
            cache_key = f"prev_sets_{obj.workout_log.id}"
            if cache_key not in self.context:
                self.context[cache_key] = _get_previous_set_logs(
                    obj.workout_log.customer, 
                    obj.workout_log.plan_exercise, 
                    current_session=obj.workout_log.session
                )
            prev_sets = self.context[cache_key]
            prev = prev_sets.get(obj.set_number)
            if prev and prev.weight_kg is not None and prev.reps is not None:
                w = float(prev.weight_kg)
                w_str = f"{int(w)}" if w.is_integer() else f"{w}"
                return f"{w_str}x{prev.reps}"
            
            # Fallback to previous_weight_kg
            if obj.previous_weight_kg is not None:
                w = float(obj.previous_weight_kg)
                w_str = f"{int(w)}" if w.is_integer() else f"{w}"
                return f"{w_str}"
            return "no data"
        except Exception:
            if obj.previous_weight_kg is not None:
                w = float(obj.previous_weight_kg)
                w_str = f"{int(w)}" if w.is_integer() else f"{w}"
                return f"{w_str}"
            return "no data"



class CustomerWorkoutLogSerializer(serializers.ModelSerializer):
    workout_name = serializers.CharField(source='plan_exercise.workout.name', read_only=True)
    muscle = serializers.SerializerMethodField()
    equipment = serializers.SerializerMethodField()
    effective_video_url = serializers.SerializerMethodField()
    video_url = serializers.SerializerMethodField()
    set_logs = CustomerExerciseSetLogSerializer(many=True, read_only=True)
    order_index = serializers.IntegerField(source='plan_exercise.order_index', read_only=True)
    track_by = serializers.CharField(source='plan_exercise.workout.track_by', read_only=True, required=False, allow_null=True)
    workout_id = serializers.IntegerField(source='plan_exercise.workout.id', read_only=True, required=False, allow_null=True)

    class Meta:
        model = WorkoutLog
        fields = [
            'id', 'plan_exercise', 'order_index', 'workout_name',
            'muscle', 'equipment', 'effective_video_url', 'video_url',
            'is_completed', 'notes', 'logged_at', 'set_logs', 'weight_type', 'track_by', 'workout_id',
        ]
        read_only_fields = ['logged_at']

    def get_muscle(self, obj):
        try:
            return obj.plan_exercise.workout.primary_muscle_group.name
        except AttributeError:
            return None

    def get_equipment(self, obj):
        try:
            return obj.plan_exercise.workout.equipment.name
        except AttributeError:
            return None

    def get_effective_video_url(self, obj):
        try:
            return obj.plan_exercise.video_url or obj.plan_exercise.workout.video_url
        except AttributeError:
            return None

    def get_video_url(self, obj):
        return self.get_effective_video_url(obj)


class CustomerWorkoutSessionSerializer(serializers.ModelSerializer):
    logs = CustomerWorkoutLogSerializer(many=True, read_only=True)
    duration = serializers.SerializerMethodField()
    customer_workout_plan_id = serializers.IntegerField(read_only=True)
    day_number = serializers.SerializerMethodField()

    class Meta:
        model = WorkoutSession
        fields = [
            'id', 'title', 'plan_day', 'customer_workout_plan_id', 'day_number',
            'session_date', 'status', 'started_at', 'completed_at', 'logs', 'duration'
        ]

    def get_duration(self, obj):
        if obj.started_at and obj.completed_at:
            diff = obj.completed_at - obj.started_at
            total_seconds = int(diff.total_seconds())
            hours = total_seconds // 3600
            minutes = (total_seconds % 3600) // 60
            seconds = total_seconds % 60
            if hours > 0:
                return f"{hours}h {minutes}m"
            elif minutes > 0:
                return f"{minutes}m {seconds}s"
            else:
                return f"{seconds}s"
        return "--:--"

    def get_day_number(self, obj):
        if obj.plan_day and hasattr(obj.plan_day, 'day_number'):
            return obj.plan_day.day_number
        return None


# ─── Customer Workout Plan Creation Serializers ──────────────────────────────

class CustomerSetTemplateSerializer(serializers.ModelSerializer):
    class Meta:
        model = ExerciseSetTemplate
        fields = ['id', 'set_number', 'target_reps', 'target_weight', 'rest_seconds', 'input_type']
        read_only_fields = ['id']

    def to_representation(self, instance):
        ret = super().to_representation(instance)
        
        # Keep target_reps as None/null if not set, otherwise convert to int
        if ret.get('target_reps') is not None:
            try:
                ret['target_reps'] = int(ret['target_reps'])
            except (ValueError, TypeError):
                ret['target_reps'] = None
        
        # Keep target_weight as None/null if not set, otherwise convert to float
        if ret.get('target_weight') is not None:
            try:
                ret['target_weight'] = float(ret['target_weight'])
            except (ValueError, TypeError):
                ret['target_weight'] = None

        if ret.get('rest_seconds') is None:
            ret['rest_seconds'] = 60

        return ret


class CustomerPlanExerciseSerializer(serializers.ModelSerializer):
    workout_name = serializers.CharField(source='workout.name', read_only=True)
    muscle = serializers.SerializerMethodField()
    equipment = serializers.SerializerMethodField()
    sets = CustomerSetTemplateSerializer(many=True, read_only=True)
    video_url = serializers.SerializerMethodField()

    class Meta:
        model = WorkoutPlanExercise
        fields = [
            'id', 'workout', 'workout_name', 'muscle', 'equipment',
            'video_url', 'order_index', 'notes', 'sets',
        ]
        read_only_fields = ['id']

    def get_muscle(self, obj):
        try:
            return obj.workout.primary_muscle_group.name
        except AttributeError:
            return None

    def get_equipment(self, obj):
        try:
            return obj.workout.equipment.name
        except AttributeError:
            return None

    def get_video_url(self, obj):
        try:
            return obj.video_url or obj.workout.video_url
        except AttributeError:
            return None


class CustomerPlanDaySerializer(serializers.ModelSerializer):
    exercises = CustomerPlanExerciseSerializer(many=True, read_only=True)
    exercise_count = serializers.IntegerField(source='exercises.count', read_only=True)

    class Meta:
        model = WorkoutPlanDay
        fields = ['id', 'day_number', 'title', 'notes', 'exercise_count', 'exercises']
        read_only_fields = ['id']


class CustomerWorkoutPlanCreateSerializer(serializers.ModelSerializer):
    """Serializer for customer to create/update their own workout plan."""

    class Meta:
        model = WorkoutPlan
        fields = [
            'id', 'plan_name', 'description', 'program_goal',
            'difficulty_level', 'total_weeks', 'total_days',
        ]
        read_only_fields = ['id']


class CustomerWorkoutPlanListSerializer(serializers.ModelSerializer):
    """Read serializer for listing customer's own workout plans."""
    source = serializers.CharField(read_only=True)
    day_count = serializers.IntegerField(source='days.count', read_only=True)
    is_favorite = serializers.BooleanField(source='is_preset', read_only=True)

    class Meta:
        model = WorkoutPlan
        fields = [
            'id', 'plan_name', 'description', 'program_goal',
            'difficulty_level', 'total_weeks', 'total_days',
            'source', 'day_count', 'status', 'is_preset', 'is_favorite', 'created_at',
        ]


class CustomerWorkoutPlanDetailSerializer(serializers.ModelSerializer):
    """Full detail serializer with days and exercises."""
    source = serializers.CharField(read_only=True)
    days = CustomerPlanDaySerializer(many=True, read_only=True)
    is_favorite = serializers.BooleanField(source='is_preset', read_only=True)

    class Meta:
        model = WorkoutPlan
        fields = [
            'id', 'plan_name', 'description', 'program_goal',
            'difficulty_level', 'total_weeks', 'total_days',
            'source', 'status', 'is_preset', 'is_favorite', 'created_at', 'days',
        ]


class CustomerPresetSetSerializer(serializers.ModelSerializer):
    weight = serializers.FloatField(source='target_weight')
    reps = serializers.IntegerField(source='target_reps')
    target_weight = serializers.FloatField(read_only=True)
    target_reps = serializers.IntegerField(read_only=True)
    rest_seconds = serializers.IntegerField(read_only=True)

    class Meta:
        model = ExerciseSetTemplate
        fields = ['set_number', 'reps', 'weight', 'target_reps', 'target_weight', 'rest_seconds', 'input_type']

    def to_representation(self, instance):
        ret = super().to_representation(instance)
        # Keep target_reps as None/null if not set, otherwise convert to int
        if ret.get('target_reps') is not None:
            try:
                ret['target_reps'] = int(ret['target_reps'])
            except (ValueError, TypeError):
                ret['target_reps'] = None
        if ret.get('reps') is not None:
            try:
                ret['reps'] = int(ret['reps'])
            except (ValueError, TypeError):
                ret['reps'] = None

        # Keep target_weight as None/null if not set, otherwise convert to float
        if ret.get('target_weight') is not None:
            try:
                ret['target_weight'] = float(ret['target_weight'])
            except (ValueError, TypeError):
                ret['target_weight'] = None
        if ret.get('weight') is not None:
            try:
                ret['weight'] = float(ret['weight'])
            except (ValueError, TypeError):
                ret['weight'] = None

        if ret.get('rest_seconds') is None:
            ret['rest_seconds'] = 60

        return ret


class CustomerPresetExerciseSerializer(serializers.ModelSerializer):
    workout_id = serializers.IntegerField(source='workout.id')
    name = serializers.CharField(source='workout.name', read_only=True)
    muscle_group = serializers.SerializerMethodField(read_only=True)
    
    workout = serializers.IntegerField(source='workout.id')
    workout_name = serializers.CharField(source='workout.name', read_only=True)
    muscle = serializers.SerializerMethodField(read_only=True)
    equipment = serializers.SerializerMethodField(read_only=True)
    video_url = serializers.SerializerMethodField(read_only=True)
    
    sets = CustomerPresetSetSerializer(many=True, read_only=True)

    class Meta:
        model = WorkoutPlanExercise
        fields = [
            'id', 'workout_id', 'name', 'muscle_group', 'order_index', 'sets',
            'workout', 'workout_name', 'muscle', 'equipment', 'video_url', 'notes'
        ]

    def get_muscle_group(self, obj):
        if obj.workout and obj.workout.primary_muscle_group:
            return obj.workout.primary_muscle_group.name
        return ""

    def get_muscle(self, obj):
        return self.get_muscle_group(obj)

    def get_equipment(self, obj):
        if obj.workout and obj.workout.equipment:
            return obj.workout.equipment.name
        return ""

    def get_video_url(self, obj):
        if obj.workout:
            return obj.video_url or obj.workout.video_url
        return ""


class CustomerPresetSerializer(serializers.ModelSerializer):
    title = serializers.CharField(source='plan_name')
    plan_name = serializers.CharField(read_only=True)
    exercises = serializers.SerializerMethodField()
    plan_day_id = serializers.SerializerMethodField()

    class Meta:
        model = WorkoutPlan
        fields = ['id', 'title', 'plan_name', 'created_at', 'plan_day_id', 'exercises']

    def get_plan_day_id(self, obj):
        from apps.trainer.workout_models import WorkoutPlanDay
        day = WorkoutPlanDay.objects.filter(plan=obj).order_by('day_number').first()
        return day.id if day else None

    def get_exercises(self, obj):
        from apps.trainer.workout_models import WorkoutPlanExercise
        exercises = WorkoutPlanExercise.objects.filter(plan_day__plan=obj).order_by('plan_day__day_number', 'order_index')
        return CustomerPresetExerciseSerializer(exercises, many=True).data

