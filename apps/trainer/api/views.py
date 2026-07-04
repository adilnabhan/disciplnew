from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q

from apps.trainer.models import (
    MuscleGroup, Equipment, WorkoutGroup, Workout,
    WorkoutPlan, WorkoutPlanDay, WorkoutPlanExercise,
    ExerciseSetTemplate, CustomerWorkoutPlan,
    WorkoutLog, PRRecord, Trainer, TrainerSubscriptionPlan,
)
from apps.trainer.workout_models import WorkoutSession
from .serializers import (
    MuscleGroupSerializer, EquipmentSerializer, WorkoutGroupSerializer,
    WorkoutSerializer, WorkoutPlanSerializer, WorkoutPlanDetailSerializer,
    WorkoutPlanDaySerializer, WorkoutPlanExerciseSerializer,
    ExerciseSetTemplateSerializer, CustomerWorkoutPlanSerializer,
    WorkoutLogSerializer, PRRecordSerializer, TrainerSubscriptionPlanSerializer,
)


def _get_trainer(user):
    from apps.trainer.models import Trainer, OrganizationTrainerLink
    from apps.mentors.models import MentorProfile

    if not user or user.is_anonymous:
        raise Trainer.DoesNotExist("User is anonymous or not authenticated.")

    # Try to find existing Trainer profile
    trainer = Trainer.objects.filter(user=user).first()
    
    if not trainer and user.mobile_number:
        trainer = Trainer.objects.filter(mobile=user.mobile_number.as_international).first()
    if not trainer and user.email:
        trainer = Trainer.objects.filter(email=user.email).first()

    if not trainer:
        # Check if user is a trainer or mentor
        is_trainer = (getattr(user, 'user_role', None) == 35)
        mentor = MentorProfile.objects.filter(user=user).first()
        if not is_trainer and mentor and mentor.designation == MentorProfile.TRAINER:
            is_trainer = True
            
        if is_trainer or (mentor and mentor.organization):
            trainer = Trainer.objects.create(
                user=user,
                user_type='trainer',
                first_name=user.first_name,
                last_name=user.last_name,
                email=user.email,
                mobile=user.mobile_number.as_international if user.mobile_number else None
            )
            
    if trainer:
        if not trainer.user:
            trainer.user = user
            trainer.save()
            
        # Ensure OrganizationTrainerLink is approved if they have a MentorProfile organization
        mentor = MentorProfile.objects.filter(user=user).first()
        if mentor and mentor.organization:
            OrganizationTrainerLink.objects.get_or_create(
                trainer=trainer,
                organization=mentor.organization,
                defaults={'status': OrganizationTrainerLink.APPROVED, 'invited_by_org': True}
            )
    else:
        raise Trainer.DoesNotExist("Trainer profile not found for this user.")

    return trainer


def _get_trainer_or_none(user):
    try:
        return _get_trainer(user)
    except Trainer.DoesNotExist:
        return None


# --- Reference Data ---

class MuscleGroupListView(APIView):
    def get(self, request):
        qs = MuscleGroup.objects.filter(status=True)
        return Response(MuscleGroupSerializer(qs, many=True).data)


class EquipmentListView(APIView):
    def get(self, request):
        qs = Equipment.objects.filter(status=True)
        return Response(EquipmentSerializer(qs, many=True).data)


class WorkoutTypesView(APIView):
    def get(self, request):
        return Response([
            {'value': value, 'label': label}
            for value, label in Workout.TYPE_CHOICES
        ])


# --- Exercises (Workouts) ---

class WorkoutListCreateView(APIView):
    """
    Single API for exercises. Returns master exercises with overrides applied.
    Priority: trainer override → gym override → master
    Trainer-private exercises (created_by=trainer) are also included.
    """

    def get(self, request):
        from apps.trainer.models import GymWorkoutOverride, TrainerWorkoutOverride, OrganizationTrainerLink
        search = request.query_params.get('search', '')

        trainer = _get_trainer_or_none(request.user)

        linked_org_ids = []
        if trainer:
            linked_org_ids = list(
                OrganizationTrainerLink.objects.filter(
                    trainer=trainer, status=OrganizationTrainerLink.APPROVED
                ).values_list('organization_id', flat=True)
            )

        # Master + trainer-private exercises
        from django.db.models import Q
        global_exercises_q = Q(created_by__isnull=True) | Q(created_by__is_staff=True) | Q(created_by__is_superuser=True) | Q(created_by__user_role__in=[1, 5, 10, 15])
        qs = Workout.objects.filter(status=True).filter(
            global_exercises_q | Q(created_by=request.user)
        )
        if search:
            qs = qs.filter(name__icontains=search)

        # Build override lookup maps
        gym_overrides = {}
        if linked_org_ids:
            for ov in GymWorkoutOverride.objects.filter(
                organization_id__in=linked_org_ids
            ).select_related('organization'):
                # Last org wins if multiple gyms override same exercise
                gym_overrides[ov.workout_id] = ov

        trainer_overrides = {}
        if trainer:
            for ov in TrainerWorkoutOverride.objects.filter(trainer=trainer):
                trainer_overrides[ov.workout_id] = ov

        result = []
        for workout in qs:
            # Filter out exercises hidden by gym
            gym_ov = gym_overrides.get(workout.id)
            if gym_ov and not gym_ov.is_visible:
                continue

            trainer_ov = trainer_overrides.get(workout.id)

            # Resolve video_url: trainer override → gym override → master
            effective_video_url = (
                (trainer_ov.video_url if trainer_ov and trainer_ov.video_url else None) or
                (gym_ov.video_url if gym_ov and gym_ov.video_url else None) or
                workout.video_url
            )
            # Resolve instructions: same priority
            effective_instructions = (
                (trainer_ov.instructions if trainer_ov and trainer_ov.instructions else None) or
                (gym_ov.instructions if gym_ov and gym_ov.instructions else None) or
                workout.instructions
            )

            data = WorkoutSerializer(workout).data
            data['effective_video_url'] = effective_video_url
            data['effective_instructions'] = effective_instructions
            data['has_gym_override'] = gym_ov is not None
            data['has_trainer_override'] = trainer_ov is not None
            result.append(data)

        return Response(result)

    def post(self, request):
        """Create a trainer-private exercise."""
        data = request.data.copy() if hasattr(request.data, 'copy') else dict(request.data)

        custom_muscle = data.get('custom_muscle_group')
        if custom_muscle and str(data.get('primary_muscle_group')) == '-999':
            from apps.trainer.workout_models import MuscleGroup
            muscle_obj, _ = MuscleGroup.objects.get_or_create(name=custom_muscle.strip())
            data['primary_muscle_group'] = muscle_obj.id

        custom_equip = data.get('custom_equipment')
        if custom_equip and str(data.get('equipment')) == '-999':
            from apps.trainer.workout_models import Equipment
            equip_obj, _ = Equipment.objects.get_or_create(name=custom_equip.strip())
            data['equipment'] = equip_obj.id

        serializer = WorkoutSerializer(data=data)
        if serializer.is_valid():
            serializer.save(created_by=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class WorkoutDetailView(APIView):
    def get(self, request, pk):
        workout = Workout.objects.get(pk=pk)
        return Response(WorkoutSerializer(workout).data)

    def put(self, request, pk):
        workout = Workout.objects.get(pk=pk)
        serializer = WorkoutSerializer(workout, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        Workout.objects.get(pk=pk).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class TrainerWorkoutOverrideView(APIView):
    """
    Trainer sets or updates their override for a master exercise.
    PUT /trainer/exercises/<workout_id>/override/
    Body: { "video_url": "...", "instructions": "..." }
    DELETE to clear the override.
    """

    def put(self, request, workout_id):
        from apps.trainer.models import TrainerWorkoutOverride
        trainer = _get_trainer_or_none(request.user)
        if not trainer:
            return Response({'error': 'Trainer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        workout = Workout.objects.get(pk=workout_id)
        override, _ = TrainerWorkoutOverride.objects.update_or_create(
            workout=workout,
            trainer=trainer,
            defaults={
                'video_url': request.data.get('video_url'),
                'instructions': request.data.get('instructions'),
            }
        )
        return Response({
            'workout_id': workout.id,
            'workout_name': workout.name,
            'video_url': override.video_url,
            'instructions': override.instructions,
        })

    def delete(self, request, workout_id):
        from apps.trainer.models import TrainerWorkoutOverride
        trainer = _get_trainer_or_none(request.user)
        if not trainer:
            return Response({'error': 'Trainer profile not found.'}, status=status.HTTP_404_NOT_FOUND)
        TrainerWorkoutOverride.objects.filter(
            workout_id=workout_id, trainer=trainer
        ).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# --- Workout Groups ---

class WorkoutGroupListCreateView(APIView):
    """
    List workout groups.
    source=trainer → trainer's own groups only
    source=gym     → gym groups from linked orgs only
    omit           → trainer's own + gym groups (default)
    """

    def get(self, request):
        try:
            trainer = _get_trainer(request.user)
        except Trainer.DoesNotExist:
            return Response({"error": "Trainer profile not found for this user."}, status=status.HTTP_404_NOT_FOUND)

        group_type = request.query_params.get('type')
        search = request.query_params.get('search', '')
        source = request.query_params.get('source')

        linked_org_ids = list(
            OrganizationTrainerLink.objects.filter(
                trainer=trainer, status=OrganizationTrainerLink.APPROVED
            ).values_list('organization_id', flat=True)
        )

        if source == 'trainer':
            qs = WorkoutGroup.objects.filter(trainer=trainer, status=True)
        elif source == 'gym':
            qs = WorkoutGroup.objects.filter(organization_id__in=linked_org_ids, status=True)
        else:
            qs = WorkoutGroup.objects.filter(status=True).filter(
                Q(trainer=trainer) | Q(organization_id__in=linked_org_ids)
            )

        if group_type:
            qs = qs.filter(type=group_type)
        if search:
            qs = qs.filter(name__icontains=search)

        return Response(WorkoutGroupSerializer(qs.distinct(), many=True).data)

    def post(self, request):
        try:
            trainer = _get_trainer(request.user)
        except Trainer.DoesNotExist:
            return Response({"error": "Trainer profile not found for this user."}, status=status.HTTP_404_NOT_FOUND)

        serializer = WorkoutGroupSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(trainer=trainer)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class WorkoutGroupDetailView(APIView):
    def put(self, request, pk):
        group = WorkoutGroup.objects.get(pk=pk)
        serializer = WorkoutGroupSerializer(group, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        WorkoutGroup.objects.get(pk=pk).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# --- Workout Plans ---

class WorkoutPlanListCreateView(APIView):
    """
    List workout plans.
    source=trainer → trainer's own plans only
    source=gym     → gym plans from linked orgs only
    omit           → trainer's own + gym plans (default)
    """

    def get(self, request):
        try:
            trainer = _get_trainer(request.user)
        except Trainer.DoesNotExist:
            return Response({"error": "Trainer profile not found for this user."}, status=status.HTTP_404_NOT_FOUND)

        group_id = request.query_params.get('group')
        search = request.query_params.get('search', '')
        source = request.query_params.get('source')

        linked_org_ids = list(
            OrganizationTrainerLink.objects.filter(
                trainer=trainer, status=OrganizationTrainerLink.APPROVED
            ).values_list('organization_id', flat=True)
        )

        if source == 'trainer':
            qs = WorkoutPlan.objects.filter(trainer=trainer, status=True, customer__isnull=True)
        elif source == 'gym':
            qs = WorkoutPlan.objects.filter(organization_id__in=linked_org_ids, status=True, customer__isnull=True)
        elif source == 'library':
            qs = WorkoutPlan.objects.filter(status=True, customer__isnull=True).filter(
                Q(trainer__isnull=True) | Q(organization_id__in=linked_org_ids)
            )
        else:
            qs = WorkoutPlan.objects.filter(status=True, customer__isnull=True).filter(
                Q(trainer=trainer) | Q(organization_id__in=linked_org_ids) | Q(trainer__isnull=True)
            )

        if group_id:
            qs = qs.filter(group_id=group_id)
        if search:
            qs = qs.filter(plan_name__icontains=search)

        return Response(WorkoutPlanSerializer(qs.distinct(), many=True).data)

    def post(self, request):
        try:
            trainer = _get_trainer(request.user)
        except Trainer.DoesNotExist:
            return Response({"error": "Trainer profile not found for this user."}, status=status.HTTP_404_NOT_FOUND)
        serializer = WorkoutPlanSerializer(data=request.data)
        if serializer.is_valid():
            plan = serializer.save(trainer=trainer)
            total_days = plan.total_days or 1
            for day_num in range(1, total_days + 1):
                WorkoutPlanDay.objects.get_or_create(plan=plan, day_number=day_num, defaults={'title': f'Day {day_num}'})
            return Response(WorkoutPlanSerializer(plan).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class WorkoutPlanDetailView(APIView):
    def get(self, request, pk):
        plan = WorkoutPlan.objects.get(pk=pk)
        return Response(WorkoutPlanDetailSerializer(plan).data)

    def put(self, request, pk):
        plan = WorkoutPlan.objects.get(pk=pk)
        serializer = WorkoutPlanSerializer(plan, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        WorkoutPlan.objects.get(pk=pk).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# --- Plan Days & Exercises ---

class WorkoutPlanDayListCreateView(APIView):
    """List or add days to a plan (used for multi-day plans)."""

    def get(self, request, plan_id):
        days = WorkoutPlanDay.objects.filter(plan_id=plan_id).order_by('day_number')
        return Response(WorkoutPlanDaySerializer(days, many=True).data)

    def post(self, request, plan_id):
        plan = WorkoutPlan.objects.get(pk=plan_id)
        serializer = WorkoutPlanDaySerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(plan=plan)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class WorkoutPlanDayDetailView(APIView):
    def put(self, request, plan_id, day_id):
        day = WorkoutPlanDay.objects.get(pk=day_id, plan_id=plan_id)
        serializer = WorkoutPlanDaySerializer(day, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, plan_id, day_id):
        WorkoutPlanDay.objects.get(pk=day_id, plan_id=plan_id).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class PlanDayExerciseListCreateView(APIView):
    """Add/list exercises for a plan day."""

    def get(self, request, day_id):
        exercises = WorkoutPlanExercise.objects.filter(plan_day_id=day_id).order_by('order_index')
        return Response(WorkoutPlanExerciseSerializer(exercises, many=True).data)

    def post(self, request, day_id):
        day = WorkoutPlanDay.objects.get(pk=day_id)
        serializer = WorkoutPlanExerciseSerializer(data=request.data)
        if serializer.is_valid():
            plan_exercise = serializer.save(plan_day=day)
            # create set templates if provided
            sets = request.data.get('sets', [])
            for s in sets:
                ExerciseSetTemplate.objects.create(plan_exercise=plan_exercise, **s)
            return Response(WorkoutPlanExerciseSerializer(plan_exercise).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class PlanDayExerciseDetailView(APIView):
    def put(self, request, day_id, exercise_id):
        exercise = WorkoutPlanExercise.objects.get(pk=exercise_id, plan_day_id=day_id)
        serializer = WorkoutPlanExerciseSerializer(exercise, data=request.data, partial=True)
        if serializer.is_valid():
            plan_exercise = serializer.save()
            if 'sets' in request.data:
                # Delete existing set templates
                ExerciseSetTemplate.objects.filter(plan_exercise=plan_exercise).delete()
                # Create new set templates
                sets = request.data.get('sets', [])
                for s in sets:
                    s_data = {
                        'set_number': s.get('set_number'),
                        'target_reps': s.get('target_reps'),
                        'target_weight': s.get('target_weight'),
                        'rest_seconds': s.get('rest_seconds'),
                    }
                    ExerciseSetTemplate.objects.create(plan_exercise=plan_exercise, **s_data)
            return Response(WorkoutPlanExerciseSerializer(plan_exercise).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, day_id, exercise_id):
        WorkoutPlanExercise.objects.get(pk=exercise_id, plan_day_id=day_id).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class ReorderPlanDayExercisesView(APIView):
    """Reorder exercises within a day. Body: [{id, order_index}, ...]"""

    def post(self, request, day_id):
        items = request.data
        if not isinstance(items, list):
            return Response(
                {'error': 'Expected a list of {id, order_index} objects.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        for item in items:
            if 'id' not in item or 'order_index' not in item:
                return Response(
                    {'error': 'Each item must have id and order_index.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            WorkoutPlanExercise.objects.filter(
                pk=item['id'], plan_day_id=day_id
            ).update(order_index=item['order_index'])
        return Response({'message': 'Reordered'})


# --- Assign Plan to Customer ---

class AssignWorkoutPlanView(APIView):
    """Assign a workout plan to a customer. Also lists customers with assignment status."""

    def get(self, request, plan_id):
        from apps.customers.models import Customer
        from apps.trainer.models import OrganizationTrainerLink
        search = request.query_params.get('search', '')
        try:
            trainer = _get_trainer(request.user)
        except Trainer.DoesNotExist:
            return Response({"error": "Trainer profile not found for this user."}, status=status.HTTP_404_NOT_FOUND)

        try:
            plan = WorkoutPlan.objects.get(pk=plan_id)
        except WorkoutPlan.DoesNotExist:
            return Response({"error": "Workout plan not found."}, status=status.HTTP_404_NOT_FOUND)

        linked_org_ids = list(
            OrganizationTrainerLink.objects.filter(
                trainer=trainer, status=OrganizationTrainerLink.APPROVED
            ).values_list('organization_id', flat=True)
        )

        if plan.organization_id:
            customers = Customer.objects.filter(
                organization_id=plan.organization_id
            ).filter(
                Q(organization_id__in=linked_org_ids) |
                Q(trainer=trainer) |
                Q(id__in=CustomerWorkoutPlan.objects.filter(trainer=trainer).values_list('customer_id', flat=True))
            )
        else:
            customers = Customer.objects.filter(
                Q(organization_id__in=linked_org_ids) |
                Q(trainer=trainer) |
                Q(id__in=CustomerWorkoutPlan.objects.filter(trainer=trainer).values_list('customer_id', flat=True))
            )

        customers = customers.distinct().select_related('user')

        if search:
            customers = customers.filter(
                Q(user__first_name__icontains=search) | Q(user__last_name__icontains=search)
            )

        assigned_ids = CustomerWorkoutPlan.objects.filter(
            plan_id=plan_id, status='active'
        ).values_list('customer_id', flat=True)

        result = []
        for c in customers:
            result.append({
                'customer_id': c.id,
                'name': f"{c.user.first_name} {c.user.last_name}",
                'mobile': str(c.user.mobile_number) if c.user.mobile_number else None,
                'profile_picture': c.user.profile_picture.url if c.user.profile_picture else None,
                'is_assigned': c.id in assigned_ids,
            })
        return Response(result)

    def post(self, request, plan_id):
        trainer = None
        trainer_id = request.data.get('trainer_id')
        if trainer_id:
            try:
                trainer = Trainer.objects.get(id=trainer_id)
            except Trainer.DoesNotExist:
                return Response({"error": "Trainer not found."}, status=status.HTTP_404_NOT_FOUND)

        if not trainer:
            try:
                trainer = _get_trainer(request.user)
            except Trainer.DoesNotExist:
                if getattr(request.user, 'user_role', None) not in [20, 25]:
                    return Response({"error": "Trainer profile not found for this user."}, status=status.HTTP_404_NOT_FOUND)

        try:
            plan = WorkoutPlan.objects.get(pk=plan_id)
        except WorkoutPlan.DoesNotExist:
            return Response({"error": "Workout plan not found."}, status=status.HTTP_404_NOT_FOUND)

        customer_id = request.data.get('customer_id')
        if not customer_id:
            return Response({'error': 'customer_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

        from apps.customers.models import Customer
        try:
            customer = Customer.objects.get(id=customer_id)
        except Customer.DoesNotExist:
            return Response({'error': 'Customer not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Enforce same fitness center (organization) requirement
        if plan.organization_id:
            if customer.organization_id != plan.organization_id:
                return Response(
                    {'error': 'This workout plan belongs to a specific fitness center and can only be assigned to customers of that same fitness center.'},
                    status=status.HTTP_400_BAD_REQUEST
                )

        # Enforce that the trainer has access/permission to assign to this customer
        if trainer:
            from apps.trainer.models import OrganizationTrainerLink
            linked_org_ids = list(
                OrganizationTrainerLink.objects.filter(
                    trainer=trainer, status=OrganizationTrainerLink.APPROVED
                ).values_list('organization_id', flat=True)
            )
            has_access = (
                (customer.organization_id in linked_org_ids) or
                (customer.trainer_id == trainer.id) or
                CustomerWorkoutPlan.objects.filter(trainer=trainer, customer=customer).exists()
            )
            if not has_access:
                return Response(
                    {'error': 'You do not have permission to assign plans to this customer.'},
                    status=status.HTTP_403_FORBIDDEN
                )

        title = request.data.get('title')
        if not title:
            title = plan.plan_name

        # Auto-create missing WorkoutPlanDay records for plans that were created
        # before the auto-create signal was deployed
        total_days = plan.total_days or (plan.total_weeks * 7) or 1
        existing_day_numbers = set(
            WorkoutPlanDay.objects.filter(plan=plan).values_list('day_number', flat=True)
        )
        missing_days = [
            WorkoutPlanDay(plan=plan, day_number=day_num, title=f"Day {day_num}")
            for day_num in range(1, total_days + 1)
            if day_num not in existing_day_numbers
        ]
        if missing_days:
            WorkoutPlanDay.objects.bulk_create(missing_days)

        obj = CustomerWorkoutPlan.objects.create(
            customer=customer,
            plan_id=plan_id,
            trainer=trainer,
            title=title,
            status='active'
        )

        # Notify Customer about workout assignment
        if customer.user:
            from apps.communication.notifications import send_push_notification
            trainer_name = f"{trainer.first_name} {trainer.last_name}".strip() if trainer else "Your Trainer"
            assigned_date = obj.created_at.strftime('%Y-%m-%d') if getattr(obj, 'created_at', None) else timezone.now().strftime('%Y-%m-%d')
            send_push_notification(
                user=customer.user,
                title="New Workout Assigned",
                body="Your trainer has assigned a new workout plan.",
                data={
                    "workout_name": title,
                    "trainer_name": trainer_name,
                    "assigned_date": assigned_date
                }
            )

        return Response(CustomerWorkoutPlanSerializer(obj).data, status=status.HTTP_201_CREATED)


# --- Trainer's Gym Customers ---

class TrainerCustomerListView(APIView):
    """List customers who have an active membership at the trainer's linked gym(s)."""

    def get(self, request):
        from apps.customers.models import Customer, CustomerMembership
        from apps.utils.pagination import CustomPagination

        trainer = _get_trainer_or_none(request.user)
        if not trainer:
            return Response({'error': 'Trainer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        linked_org_ids = list(
            OrganizationTrainerLink.objects.filter(
                trainer=trainer, status=OrganizationTrainerLink.APPROVED
            ).values_list('organization_id', flat=True)
        )

        search = request.query_params.get('search', '').strip()
        membership_status = request.query_params.get('status', 'active')

        # Get active customer IDs from CustomerWorkoutPlan assigned by/to this trainer
        assigned_plan_customer_ids = list(
            CustomerWorkoutPlan.objects.filter(
                trainer=trainer, status='active'
            ).values_list('customer_id', flat=True)
        )

        if not linked_org_ids:
            customers = Customer.objects.filter(
                Q(trainer=trainer) | Q(id__in=assigned_plan_customer_ids)
            ).select_related('user', 'trainer__user').distinct()
        else:
            customers = Customer.objects.filter(
                Q(organization_id__in=linked_org_ids) | Q(trainer=trainer) | Q(id__in=assigned_plan_customer_ids)
            ).select_related('user', 'trainer__user').distinct()

        if membership_status == 'active':
            customers = customers.filter(
                memberships__status__in=[CustomerMembership.ACTIVE, CustomerMembership.EXPIRED]
            ).distinct()

        if search:
            customers = customers.filter(
                Q(user__first_name__icontains=search) |
                Q(user__last_name__icontains=search) |
                Q(user__mobile_number__icontains=search)
            )

        paginator = CustomPagination()
        page = paginator.paginate_queryset(customers, request)

        result = []
        for c in page:
            u = c.user
            
            # Map target goal to a fitness category (Strength, Yoga, Cardio, etc.)
            category = 'Strength'
            if c.target_goal:
                first_goal = c.target_goal[0].lower()
                if 'flexibility' in first_goal:
                    category = 'Yoga'
                elif 'stamina' in first_goal or 'endurance' in first_goal:
                    category = 'Cardio'
                elif 'weight' in first_goal or 'muscle' in first_goal:
                    category = 'Strength'

            from django.utils import timezone
            today = timezone.localdate()

            # 1. Today's workout name
            today_workout_name = None
            today_session = WorkoutSession.objects.filter(
                customer=c,
                session_date=today
            ).last()
            
            if today_session:
                today_workout_name = today_session.title or (today_session.plan_day.title if today_session.plan_day else None)
            else:
                cwp = CustomerWorkoutPlan.objects.filter(customer=c, status='active').select_related('plan').last()
                if cwp:
                    day_offset = (today - cwp.start_date).days + 1 if cwp.start_date else 1
                    plan_day = WorkoutPlanDay.objects.filter(plan=cwp.plan, day_number=day_offset).first()
                    if plan_day:
                        today_workout_name = plan_day.title
                    else:
                        plan_day_first = WorkoutPlanDay.objects.filter(plan=cwp.plan).order_by('day_number').first()
                        if plan_day_first:
                            today_workout_name = plan_day_first.title
                        else:
                            today_workout_name = cwp.plan.plan_name

            # 2. Previous workout name and time
            previous_workout_name = None
            previous_workout_time = None
            
            prev_session = WorkoutSession.objects.filter(
                customer=c,
                status='completed',
                session_date__lt=today
            ).order_by('-session_date', '-completed_at').first()
            
            if prev_session:
                previous_workout_name = prev_session.title or (prev_session.plan_day.title if prev_session.plan_day else None)
                delta_days = (today - prev_session.session_date).days
                if delta_days == 1:
                    previous_workout_time = "Yesterday"
                else:
                    previous_workout_time = f"{delta_days} days ago"

            first_goal_display = ''
            if c.target_goal and len(c.target_goal) > 0:
                first_goal_display = c.target_goal[0].replace('_', ' ').title()

            result.append({
                'customer_id': c.id,
                'user_id': u.id if u else None,
                'name': f"{u.first_name} {u.last_name}".strip() if u else '',
                'mobile': str(u.mobile_number) if u and u.mobile_number else None,
                'profile_picture': u.profile_picture.url if u and u.profile_picture else None,
                'is_active_member': c.is_active_member,
                'trainer_id': c.trainer_id,
                'trainer_name': f"{c.trainer.user.first_name} {c.trainer.user.last_name}".strip() if c.trainer and c.trainer.user else None,
                'is_assigned_to_me': c.trainer_id == trainer.id,
                'target_goal': first_goal_display,
                'category': category,
                'organization_name': c.organization.name if c.organization else 'Direct Client',
                'last_active': u.last_login.strftime('%I:%M %p') if u and u.last_login else '05:30 AM',
                'today_workout_name': today_workout_name,
                'previous_workout_name': previous_workout_name,
                'previous_workout_time': previous_workout_time,
            })

        return paginator.get_paginated_response(result)


class TrainerClientDetailView(APIView):
    """Full client detail screen for trainer — profile, membership, assigned plans, PR records."""

    def get(self, request, customer_id):
        from apps.customers.models import Customer, CustomerMembership
        from apps.trainer.models import OrganizationTrainerLink
        from collections import defaultdict

        try:
            customer = Customer.objects.select_related('user').get(id=customer_id)
        except Customer.DoesNotExist:
            return Response({'error': 'Customer not found.'}, status=status.HTTP_404_NOT_FOUND)

        u = customer.user

        # ── Profile ───────────────────────────────────────────────────────
        trainer = _get_trainer_or_none(request.user)
        is_assigned_to_me = (trainer is not None) and (customer.trainer_id == trainer.id)

        profile = {
            'customer_id': customer.id,
            'user_id': u.id if u else None,
            'name': u.full_name if u else '',
            'mobile': str(u.mobile_number) if u and u.mobile_number else None,
            'email': u.email if u else None,
            'gender': u.gender if u else None,
            'date_of_birth': u.date_of_birth if u else None,
            'blood_group': u.blood_group if u else None,
            'profile_picture': u.profile_picture.url if u and u.profile_picture else None,
            'height': customer.height,
            'weight': customer.weight,
            'bmi': customer.bmi,
            'fitness_level': customer.fitness_level,
            'target_goal': customer.target_goal,
            'injuries': list(customer.injuries.values_list('name', flat=True)),
            'medical_conditions': list(customer.medical_conditions.values_list('name', flat=True)),
            'is_active_member': customer.is_active_member,
            'trainer_notes': customer.trainer_notes,
            'trainer_id': customer.trainer_id,
            'trainer_name': f"{customer.trainer.user.first_name} {customer.trainer.user.last_name}".strip() if customer.trainer and customer.trainer.user else None,
            'is_assigned_to_me': is_assigned_to_me,
        }

        # ── Active Membership ─────────────────────────────────────────────
        active_membership = CustomerMembership.objects.filter(
            customer=customer, status=CustomerMembership.ACTIVE, is_active=True
        ).select_related('membership__organization').first()

        membership = None
        if active_membership:
            membership = {
                'plan_name': active_membership.membership.name,
                'organization': active_membership.membership.organization.name,
                'start_date': active_membership.start_date,
                'end_date': active_membership.end_date,
                'status': active_membership.status,
                'amount': active_membership.amount,
            }

        # ── Assigned Workout Plans ────────────────────────────────────────
        assigned_plans = CustomerWorkoutPlan.objects.filter(
            customer=customer, status='active'
        ).select_related('plan').order_by('-created_at')

        plans = [{
            'customer_workout_plan_id': cwp.id,
            'plan_id': cwp.plan.id,
            'plan_name': cwp.plan.plan_name,
            'start_date': cwp.start_date,
            'total_days': cwp.plan.total_days,
            'status': cwp.status,
        } for cwp in assigned_plans]

        # ── PR Records ────────────────────────────────────────────────────
        pr_records = PRRecord.objects.filter(
            customer=customer
        ).select_related('workout').order_by('-created_at')

        prs = [{
            'workout_name': pr.workout.name,
            'value': pr.value,
            'unit': pr.unit,
            'verified_at': pr.verified_at,
        } for pr in pr_records]

        # ── Recent Workout Sessions ───────────────────────────────────────
        from apps.trainer.workout_models import WorkoutSession
        recent_sessions = WorkoutSession.objects.filter(
            customer=customer, status='completed'
        ).order_by('-session_date')[:5]

        sessions = [{
            'session_date': s.session_date,
            'plan_day_title': s.plan_day.title,
            'completed_at': s.completed_at,
        } for s in recent_sessions]

        return Response({
            'profile': profile,
            'membership': membership,
            'assigned_plans': plans,
            'pr_records': prs,
            'recent_sessions': sessions,
        })

    def put(self, request, customer_id):
        from apps.customers.models import Customer
        try:
            customer = Customer.objects.get(id=customer_id)
        except Customer.DoesNotExist:
            return Response({'error': 'Customer not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Update the trainer_notes field
        notes = request.data.get('trainer_notes')
        customer.trainer_notes = notes
        customer.save(update_fields=['trainer_notes'])

        return Response({
            'success': True,
            'trainer_notes': customer.trainer_notes
        }, status=status.HTTP_200_OK)


# --- Workout Logs ---

class WorkoutLogCreateView(APIView):
    """Log a completed exercise with sets."""

    def post(self, request):
        from apps.customers.models import Customer
        serializer = WorkoutLogSerializer(data=request.data)
        if serializer.is_valid():
            customer = Customer.objects.get(user=request.user)
            serializer.save(customer=customer)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class CustomerWorkoutHistoryView(APIView):
    """Workout history for a customer grouped by date."""

    def get(self, request, customer_id):
        from collections import defaultdict
        from datetime import date
        
        logs = (
            WorkoutLog.objects
            .filter(customer_id=customer_id, session__status='completed')
            .select_related('plan_exercise__workout', 'session')
            .order_by('-logged_at')
        )

        # Date range filtering
        start_date_str = request.query_params.get('start_date')
        end_date_str = request.query_params.get('end_date')

        if start_date_str:
            try:
                logs = logs.filter(logged_at__date__gte=date.fromisoformat(start_date_str))
            except ValueError:
                pass

        if end_date_str:
            try:
                logs = logs.filter(logged_at__date__lte=date.fromisoformat(end_date_str))
            except ValueError:
                pass

        grouped = defaultdict(list)
        for log in logs:
            date_key = log.logged_at.date().isoformat()
            grouped[date_key].append(WorkoutLogSerializer(log).data)

        result = [{'date': d, 'logs': v} for d, v in sorted(grouped.items(), reverse=True)]
        return Response(result)


# --- PR Records / General Stats ---

class PRRecordListCreateView(APIView):
    def get(self, request, customer_id):
        records = PRRecord.objects.filter(customer_id=customer_id).select_related('workout')
        return Response(PRRecordSerializer(records, many=True).data)

    def post(self, request, customer_id):
        from apps.customers.models import Customer
        data = request.data.copy()
        data['customer'] = customer_id
        serializer = PRRecordSerializer(data=data)
        if serializer.is_valid():
            customer = Customer.objects.get(id=customer_id)
            serializer.save(customer=customer)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class TrainerSubscriptionPlansView(APIView):
    """List all active Discipl subscription plans available for trainers."""

    def get(self, request):
        plans = TrainerSubscriptionPlan.objects.filter(is_active=True)
        return Response(TrainerSubscriptionPlanSerializer(plans, many=True).data)


from apps.trainer.models import OrganizationTrainerLink
from .serializers import OrganizationTrainerLinkSerializer
from django.utils import timezone


class TrainerLinkRequestView(APIView):
    """Trainer sends a join request to an organization."""

    def post(self, request):
        trainer = _get_trainer_or_none(request.user)
        if not trainer:
            return Response({'error': 'Trainer profile not found.'}, status=status.HTTP_400_BAD_REQUEST)

        organization_id = request.data.get('organization_id')
        if not organization_id:
            return Response({'error': 'organization_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

        link, created = OrganizationTrainerLink.objects.get_or_create(
            trainer=trainer,
            organization_id=organization_id,
            defaults={'status': OrganizationTrainerLink.PENDING, 'invited_by_org': False}
        )

        if not created:
            if link.status == OrganizationTrainerLink.APPROVED:
                return Response({'error': 'Already linked to this organization.'}, status=status.HTTP_400_BAD_REQUEST)
            if link.status == OrganizationTrainerLink.PENDING and link.invited_by_org:
                return Response({'error': 'Gym has already sent you an invite. Please respond to it.'}, status=status.HTTP_400_BAD_REQUEST)
            # Re-send rejected request
            link.status = OrganizationTrainerLink.PENDING
            link.invited_by_org = False
            link.responded_at = None
            link.rejection_reason = None
            link.save()

        return Response(OrganizationTrainerLinkSerializer(link).data, status=status.HTTP_201_CREATED)

    def get(self, request):
        """Trainer views their own link requests and gym invites."""
        trainer = _get_trainer_or_none(request.user)
        if not trainer:
            return Response({'error': 'Trainer profile not found.'}, status=status.HTTP_400_BAD_REQUEST)

        links = OrganizationTrainerLink.objects.filter(trainer=trainer).select_related('organization')
        return Response(OrganizationTrainerLinkSerializer(links, many=True).data)

    def put(self, request):
        """Trainer responds to a gym invite (accept or reject)."""
        trainer = _get_trainer_or_none(request.user)
        if not trainer:
            return Response({'error': 'Trainer profile not found.'}, status=status.HTTP_400_BAD_REQUEST)

        link_id = request.data.get('link_id')
        action = request.data.get('action')  # 'accept' or 'reject'

        if not link_id or action not in ('accept', 'reject'):
            return Response({'error': 'link_id and action (accept/reject) are required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            link = OrganizationTrainerLink.objects.get(id=link_id, trainer=trainer, invited_by_org=True)
        except OrganizationTrainerLink.DoesNotExist:
            return Response({'error': 'Invite not found.'}, status=status.HTTP_404_NOT_FOUND)

        if link.status != OrganizationTrainerLink.PENDING:
            return Response({'error': f'Invite already {link.status}.'}, status=status.HTTP_400_BAD_REQUEST)

        link.status = OrganizationTrainerLink.APPROVED if action == 'accept' else OrganizationTrainerLink.REJECTED
        link.responded_at = timezone.now()
        link.rejection_reason = request.data.get('rejection_reason') if action == 'reject' else None
        link.save()

        return Response(OrganizationTrainerLinkSerializer(link).data)


class OrganizationLinkRequestsView(APIView):
    """Organization views and manages incoming trainer/dietitian link requests."""

    def get(self, request, organization_id):
        """List all pending requests for an organization."""
        status_filter = request.query_params.get('status', OrganizationTrainerLink.PENDING)
        links = OrganizationTrainerLink.objects.filter(
            organization_id=organization_id,
            status=status_filter
        ).select_related('trainer')
        return Response(OrganizationTrainerLinkSerializer(links, many=True).data)

    def put(self, request, organization_id, link_id):
        """Approve or reject a link request."""
        action = request.data.get('action')  # 'approve' or 'reject'
        if action not in ('approve', 'reject'):
            return Response({'error': "action must be 'approve' or 'reject'."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            link = OrganizationTrainerLink.objects.get(id=link_id, organization_id=organization_id)
        except OrganizationTrainerLink.DoesNotExist:
            return Response({'error': 'Request not found.'}, status=status.HTTP_404_NOT_FOUND)

        if link.status != OrganizationTrainerLink.PENDING:
            return Response({'error': 'Request already responded to.'}, status=status.HTTP_400_BAD_REQUEST)

        link.status = OrganizationTrainerLink.APPROVED if action == 'approve' else OrganizationTrainerLink.REJECTED
        link.responded_at = timezone.now()
        link.rejection_reason = request.data.get('rejection_reason') if action == 'reject' else None
        link.save()

        return Response(OrganizationTrainerLinkSerializer(link).data)


class TrainerDashboardView(APIView):
    """Single API for the trainer dashboard screen."""

    def get(self, request):
        from django.db.models import Count, Avg, Sum
        from datetime import timedelta
        from apps.customers.models import Customer, CustomerMembership
        from apps.trainer.models import OrganizationTrainerLink
        from apps.subscription.models import OrganizationTransaction
        from apps.user.models import User

        trainer = _get_trainer_or_none(request.user)
        if not trainer:
            return Response({'error': 'Trainer profile not found.'}, status=status.HTTP_400_BAD_REQUEST)

        now = timezone.now()
        today = now.date()

        # ── Approved linked organizations ─────────────────────────────────
        approved_links = OrganizationTrainerLink.objects.filter(
            trainer=trainer, status=OrganizationTrainerLink.APPROVED
        ).select_related('organization')
        linked_org_ids = list(approved_links.values_list('organization_id', flat=True))

        # ── Account switching list ────────────────────────────────────────
        accounts = [{
            'type': 'trainer',
            'id': trainer.id,
            'name': f"{trainer.first_name} {trainer.last_name}".strip(),
            'profile_image': trainer.profile_image.url if trainer.profile_image else None,
        }]
        for link in approved_links:
            org = link.organization
            accounts.append({
                'type': 'organization',
                'id': org.id,
                'name': org.name,
                'logo': org.logo.url if org.logo else None,
            })

        # ── Customers via linked organizations ────────────────────────────
        # Customers directly assigned workout plans by this trainer
        directly_assigned_user_ids = CustomerWorkoutPlan.objects.filter(
            trainer=trainer
        ).values_list('customer_id', flat=True)

        # All customers reachable: org-linked OR directly assigned
        org_customers = Customer.objects.filter(
            Q(organization_id__in=linked_org_ids) |
            Q(user_id__in=directly_assigned_user_ids)
        ).distinct()
        # ── Stats ─────────────────────────────────────────────────────────
        active_clients = org_customers.filter(is_active_member=True).count()

        pending_verifications = CustomerMembership.objects.filter(
            customer__in=org_customers,
            status=CustomerMembership.PENDING
        ).count()

        workout_plans_created = WorkoutPlan.objects.filter(trainer=trainer, status=True).count()

        avg_rating = org_customers.aggregate(r=Avg('reviews__rating'))['r']

        # ── Member Insights — upcoming birthdays (next 7 days) ────────────
        upcoming_birthdays = []
        for customer in org_customers.select_related('user').filter(user__date_of_birth__isnull=False):
            dob = customer.user.date_of_birth
            try:
                birthday_this_year = dob.replace(year=today.year)
            except ValueError:
                birthday_this_year = dob.replace(year=today.year, day=28)
            if birthday_this_year < today:
                try:
                    birthday_this_year = dob.replace(year=today.year + 1)
                except ValueError:
                    birthday_this_year = dob.replace(year=today.year + 1, day=28)
            days_until = (birthday_this_year - today).days
            if 0 <= days_until <= 7:
                upcoming_birthdays.append({
                    'customer_id': customer.id,
                    'name': customer.user.full_name,
                    'date_of_birth': dob.strftime('%d %B'),
                    'days_until': days_until,
                    'profile_picture': customer.user.profile_picture.url if customer.user.profile_picture else None,
                })
        upcoming_birthdays.sort(key=lambda x: x['days_until'])

        # ── Performance Overview — last 6 months earnings ─────────────────
        monthly_earnings = []
        for i in range(5, -1, -1):
            month_start = (now.replace(day=1) - timedelta(days=i * 30)).replace(
                day=1, hour=0, minute=0, second=0, microsecond=0
            )
            month_end = month_start.replace(
                month=month_start.month % 12 + 1,
                year=month_start.year + (1 if month_start.month == 12 else 0)
            )
            total = OrganizationTransaction.objects.filter(
                trainer=trainer,
                status='Successful',
                payment_date__gte=month_start,
                payment_date__lt=month_end,
            ).aggregate(t=Sum('amount'))['t'] or 0
            monthly_earnings.append({'month': month_start.strftime('%b'), 'amount': float(total)})

        # ── Clients Performance leaderboard — top 3 by completed sessions ─
        org_customer_ids = list(org_customers.values_list('id', flat=True))

        top_entries = (
            WorkoutSession.objects.filter(
                customer_id__in=org_customer_ids,
                status='completed'
            )
            .values('customer_id')
            .annotate(sessions_completed=Count('id'))
            .order_by('-sessions_completed')[:3]
        )

        leaderboard = []
        for rank, entry in enumerate(top_entries, start=1):
            from apps.customers.models import Customer
            cust = Customer.objects.select_related('user').get(id=entry['customer_id'])
            leaderboard.append({
                'rank': rank,
                'customer_id': cust.id,
                'name': cust.user.full_name if cust.user else '',
                'sessions_completed': entry['sessions_completed'],
                'profile_picture': request.build_absolute_uri(
                    cust.user.profile_picture.url
                ) if cust.user and cust.user.profile_picture else None,
            })

        return Response({
            'accounts': accounts,
            'stats': {
                'active_clients': active_clients,
                'pending_verifications': pending_verifications,
                'workout_plans_created': workout_plans_created,
                'average_rating': round(avg_rating, 1) if avg_rating else 0.0,
            },
            'banners': [
                "https://s3.ap-southeast-1.wasabisys.com/discipl-habitoz/media/banner_images/gym_banner1.png",
                "https://s3.ap-southeast-1.wasabisys.com/discipl-habitoz/media/banner_images/gym_banner2.png",
                "https://s3.ap-southeast-1.wasabisys.com/discipl-habitoz/media/banner_images/gymbanner3.png",
            ],
            'member_insights': {
                'upcoming_birthdays': upcoming_birthdays,
            },
            'performance_overview': {
                'monthly_earnings': monthly_earnings,
                'current_month': monthly_earnings[-1]['amount'],
                'total': sum(m['amount'] for m in monthly_earnings),
            },
            'clients_performance': {
                'leaderboard': leaderboard,
                'total_clients': active_clients,
            },
        })


class TrainerReviewView(APIView):
    """Customer submits or updates a review/rating for a trainer."""

    def post(self, request, trainer_id):
        from apps.customers.models import Customer
        from apps.trainer.models import TrainerReview

        customer = getattr(request.user, 'customer', None)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_400_BAD_REQUEST)

        rating = request.data.get('rating')
        comment = request.data.get('comment', '')

        if not rating or not (1 <= int(rating) <= 5):
            return Response({'error': 'rating must be between 1 and 5.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            trainer = Trainer.objects.get(id=trainer_id)
        except Trainer.DoesNotExist:
            return Response({'error': 'Trainer not found.'}, status=status.HTTP_404_NOT_FOUND)

        review, created = TrainerReview.objects.update_or_create(
            trainer=trainer,
            customer=customer,
            defaults={'rating': int(rating), 'comment': comment}
        )

        # Update cached avg rating on trainer
        from django.db.models import Avg
        avg = TrainerReview.objects.filter(trainer=trainer).aggregate(a=Avg('rating'))['a'] or 0
        # Store on user model if needed — for now just return
        return Response({
            'id': review.id,
            'rating': review.rating,
            'comment': review.comment,
            'created': not created,
            'average_rating': round(avg, 1),
        }, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)


class TrainerPublicProfileView(APIView):
    """
    Public profile of a trainer.
    Returns: basic info, stats, specializations, certifications,
             transformations, reviews with average rating.
    """

    def get(self, request, trainer_id):
        from django.db.models import Avg, Count
        from apps.trainer.models import (
            TrainerReview, TrainerCertification, TrainerTransformation,
            TrainerSpecialization, TrainerSocialLink, Location
        )
        from apps.trainer.workout_models import CustomerWorkoutPlan, WorkoutSession

        try:
            trainer = Trainer.objects.get(id=trainer_id)
        except Trainer.DoesNotExist:
            return Response({'error': 'Trainer not found.'}, status=status.HTTP_404_NOT_FOUND)

        # ── Basic Info ────────────────────────────────────────────────────
        profile_image = trainer.profile_image.url if trainer.profile_image else None

        basic = {
            'id': trainer.id,
            'name': f"{trainer.first_name} {trainer.last_name}".strip(),
            'user_type': trainer.user_type,
            'gender': trainer.gender,
            'bio': trainer.bio,
            'experience_years': trainer.experience_years,
            'profile_image': profile_image,
            'is_freelancer': trainer.is_freelancer,
            'join_gym': trainer.join_gym,
            'expected_pay_min': trainer.expected_pay_min,
            'expected_pay_max': trainer.expected_pay_max,
        }

        # ── Location ──────────────────────────────────────────────────────
        loc = Location.objects.filter(trainer=trainer).first()
        location = None
        if loc:
            location = {
                'city': loc.city,
                'state': loc.state,
                'country': loc.country,
            }

        # ── Social Links ──────────────────────────────────────────────────
        social = TrainerSocialLink.objects.filter(trainer=trainer).first()
        social_links = {}
        if social:
            social_links = {
                'instagram': social.instagram,
                'youtube': social.youtube,
                'facebook': social.facebook,
                'website': social.website,
                'whatsapp': social.whatsapp,
            }

        # ── Specializations ───────────────────────────────────────────────
        specializations = list(
            TrainerSpecialization.objects.filter(trainer=trainer)
            .select_related('specialization')
            .values_list('specialization__name', flat=True)
        )

        # ── Stats ─────────────────────────────────────────────────────────
        total_customers = CustomerWorkoutPlan.objects.filter(
            trainer=trainer
        ).values('customer').distinct().count()

        total_sessions_verified = WorkoutSession.objects.filter(
            customer_workout_plan__trainer=trainer,
            status='completed'
        ).count()

        # ── Ratings ───────────────────────────────────────────────────────
        review_stats = TrainerReview.objects.filter(trainer=trainer).aggregate(
            average_rating=Avg('rating'),
            total_reviews=Count('id')
        )
        average_rating = round(review_stats['average_rating'] or 0, 1)
        total_reviews = review_stats['total_reviews']

        # ── Recent Reviews ────────────────────────────────────────────────
        recent_reviews = []
        for r in TrainerReview.objects.filter(trainer=trainer).select_related('customer__user').order_by('-created_at')[:10]:
            u = r.customer.user if r.customer else None
            recent_reviews.append({
                'id': r.id,
                'customer_name': u.full_name if u else 'Anonymous',
                'profile_picture': u.profile_picture.url if u and u.profile_picture else None,
                'rating': r.rating,
                'comment': r.comment,
                'created_at': r.created_at,
            })

        # ── Certifications ────────────────────────────────────────────────
        certifications = []
        for cert in TrainerCertification.objects.filter(trainer=trainer):
            certifications.append({
                'id': cert.id,
                'certificate_name': cert.certificate_name,
                'issued_by': cert.issued_by,
                'issued_date': cert.issued_date,
                'certificate_file': cert.certificate_file.url if cert.certificate_file else None,
            })

        # ── Client Transformations ────────────────────────────────────────
        transformations = []
        for t in TrainerTransformation.objects.filter(trainer=trainer):
            transformations.append({
                'id': t.id,
                'before_image': t.before_image,
                'after_image': t.after_image,
                'description': t.description,
            })

        return Response({
            'profile': basic,
            'location': location,
            'social_links': social_links,
            'specializations': specializations,
            'stats': {
                'total_customers': total_customers,
                'total_sessions_verified': total_sessions_verified,
                'average_rating': average_rating,
                'total_reviews': total_reviews,
            },
            'certifications': certifications,
            'transformations': transformations,
            'reviews': recent_reviews,
        })


class TrainerAllReviewsView(APIView):
    """Paginated list of all reviews for a trainer."""

    def get(self, request, trainer_id):
        from apps.trainer.models import TrainerReview
        from apps.utils.pagination import CustomPagination

        try:
            trainer = Trainer.objects.get(id=trainer_id)
        except Trainer.DoesNotExist:
            return Response({'error': 'Trainer not found.'}, status=status.HTTP_404_NOT_FOUND)

        reviews = TrainerReview.objects.filter(
            trainer=trainer
        ).select_related('customer__user').order_by('-created_at')

        paginator = CustomPagination()
        page = paginator.paginate_queryset(reviews, request)

        result = []
        for r in page:
            u = r.customer.user if r.customer else None
            result.append({
                'id': r.id,
                'customer_name': u.full_name if u else 'Anonymous',
                'profile_picture': u.profile_picture.url if u and u.profile_picture else None,
                'rating': r.rating,
                'comment': r.comment,
                'created_at': r.created_at,
            })

        return paginator.get_paginated_response(result)


class TrainerReportsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from apps.trainer.models import Trainer
        from apps.trainer.workout_models import WorkoutSession, CustomerWorkoutPlan
        from apps.customers.models import Customer
        from django.db.models import Count

        trainer = _get_trainer_or_none(request.user)
        if not trainer:
            return Response({'error': 'Trainer profile not found.'}, status=400)

        # Get all customers assigned to this trainer
        assigned_plans = CustomerWorkoutPlan.objects.filter(trainer=trainer)
        customer_ids = assigned_plans.values_list('customer_id', flat=True).distinct()
        clients_trained_count = len(customer_ids)

        workout_plans_given_count = assigned_plans.values_list('plan_id', flat=True).distinct().count()

        # Workout adherence (completed sessions vs pending/in-progress)
        sessions = WorkoutSession.objects.filter(customer_id__in=customer_ids)
        total_sessions = sessions.count()
        completed_sessions = sessions.filter(status='completed').count()

        completion_rate = "0.0%"
        if total_sessions > 0:
            completion_rate = f"{round((completed_sessions / total_sessions) * 100, 1)}%"

        # Active progress summary
        active_progress = f"{completed_sessions} workouts completed by {clients_trained_count} clients"

        return Response({
            'clients_trained_count': clients_trained_count,
            'workout_plans_given_count': workout_plans_given_count,
            'workouts_completed_count': completed_sessions,
            'attendance_rate': completion_rate,
            'completion_rate': completion_rate,
            'active_progress': active_progress
        })
