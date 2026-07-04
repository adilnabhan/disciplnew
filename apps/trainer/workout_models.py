import datetime
from django.db import models


class MuscleGroup(models.Model):

    name = models.CharField(max_length=150)
    icon = models.CharField(max_length=255, null=True, blank=True)
    status = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name


class WorkoutGroup(models.Model):

    TYPE_SINGLE = 'single_day'
    TYPE_MULTI = 'multi_day'
    TYPE_CHOICES = (
        (TYPE_SINGLE, 'Single-Day'),
        (TYPE_MULTI, 'Multi-Day'),
    )

    trainer = models.ForeignKey(
        'trainer.Trainer',
        on_delete=models.CASCADE,
        related_name='workout_groups',
        null=True,
        blank=True
    )
    organization = models.ForeignKey(
        'fitnesscenter.Organization',
        on_delete=models.CASCADE,
        related_name='workout_groups',
        null=True,
        blank=True
    )
    name = models.CharField(max_length=255)
    name_internal = models.CharField(max_length=255, null=True, blank=True)
    type = models.CharField(max_length=20, choices=TYPE_CHOICES, default=TYPE_SINGLE)
    status = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

    @property
    def source(self):
        return 'gym' if self.organization_id else 'trainer'


class Equipment(models.Model):

    name = models.CharField(max_length=150)
    status = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name


class ProgramGoal(models.Model):

    name = models.CharField(max_length=150)
    description = models.TextField(blank=True, null=True)
    status = models.BooleanField(default=True)

    def __str__(self):
        return self.name


class DifficultyLevel(models.Model):

    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    status = models.BooleanField(default=True)

    def __str__(self):
        return self.name


class Workout(models.Model):
    """
    Master exercise record. Admin uploads via bulk CSV.
    created_by=null → master (visible to all)
    created_by=user → trainer-private (visible only to that trainer)
    """

    TYPE_CHOICES = (
        ('strength', 'Strength'),
        ('cardio', 'Cardio'),
        ('flexibility', 'Flexibility'),
        ('balance', 'Balance'),
        ('hiit', 'HIIT'),
        ('other', 'Other'),
    )

    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    primary_muscle_group = models.ForeignKey(
        MuscleGroup,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='workouts'
    )
    equipment = models.ForeignKey(
        Equipment,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='workouts'
    )
    TRACK_BY_CHOICES = (
        ('rep', 'Reps'),
        ('time', 'Time'),
        ('distance', 'Distance'),
    )
    type = models.CharField(max_length=20, choices=TYPE_CHOICES, null=True, blank=True)
    track_by = models.CharField(max_length=20, choices=TRACK_BY_CHOICES, default='rep', null=True, blank=True)
    video_url = models.CharField(max_length=500, null=True, blank=True)
    thumbnail = models.ImageField(upload_to='workouts/thumbnails/', null=True, blank=True)
    instructions = models.TextField(null=True, blank=True)
    status = models.BooleanField(default=True)
    created_by = models.ForeignKey(
        'user.User',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='created_workouts'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

    @property
    def is_global(self):
        if self.created_by_id is None:
            return True
        try:
            user = self.created_by
            if user:
                return user.is_staff or user.is_superuser or user.user_role in (1, 5, 10, 15)
        except Exception:
            pass
        return False


class WorkoutMuscle(models.Model):

    workout = models.ForeignKey(
        Workout,
        on_delete=models.CASCADE,
        related_name='muscles'
    )
    muscle_group = models.ForeignKey(
        MuscleGroup,
        on_delete=models.CASCADE,
        related_name='workout_muscles'
    )


class GymWorkoutOverride(models.Model):
    """
    Fitness center overrides for a master exercise.
    Only stores what the gym wants to change — video_url is the primary use case.
    Priority: trainer override → gym override → master
    """
    workout = models.ForeignKey(
        Workout,
        on_delete=models.CASCADE,
        related_name='gym_overrides'
    )
    organization = models.ForeignKey(
        'fitnesscenter.Organization',
        on_delete=models.CASCADE,
        related_name='workout_overrides'
    )
    video_url = models.CharField(max_length=500, null=True, blank=True)
    instructions = models.TextField(null=True, blank=True)
    is_visible = models.BooleanField(
        default=True,
        help_text='Set False to hide this exercise from trainers in this gym'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('workout', 'organization')

    def __str__(self):
        return f"{self.organization.name} override for {self.workout.name}"


class TrainerWorkoutOverride(models.Model):
    """
    Trainer overrides for a master exercise.
    Only stores what the trainer wants to change — video_url is the primary use case.
    Priority: trainer override → gym override → master
    """
    workout = models.ForeignKey(
        Workout,
        on_delete=models.CASCADE,
        related_name='trainer_overrides'
    )
    trainer = models.ForeignKey(
        'trainer.Trainer',
        on_delete=models.CASCADE,
        related_name='workout_overrides'
    )
    video_url = models.CharField(max_length=500, null=True, blank=True)
    instructions = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('workout', 'trainer')

    def __str__(self):
        return f"{self.trainer} override for {self.workout.name}"


class WorkoutPlan(models.Model):

    trainer = models.ForeignKey(
        'trainer.Trainer',
        on_delete=models.CASCADE,
        related_name='workout_plans',
        null=True,
        blank=True
    )
    organization = models.ForeignKey(
        'fitnesscenter.Organization',
        on_delete=models.CASCADE,
        related_name='workout_plans',
        null=True,
        blank=True
    )
    customer = models.ForeignKey(
        'customers.Customer',
        on_delete=models.CASCADE,
        related_name='created_workout_plans',
        null=True,
        blank=True
    )
    group = models.ForeignKey(
        WorkoutGroup,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='plans'
    )
    plan_name = models.CharField(max_length=255)
    plan_name_internal = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(blank=True, null=True)
    program_goal = models.ForeignKey(
        ProgramGoal,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    difficulty_level = models.ForeignKey(
        DifficultyLevel,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    total_weeks = models.IntegerField(default=1)
    total_days = models.IntegerField(null=True, blank=True)
    status = models.BooleanField(default=True)
    is_preset = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    @property
    def source(self):
        if self.customer_id:
            return 'customer'
        return 'gym' if self.organization_id else 'trainer'


class WorkoutPlanWeek(models.Model):

    plan = models.ForeignKey(
        WorkoutPlan,
        on_delete=models.CASCADE,
        related_name='weeks'
    )
    week_number = models.IntegerField()
    title = models.CharField(max_length=255, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)


class WorkoutPlanDay(models.Model):

    week = models.ForeignKey(
        WorkoutPlanWeek,
        on_delete=models.CASCADE,
        related_name='days',
        null=True,
        blank=True
    )
    plan = models.ForeignKey(
        WorkoutPlan,
        on_delete=models.CASCADE,
        related_name='days',
        null=True,
        blank=True
    )
    day_number = models.IntegerField()
    title = models.CharField(max_length=255, blank=True, null=True)
    notes = models.TextField(blank=True, null=True)


class WorkoutPlanExercise(models.Model):

    plan_day = models.ForeignKey(
        WorkoutPlanDay,
        on_delete=models.CASCADE,
        related_name='exercises'
    )
    workout = models.ForeignKey(
        Workout,
        on_delete=models.CASCADE,
        related_name='plan_exercises'
    )
    video_url = models.CharField(max_length=500, null=True, blank=True)
    order_index = models.IntegerField(default=0)
    notes = models.TextField(blank=True, null=True)

    def effective_video_url(self):
        return self.video_url or self.workout.video_url


class ExerciseSetTemplate(models.Model):

    INPUT_TYPE_CHOICES = (
        ('reps', 'Reps'),
        ('seconds', 'Seconds'),
        ('minutes', 'Minutes'),
        ('distance', 'Distance'),
        ('calories', 'Calories'),
        ('custom', 'Custom'),
    )

    plan_exercise = models.ForeignKey(
        WorkoutPlanExercise,
        on_delete=models.CASCADE,
        related_name='sets'
    )
    set_number = models.IntegerField()
    target_reps = models.IntegerField(null=True, blank=True)
    target_weight = models.DecimalField(max_digits=6, decimal_places=2, null=True, blank=True)
    rest_seconds = models.IntegerField(null=True, blank=True)
    input_type = models.CharField(max_length=20, choices=INPUT_TYPE_CHOICES, default='reps')


class CustomerWorkoutPlan(models.Model):

    STATUS_CHOICES = (
        ('active', 'Active'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    )

    customer = models.ForeignKey(
        'customers.Customer',
        on_delete=models.CASCADE,
        related_name='customer_workout_plans'
    )
    trainer = models.ForeignKey(
        'trainer.Trainer',
        on_delete=models.CASCADE,
        related_name='assigned_workout_plans',
        null=True,
        blank=True
    )
    plan = models.ForeignKey(
        WorkoutPlan,
        on_delete=models.CASCADE,
        related_name='customer_plans'
    )
    start_date = models.DateField(default=datetime.date.today)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='active')
    title = models.CharField(max_length=255, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)


class WorkoutSession(models.Model):

    STATUS_CHOICES = (
        ('pending', 'Pending'),
        ('in_progress', 'In Progress'),
        ('completed', 'Completed'),
        ('skipped', 'Skipped'),
        ('rest_day', 'Rest Day'),
    )

    customer = models.ForeignKey(
        'customers.Customer',
        on_delete=models.CASCADE,
        related_name='workout_sessions'
    )
    customer_workout_plan = models.ForeignKey(
        CustomerWorkoutPlan,
        on_delete=models.CASCADE,
        related_name='sessions',
        null=True,
        blank=True
    )
    plan_day = models.ForeignKey(
        WorkoutPlanDay,
        on_delete=models.CASCADE,
        related_name='sessions'
    )
    session_date = models.DateField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    title = models.CharField(max_length=255, null=True, blank=True)

    def delete(self, *args, **kwargs):
        plan = self.plan_day.plan if self.plan_day else None
        customer = self.customer
        super().delete(*args, **kwargs)
        if plan and plan.customer == customer and not plan.is_preset:
            # Only delete the plan if it's an ad-hoc session plan and there are no other sessions left
            is_adhoc = 'ad-hoc' in (plan.description or '').lower()
            if is_adhoc:
                has_other_sessions = WorkoutSession.objects.filter(
                    customer=customer,
                    plan_day__plan=plan
                ).exists()
                if not has_other_sessions:
                    plan.delete()


class WorkoutLog(models.Model):

    customer = models.ForeignKey(
        'customers.Customer',
        on_delete=models.CASCADE,
        related_name='workout_logs'
    )
    session = models.ForeignKey(
        WorkoutSession,
        on_delete=models.CASCADE,
        related_name='logs',
        null=True,
        blank=True
    )
    plan_exercise = models.ForeignKey(
        WorkoutPlanExercise,
        on_delete=models.CASCADE,
        related_name='logs'
    )
    is_completed = models.BooleanField(default=False)
    logged_at = models.DateTimeField(auto_now_add=True)
    notes = models.TextField(null=True, blank=True)
    weight_type = models.CharField(max_length=20, default='kg', null=True, blank=True)


class ExerciseSetLog(models.Model):

    workout_log = models.ForeignKey(
        WorkoutLog,
        on_delete=models.CASCADE,
        related_name='set_logs'
    )
    set_number = models.IntegerField()
    reps = models.IntegerField(null=True, blank=True)
    weight_kg = models.DecimalField(max_digits=6, decimal_places=2, null=True, blank=True)
    previous_weight_kg = models.DecimalField(max_digits=6, decimal_places=2, null=True, blank=True)
    previous_reps = models.IntegerField(null=True, blank=True)
    is_completed = models.BooleanField(default=False)
    input_type = models.CharField(max_length=20, default='reps')
    value = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)


class PRRecord(models.Model):

    customer = models.ForeignKey(
        'customers.Customer',
        on_delete=models.CASCADE,
        related_name='pr_records'
    )
    workout = models.ForeignKey(
        Workout,
        on_delete=models.CASCADE,
        related_name='pr_records'
    )
    value = models.DecimalField(max_digits=6, decimal_places=2)
    unit = models.CharField(max_length=10, default='kg')
    verified_at = models.DateField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
