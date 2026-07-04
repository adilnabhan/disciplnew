from django.contrib import admin
from import_export import resources, fields
from import_export.admin import ImportExportModelAdmin
from import_export.widgets import ForeignKeyWidget
from .models import (
    Trainer,
    TrainerExperience,
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
    TrainerPlan,
    TrainerLocationPreference,
    TrainerSubscription,
    TrainerSubscriptionPlan,
    OrganizationTrainerLink,
    TrainerReview,
)
from .workout_models import (
    MuscleGroup,
    WorkoutGroup,
    Equipment,
    ProgramGoal,
    DifficultyLevel,
    Workout,
    WorkoutMuscle,
    WorkoutPlan,
    WorkoutPlanWeek,
    WorkoutPlanDay,
    WorkoutPlanExercise,
    ExerciseSetTemplate,
    CustomerWorkoutPlan,
    WorkoutSession,
    WorkoutLog,
    ExerciseSetLog,
    PRRecord,
)
from django.contrib.admin.models import LogEntryManager

original_log_actions = LogEntryManager.log_actions

def patched_log_actions(self, *args, **kwargs):
    kwargs.pop("single_object", None)
    return original_log_actions(self, *args, **kwargs)

LogEntryManager.log_actions = patched_log_actions

class WorkoutResource(resources.ModelResource):
    """
    Supports bulk CSV/XLSX upload from admin.
    CSV columns: Name, Type, Primary Muscle Group, Equipment, Video URL, Instructions, Description, Status
    Primary Muscle Group and Equipment are matched by name.
    Rows with created_by blank are treated as global library exercises.
    """
    name = fields.Field(
        column_name='Name',
        attribute='name'
    )
    type = fields.Field(
        column_name='Type',
        attribute='type'
    )
    primary_muscle_group = fields.Field(
        column_name='Primary Muscle Group',
        attribute='primary_muscle_group',
        widget=ForeignKeyWidget(MuscleGroup, field='name')
    )
    equipment = fields.Field(
        column_name='Equipment',
        attribute='equipment',
        widget=ForeignKeyWidget(Equipment, field='name')
    )
    video_url = fields.Field(
        column_name='Video URL',
        attribute='video_url'
    )
    instructions = fields.Field(
        column_name='Instructions',
        attribute='instructions'
    )
    description = fields.Field(
        column_name='Description',
        attribute='description'
    )
    status = fields.Field(
        column_name='Status',
        attribute='status'
    )

    class Meta:
        model = Workout
        import_id_fields = []  # Allow creating new workouts without requiring 'name' to match existing
        fields = [
            'name', 'type', 'primary_muscle_group', 'equipment',
            'video_url', 'instructions', 'description', 'status',
        ]
        skip_unchanged = False  # Don't skip rows - import all
        report_skipped = True

    @classmethod
    def get_headers(cls, dataset, **kwargs):
        """
        Override to normalize CSV headers before field matching.
        Maps common header variations to expected column names.
        """
        raw_headers = dataset.headers
        
        header_map = {
            'name': 'Name',
            'type': 'Type',
            'primary muscle group': 'Primary Muscle Group',
            'equipment': 'Equipment',
            'video url': 'Video URL',
            'instructions': 'Instructions',
            'description': 'Description',
            'status': 'Status',
        }
        
        normalized_headers = []
        for header in raw_headers:
            if isinstance(header, str):
                # Strip whitespace, BOM, and normalize to canonical form
                clean_header = header.strip().lstrip('\ufeff')
                canonical = header_map.get(clean_header.lower(), clean_header)
                normalized_headers.append(canonical)
            else:
                normalized_headers.append(header)
        
        dataset.headers = normalized_headers
        return normalized_headers

    def before_import_row(self, row, row_number=None, **kwargs):
        """Process and validate row data before instance creation."""
        # Ensure global library exercises have no created_by
        row['created_by'] = None

        # Strip whitespace from string values
        for key, value in list(row.items()):
            if isinstance(value, str):
                row[key] = value.strip()

        # Normalize Type field values
        type_val = row.get('Type')
        if isinstance(type_val, str):
            type_lower = type_val.strip().lower()
            if type_lower in ('', 'none'):
                row['Type'] = 'other'
            elif type_lower == 'compound':
                row['Type'] = 'strength'
            elif type_lower in ('cardio', 'strength', 'flexibility', 'balance', 'hiit', 'other'):
                row['Type'] = type_lower
            else:
                row['Type'] = 'other'

        # Convert Status to boolean
        status_val = row.get('Status', 'True')
        if isinstance(status_val, str):
            row['Status'] = status_val.strip().lower() in ('approved', 'true', '1', 'yes', 'active')
        elif status_val is None:
            row['Status'] = True

        # Create missing MuscleGroup if it doesn't exist
        muscle_group_name = row.get('Primary Muscle Group')
        if muscle_group_name and muscle_group_name not in ('', 'None'):
            MuscleGroup.objects.get_or_create(name=muscle_group_name, defaults={'status': True})

        # Create missing Equipment if it doesn't exist
        equipment_name = row.get('Equipment')
        if equipment_name and equipment_name not in ('', 'None'):
            Equipment.objects.get_or_create(name=equipment_name, defaults={'status': True})

    def skip_row(self, instance, original, *args, **kwargs):
        """Skip rows with empty names"""
        return not instance.name


@admin.register(Trainer)
class TrainerAdmin(admin.ModelAdmin):
    list_display = ['id', 'first_name', 'last_name', 'email', 'mobile', 'gender', 'profile_step', 'created_at']
    list_filter = ['gender', 'is_freelancer', 'join_gym', 'event_collaborator', 'created_at']
    search_fields = ['first_name', 'last_name', 'email', 'mobile']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(TrainerExperience)
class TrainerExperienceAdmin(admin.ModelAdmin):
    list_display = ['id', 'trainer', 'organization_name', 'designation', 'start_date', 'end_date', 'currently_working']
    list_filter = ['currently_working', 'created_at']
    search_fields = ['organization_name', 'designation', 'trainer__first_name', 'trainer__last_name']


@admin.register(Specialization)
class SpecializationAdmin(admin.ModelAdmin):
    list_display = ['id', 'name']
    search_fields = ['name']


@admin.register(TrainerSpecialization)
class TrainerSpecializationAdmin(admin.ModelAdmin):
    list_display = ['id', 'trainer', 'specialization']
    list_filter = ['specialization']
    search_fields = ['trainer__first_name', 'trainer__last_name']


@admin.register(TrainerCertification)
class TrainerCertificationAdmin(admin.ModelAdmin):
    list_display = ['id', 'trainer', 'certificate_name', 'issued_by', 'issued_date']
    list_filter = ['issued_date']
    search_fields = ['certificate_name', 'issued_by', 'trainer__first_name']


@admin.register(TrainerPortfolio)
class TrainerPortfolioAdmin(admin.ModelAdmin):
    list_display = ['id', 'trainer', 'type']
    list_filter = ['type']
    search_fields = ['trainer__first_name', 'trainer__last_name']


@admin.register(TrainerTransformation)
class TrainerTransformationAdmin(admin.ModelAdmin):
    list_display = ['id', 'trainer', 'description']
    search_fields = ['trainer__first_name', 'trainer__last_name', 'description']


@admin.register(Language)
class LanguageAdmin(admin.ModelAdmin):
    list_display = ['id', 'name']
    search_fields = ['name']


@admin.register(TrainerLanguage)
class TrainerLanguageAdmin(admin.ModelAdmin):
    list_display = ['id', 'trainer', 'language']
    list_filter = ['language']
    search_fields = ['trainer__first_name', 'trainer__last_name']


@admin.register(TrainerSocialLink)
class TrainerSocialLinkAdmin(admin.ModelAdmin):
    list_display = ['id', 'trainer', 'website', 'instagram', 'facebook']
    search_fields = ['trainer__first_name', 'trainer__last_name', 'website']


@admin.register(Location)
class LocationAdmin(admin.ModelAdmin):
    list_display = ['id', 'trainer', 'city', 'state', 'country', 'pincode']
    list_filter = ['city', 'state', 'country']
    search_fields = ['trainer__first_name', 'trainer__last_name', 'city', 'state']


@admin.register(TrainerBankAccount)
class TrainerBankAccountAdmin(admin.ModelAdmin):
    list_display = ['id', 'trainer', 'account_holder_name', 'account_number', 'ifsc_code', 'razorpay_account_status']
    list_filter = ['razorpay_account_status', 'business_type']
    search_fields = ['trainer__first_name', 'account_holder_name', 'account_number']
    readonly_fields = ['razorpay_account_id', 'razorpay_product_id', 'razorpay_stakeholder_id', 'created_at']


@admin.register(TrainerPlan)
class TrainerPlanAdmin(admin.ModelAdmin):
    list_display = ['id', 'trainer', 'plan_name', 'price', 'offer_price', 'duration_days', 'is_active']
    list_filter = ['is_active', 'emi_available', 'created_at']
    search_fields = ['trainer__first_name', 'plan_name']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(TrainerLocationPreference)
class TrainerLocationPreferenceAdmin(admin.ModelAdmin):
    list_display = ['id', 'trainer', 'location_name', 'created_at']
    search_fields = ['trainer__first_name', 'trainer__last_name', 'location_name']


@admin.register(TrainerSubscriptionPlan)
class TrainerSubscriptionPlanAdmin(admin.ModelAdmin):
    list_display = ['name', 'plan_type', 'regular_price', 'discounted_price', 'period', 'is_active']
    list_filter = ['plan_type', 'is_active']
    search_fields = ['name']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(TrainerSubscription)
class TrainerSubscriptionAdmin(admin.ModelAdmin):
    list_display = ['id', 'trainer', 'plan', 'status', 'paid_amount', 'payment_status', 'start_date', 'end_date']
    list_filter = ['status', 'payment_status', 'created_at']
    search_fields = ['trainer__first_name', 'trainer__last_name', 'razorpay_order_id', 'razorpay_payment_id']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(OrganizationTrainerLink)
class OrganizationTrainerLinkAdmin(admin.ModelAdmin):
    list_display = ['id', 'trainer', 'organization', 'status', 'requested_at', 'responded_at']
    list_filter = ['status', 'requested_at']
    search_fields = ['trainer__first_name', 'trainer__last_name', 'organization__name']
    readonly_fields = ['requested_at', 'responded_at']


@admin.register(TrainerReview)
class TrainerReviewAdmin(admin.ModelAdmin):
    list_display = ['id', 'trainer', 'customer', 'rating', 'created_at']
    list_filter = ['rating', 'created_at']
    search_fields = ['trainer__first_name', 'trainer__last_name', 'customer__user__first_name']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(MuscleGroup)
class MuscleGroupAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'status', 'created_at']
    list_filter = ['status']
    search_fields = ['name']


@admin.register(Equipment)
class EquipmentAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'status', 'created_at']
    list_filter = ['status']
    search_fields = ['name']


@admin.register(ProgramGoal)
class ProgramGoalAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'status']
    list_filter = ['status']
    search_fields = ['name']


@admin.register(DifficultyLevel)
class DifficultyLevelAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'status']
    list_filter = ['status']
    search_fields = ['name']

@admin.register(Workout)
class WorkoutAdmin(ImportExportModelAdmin):
    resource_class = WorkoutResource
    list_display = ['id', 'name', 'type', 'primary_muscle_group', 'equipment', 'is_global', 'status', 'created_at']
    list_filter = ['status', 'type', 'primary_muscle_group', 'equipment']
    search_fields = ['name', 'description']
    readonly_fields = ['created_at', 'updated_at']

    def is_global(self, obj):
        return obj.is_global
    is_global.boolean = True
    is_global.short_description = 'Global Library'


@admin.register(WorkoutGroup)
class WorkoutGroupAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'name_internal', 'trainer', 'type', 'status', 'created_at']
    list_filter = ['type', 'status']
    search_fields = ['name', 'trainer__first_name', 'trainer__last_name']


class WorkoutPlanDayInline(admin.TabularInline):
    model = WorkoutPlanDay
    extra = 0
    fields = ['day_number', 'title', 'notes']
    show_change_link = True


@admin.register(WorkoutPlan)
class WorkoutPlanAdmin(admin.ModelAdmin):
    list_display = ['id', 'plan_name', 'plan_name_internal', 'trainer', 'group', 'total_weeks', 'total_days', 'status']
    list_filter = ['status', 'group__type', 'program_goal', 'difficulty_level']
    search_fields = ['plan_name', 'plan_name_internal', 'trainer__first_name']
    readonly_fields = ['created_at', 'updated_at']
    inlines = [WorkoutPlanDayInline]


class ExerciseSetTemplateInline(admin.TabularInline):
    model = ExerciseSetTemplate
    extra = 0
    fields = ['set_number', 'target_reps', 'target_weight', 'rest_seconds']


@admin.register(WorkoutPlanExercise)
class WorkoutPlanExerciseAdmin(admin.ModelAdmin):
    list_display = ['id', 'plan_day', 'workout', 'order_index']
    list_filter = ['plan_day__plan']
    search_fields = ['workout__name']
    inlines = [ExerciseSetTemplateInline]


@admin.register(CustomerWorkoutPlan)
class CustomerWorkoutPlanAdmin(admin.ModelAdmin):
    list_display = ['id', 'customer', 'trainer', 'plan', 'start_date', 'status']
    list_filter = ['status', 'created_at']
    search_fields = ['customer__user__first_name', 'customer__user__last_name', 'trainer__first_name']


@admin.register(WorkoutSession)
class WorkoutSessionAdmin(admin.ModelAdmin):
    list_display = ['id', 'customer', 'plan_day', 'session_date', 'status', 'started_at', 'completed_at']
    list_filter = ['status', 'session_date']
    search_fields = ['customer__user__first_name', 'customer__user__last_name']


class ExerciseSetLogInline(admin.TabularInline):
    model = ExerciseSetLog
    extra = 1
    fields = ['set_number', 'reps', 'weight_kg', 'previous_weight_kg']


@admin.register(WorkoutLog)
class WorkoutLogAdmin(admin.ModelAdmin):
    list_display = ['id', 'customer', 'plan_exercise', 'logged_at']
    list_filter = ['logged_at']
    search_fields = ['customer__user__first_name', 'customer__user__last_name', 'plan_exercise__workout__name']
    readonly_fields = ['logged_at']
    inlines = [ExerciseSetLogInline]


@admin.register(PRRecord)
class PRRecordAdmin(admin.ModelAdmin):
    list_display = ['id', 'customer', 'workout', 'value', 'unit', 'verified_at', 'created_at']
    list_filter = ['unit', 'verified_at']
    search_fields = ['customer__user__first_name', 'customer__user__last_name', 'workout__name']
    readonly_fields = ['created_at']
