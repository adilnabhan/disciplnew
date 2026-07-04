from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.utils import timezone
from django.db.models import Max
from datetime import date, timedelta
import calendar

from apps.trainer.models import (
    CustomerWorkoutPlan, WorkoutPlanDay, WorkoutPlanExercise,
    ExerciseSetTemplate, WorkoutSession, WorkoutLog, ExerciseSetLog,
)
from .workout_serializers import (
    CustomerWorkoutLogSerializer,
    CustomerExerciseSetLogSerializer,
    CustomerWorkoutSessionSerializer,
)


def _get_customer(request):
    """Helper to get Customer from request.user."""
    return getattr(request.user, 'customer', None)


class CustomerExerciseBrowseView(APIView):
    """Browse available exercises (master library) for plan building."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from apps.trainer.workout_models import Workout, MuscleGroup
        search = request.query_params.get('search', '').strip()
        muscle = request.query_params.get('muscle_group', '').strip()
        workout_type = request.query_params.get('type', '').strip()
        custom_only = request.query_params.get('custom_only', '').strip().lower()
        from django.db.models import Q
        global_exercises_q = Q(created_by__isnull=True) | Q(created_by__is_staff=True) | Q(created_by__is_superuser=True) | Q(created_by__user_role__in=[1, 5, 10, 15])

        if custom_only == 'true':
            qs = Workout.objects.filter(status=True, created_by=request.user).exclude(global_exercises_q)
        elif custom_only in ('all', 'both'):
            qs = Workout.objects.filter(
                global_exercises_q | Q(created_by=request.user),
                status=True
            )
        else:
            qs = Workout.objects.filter(global_exercises_q, status=True)

        qs = qs.select_related(
            'primary_muscle_group', 'equipment'
        )

        if search:
            qs = qs.filter(name__icontains=search)
        if muscle:
            qs = qs.filter(primary_muscle_group__name__icontains=muscle)
        if workout_type:
            qs = qs.filter(type=workout_type)

        exercises = []
        for w in qs.order_by('name'):
            exercises.append({
                'id': w.id,
                'name': w.name,
                'type': w.type,
                'muscle_group': w.primary_muscle_group.name if w.primary_muscle_group else None,
                'equipment': w.equipment.name if w.equipment else None,
                'video_url': w.video_url,
                'is_global': w.is_global,
                'description': w.description,
                'instructions': w.instructions,
                'thumbnail': w.thumbnail.url if w.thumbnail else None,
                'created_at': w.created_at,
            })

        return Response(exercises)

    def post(self, request):
        """Create a customer-private exercise."""
        from apps.trainer.api.serializers import WorkoutSerializer
        from apps.trainer.workout_models import MuscleGroup, Equipment

        data = request.data.copy() if hasattr(request.data, 'copy') else dict(request.data)

        # Handle custom muscle group name
        custom_muscle_name = data.pop('custom_muscle_group_name', None)
        if custom_muscle_name and not data.get('primary_muscle_group'):
            muscle, _ = MuscleGroup.objects.get_or_create(
                name__iexact=custom_muscle_name.strip(),
                defaults={'name': custom_muscle_name.strip(), 'status': True}
            )
            data['primary_muscle_group'] = muscle.id

        # Handle custom equipment name
        custom_equipment_name = data.pop('custom_equipment_name', None)
        if custom_equipment_name and not data.get('equipment'):
            equip, _ = Equipment.objects.get_or_create(
                name__iexact=custom_equipment_name.strip(),
                defaults={'name': custom_equipment_name.strip(), 'status': True}
            )
            data['equipment'] = equip.id

        serializer = WorkoutSerializer(data=data)
        if serializer.is_valid():
            serializer.save(created_by=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class CustomerExerciseSwapView(APIView):
    """
    Suggest alternative exercises that target the same muscle group but only require
    equipment currently available (and functional) at the user's gym organization.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        from apps.trainer.workout_models import Workout
        from apps.fitnesscenter.models import GymEquipment

        original_exercise_id = request.data.get('original_exercise_id')
        organization_id = request.data.get('organization_id')

        if not original_exercise_id or not organization_id:
            return Response(
                {"error": "original_exercise_id and organization_id are required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            original_exercise = Workout.objects.get(id=original_exercise_id)
        except Workout.DoesNotExist:
            return Response(
                {"error": "Original exercise not found."},
                status=status.HTTP_404_NOT_FOUND
            )

        muscle_group_id = original_exercise.primary_muscle_group_id
        if not muscle_group_id:
            return Response(
                {"error": "Original exercise does not have a primary muscle group defined."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Get the list of functional equipment IDs at this gym organization
        available_equipment_ids = GymEquipment.objects.filter(
            organization_id=organization_id,
            is_functional=True
        ).values_list('equipment_id', flat=True)

        # Query exercises targeting the same muscle group that only use available equipment
        from django.db.models import Q
        global_exercises_q = Q(created_by__isnull=True) | Q(created_by__is_staff=True) | Q(created_by__is_superuser=True) | Q(created_by__user_role__in=[1, 5, 10, 15])
        substitutes = Workout.objects.filter(
            global_exercises_q | Q(created_by=request.user),
            primary_muscle_group_id=muscle_group_id,
            equipment_id__in=available_equipment_ids,
            status=True
        ).exclude(id=original_exercise_id).select_related('primary_muscle_group', 'equipment')[:3]

        results = []
        for w in substitutes:
            results.append({
                "id": w.id,
                "name": w.name,
                "description": w.description,
                "type": w.type,
                "primary_muscle_group": w.primary_muscle_group_id,
                "primary_muscle_group_name": w.primary_muscle_group.name if w.primary_muscle_group else None,
                "equipment": w.equipment_id,
                "equipment_name": w.equipment.name if w.equipment else None,
                "video_url": w.video_url,
                "instructions": w.instructions
            })

        return Response(results, status=status.HTTP_200_OK)


class CustomerWorkoutCalendarView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        _cleanup_empty_sessions(customer)

        year_str = request.query_params.get('year')
        month_str = request.query_params.get('month')

        if year_str and month_str:
            try:
                year = int(year_str)
                month = int(month_str)
            except ValueError:
                return Response({'error': 'Invalid year or month format.'}, status=status.HTTP_400_BAD_REQUEST)

            from django.db import transaction

            start_date = date(year, month, 1)
            last_day = calendar.monthrange(year, month)[1]
            end_date = date(year, month, last_day)

            # Bulk query existing sessions for this customer and month
            sessions = list(WorkoutSession.objects.filter(
                customer=customer,
                session_date__gte=start_date,
                session_date__lte=end_date
            ).prefetch_related('logs', 'plan_day', 'plan_day__exercises'))

            sessions_by_date = {s.session_date: s for s in sessions}

            # Fetch active customer plans
            assigned_plans = list(CustomerWorkoutPlan.objects.filter(
                customer=customer,
                status='active'
            ).select_related('plan').prefetch_related('plan__days', 'plan__days__exercises'))

            # Cache plan days to avoid list conversions inside the loop
            plan_days_cache = {
                cwp.plan.id: list(cwp.plan.days.all())
                for cwp in assigned_plans
                if cwp.plan
            }

            days_list = []
            curr_date = start_date
            while curr_date <= end_date:
                date_str = curr_date.isoformat()
                session = sessions_by_date.get(curr_date)

                has_workout = False
                is_completed = False
                is_rest_day = False
                workout_id = None
                plan_day_id = None
                customer_workout_plan_id = None

                if session:
                    workout_id = session.id
                    plan_day_id = session.plan_day_id
                    customer_workout_plan_id = session.customer_workout_plan_id
                    is_completed = session.status == 'completed'
                    is_rest_day = session.status == 'rest_day' or (session.plan_day is not None and len(session.plan_day.exercises.all()) == 0)
                    if not is_rest_day and session.status != 'skipped':
                        if len(session.logs.all()) > 0:
                            has_workout = True
                        elif session.plan_day and len(session.plan_day.exercises.all()) > 0:
                            has_workout = True
                else:
                    # Check if there is an active plan covering this day
                    for cwp in assigned_plans:
                        plan = cwp.plan
                        if not plan:
                            continue
                        plan_start = cwp.start_date
                        if not plan_start:
                            continue
                        day_offset = (curr_date - plan_start).days + 1
                        total_days = plan.total_days or (plan.total_weeks * 7)

                        if 1 <= day_offset <= total_days:
                            plan_days = plan_days_cache.get(plan.id, [])
                            plan_day = next((d for d in plan_days if d.day_number == day_offset), None)
                            if plan_day:
                                plan_day_id = plan_day.id
                                customer_workout_plan_id = cwp.id
                                if len(plan_day.exercises.all()) > 0:
                                    has_workout = True
                                else:
                                    is_rest_day = True
                                break

                days_list.append({
                    "date": date_str,
                    "has_workout": has_workout,
                    "is_completed": is_completed,
                    "is_rest_day": is_rest_day,
                    "workout_id": workout_id,
                    "plan_day_id": plan_day_id,
                    "customer_workout_plan_id": customer_workout_plan_id
                })
                curr_date += timedelta(days=1)

            return Response({
                "year": year,
                "month": month,
                "days": days_list
            })

        # Backward compatibility for daily view
        date_str = request.query_params.get('date', timezone.localdate().isoformat())
        requested_date = date.fromisoformat(date_str)

        assigned_plans = CustomerWorkoutPlan.objects.filter(
            customer=customer,
            status='active'
        ).select_related('plan')

        result = []
        has_customer_plan = False

        from django.db import transaction

        for cwp in assigned_plans:
            plan = cwp.plan
            if not cwp.start_date:
                continue
            day_offset = (requested_date - cwp.start_date).days + 1
            total_days = plan.total_days or (plan.total_weeks * 7)

            if day_offset < 1 or day_offset > total_days:
                continue

            plan_day = WorkoutPlanDay.objects.filter(
                plan=plan, day_number=day_offset
            ).first()

            if not plan_day:
                continue

            session = WorkoutSession.objects.filter(
                customer=customer,
                customer_workout_plan=cwp,
                plan_day=plan_day,
                session_date=requested_date,
            ).first()

            if not session:
                with transaction.atomic():
                    session = WorkoutSession.objects.create(
                        customer=customer,
                        customer_workout_plan=cwp,
                        plan_day=plan_day,
                        session_date=requested_date,
                        status='pending',
                        title=cwp.title or plan.plan_name
                    )
                    exercises = WorkoutPlanExercise.objects.filter(
                        plan_day=plan_day
                    ).order_by('order_index').select_related('workout')

                    for exercise in exercises:
                        log = WorkoutLog.objects.create(
                            session=session,
                            customer=customer,
                            plan_exercise=exercise,
                        )
                        templates = ExerciseSetTemplate.objects.filter(
                            plan_exercise=exercise
                        ).order_by('set_number')
                        prev_sets = _get_previous_set_logs(customer, exercise, current_session=session)
                        for tmpl in templates:
                            prev = prev_sets.get(tmpl.set_number)
                            ExerciseSetLog.objects.create(
                                workout_log=log,
                                set_number=tmpl.set_number,
                                reps=None,
                                weight_kg=None,
                                previous_weight_kg=prev.weight_kg if prev else None,
                                previous_reps=prev.reps if prev else None,
                                is_completed=False,
                                input_type=tmpl.input_type or 'reps',
                            )

            # Determine source: customer-created vs trainer/gym assigned
            source = plan.source  # 'customer', 'trainer', or 'gym'
            is_customer_plan = source == 'customer'
            if is_customer_plan:
                has_customer_plan = True

            # Check membership status for the organization/trainer
            membership_status = 'active'
            if source in ['gym', 'trainer']:
                org = None
                if source == 'gym':
                    org = plan.organization
                elif source == 'trainer' and plan.trainer:
                    from apps.trainer.models import OrganizationTrainerLink
                    link = OrganizationTrainerLink.objects.filter(trainer=plan.trainer, status='approved').first()
                    if link:
                        org = link.organization
                
                if org:
                    from apps.customers.models import CustomerMembership
                    membership = CustomerMembership.objects.filter(
                        customer=customer,
                        membership__organization=org
                    ).first()
                    if membership:
                        membership_status = membership.status.lower()
                    else:
                        membership_status = 'none'

            exercise_count = plan_day.exercises.count()
            is_rest_day = (session.status == 'rest_day' if session else False) or (exercise_count == 0)
            trainer_name = None
            if cwp.trainer:
                trainer_name = f"{cwp.trainer.first_name} {cwp.trainer.last_name}".strip()
            elif plan.trainer:
                trainer_name = f"{plan.trainer.first_name} {plan.trainer.last_name}".strip()
            result.append({
                'customer_workout_plan_id': cwp.id,
                'plan_id': plan.id,
                'plan_name': cwp.title or plan.plan_name,
                'day_number': day_offset,
                'total_days': total_days,
                'plan_day_id': plan_day.id,
                'plan_day_title': plan_day.title,
                'is_rest_day': is_rest_day,
                'exercise_count': exercise_count,
                'session_id': session.id if session else None,
                'is_completed': session.status == 'completed' if session else False,
                'source': source,
                'membership_status': membership_status,
                'is_primary': False,  # set below
                'trainer_name': trainer_name,
            })

        # Fetch completed or rest_day sessions that aren't tied to an active plan (e.g. ad-hoc completed plans)
        completed_sessions = WorkoutSession.objects.filter(
            customer=customer,
            session_date=requested_date,
            status__in=['completed', 'rest_day', 'in_progress']
        ).select_related('plan_day', 'plan_day__plan', 'customer_workout_plan')

        existing_session_ids = {item['session_id'] for item in result if item['session_id'] is not None}
        for session in completed_sessions:
            if session.id in existing_session_ids:
                continue

            plan_day = session.plan_day
            plan = plan_day.plan if plan_day else None
            cwp = session.customer_workout_plan

            plan_id = plan.id if plan else None
            plan_name = (cwp.title if cwp and cwp.title else None) or (plan.plan_name if plan else None) or session.title or "My Session"
            plan_day_id = plan_day.id if plan_day else None
            plan_day_title = plan_day.title if plan_day else (session.title or "My Session")
            exercise_count = plan_day.exercises.count() if plan_day else 0

            day_offset = 1
            total_days = 1
            if cwp and plan:
                day_offset = (requested_date - cwp.start_date).days + 1 if cwp.start_date else 1
                total_days = plan.total_days or (plan.total_weeks * 7)

            source = plan.source if (plan and hasattr(plan, 'source') and plan.source) else 'customer'
            if source == 'customer':
                has_customer_plan = True

            trainer_name = None
            if cwp and cwp.trainer:
                trainer_name = f"{cwp.trainer.first_name} {cwp.trainer.last_name}".strip()
            elif plan and plan.trainer:
                trainer_name = f"{plan.trainer.first_name} {plan.trainer.last_name}".strip()

            result.append({
                'customer_workout_plan_id': cwp.id if cwp else None,
                'plan_id': plan_id,
                'plan_name': plan_name,
                'day_number': day_offset,
                'total_days': total_days,
                'plan_day_id': plan_day_id,
                'plan_day_title': plan_day_title,
                'is_rest_day': session.status == 'rest_day' or (plan_day is not None and exercise_count == 0),
                'exercise_count': exercise_count,
                'session_id': session.id,
                'is_completed': session.status == 'completed',
                'source': source,
                'membership_status': 'active',
                'is_primary': False,
                'trainer_name': trainer_name,
            })

        # Priority: customer plan > trainer/gym plan
        for item in result:
            if item['source'] == 'customer':
                item['is_primary'] = True
            elif not has_customer_plan:
                # If no customer plan for this day, trainer/gym plan is primary
                item['is_primary'] = True

        # Sort: customer plans first, then trainer, then gym
        source_order = {'customer': 0, 'trainer': 1, 'gym': 2}
        result.sort(key=lambda x: source_order.get(x['source'], 9))

        return Response(result)


class CustomerAssignedPlanDaysView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, cwp_id):
        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        _cleanup_empty_sessions(customer)

        cwp = CustomerWorkoutPlan.objects.get(pk=cwp_id, customer=customer)
        plan = cwp.plan
        days = WorkoutPlanDay.objects.filter(plan=plan).order_by('day_number')

        sessions = {
            s.plan_day_id: s
            for s in WorkoutSession.objects.filter(
                customer=customer,
                customer_workout_plan=cwp,
            )
        }

        today = timezone.localdate()
        result = []
        for day in days:
            session = sessions.get(day.id)
            expected_date = cwp.start_date + timezone.timedelta(days=day.day_number - 1)
            exercise_count = day.exercises.count()
            is_rest_day = session.status == 'rest_day' if session else False
            result.append({
                'plan_day_id': day.id,
                'day_number': day.day_number,
                'title': day.title,
                'is_rest_day': is_rest_day,
                'exercise_count': exercise_count,
                'is_completed': session.status == 'completed' if session else False,
                'is_current': expected_date == today,
                'session_id': session.id if session else None,
            })

        return Response({
            'plan_id': plan.id,
            'plan_name': plan.plan_name,
            'total_days': plan.total_days,
            'days': result,
        })


class CustomerPlanDayDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, plan_day_id):
        from apps.trainer.api.serializers import WorkoutPlanExerciseSerializer
        day = WorkoutPlanDay.objects.get(pk=plan_day_id)
        exercises = WorkoutPlanExercise.objects.filter(
            plan_day=day
        ).order_by('order_index').select_related('workout')

        customer = _get_customer(request)
        exercise_count = exercises.count()
        is_rest_day = False
        if customer:
            is_rest_day = WorkoutSession.objects.filter(customer=customer, plan_day=day, status='rest_day').exists()
        return Response({
            'plan_day_id': day.id,
            'day_number': day.day_number,
            'title': day.title,
            'is_rest_day': is_rest_day,
            'exercise_count': exercise_count,
            'exercises': WorkoutPlanExerciseSerializer(exercises, many=True).data,
        })


class StartWorkoutSessionView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        from apps.trainer.workout_models import WorkoutPlan, WorkoutPlanDay, WorkoutPlanExercise, ExerciseSetTemplate
        try:
            customer = _get_customer(request)
            if not customer:
                return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

            data = request.data if isinstance(request.data, dict) else {}
            session_id = data.get('session_id')
            session = None
            
            if session_id:
                session = WorkoutSession.objects.filter(pk=session_id, customer=customer).first()
                if not session:
                    return Response({'error': 'Workout Session not found.'}, status=status.HTTP_404_NOT_FOUND)
                plan_day = session.plan_day
                cwp = session.customer_workout_plan
                plan_day_id = plan_day.id if plan_day else None
            else:
                cwp_id = data.get('customer_workout_plan_id')
                plan_day_id = data.get('plan_day_id')
                preset_id = data.get('preset_id') or data.get('customer_preset_id')

                if preset_id:
                    try:
                        plan = WorkoutPlan.objects.get(pk=preset_id, is_preset=True)
                    except WorkoutPlan.DoesNotExist:
                        # Self-healing lookup fallback:
                        plan = WorkoutPlan.objects.filter(customer=customer, is_preset=True).first()
                        if not plan:
                            return Response({'error': 'Preset not found.'}, status=status.HTTP_404_NOT_FOUND)
                    plan_day = plan.days.first()
                    if not plan_day:
                        plan_day = WorkoutPlanDay.objects.create(
                            plan=plan,
                            day_number=1,
                            title=plan.plan_name
                        )
                    plan_day_id = plan_day.id

                if not plan_day_id:
                    # Check for existing in-progress session
                    active_session = WorkoutSession.objects.filter(
                        customer=customer,
                        status='in_progress'
                    ).last()
                    if active_session:
                        return Response(
                            CustomerWorkoutSessionSerializer(active_session).data,
                            status=status.HTTP_200_OK
                        )

                    # Create an ad-hoc custom plan
                    from apps.trainer.models import WorkoutPlan
                    adhoc_title = data.get('title') or "My Session"
                    plan = WorkoutPlan.objects.create(
                        customer=customer,
                        plan_name=adhoc_title,
                        description="Custom ad-hoc workout session",
                        is_preset=False,
                        total_weeks=1,
                        total_days=1
                    )
                    plan_day = WorkoutPlanDay.objects.create(
                        plan=plan,
                        day_number=1,
                        title=adhoc_title
                    )
                    cwp = CustomerWorkoutPlan.objects.create(
                        customer=customer,
                        plan=plan,
                        status='active'
                    )
                else:
                    try:
                        plan_day = WorkoutPlanDay.objects.get(pk=plan_day_id)
                    except WorkoutPlanDay.DoesNotExist:
                        return Response({'error': 'WorkoutPlanDay not found.'}, status=status.HTTP_404_NOT_FOUND)

                    # Check plan ownership
                    if plan_day.plan.customer and plan_day.plan.customer != customer and not plan_day.plan.is_preset:
                        return Response({'detail': 'Not your plan.'}, status=status.HTTP_403_FORBIDDEN)

                    # Check for an active session of this day first to prevent duplicates
                    active_session = WorkoutSession.objects.filter(
                        customer=customer,
                        plan_day_id=plan_day_id,
                        status='in_progress'
                    ).last()
                    if active_session:
                        return Response(
                            CustomerWorkoutSessionSerializer(active_session).data,
                            status=status.HTTP_200_OK
                        )

                    # Clean up/auto-complete other active in-progress sessions to prevent duplicates
                    from apps.trainer.workout_models import ExerciseSetLog
                    other_active_sessions = WorkoutSession.objects.filter(
                        customer=customer,
                        status='in_progress'
                    )
                    from django.db.models import Q
                    for s in other_active_sessions:
                        has_data = ExerciseSetLog.objects.filter(workout_log__session=s).filter(
                            Q(is_completed=True) | Q(reps__isnull=False) | Q(weight_kg__isnull=False)
                        ).exists()
                        if not has_data:
                            plan = s.plan_day.plan if s.plan_day else None
                            s.delete()
                            if plan and plan.customer == customer and not plan.is_preset:
                                try:
                                    plan.delete()
                                except Exception:
                                    pass
                        else:
                            s.status = 'completed'
                            s.completed_at = timezone.now()
                            s.save()

                    if plan_day.plan.is_preset:
                        cwp = CustomerWorkoutPlan.objects.filter(plan=plan_day.plan, customer=customer).first()
                        if not cwp:
                            cwp = CustomerWorkoutPlan.objects.create(
                                customer=customer,
                                plan=plan_day.plan,
                                status='active'
                            )
                    else:
                        cwp = None
                        if cwp_id:
                            cwp = CustomerWorkoutPlan.objects.filter(pk=cwp_id, customer=customer).first()
                        if not cwp:
                            cwp = CustomerWorkoutPlan.objects.filter(plan=plan_day.plan, customer=customer).first()
                        if not cwp:
                            # Dynamically auto-assign the plan to the customer
                            cwp = CustomerWorkoutPlan.objects.create(
                                customer=customer,
                                plan=plan_day.plan,
                                status='active'
                            )

            today = timezone.localdate()

            # Auto-delete any rest day session on today for this customer since they are starting a workout session
            WorkoutSession.objects.filter(
                customer=customer,
                session_date=today,
                status='rest_day'
            ).delete()

            title_param = data.get('title') or (plan_day.title if plan_day else "My Session")

            # Use filter().last() to avoid MultipleObjectsReturned if multiple sessions exist
            if not session:
                session = WorkoutSession.objects.filter(
                    customer=customer,
                    customer_workout_plan=cwp,
                    plan_day=plan_day,
                    session_date=today,
                    status__in=['in_progress', 'pending']
                ).last()

            created = False
            if not session:
                session = WorkoutSession.objects.create(
                    customer=customer,
                    customer_workout_plan=cwp,
                    plan_day=plan_day,
                    session_date=today,
                    status='in_progress',
                    started_at=timezone.now(),
                    title=title_param
                )
                created = True

            if not created and session.status == 'completed':
                return Response(
                    {'detail': 'This session is already completed.'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            if not created and session.status == 'pending':
                session.status = 'in_progress'
                session.started_at = timezone.now()
                if data.get('title'):
                    session.title = data.get('title')
                session.save()

            # Only populate logs if the session was newly created or currently has no logs
            if created or not session.logs.exists():
                from django.db import transaction
                with transaction.atomic():
                    exercises = WorkoutPlanExercise.objects.filter(
                        plan_day=plan_day
                    ).order_by('order_index').select_related('workout')

                    for exercise in exercises:
                        log = WorkoutLog.objects.filter(
                            session=session,
                            customer=customer,
                            plan_exercise=exercise,
                        ).first()
                        log_created = False
                        if not log:
                            log = WorkoutLog.objects.create(
                                session=session,
                                customer=customer,
                                plan_exercise=exercise,
                            )
                            log_created = True

                        if log_created:
                            templates = ExerciseSetTemplate.objects.filter(
                                plan_exercise=exercise
                            ).order_by('set_number')
                            prev_sets = _get_previous_set_logs(customer, exercise, current_session=session)
                            for tmpl in templates:
                                prev = prev_sets.get(tmpl.set_number)
                                ExerciseSetLog.objects.create(
                                    workout_log=log,
                                    set_number=tmpl.set_number,
                                    reps=None,
                                    weight_kg=None,
                                    previous_weight_kg=prev.weight_kg if prev else None,
                                    previous_reps=prev.reps if prev else None,
                                    is_completed=False,
                                    input_type=tmpl.input_type or 'reps',
                                )

            return Response(
                CustomerWorkoutSessionSerializer(session).data,
                status=status.HTTP_201_CREATED if created else status.HTTP_200_OK
            )
        except Exception as e:
            import traceback
            tb = traceback.format_exc()
            print("ERROR in StartWorkoutSessionView:")
            print(tb)
            return Response({
                'error': str(e),
                'traceback': tb
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


def sync_session_status(session):
    if not session or session.status in ('rest_day', 'skipped', 'completed'):
        return

    # Ensure started_at is populated if not already set
    if not session.started_at:
        session.started_at = timezone.now()

    # Check if there are any set logs in the session
    from apps.trainer.workout_models import ExerciseSetLog
    set_logs = ExerciseSetLog.objects.filter(workout_log__session=session)
    
    if not set_logs.exists():
        if session.status != 'in_progress':
            session.status = 'in_progress'
            session.completed_at = None
            session.save()
        else:
            session.save(update_fields=['started_at'])
        return

    # We no longer auto-complete the session when all set logs are checked.
    # The session status should remain 'in_progress' until explicitly finished by the user.
    # We only ensure that if there are set logs, the session status is 'in_progress'.
    if session.status != 'in_progress':
        session.status = 'in_progress'
        session.completed_at = None
        session.save()
    else:
        session.save(update_fields=['started_at'])


def _is_edit_window_expired(session):
    """Check if the 1-hour edit window has expired for a completed session."""
    if not session or session.status != 'completed':
        return False
    if not session.completed_at:
        return False
    return timezone.now() > session.completed_at + timezone.timedelta(hours=1)


class UpdateSetLogView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, set_log_id):
        from apps.trainer.workout_models import ExerciseSetLog
        from django.db import transaction

        try:
            set_log = ExerciseSetLog.objects.get(pk=set_log_id)
        except ExerciseSetLog.DoesNotExist:
            return Response({'error': 'Set log not found.'}, status=status.HTTP_404_NOT_FOUND)

        workout_log = set_log.workout_log
        if workout_log.customer.user != request.user:
            return Response({'error': 'Permission denied.'}, status=status.HTTP_403_FORBIDDEN)

        session = workout_log.session
        if session and session.status not in ['in_progress', 'pending']:
            return Response({'error': 'Cannot delete set from a completed workout session.'}, status=status.HTTP_400_BAD_REQUEST)

        with transaction.atomic():
            workout_log_id = workout_log.id
            set_log.delete()

            remaining_sets = ExerciseSetLog.objects.filter(workout_log_id=workout_log_id).order_by('set_number')
            for index, s in enumerate(remaining_sets, start=1):
                if s.set_number != index:
                    s.set_number = index
                    s.save(update_fields=['set_number'])

        return Response(status=status.HTTP_204_NO_CONTENT)

    def patch(self, request, set_log_id):
        try:
            set_log = ExerciseSetLog.objects.get(pk=set_log_id)
        except ExerciseSetLog.DoesNotExist:
            return Response({'error': 'Set log not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Check 1-hour edit window for completed sessions
        if set_log.workout_log and set_log.workout_log.session:
            if _is_edit_window_expired(set_log.workout_log.session):
                return Response(
                    {'error': 'Workout is read-only after 1 hour.'},
                    status=status.HTTP_403_FORBIDDEN
                )

        is_completed_val = request.data.get('is_completed')
        
        if 'reps' in request.data:
            set_log.reps = request.data['reps']
        if 'weight_kg' in request.data:
            set_log.weight_kg = request.data['weight_kg']
        if 'input_type' in request.data:
            set_log.input_type = request.data['input_type']
        if 'value' in request.data:
            set_log.value = request.data['value']
            
        if is_completed_val is not None:
            is_comp = is_completed_val
            if isinstance(is_comp, str):
                is_comp = is_comp.lower() in ('true', '1', 't', 'y', 'yes')
            else:
                is_comp = bool(is_comp)
            set_log.is_completed = is_comp
            
            if is_comp:
                fallback_reps = None
                fallback_weight = None
                try:
                    if set_log.workout_log and set_log.workout_log.plan_exercise:
                        tmpl = set_log.workout_log.plan_exercise.sets.filter(set_number=set_log.set_number).first()
                        if tmpl:
                            fallback_reps = tmpl.target_reps
                            fallback_weight = tmpl.target_weight
                except Exception:
                    pass
                
                if set_log.reps is None:
                    set_log.reps = fallback_reps
                if set_log.weight_kg is None:
                    set_log.weight_kg = fallback_weight
            else:
                set_log.reps = None
                set_log.weight_kg = None
        
        set_log.save()

        # Sync session status dynamically
        try:
            if set_log.workout_log and set_log.workout_log.session:
                sync_session_status(set_log.workout_log.session)
        except Exception:
            pass

        return Response(CustomerExerciseSetLogSerializer(set_log).data)

    # Support PUT as an alias for PATCH
    def put(self, request, set_log_id):
        return self.patch(request, set_log_id)

    def delete(self, request, set_log_id):
        from apps.trainer.workout_models import ExerciseSetLog
        from django.db import transaction

        try:
            set_log = ExerciseSetLog.objects.get(pk=set_log_id)
        except ExerciseSetLog.DoesNotExist:
            return Response({'error': 'Set log not found.'}, status=status.HTTP_404_NOT_FOUND)

        workout_log = set_log.workout_log
        if workout_log.customer.user != request.user:
            return Response({'error': 'Permission denied.'}, status=status.HTTP_403_FORBIDDEN)

        session = workout_log.session
        if session and session.status not in ['in_progress', 'pending']:
            return Response({'error': 'Cannot delete set from a completed workout session.'}, status=status.HTTP_400_BAD_REQUEST)

        # Check 1-hour edit window for completed sessions
        if session and _is_edit_window_expired(session):
            return Response(
                {'error': 'Workout is read-only after 1 hour.'},
                status=status.HTTP_403_FORBIDDEN
            )

        with transaction.atomic():
            workout_log_id = workout_log.id
            set_log.delete()

            remaining_sets = ExerciseSetLog.objects.filter(workout_log_id=workout_log_id).order_by('set_number')
            for index, s in enumerate(remaining_sets, start=1):
                if s.set_number != index:
                    s.set_number = index
                    s.save(update_fields=['set_number'])

        # Sync session status dynamically
        if session:
            try:
                sync_session_status(session)
            except Exception:
                pass

        return Response(status=status.HTTP_204_NO_CONTENT)


class AddSetToLogView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, log_id):
        from .workout_serializers import CustomerWorkoutLogSerializer
        try:
            log = WorkoutLog.objects.get(pk=log_id)
        except WorkoutLog.DoesNotExist:
            return Response({'error': 'Workout log not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Check 1-hour edit window for completed sessions
        if log.session and _is_edit_window_expired(log.session):
            return Response(
                {'error': 'Workout is read-only after 1 hour.'},
                status=status.HTTP_403_FORBIDDEN
            )
        next_number = (log.set_logs.aggregate(m=Max('set_number'))['m'] or 0) + 1
        
        # Look up previous set log for this exercise to set previous_weight_kg
        prev_sets = _get_previous_set_logs(log.customer, log.plan_exercise, current_session=log.session)
        prev = prev_sets.get(next_number)

        is_completed_raw = request.data.get('is_completed', False)
        if isinstance(is_completed_raw, str):
            is_completed = is_completed_raw.lower() in ('true', '1', 't', 'y', 'yes')
        else:
            is_completed = bool(is_completed_raw)

        reps = request.data.get('reps')
        weight_kg = request.data.get('weight_kg')

        if is_completed:
            fallback_reps = None
            fallback_weight = None
            try:
                if log.plan_exercise:
                    tmpl = log.plan_exercise.sets.filter(set_number=next_number).first()
                    if tmpl:
                        fallback_reps = tmpl.target_reps
                        fallback_weight = tmpl.target_weight
            except Exception:
                pass
            
            if reps is None:
                reps = fallback_reps
            if weight_kg is None:
                weight_kg = fallback_weight
        else:
            reps = None
            weight_kg = None

        input_type = request.data.get('input_type')
        if not input_type:
            fallback_input_type = 'reps'
            try:
                if log.plan_exercise:
                    tmpl = log.plan_exercise.sets.filter(set_number=next_number).first()
                    if not tmpl:
                        tmpl = log.plan_exercise.sets.first()
                    if tmpl:
                        fallback_input_type = tmpl.input_type or 'reps'
            except Exception:
                pass
            input_type = fallback_input_type

        value = request.data.get('value')

        set_log = ExerciseSetLog.objects.create(
            workout_log=log,
            set_number=next_number,
            weight_kg=weight_kg,
            reps=reps,
            previous_weight_kg=prev.weight_kg if prev else None,
            previous_reps=prev.reps if prev else None,
            is_completed=is_completed,
            input_type=input_type,
            value=value,
        )
        
        # Sync session status dynamically
        sync_session_status(log.session)
        
        return Response(CustomerWorkoutLogSerializer(log).data, status=status.HTTP_201_CREATED)


class BulkUpdateWorkoutLogSetsView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, log_id):
        from .workout_serializers import CustomerWorkoutLogSerializer
        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            log = WorkoutLog.objects.get(pk=log_id, customer=customer)
        except WorkoutLog.DoesNotExist:
            return Response({'error': 'Workout log not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Check 1-hour edit window for completed sessions
        if log.session and _is_edit_window_expired(log.session):
            return Response(
                {'error': 'Workout is read-only after 1 hour.'},
                status=status.HTTP_403_FORBIDDEN
            )

        sets_data = request.data.get('sets', [])
        if not isinstance(sets_data, list):
            return Response({'error': 'sets must be a list.'}, status=status.HTTP_400_BAD_REQUEST)

        sent_set_numbers = {item.get('set_number') for item in sets_data if item.get('set_number') is not None}
        prev_sets = _get_previous_set_logs(customer, log.plan_exercise, current_session=log.session)
        existing_set_logs = {s.set_number: s for s in log.set_logs.all()}

        for item in sets_data:
            set_num = item.get('set_number')
            if not set_num:
                continue
            
            reps = item.get('reps')
            weight_kg = item.get('weight_kg')
            is_completed_raw = item.get('is_completed', False)
            if isinstance(is_completed_raw, str):
                is_completed = is_completed_raw.lower() in ('true', '1', 't', 'y', 'yes')
            else:
                is_completed = bool(is_completed_raw)

            fallback_reps = None
            fallback_weight = None
            fallback_input_type = 'reps'
            try:
                if log.plan_exercise:
                    tmpl = log.plan_exercise.sets.filter(set_number=set_num).first()
                    if not tmpl:
                        tmpl = log.plan_exercise.sets.first()
                    if tmpl:
                        fallback_reps = tmpl.target_reps
                        fallback_weight = tmpl.target_weight
                        fallback_input_type = tmpl.input_type or 'reps'
            except Exception:
                pass

            set_log = existing_set_logs.get(set_num)
            if set_log:
                if 'reps' in item:
                    set_log.reps = reps
                if 'weight_kg' in item:
                    set_log.weight_kg = weight_kg
                if 'is_completed' in item:
                    set_log.is_completed = is_completed
                if 'input_type' in item:
                    set_log.input_type = item['input_type']
                if 'value' in item:
                    set_log.value = item['value']
                
                if set_log.is_completed:
                    if set_log.reps is None:
                        set_log.reps = fallback_reps
                    if set_log.weight_kg is None:
                        set_log.weight_kg = fallback_weight
                else:
                    set_log.reps = None
                    set_log.weight_kg = None
                set_log.save()
            else:
                prev = prev_sets.get(set_num)
                final_reps = reps
                final_weight = weight_kg
                final_value = item.get('value')
                input_type = item.get('input_type', fallback_input_type)
                
                if is_completed:
                    if final_reps is None:
                        final_reps = fallback_reps
                    if final_weight is None:
                        final_weight = fallback_weight
                else:
                    final_reps = None
                    final_weight = None

                ExerciseSetLog.objects.create(
                    workout_log=log,
                    set_number=set_num,
                    reps=final_reps,
                    weight_kg=final_weight,
                    previous_weight_kg=prev.weight_kg if prev else None,
                    previous_reps=prev.reps if prev else None,
                    is_completed=is_completed,
                    input_type=input_type,
                    value=final_value
                )

        if sent_set_numbers:
            log.set_logs.exclude(set_number__in=sent_set_numbers).delete()

        sync_session_status(log.session)

        return Response(CustomerWorkoutLogSerializer(log).data, status=status.HTTP_200_OK)

    def patch(self, request, log_id):
        from .workout_serializers import CustomerWorkoutLogSerializer
        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            log = WorkoutLog.objects.get(pk=log_id, customer=customer)
        except WorkoutLog.DoesNotExist:
            return Response({'error': 'Workout log not found.'}, status=status.HTTP_404_NOT_FOUND)

        weight_type = request.data.get('weight_type')
        if weight_type is not None:
            log.weight_type = weight_type
            log.save()

        return Response(CustomerWorkoutLogSerializer(log).data, status=status.HTTP_200_OK)


class FinishWorkoutSessionView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, session_id):
        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            session = WorkoutSession.objects.get(pk=session_id, customer=customer)
        except WorkoutSession.DoesNotExist:
            return Response({'error': 'Workout session not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Check if the frontend is calling this to discard/skip the session
        status_param = str(request.data.get('status', '')).lower()
        discard_param = request.data.get('discard', False)
        is_discarded_param = request.data.get('is_discarded', False)
        action_param = str(request.data.get('action', '')).lower()

        def is_truthy(val):
            if isinstance(val, str):
                return val.lower() in ['true', '1', 't', 'y', 'yes']
            return bool(val)

        is_discard = (
            status_param in ['discard', 'discarded', 'skipped'] or 
            action_param in ['discard', 'discarded', 'skip'] or
            is_truthy(discard_param) or 
            is_truthy(is_discarded_param)
        )

        if is_discard:
            session.delete()
            return Response({'detail': 'Workout session discarded successfully.'}, status=status.HTTP_200_OK)

        # Check if the session has any completed sets. If not, discard it.
        from apps.trainer.workout_models import ExerciseSetLog
        has_completed_sets = ExerciseSetLog.objects.filter(
            workout_log__session=session,
            is_completed=True
        ).exists()

        if not has_completed_sets and session.status != 'rest_day' and not session.customer_workout_plan:
            plan = session.plan_day.plan if session.plan_day else None
            session.delete()
            if plan and plan.customer == customer and not plan.is_preset:
                try:
                    plan.delete()
                except Exception:
                    pass
            return Response({
                'detail': 'Workout session discarded because no sets were completed.',
                'discarded': True
            }, status=status.HTTP_200_OK)

        request_title = (
            str(request.data.get('title') or '').strip() or
            str(request.data.get('plan_name') or '').strip() or
            str(request.data.get('preset_title') or '').strip() or
            str(request.data.get('preset_name') or '').strip()
        )
        title = request_title
        if not title:
            if session.title and session.title not in ('Day 1', 'Custom Workout', 'My Session'):
                title = session.title
            elif session.plan_day and session.plan_day.title and session.plan_day.title not in ('Day 1', 'My Session'):
                title = session.plan_day.title
            elif session.plan_day and session.plan_day.plan and session.plan_day.plan.plan_name:
                title = session.plan_day.plan.plan_name
            else:
                title = "My Session"

        session.status = 'completed'
        if not session.started_at:
            session.started_at = timezone.now() - timezone.timedelta(minutes=30)
        session.completed_at = timezone.now()
        session.title = title
        session.save()

        # Capture original plan and plan day before any preset re-linking happens
        original_plan = session.plan_day.plan if (session.plan_day and session.plan_day.plan) else None
        original_plan_day = session.plan_day
        
        # Mark all workout logs as completed
        WorkoutLog.objects.filter(session=session, is_completed=False).update(is_completed=True)

        # Populate missing reps/weight with target templates ONLY for sets completed by the user
        from apps.trainer.workout_models import ExerciseSetLog
        completed_set_logs = ExerciseSetLog.objects.filter(
            workout_log__session=session,
            is_completed=True
        )
        for s in completed_set_logs:
            if s.reps is None or s.weight_kg is None:
                fallback_reps = None
                fallback_weight = None
                try:
                    if s.workout_log.plan_exercise:
                        tmpl = s.workout_log.plan_exercise.sets.filter(set_number=s.set_number).first()
                        if tmpl:
                            fallback_reps = tmpl.target_reps
                            fallback_weight = tmpl.target_weight
                except Exception:
                    pass
                
                if s.reps is None:
                    s.reps = fallback_reps
                if s.weight_kg is None:
                    s.weight_kg = fallback_weight
                s.save()

        save_as_preset_raw = request.data.get('save_as_preset') or request.query_params.get('save_as_preset', False)
        is_favorite_raw = request.data.get('is_favorite') or request.query_params.get('is_favorite', False)

        def is_truthy(val):
            if isinstance(val, str):
                return val.lower() in ['true', '1', 't', 'y', 'yes']
            return bool(val)

        save_as_preset = is_truthy(save_as_preset_raw) or is_truthy(is_favorite_raw)

        preset_id = None
        preset_title = None
        if save_as_preset:
            from apps.trainer.workout_models import WorkoutPlan, WorkoutPlanDay, WorkoutPlanExercise

            # Use preset_title from request if provided, otherwise fall back
            # to session title. This lets the user name the preset independently.
            preset_title = (
                str(request.data.get('preset_title') or request.query_params.get('preset_title') or '').strip() or
                str(request.data.get('preset_name') or request.query_params.get('preset_name') or '').strip() or
                str(request.data.get('plan_name') or request.query_params.get('plan_name') or '').strip() or
                str(request.data.get('title') or request.query_params.get('title') or '').strip() or
                title or
                "My Workout"
            )

            preset = WorkoutPlan.objects.create(
                customer=customer,
                plan_name=preset_title,
                description=f"Preset saved from workout session on {session.session_date}",
                is_preset=True,
                total_weeks=1,
                total_days=1,
                status=True
            )
            preset_day = WorkoutPlanDay.objects.create(
                plan=preset,
                day_number=1,
                title=preset_title
            )
            logs = session.logs.all().order_by('id')
            for index, log in enumerate(logs):
                target_workout = log.plan_exercise.workout if log.plan_exercise else None
                if target_workout:
                    ex = WorkoutPlanExercise.objects.create(
                        plan_day=preset_day,
                        workout=target_workout,
                        order_index=index + 1
                    )
                    # Point the log to the new preset's exercise!
                    log.plan_exercise = ex
                    log.save()

                    from apps.trainer.workout_models import ExerciseSetTemplate
                    set_logs = log.set_logs.all().order_by('set_number')
                    for s in set_logs:
                        fallback_reps = None
                        fallback_weight = None
                        try:
                            if log.plan_exercise:
                                tmpl = log.plan_exercise.sets.filter(set_number=s.set_number).first()
                                if tmpl:
                                    fallback_reps = tmpl.target_reps
                                    fallback_weight = tmpl.target_weight
                        except Exception:
                            pass

                        ExerciseSetTemplate.objects.create(
                            plan_exercise=ex,
                            set_number=s.set_number,
                            target_reps=s.reps if s.reps is not None else fallback_reps,
                            target_weight=s.weight_kg if s.weight_kg is not None else fallback_weight,
                            rest_seconds=60,
                        )

            # Create a completed CustomerWorkoutPlan assignment for the preset
            from apps.trainer.models import CustomerWorkoutPlan
            preset_cwp = CustomerWorkoutPlan.objects.create(
                customer=customer,
                plan=preset,
                status='completed',
                start_date=session.session_date
            )

            # Re-link session and its logs to the new preset
            session.plan_day = preset_day
            session.customer_workout_plan = preset_cwp
            session.save()

            preset_id = preset.id

        # Clean up original ad-hoc plan immediately upon session completion
        if original_plan and _is_adhoc_plan(original_plan):
            if save_as_preset:
                original_plan.status = False
                original_plan.plan_name = title
                original_plan.save()
                if original_plan_day:
                    original_plan_day.title = title
                    original_plan_day.save()
                from apps.trainer.models import CustomerWorkoutPlan
                CustomerWorkoutPlan.objects.filter(
                    customer=customer,
                    plan=original_plan,
                    status='active'
                ).update(status='cancelled')
            else:
                # Keep it active as a draft/custom plan, but remove 'ad-hoc' from description
                # so it is not excluded from My Plans list
                original_plan.status = True
                original_plan.description = "Custom draft workout plan"
                original_plan.plan_name = title
                original_plan.save()
                if original_plan_day:
                    original_plan_day.title = title
                    original_plan_day.save()
                from apps.trainer.models import CustomerWorkoutPlan
                CustomerWorkoutPlan.objects.filter(
                    customer=customer,
                    plan=original_plan,
                    status='active'
                ).update(status='completed')

        response_payload = {
            'session_id': session.id,
            'status': session.status,
            'title': session.title
        }
        if preset_id:
            response_payload['preset_id'] = preset_id
            response_payload['preset_title'] = preset_title
            response_payload['is_preset'] = True
            response_payload['is_favorite'] = True

        return Response(response_payload)


# --- Helpers ---

def _is_adhoc_plan(plan):
    """Check if a WorkoutPlan is an ad-hoc session plan (not user-created, not a preset)."""
    if plan.is_preset:
        return False
    desc = (plan.description or '').lower()
    return 'ad-hoc' in desc


def _get_previous_set_logs(customer, plan_exercise, current_session=None):
    from apps.trainer.workout_models import WorkoutLog
    qs = WorkoutLog.objects.filter(
        customer=customer,
        plan_exercise__workout=plan_exercise.workout,
        set_logs__is_completed=True
    ).distinct()

    if current_session:
        qs = qs.exclude(session=current_session)
    else:
        qs = qs.exclude(session__status='in_progress')

    # Iterate over recent logs to construct previous set history.
    # This ensures that if a user skipped a set in their *most recent* session,
    # it correctly falls back to the session before that where they DID complete it!
    prev_sets = {}
    for log in qs.order_by('-logged_at')[:10]:
        completed_sets = log.set_logs.filter(is_completed=True)
        for s in completed_sets:
            if s.set_number not in prev_sets:
                prev_sets[s.set_number] = s
                
    return prev_sets


def _cleanup_empty_sessions(customer):
    from apps.trainer.workout_models import WorkoutSession, WorkoutPlan, ExerciseSetLog
    
    today = timezone.localdate()
    cutoff_time = timezone.now() - timezone.timedelta(hours=24)

    sessions = WorkoutSession.objects.filter(
        customer=customer,
        status__in=['in_progress', 'pending']
    )
    for s in sessions:
        # DO NOT clean up sessions that are for today or started within the last 24 hours
        if s.session_date >= today:
            continue
        if s.started_at and s.started_at >= cutoff_time:
            continue

        from django.db.models import Q
        has_data = ExerciseSetLog.objects.filter(
            workout_log__session=s
        ).filter(
            Q(is_completed=True) | Q(reps__isnull=False) | Q(weight_kg__isnull=False)
        ).exists()

        if not has_data:
            plan = s.plan_day.plan if s.plan_day else None
            s.delete()
            if plan and plan.pk and plan.customer == customer and not plan.is_preset:
                try:
                    plan.delete()
                except Exception:
                    pass

    # Also clean up any orphan ad-hoc custom plans with no sessions at all
    orphan_plans = WorkoutPlan.objects.filter(
        customer=customer,
        is_preset=False,
        created_at__lt=cutoff_time,
        description__icontains="ad-hoc"
    ).exclude(
        days__sessions__isnull=False
    )
    for plan in orphan_plans:
        try:
            plan.delete()
        except Exception:
            pass

    # Soft-delete ad-hoc plans whose sessions are ALL completed
    # (these survive the orphan check above because they DO have sessions)
    adhoc_plans_with_completed_sessions = WorkoutPlan.objects.filter(
        customer=customer,
        is_preset=False,
        status=True,
        description__icontains="ad-hoc"
    ).exclude(
        days__sessions__status__in=['in_progress', 'pending']
    )
    for plan in adhoc_plans_with_completed_sessions:
        plan.status = False
        plan.save()


# ─── Customer Workout Plan CRUD ──────────────────────────────────────────────

class CustomerWorkoutPlanListCreateView(APIView):
    """Customer creates and lists their own workout plans."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from apps.trainer.models import WorkoutPlan
        from .workout_serializers import CustomerWorkoutPlanListSerializer

        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        _cleanup_empty_sessions(customer)

        plans = WorkoutPlan.objects.filter(
            customer=customer, status=True, is_preset=False
        ).exclude(
            description__icontains="ad-hoc"
        ).order_by('-created_at')

        return Response(CustomerWorkoutPlanListSerializer(plans, many=True).data)

    def post(self, request):
        from apps.trainer.models import WorkoutPlan
        from .workout_serializers import CustomerWorkoutPlanCreateSerializer

        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        serializer = CustomerWorkoutPlanCreateSerializer(data=request.data)
        if serializer.is_valid():
            plan = serializer.save(customer=customer)

            # Auto-assign to customer via CustomerWorkoutPlan
            CustomerWorkoutPlan.objects.create(
                customer=customer,
                plan=plan,
                status='active',
            )

            return Response(CustomerWorkoutPlanCreateSerializer(plan).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class CustomerWorkoutPlanDetailView(APIView):
    """Customer views, edits, or deletes their own workout plan."""
    permission_classes = [IsAuthenticated]

    def get(self, request, plan_id):
        from apps.trainer.models import WorkoutPlan
        from .workout_serializers import CustomerWorkoutPlanDetailSerializer

        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            plan = WorkoutPlan.objects.get(pk=plan_id, customer=customer)
        except WorkoutPlan.DoesNotExist:
            return Response({'detail': 'Plan not found.'}, status=status.HTTP_404_NOT_FOUND)

        return Response(CustomerWorkoutPlanDetailSerializer(plan).data)

    def put(self, request, plan_id):
        from apps.trainer.models import WorkoutPlan
        from .workout_serializers import CustomerWorkoutPlanCreateSerializer

        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            plan = WorkoutPlan.objects.get(pk=plan_id, customer=customer)
        except WorkoutPlan.DoesNotExist:
            return Response({'detail': 'Plan not found.'}, status=status.HTTP_404_NOT_FOUND)

        serializer = CustomerWorkoutPlanCreateSerializer(plan, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, plan_id):
        from apps.trainer.models import WorkoutPlan

        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            plan = WorkoutPlan.objects.get(pk=plan_id, customer=customer)
        except WorkoutPlan.DoesNotExist:
            return Response({'detail': 'Plan not found.'}, status=status.HTTP_404_NOT_FOUND)

        plan.status = False  # Soft delete
        plan.save()
        # Also cancel the auto-assigned CustomerWorkoutPlan
        CustomerWorkoutPlan.objects.filter(
            customer=customer, plan=plan, status='active'
        ).update(status='cancelled')

        return Response({'detail': 'Plan deleted.'}, status=status.HTTP_204_NO_CONTENT)


class CustomerPlanDayListCreateView(APIView):
    """Customer adds days to their workout plan."""
    permission_classes = [IsAuthenticated]

    def get(self, request, plan_id):
        from apps.trainer.models import WorkoutPlan
        from .workout_serializers import CustomerPlanDaySerializer

        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            plan = WorkoutPlan.objects.get(pk=plan_id, customer=customer)
        except WorkoutPlan.DoesNotExist:
            return Response({'detail': 'Plan not found.'}, status=status.HTTP_404_NOT_FOUND)

        days = WorkoutPlanDay.objects.filter(plan=plan).order_by('day_number')
        return Response(CustomerPlanDaySerializer(days, many=True).data)

    def post(self, request, plan_id):
        from apps.trainer.models import WorkoutPlan
        from .workout_serializers import CustomerPlanDaySerializer

        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            plan = WorkoutPlan.objects.get(pk=plan_id, customer=customer)
        except WorkoutPlan.DoesNotExist:
            return Response({'detail': 'Plan not found.'}, status=status.HTTP_404_NOT_FOUND)

        serializer = CustomerPlanDaySerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(plan=plan)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class CustomerPlanDayEditDeleteView(APIView):
    """Customer edits or deletes a day from their plan."""
    permission_classes = [IsAuthenticated]

    def put(self, request, plan_id, day_id):
        from apps.trainer.models import WorkoutPlan
        from .workout_serializers import CustomerPlanDaySerializer

        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            WorkoutPlan.objects.get(pk=plan_id, customer=customer)
        except WorkoutPlan.DoesNotExist:
            return Response({'detail': 'Plan not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            day = WorkoutPlanDay.objects.get(pk=day_id, plan_id=plan_id)
        except WorkoutPlanDay.DoesNotExist:
            return Response({'detail': 'Day not found.'}, status=status.HTTP_404_NOT_FOUND)

        serializer = CustomerPlanDaySerializer(day, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, plan_id, day_id):
        from apps.trainer.models import WorkoutPlan

        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            WorkoutPlan.objects.get(pk=plan_id, customer=customer)
        except WorkoutPlan.DoesNotExist:
            return Response({'detail': 'Plan not found.'}, status=status.HTTP_404_NOT_FOUND)

        WorkoutPlanDay.objects.filter(pk=day_id, plan_id=plan_id).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class CustomerDayExerciseListCreateView(APIView):
    """Customer adds exercises to a day in their plan."""
    permission_classes = [IsAuthenticated]

    def get(self, request, day_id):
        from .workout_serializers import CustomerPlanExerciseSerializer

        exercises = WorkoutPlanExercise.objects.filter(
            plan_day_id=day_id
        ).order_by('order_index').select_related('workout')
        return Response(CustomerPlanExerciseSerializer(exercises, many=True).data)

    def post(self, request, day_id):
        from .workout_serializers import CustomerPlanExerciseSerializer

        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Verify the day belongs to customer's plan (allow if customer owns it or if no customer set)
        try:
            day = WorkoutPlanDay.objects.select_related('plan').get(pk=day_id)
            if day.plan.customer and day.plan.customer != customer:
                return Response({'detail': 'Not your plan.'}, status=status.HTTP_403_FORBIDDEN)
        except WorkoutPlanDay.DoesNotExist:
            return Response({'detail': 'Day not found.'}, status=status.HTTP_404_NOT_FOUND)

        serializer = CustomerPlanExerciseSerializer(data=request.data)
        if serializer.is_valid():
            exercise = serializer.save(plan_day=day)

            # Create set templates if provided
            sets_data = request.data.get('sets', [])
            templates = []
            for s in sets_data:
                tmpl = ExerciseSetTemplate.objects.create(plan_exercise=exercise, **s)
                templates.append(tmpl)

            # Dynamic sync: check if there is an active session for this plan day
            active_session = WorkoutSession.objects.filter(
                customer=customer,
                plan_day=day,
                status='in_progress'
            ).last()

            if active_session:
                log, log_created = WorkoutLog.objects.get_or_create(
                    session=active_session,
                    customer=customer,
                    plan_exercise=exercise,
                )
                if log_created:
                    prev_sets = _get_previous_set_logs(customer, exercise, current_session=active_session)
                    for tmpl in templates:
                        prev = prev_sets.get(tmpl.set_number)
                        ExerciseSetLog.objects.create(
                            workout_log=log,
                            set_number=tmpl.set_number,
                            reps=tmpl.target_reps,
                            weight_kg=tmpl.target_weight,
                            previous_weight_kg=prev.weight_kg if prev else None,
                            is_completed=False,
                            input_type=tmpl.input_type or 'reps',
                        )

            return Response(
                CustomerPlanExerciseSerializer(exercise).data,
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class CustomerDayExerciseDetailView(APIView):
    """Customer edits or deletes an exercise from their plan day."""
    permission_classes = [IsAuthenticated]

    def put(self, request, day_id, exercise_id):
        from .workout_serializers import CustomerPlanExerciseSerializer

        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            exercise = WorkoutPlanExercise.objects.select_related('plan_day__plan').get(
                pk=exercise_id, plan_day_id=day_id
            )
            if exercise.plan_day.plan.customer != customer:
                return Response({'detail': 'Not your plan.'}, status=status.HTTP_403_FORBIDDEN)
        except WorkoutPlanExercise.DoesNotExist:
            return Response({'detail': 'Exercise not found.'}, status=status.HTTP_404_NOT_FOUND)

        serializer = CustomerPlanExerciseSerializer(exercise, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, day_id, exercise_id):
        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            exercise = WorkoutPlanExercise.objects.select_related('plan_day__plan').get(
                pk=exercise_id, plan_day_id=day_id
            )
            if exercise.plan_day.plan.customer != customer:
                return Response({'detail': 'Not your plan.'}, status=status.HTTP_403_FORBIDDEN)
        except WorkoutPlanExercise.DoesNotExist:
            return Response({'detail': 'Exercise not found.'}, status=status.HTTP_404_NOT_FOUND)

        exercise.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class ActiveWorkoutSessionView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        _cleanup_empty_sessions(customer)

        session_id = request.query_params.get('session_id')
        session_date_str = request.query_params.get('date')

        if session_id:
            session = WorkoutSession.objects.filter(customer=customer, pk=session_id).first()
        elif session_date_str:
            try:
                session_date = date.fromisoformat(session_date_str)
                session = WorkoutSession.objects.filter(customer=customer, session_date=session_date).last()
            except ValueError:
                return Response({'error': 'Invalid date format. Use YYYY-MM-DD.'}, status=status.HTTP_400_BAD_REQUEST)
        else:
            session = WorkoutSession.objects.filter(
                customer=customer,
                status='in_progress'
            ).last()

        if not session:
            return Response(None, status=status.HTTP_200_OK)

        return Response(CustomerWorkoutSessionSerializer(session).data)

    def delete(self, request):
        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        session_id = request.query_params.get('session_id')
        session_date_str = request.query_params.get('date')

        if session_id:
            session = WorkoutSession.objects.filter(customer=customer, pk=session_id).first()
        elif session_date_str:
            try:
                session_date = date.fromisoformat(session_date_str)
                session = WorkoutSession.objects.filter(customer=customer, session_date=session_date).last()
            except ValueError:
                return Response({'error': 'Invalid date format. Use YYYY-MM-DD.'}, status=status.HTTP_400_BAD_REQUEST)
        else:
            session = WorkoutSession.objects.filter(
                customer=customer,
                status='in_progress'
            ).last()

        if not session:
            return Response(status=status.HTTP_204_NO_CONTENT)

        session.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class WorkoutSessionDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, session_id):
        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            session = WorkoutSession.objects.get(pk=session_id, customer=customer)
        except WorkoutSession.DoesNotExist:
            return Response({'error': 'Workout session not found.'}, status=status.HTTP_404_NOT_FOUND)

        return Response(CustomerWorkoutSessionSerializer(session).data)

    def delete(self, request, session_id):
        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            session = WorkoutSession.objects.get(pk=session_id, customer=customer)
            session.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except WorkoutSession.DoesNotExist:
            return Response({'error': 'Workout session not found.'}, status=status.HTTP_404_NOT_FOUND)


class AddExerciseToActiveSessionView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        from apps.trainer.workout_models import Workout
        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        workout_ids = request.data.get('workout_ids') or request.data.get('exercise_ids')
        workout_id = request.data.get('workout_id') or request.data.get('exercise_id')

        if not workout_ids and not workout_id:
            return Response({'error': 'workout_id or workout_ids is required.'}, status=status.HTTP_400_BAD_REQUEST)

        active_session = WorkoutSession.objects.filter(
            customer=customer,
            status='in_progress'
        ).last()

        if not active_session:
            from apps.trainer.models import WorkoutPlan
            plan = WorkoutPlan.objects.create(
                customer=customer,
                plan_name="My Session",
                description="Custom ad-hoc workout session",
                is_preset=False,
                total_weeks=1,
                total_days=1
            )
            plan_day = WorkoutPlanDay.objects.create(
                plan=plan,
                day_number=1,
                title="My Session"
            )
            cwp = CustomerWorkoutPlan.objects.create(
                customer=customer,
                plan=plan,
                status='active'
            )
            active_session = WorkoutSession.objects.create(
                customer=customer,
                customer_workout_plan=cwp,
                plan_day=plan_day,
                session_date=timezone.localdate(),
                status='in_progress',
                started_at=timezone.now(),
                title="My Session"
            )

        # Normalize to list of IDs
        ids_to_add = []
        if workout_ids:
            if isinstance(workout_ids, list):
                ids_to_add = workout_ids
            else:
                ids_to_add = [workout_ids]
        elif workout_id:
            ids_to_add = [workout_id]

        # Fetch workouts
        workouts = Workout.objects.filter(pk__in=ids_to_add)
        if not workouts.exists():
            return Response({'error': 'No valid workout exercises found.'}, status=status.HTTP_404_NOT_FOUND)

        plan_day = active_session.plan_day
        if not plan_day:
            return Response({'error': 'Active session does not have a plan day.'}, status=status.HTTP_400_BAD_REQUEST)

        # If this session is from a preset, clone the plan_day so we don't modify the preset template
        if plan_day.plan and plan_day.plan.is_preset:
            from apps.trainer.workout_models import WorkoutPlan as WP
            new_plan = WP.objects.create(
                customer=customer,
                plan_name=active_session.title or plan_day.plan.plan_name,
                description=f"{plan_day.plan.description or ''} (Ad-hoc cloned session plan)".strip(),
                total_weeks=1,
                total_days=1,
                is_preset=False,
                status=True
            )
            new_plan_day = WorkoutPlanDay.objects.create(
                plan=new_plan,
                day_number=1,
                title=plan_day.title
            )
            # Copy existing exercises from the preset day to the new day
            existing_exercises = WorkoutPlanExercise.objects.filter(plan_day=plan_day).order_by('order_index')
            for ex in existing_exercises:
                new_ex = WorkoutPlanExercise.objects.create(
                    plan_day=new_plan_day,
                    workout=ex.workout,
                    order_index=ex.order_index
                )
                # Copy set templates
                for tmpl in ExerciseSetTemplate.objects.filter(plan_exercise=ex).order_by('set_number'):
                    ExerciseSetTemplate.objects.create(
                        plan_exercise=new_ex,
                        set_number=tmpl.set_number,
                        target_reps=tmpl.target_reps,
                        target_weight=tmpl.target_weight,
                        rest_seconds=tmpl.rest_seconds,
                    )
                # Re-point existing workout logs to the new exercise
                WorkoutLog.objects.filter(
                    session=active_session,
                    plan_exercise=ex
                ).update(plan_exercise=new_ex)

            # Create CustomerWorkoutPlan for the new plan
            new_cwp = CustomerWorkoutPlan.objects.create(
                customer=customer,
                plan=new_plan,
                status='active'
            )
            # Update the session to point to the new plan_day and cwp
            active_session.plan_day = new_plan_day
            active_session.customer_workout_plan = new_cwp
            active_session.save(update_fields=['plan_day', 'customer_workout_plan'])
            plan_day = new_plan_day

        added_logs = []
        for workout in workouts:
            # Get the next order index
            max_order = WorkoutPlanExercise.objects.filter(plan_day=plan_day).aggregate(m=Max('order_index'))['m'] or 0
            order_index = max_order + 1

            # Check if this workout is already added to the plan day
            exercise, created = WorkoutPlanExercise.objects.get_or_create(
                plan_day=plan_day,
                workout=workout,
                defaults={'order_index': order_index}
            )

            log, log_created = WorkoutLog.objects.get_or_create(
                session=active_session,
                customer=customer,
                plan_exercise=exercise,
            )

            if log_created:
                # Add a default first set with previous_weight_kg populated
                prev_sets = _get_previous_set_logs(customer, exercise, current_session=active_session)
                prev = prev_sets.get(1)
                ExerciseSetLog.objects.create(
                    workout_log=log,
                    set_number=1,
                    reps=None,
                    weight_kg=None,
                    previous_weight_kg=prev.weight_kg if prev else None,
                    is_completed=False,
                )
            
            added_logs.append(log)

        if workout_ids and isinstance(workout_ids, list):
            return Response(CustomerWorkoutLogSerializer(added_logs, many=True).data, status=status.HTTP_201_CREATED)
        else:
            return Response(CustomerWorkoutLogSerializer(added_logs[0]).data, status=status.HTTP_201_CREATED)


class RemoveExerciseFromActiveSessionView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, log_id):
        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            log = WorkoutLog.objects.get(pk=log_id, customer=customer)
        except WorkoutLog.DoesNotExist:
            return Response({'error': 'Workout log not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Delete the associated set logs and the log itself
        session = log.session
        log.set_logs.all().delete()
        plan_exercise = log.plan_exercise
        log.delete()

        if plan_exercise and plan_exercise.plan_day and plan_exercise.plan_day.plan.customer == customer:
            plan_exercise.delete()

        # Sync session status dynamically
        sync_session_status(session)

        return Response(status=status.HTTP_204_NO_CONTENT)


class CustomerMuscleGroupListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from apps.trainer.workout_models import MuscleGroup
        qs = MuscleGroup.objects.filter(status=True).order_by('name')
        data = [{'id': m.id, 'name': m.name} for m in qs]
        return Response(data)

    def post(self, request):
        from apps.trainer.workout_models import MuscleGroup
        name = request.data.get('name', '').strip()
        if not name:
            return Response({'error': 'Name is required.'}, status=status.HTTP_400_BAD_REQUEST)
        muscle, created = MuscleGroup.objects.get_or_create(
            name__iexact=name,
            defaults={'name': name, 'status': True}
        )
        return Response({'id': muscle.id, 'name': muscle.name}, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)


class CustomerEquipmentListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from apps.trainer.workout_models import Equipment
        qs = Equipment.objects.filter(status=True).order_by('name')
        data = [{'id': e.id, 'name': e.name} for e in qs]
        return Response(data)

    def post(self, request):
        from apps.trainer.workout_models import Equipment
        name = request.data.get('name', '').strip()
        if not name:
            return Response({'error': 'Name is required.'}, status=status.HTTP_400_BAD_REQUEST)
        equip, created = Equipment.objects.get_or_create(
            name__iexact=name,
            defaults={'name': name, 'status': True}
        )
        return Response({'id': equip.id, 'name': equip.name}, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)


class CustomerExerciseDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, pk=None, title=None):
        from apps.trainer.workout_models import Workout
        from apps.trainer.api.serializers import WorkoutSerializer

        exercise_id = pk or request.query_params.get('id') or request.query_params.get('exercise_id')
        exercise_title = title or request.query_params.get('title') or request.query_params.get('name')

        if exercise_title:
            exercise_title = exercise_title.strip()
            # If the title is numeric, treat it as an exercise ID lookup
            if exercise_title.isdigit() and not exercise_id:
                exercise_id = int(exercise_title)
                exercise_title = None

        if not exercise_id and not exercise_title:
            return Response(
                {"error": "Either 'id', 'exercise_id', 'title', or 'name' query parameter is required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        from django.db.models import Q
        global_exercises_q = Q(created_by__isnull=True) | Q(created_by__is_staff=True) | Q(created_by__is_superuser=True) | Q(created_by__user_role__in=[1, 5, 10, 15])
        if request.user and request.user.is_authenticated:
            queryset = Workout.objects.filter(
                Q(status=True) & (global_exercises_q | Q(created_by=request.user))
            )
        else:
            queryset = Workout.objects.filter(global_exercises_q, status=True)
        workout = None

        if exercise_id:
            try:
                workout = queryset.get(pk=exercise_id)
            except (Workout.DoesNotExist, ValueError):
                pass

        if not workout and exercise_title:
            workout = queryset.filter(name__iexact=exercise_title).first()

        if not workout:
            return Response(
                {"error": f"Exercise with identifier '{exercise_title or exercise_id}' not found."},
                status=status.HTTP_404_NOT_FOUND
            )

        serializer = WorkoutSerializer(workout)
        return Response(serializer.data)

    def patch(self, request, pk=None):
        from apps.trainer.workout_models import Workout
        from apps.trainer.api.serializers import WorkoutSerializer

        exercise_id = pk or request.query_params.get('id') or request.query_params.get('exercise_id')
        if not exercise_id:
            return Response({'error': 'Exercise ID is required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            workout = Workout.objects.get(pk=exercise_id, created_by=request.user)
        except Workout.DoesNotExist:
            return Response({'error': 'Custom exercise not found or not owned by you.'}, status=status.HTTP_404_NOT_FOUND)

        serializer = WorkoutSerializer(workout, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk=None):
        from apps.trainer.workout_models import Workout

        exercise_id = pk or request.query_params.get('id') or request.query_params.get('exercise_id')
        if not exercise_id:
            return Response({'error': 'Exercise ID is required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            workout = Workout.objects.get(pk=exercise_id, created_by=request.user)
            workout.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Workout.DoesNotExist:
            return Response({'error': 'Custom exercise not found or not owned by you.'}, status=status.HTTP_404_NOT_FOUND)


class ToggleRestDayView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        cwp_id = request.query_params.get('customer_workout_plan_id')
        
        if cwp_id:
            from apps.trainer.workout_models import CustomerWorkoutPlan, WorkoutPlanDay
            try:
                cwp = CustomerWorkoutPlan.objects.get(pk=cwp_id, customer=customer)
            except CustomerWorkoutPlan.DoesNotExist:
                return Response({'error': 'CustomerWorkoutPlan not found.'}, status=status.HTTP_404_NOT_FOUND)

            plan_days = WorkoutPlanDay.objects.filter(plan=cwp.plan).order_by('day_number')
            
            data = []
            for pd in plan_days:
                s = WorkoutSession.objects.filter(
                    customer=customer,
                    customer_workout_plan=cwp,
                    plan_day=pd,
                    status='rest_day'
                ).last()
                
                # Calculate estimated date based on plan day number
                start_date = cwp.start_date or timezone.localdate()
                day_offset = pd.day_number - 1
                calculated_date = start_date + timezone.timedelta(days=day_offset)
                
                data.append({
                    'session_id': s.id if s else None,
                    'customer_workout_plan_id': cwp.id,
                    'plan_day_id': pd.id,
                    'date': (s.session_date if s else calculated_date).isoformat(),
                    'is_rest_day': s is not None,
                    'title': s.title if (s and s.title) else pd.title
                })
            return Response(data)
            
        queryset = WorkoutSession.objects.filter(
            customer=customer,
            status='rest_day'
        ).order_by('session_date', '-id')
        data = []
        seen_dates = set()
        for s in queryset:
            date_str = s.session_date.isoformat()
            if date_str in seen_dates:
                continue
            seen_dates.add(date_str)
            data.append({
                'session_id': s.id,
                'customer_workout_plan_id': s.customer_workout_plan_id,
                'plan_day_id': s.plan_day_id,
                'date': date_str,
                'is_rest_day': True,
                'title': s.title or s.plan_day.title
            })

        return Response(data)

    def post(self, request):
        from apps.trainer.workout_models import CustomerWorkoutPlan, WorkoutPlan, WorkoutPlanDay

        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        rest_days = request.data.get('rest_days')

        # Handle bulk request
        if rest_days is not None and isinstance(rest_days, list):
            global_cwp_id = request.data.get('customer_workout_plan_id')
            items_to_process = []
            
            # Step 1: Validation
            for idx, item in enumerate(rest_days):
                plan_day_id = item.get('plan_day_id')
                date_str = item.get('date')
                is_rest_day = item.get('is_rest_day', True)
                item_cwp_id = item.get('customer_workout_plan_id') or global_cwp_id

                if not plan_day_id or not date_str:
                    return Response({'error': f'Item at index {idx} requires plan_day_id and date.'}, status=status.HTTP_400_BAD_REQUEST)

                try:
                    session_date = date.fromisoformat(date_str)
                except ValueError:
                    return Response({'error': f'Invalid date format at index {idx}. Use YYYY-MM-DD.'}, status=status.HTTP_400_BAD_REQUEST)

                if session_date < timezone.localdate():
                    return Response({'error': f'Cannot mark past dates as a rest day (index {idx}).'}, status=status.HTTP_400_BAD_REQUEST)

                cwp = None
                plan_day = None
                try:
                    plan_day = WorkoutPlanDay.objects.get(pk=plan_day_id)
                except WorkoutPlanDay.DoesNotExist:
                    # Fallback lookup to prevent 404 errors (Self-healing mechanism)
                    if item_cwp_id:
                        cwp = CustomerWorkoutPlan.objects.filter(pk=item_cwp_id, customer=customer).first()
                    if not cwp:
                        cwp = CustomerWorkoutPlan.objects.filter(customer=customer, status='active').first()
                    
                    if cwp:
                        plan_day = WorkoutPlanDay.objects.filter(plan=cwp.plan).first()
                    
                    if not plan_day:
                        plan_day = WorkoutPlanDay.objects.filter(plan__customer=customer).first()
                        if plan_day:
                            cwp = CustomerWorkoutPlan.objects.filter(plan=plan_day.plan, customer=customer).first()
                    
                    if not plan_day:
                        fallback_plan = WorkoutPlan.objects.create(
                            customer=customer,
                            plan_name="Custom Workout",
                            description="ad-hoc session plan",
                            is_preset=False,
                            total_weeks=1,
                            total_days=7,
                            status=True
                        )
                        plan_day = WorkoutPlanDay.objects.create(
                            plan=fallback_plan,
                            day_number=1,
                            title="Day 1"
                        )
                        cwp = CustomerWorkoutPlan.objects.create(
                            customer=customer,
                            plan=fallback_plan,
                            status='active'
                        )

                if not cwp:
                    if item_cwp_id:
                        cwp = CustomerWorkoutPlan.objects.filter(pk=item_cwp_id, customer=customer).first()
                    if not cwp:
                        cwp = CustomerWorkoutPlan.objects.filter(plan=plan_day.plan, customer=customer).first()

                items_to_process.append({
                    'plan_day': plan_day,
                    'session_date': session_date,
                    'is_rest_day': is_rest_day,
                    'cwp': cwp
                })

            # Step 2: Processing
            results = []
            for item in items_to_process:
                plan_day = item['plan_day']
                session_date = item['session_date']
                is_rest_day = item['is_rest_day']
                cwp = item['cwp']

                if is_rest_day:
                    # Auto-delete any other sessions on this date for the customer to prevent duplicate/conflicting sessions
                    WorkoutSession.objects.filter(
                        customer=customer,
                        session_date=session_date
                    ).delete()
                else:
                    # If unmarking a rest day, delete any rest day sessions on this date
                    WorkoutSession.objects.filter(
                        customer=customer,
                        session_date=session_date,
                        status='rest_day'
                    ).delete()

                session, created = WorkoutSession.objects.get_or_create(
                    customer=customer,
                    customer_workout_plan=cwp,
                    plan_day=plan_day,
                    session_date=session_date,
                    defaults={
                        'status': 'rest_day' if is_rest_day else 'pending',
                        'title': plan_day.title
                    }
                )

                if not created:
                    if is_rest_day:
                        session.status = 'rest_day'
                    else:
                        session.status = 'pending'
                    session.save()

                if is_rest_day:
                    # Enforce only one rest day session per plan day for a customer to prevent duplicate entries
                    WorkoutSession.objects.filter(
                        customer=customer,
                        customer_workout_plan=cwp,
                        plan_day=plan_day,
                        session_date=session_date,
                        status='rest_day'
                    ).exclude(pk=session.pk).delete()

                # If it's not a rest day and has no logs, we can delete the session row to clean up
                if not is_rest_day and not session.logs.exists():
                    session.delete()
                    results.append({
                        'plan_day_id': plan_day.id,
                        'session_id': None,
                        'status': 'pending',
                        'is_rest_day': False
                    })
                else:
                    results.append({
                        'plan_day_id': plan_day.id,
                        'session_id': session.id,
                        'status': session.status,
                        'is_rest_day': session.status == 'rest_day'
                    })

            return Response({
                'success': True,
                'rest_days': results
            })

        # Handle single request (legacy/fallback)
        cwp_id = request.data.get('customer_workout_plan_id')
        plan_day_id = request.data.get('plan_day_id')
        date_str = request.data.get('date')
        is_rest_day = request.data.get('is_rest_day', True)

        if not plan_day_id or not date_str:
            return Response({'error': 'plan_day_id and date are required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            session_date = date.fromisoformat(date_str)
        except ValueError:
            return Response({'error': 'Invalid date format. Use YYYY-MM-DD.'}, status=status.HTTP_400_BAD_REQUEST)

        if session_date < timezone.localdate():
            return Response({'error': 'Cannot mark past dates as a rest day.'}, status=status.HTTP_400_BAD_REQUEST)

        cwp = None
        plan_day = None
        try:
            plan_day = WorkoutPlanDay.objects.get(pk=plan_day_id)
        except WorkoutPlanDay.DoesNotExist:
            # Fallback lookup to prevent 404 errors (Self-healing mechanism)
            if cwp_id:
                cwp = CustomerWorkoutPlan.objects.filter(pk=cwp_id, customer=customer).first()
            if not cwp:
                cwp = CustomerWorkoutPlan.objects.filter(customer=customer, status='active').first()
            
            if cwp:
                plan_day = WorkoutPlanDay.objects.filter(plan=cwp.plan).first()
            
            if not plan_day:
                plan_day = WorkoutPlanDay.objects.filter(plan__customer=customer).first()
                if plan_day:
                    cwp = CustomerWorkoutPlan.objects.filter(plan=plan_day.plan, customer=customer).first()
            
            if not plan_day:
                fallback_plan = WorkoutPlan.objects.create(
                    customer=customer,
                    plan_name="Custom Workout",
                    description="ad-hoc session plan",
                    is_preset=False,
                    total_weeks=1,
                    total_days=7,
                    status=True
                )
                plan_day = WorkoutPlanDay.objects.create(
                    plan=fallback_plan,
                    day_number=1,
                    title="Day 1"
                )
                cwp = CustomerWorkoutPlan.objects.create(
                    customer=customer,
                    plan=fallback_plan,
                    status='active'
                )

        if not cwp:
            if cwp_id:
                cwp = CustomerWorkoutPlan.objects.filter(pk=cwp_id, customer=customer).first()
            if not cwp:
                cwp = CustomerWorkoutPlan.objects.filter(plan=plan_day.plan, customer=customer).first()

        if is_rest_day:
            # Auto-delete any other sessions on this date for the customer to prevent duplicate/conflicting sessions
            WorkoutSession.objects.filter(
                customer=customer,
                session_date=session_date
            ).delete()
        else:
            # If unmarking a rest day, delete any rest day sessions on this date
            WorkoutSession.objects.filter(
                customer=customer,
                session_date=session_date,
                status='rest_day'
            ).delete()

        session, created = WorkoutSession.objects.get_or_create(
            customer=customer,
            customer_workout_plan=cwp,
            plan_day=plan_day,
            session_date=session_date,
            defaults={
                'status': 'rest_day' if is_rest_day else 'pending',
                'title': plan_day.title
            }
        )

        if not created:
            if is_rest_day:
                session.status = 'rest_day'
            else:
                session.status = 'pending'
            session.save()

        # Enforce only one rest day session per plan day for a customer to prevent duplicate entries
        if is_rest_day:
            WorkoutSession.objects.filter(
                customer=customer,
                customer_workout_plan=cwp,
                plan_day=plan_day,
                session_date=session_date,
                status='rest_day'
            ).exclude(pk=session.pk).delete()

        # If it's not a rest day and has no logs, we can delete the session row to clean up
        if not is_rest_day and not session.logs.exists():
            session.delete()
            return Response({
                'session_id': None,
                'status': 'pending',
                'is_rest_day': False
            })

        return Response({
            'session_id': session.id,
            'status': session.status,
            'is_rest_day': session.status == 'rest_day'
        })


def _initialize_default_presets(customer):
    from apps.trainer.workout_models import WorkoutPlan, WorkoutPlanDay, WorkoutPlanExercise, Workout, ExerciseSetTemplate
    from django.db.models import Q
    global_exercises_q = Q(created_by__isnull=True) | Q(created_by__is_staff=True) | Q(created_by__is_superuser=True) | Q(created_by__user_role__in=[1, 5, 10, 15])
    
    # Preset 1: Full Body Workout
    plan1 = WorkoutPlan.objects.create(
        customer=customer,
        plan_name="Full Body Workout",
        description="A complete full body workout targeting major muscle groups.",
        is_preset=True,
        total_weeks=1,
        total_days=1,
        status=True
    )
    day1 = WorkoutPlanDay.objects.create(plan=plan1, day_number=1, title="Full Body Day")
    global_workouts = Workout.objects.filter(global_exercises_q, status=True)[:3]
    for index, w in enumerate(global_workouts):
        ex = WorkoutPlanExercise.objects.create(plan_day=day1, workout=w, order_index=index + 1)
        ExerciseSetTemplate.objects.create(plan_exercise=ex, set_number=1, target_reps=10, target_weight=15.0)
        ExerciseSetTemplate.objects.create(plan_exercise=ex, set_number=2, target_reps=10, target_weight=15.0)

    # Preset 2: Push Day Focus
    plan2 = WorkoutPlan.objects.create(
        customer=customer,
        plan_name="Push Day Focus",
        description="Chest, shoulders, and triceps focus.",
        is_preset=True,
        total_weeks=1,
        total_days=1,
        status=True
    )
    day2 = WorkoutPlanDay.objects.create(plan=plan2, day_number=1, title="Push Day")
    global_workouts_2 = Workout.objects.filter(global_exercises_q, status=True)[3:5] if Workout.objects.filter(global_exercises_q, status=True).count() >= 5 else Workout.objects.filter(global_exercises_q, status=True)
    for index, w in enumerate(global_workouts_2):
        ex = WorkoutPlanExercise.objects.create(plan_day=day2, workout=w, order_index=index + 1)
        ExerciseSetTemplate.objects.create(plan_exercise=ex, set_number=1, target_reps=12, target_weight=10.0)
        ExerciseSetTemplate.objects.create(plan_exercise=ex, set_number=2, target_reps=12, target_weight=10.0)


class CustomerPresetListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from apps.trainer.workout_models import WorkoutPlan
        from .workout_serializers import CustomerPresetSerializer

        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        presets = WorkoutPlan.objects.filter(
            customer=customer,
            status=True,
            is_preset=True
        ).order_by('-created_at')

        return Response(CustomerPresetSerializer(presets, many=True).data)

    def post(self, request):
        from apps.trainer.workout_models import (
            WorkoutPlan, WorkoutPlanDay, WorkoutPlanExercise,
            Workout, WorkoutSession, ExerciseSetTemplate
        )
        from .workout_serializers import CustomerPresetSerializer

        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        session_id = request.data.get('session_id')

        if session_id:
            # --- Flow: Create preset FROM an existing session ---
            try:
                session = WorkoutSession.objects.get(pk=session_id, customer=customer)
            except WorkoutSession.DoesNotExist:
                return Response({'error': 'Workout session not found.'}, status=status.HTTP_404_NOT_FOUND)

            plan_name = (
                request.data.get('preset_title')
                or request.data.get('title')
                or request.data.get('plan_name')
                or session.title
                or "My Favorite Workout"
            )
            description = (
                request.data.get('description')
                or f"Preset saved from session on {session.session_date}"
            )

            plan = WorkoutPlan.objects.create(
                customer=customer,
                plan_name=plan_name,
                description=description,
                is_preset=True,
                total_weeks=1,
                total_days=1,
                status=True
            )
            plan_day = WorkoutPlanDay.objects.create(
                plan=plan,
                day_number=1,
                title=plan_name
            )

            logs = session.logs.all().order_by('id')
            for index, log in enumerate(logs):
                target_workout = log.plan_exercise.workout if log.plan_exercise else None
                if target_workout:
                    ex = WorkoutPlanExercise.objects.create(
                        plan_day=plan_day,
                        workout=target_workout,
                        order_index=index + 1
                    )
                    set_logs = log.set_logs.all().order_by('set_number')
                    for s in set_logs:
                        fallback_reps = None
                        fallback_weight = None
                        try:
                            if log.plan_exercise:
                                tmpl = log.plan_exercise.sets.filter(set_number=s.set_number).first()
                                if tmpl:
                                    fallback_reps = tmpl.target_reps
                                    fallback_weight = tmpl.target_weight
                        except Exception:
                            pass

                        ExerciseSetTemplate.objects.create(
                            plan_exercise=ex,
                            set_number=s.set_number,
                            target_reps=s.reps if s.reps is not None else fallback_reps,
                            target_weight=s.weight_kg if s.weight_kg is not None else fallback_weight,
                            rest_seconds=60,
                        )

            # Clean up the original ad-hoc plan
            original_plan = session.plan_day.plan if session.plan_day else None
            if original_plan and _is_adhoc_plan(original_plan):
                original_plan.status = False
                original_plan.plan_name = plan_name
                original_plan.save()
                if session.plan_day:
                    session.plan_day.title = plan_name
                    session.plan_day.save()
                from apps.trainer.models import CustomerWorkoutPlan
                CustomerWorkoutPlan.objects.filter(
                    customer=customer,
                    plan=original_plan,
                    status='active'
                ).update(status='cancelled')

            return Response(CustomerPresetSerializer(plan).data, status=status.HTTP_201_CREATED)

        # --- Flow: Create preset directly (from API docs 2.2) ---
        title = (
            request.data.get('title')
            or request.data.get('plan_name')
            or request.data.get('preset_title')
        )
        if not title or not str(title).strip():
            return Response({'error': 'plan_name or title is required.'}, status=status.HTTP_400_BAD_REQUEST)

        title = str(title).strip()
        description = request.data.get('description', '')

        exercises_data = request.data.get('exercises', [])
        # Support various legacy formats from Flutter developers
        if not exercises_data:
            ids = request.data.get('workout_ids') or request.data.get('exercise_ids') or request.data.get('exercises_ids')
            if ids and isinstance(ids, list):
                exercises_data = [{'workout_id': i} for i in ids]
        elif not isinstance(exercises_data, list):
            return Response({'error': 'exercises must be a list of objects.'}, status=status.HTTP_400_BAD_REQUEST)

        # Normalize and validate exercises
        validated_exercises = []
        if exercises_data:
            # If it's a simple list of values, normalize to dicts
            if not isinstance(exercises_data[0], dict):
                normalized = []
                for val in exercises_data:
                    try:
                        normalized.append({'workout_id': int(val)})
                    except (ValueError, TypeError):
                        return Response({'error': 'exercises list items must be objects or valid IDs.'}, status=status.HTTP_400_BAD_REQUEST)
                exercises_data = normalized

            for index, item in enumerate(exercises_data):
                if not isinstance(item, dict):
                    return Response({'error': f'Item at index {index} in exercises must be an object.'}, status=status.HTTP_400_BAD_REQUEST)

                workout_id = item.get('workout_id') or item.get('exercise_id') or item.get('id')
                if not workout_id:
                    return Response({'error': f'Item at index {index} in exercises requires a workout_id or exercise_id.'}, status=status.HTTP_400_BAD_REQUEST)

                try:
                    workout_id_int = int(workout_id)
                except (ValueError, TypeError):
                    return Response({'error': f'workout_id at index {index} must be an integer.'}, status=status.HTTP_400_BAD_REQUEST)

                try:
                    workout = Workout.objects.get(pk=workout_id_int)
                except Workout.DoesNotExist:
                    return Response({'error': f'Workout with ID {workout_id_int} at index {index} does not exist.'}, status=status.HTTP_400_BAD_REQUEST)

                order_index = item.get('order_index')
                if order_index is not None:
                    try:
                        order_index = int(order_index)
                    except (ValueError, TypeError):
                        return Response({'error': f'order_index at index {index} must be an integer.'}, status=status.HTTP_400_BAD_REQUEST)
                else:
                    order_index = index + 1

                sets_data = item.get('sets')
                validated_sets = []
                if sets_data is not None:
                    if not isinstance(sets_data, list):
                        return Response({'error': f'sets at index {index} must be a list.'}, status=status.HTTP_400_BAD_REQUEST)
                    for s_idx, s_item in enumerate(sets_data):
                        if not isinstance(s_item, dict):
                            return Response({'error': f'Set at index {s_idx} for exercise index {index} must be an object.'}, status=status.HTTP_400_BAD_REQUEST)

                        set_number = s_item.get('set_number')
                        if set_number is not None:
                            try:
                                set_number = int(set_number)
                            except (ValueError, TypeError):
                                return Response({'error': f'set_number at set index {s_idx} for exercise index {index} must be an integer.'}, status=status.HTTP_400_BAD_REQUEST)
                        else:
                            set_number = s_idx + 1

                        reps = s_item.get('reps') or s_item.get('target_reps')
                        weight = s_item.get('weight') or s_item.get('target_weight')
                        rest_seconds = s_item.get('rest_seconds')

                        if reps is not None:
                            try:
                                reps = int(reps)
                            except (ValueError, TypeError):
                                return Response({'error': f'reps at set index {s_idx} for exercise index {index} must be an integer.'}, status=status.HTTP_400_BAD_REQUEST)
                        else:
                            reps = 10

                        if weight is not None:
                            try:
                                weight = float(weight)
                            except (ValueError, TypeError):
                                return Response({'error': f'weight at set index {s_idx} for exercise index {index} must be a number.'}, status=status.HTTP_400_BAD_REQUEST)
                        else:
                            weight = 0.0

                        if rest_seconds is not None:
                            try:
                                rest_seconds = int(rest_seconds)
                            except (ValueError, TypeError):
                                return Response({'error': f'rest_seconds at set index {s_idx} for exercise index {index} must be an integer.'}, status=status.HTTP_400_BAD_REQUEST)
                        else:
                            rest_seconds = 60

                        validated_sets.append({
                            'set_number': set_number,
                            'target_reps': reps,
                            'target_weight': weight,
                            'rest_seconds': rest_seconds
                        })

                validated_exercises.append({
                    'workout': workout,
                    'order_index': order_index,
                    'sets': validated_sets
                })

        plan = WorkoutPlan.objects.create(
            customer=customer,
            plan_name=title,
            description=description,
            is_preset=True,
            total_weeks=1,
            total_days=1,
            status=True
        )
        plan_day = WorkoutPlanDay.objects.create(
            plan=plan,
            day_number=1,
            title=title
        )

        for item in validated_exercises:
            ex = WorkoutPlanExercise.objects.create(
                plan_day=plan_day,
                workout=item['workout'],
                order_index=item['order_index']
            )

            sets_list = item['sets']
            if not sets_list:
                # Default set if none provided
                ExerciseSetTemplate.objects.create(
                    plan_exercise=ex,
                    set_number=1,
                    target_reps=10,
                    target_weight=0.0,
                    rest_seconds=60,
                )
            else:
                for s in sets_list:
                    ExerciseSetTemplate.objects.create(
                        plan_exercise=ex,
                        set_number=s['set_number'],
                        target_reps=s['target_reps'],
                        target_weight=s['target_weight'],
                        rest_seconds=s['rest_seconds']
                    )

        return Response(CustomerPresetSerializer(plan).data, status=status.HTTP_201_CREATED)


class CustomerPresetDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, preset_id):
        from apps.trainer.workout_models import WorkoutPlan
        from .workout_serializers import CustomerPresetSerializer

        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            preset = WorkoutPlan.objects.get(pk=preset_id, customer=customer, is_preset=True)
            return Response(CustomerPresetSerializer(preset).data)
        except WorkoutPlan.DoesNotExist:
            return Response({'error': 'Preset not found.'}, status=status.HTTP_404_NOT_FOUND)

    def put(self, request, preset_id):
        return self.patch(request, preset_id)

    def patch(self, request, preset_id):
        from apps.trainer.workout_models import (
            WorkoutPlan, WorkoutPlanDay, WorkoutPlanExercise,
            Workout, ExerciseSetTemplate
        )
        from .workout_serializers import CustomerPresetSerializer

        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            preset = WorkoutPlan.objects.get(pk=preset_id, customer=customer, is_preset=True)
        except WorkoutPlan.DoesNotExist:
            return Response({'error': 'Preset not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Accept all three field name variants for title
        title = (
            request.data.get('title')
            or request.data.get('plan_name')
            or request.data.get('preset_title')
        )
        if title and str(title).strip():
            preset.plan_name = str(title).strip()
            preset.save()

        if 'description' in request.data:
            preset.description = request.data.get('description')
            preset.save()

        if 'exercises' in request.data:
            plan_day, _ = WorkoutPlanDay.objects.get_or_create(
                plan=preset,
                day_number=1,
                defaults={'title': preset.plan_name}
            )
            # Update plan_day title when preset title changes
            if title and str(title).strip():
                plan_day.title = str(title).strip()
                plan_day.save()

            WorkoutPlanExercise.objects.filter(plan_day=plan_day).delete()

            exercises_data = request.data.get('exercises', [])
            for index, item in enumerate(exercises_data):
                workout_id = item.get('workout_id') or item.get('exercise_id')
                if not workout_id:
                    continue
                try:
                    workout = Workout.objects.get(pk=workout_id)
                except Workout.DoesNotExist:
                    continue

                order_index = item.get('order_index', index + 1)
                ex = WorkoutPlanExercise.objects.create(
                    plan_day=plan_day,
                    workout=workout,
                    order_index=order_index
                )

                sets_data = item.get('sets', [])
                if not sets_data:
                    ExerciseSetTemplate.objects.create(
                        plan_exercise=ex,
                        set_number=1,
                        target_reps=10,
                        target_weight=0.0,
                        rest_seconds=60,
                    )
                else:
                    for s_item in sets_data:
                        set_number = s_item.get('set_number') or s_item.get('setNum')
                        if set_number is not None:
                            try:
                                set_number = int(set_number)
                            except (ValueError, TypeError):
                                set_number = 1
                        else:
                            set_number = 1
                        
                        reps = s_item.get('reps')
                        if reps is None:
                            reps = s_item.get('target_reps')
                        if reps is not None:
                            try:
                                reps = int(reps)
                            except (ValueError, TypeError):
                                reps = 10
                        else:
                            reps = 10

                        weight = s_item.get('weight')
                        if weight is None:
                            weight = s_item.get('target_weight')
                        if weight is not None:
                            try:
                                weight = float(weight)
                            except (ValueError, TypeError):
                                weight = 0.0
                        else:
                            weight = 0.0

                        ExerciseSetTemplate.objects.create(
                            plan_exercise=ex,
                            set_number=set_number,
                            target_reps=reps,
                            target_weight=weight,
                            rest_seconds=60,
                        )

        return Response(CustomerPresetSerializer(preset).data, status=status.HTTP_200_OK)

    def delete(self, request, preset_id):
        from apps.trainer.workout_models import WorkoutPlan

        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            preset = WorkoutPlan.objects.get(pk=preset_id, customer=customer, is_preset=True)
            preset.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except WorkoutPlan.DoesNotExist:
            return Response({'error': 'Preset not found.'}, status=status.HTTP_404_NOT_FOUND)


# ─── Assigned Workout Views ──────────────────────────────────────────────────


class CustomerAssignedWorkoutListView(APIView):
    """List workouts assigned to the customer by trainers/gyms."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        status_filter = request.query_params.get('status', 'active')

        cwps = CustomerWorkoutPlan.objects.filter(
            customer=customer,
            status=status_filter,
        ).exclude(
            plan__source_lookup='customer'  # We'll filter in Python instead
        ).select_related('plan', 'trainer', 'plan__trainer', 'plan__organization')

        # Filter to only trainer/gym assigned plans (not customer-created)
        results = []
        for cwp in cwps:
            plan = cwp.plan
            source = plan.source  # 'customer', 'trainer', or 'gym'
            if source == 'customer':
                continue

            trainer_name = None
            if cwp.trainer:
                trainer_name = f"{cwp.trainer.first_name} {cwp.trainer.last_name}".strip()
            elif plan.trainer:
                trainer_name = f"{plan.trainer.first_name} {plan.trainer.last_name}".strip()

            total_days = plan.total_days or (plan.total_weeks * 7)
            day_count = plan.days.count()

            results.append({
                'customer_workout_plan_id': cwp.id,
                'plan_id': plan.id,
                'plan_name': cwp.title or plan.plan_name,
                'description': plan.description,
                'source': source,
                'trainer_name': trainer_name,
                'total_days': total_days,
                'day_count': day_count,
                'start_date': cwp.start_date.isoformat() if cwp.start_date else None,
                'status': cwp.status,
                'created_at': cwp.created_at.isoformat() if cwp.created_at else None,
            })

        return Response(results)


class CustomerAssignedWorkoutDetailView(APIView):
    """Detailed view of an assigned workout plan with days, exercises, sets."""
    permission_classes = [IsAuthenticated]

    def get(self, request, cwp_id):
        from apps.trainer.api.serializers import WorkoutPlanExerciseSerializer
        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            cwp = CustomerWorkoutPlan.objects.select_related('plan', 'trainer').get(
                pk=cwp_id, customer=customer
            )
        except CustomerWorkoutPlan.DoesNotExist:
            return Response({'error': 'Assigned workout not found.'}, status=status.HTTP_404_NOT_FOUND)

        plan = cwp.plan
        days = WorkoutPlanDay.objects.filter(plan=plan).order_by('day_number')

        trainer_name = None
        if cwp.trainer:
            trainer_name = f"{cwp.trainer.first_name} {cwp.trainer.last_name}".strip()
        elif plan.trainer:
            trainer_name = f"{plan.trainer.first_name} {plan.trainer.last_name}".strip()

        days_data = []
        for day in days:
            exercises = WorkoutPlanExercise.objects.filter(
                plan_day=day
            ).order_by('order_index').select_related('workout')

            session = WorkoutSession.objects.filter(
                customer=customer,
                customer_workout_plan=cwp,
                plan_day=day,
            ).last()

            days_data.append({
                'plan_day_id': day.id,
                'day_number': day.day_number,
                'title': day.title,
                'exercise_count': exercises.count(),
                'is_completed': session.status == 'completed' if session else False,
                'session_id': session.id if session else None,
                'session_status': session.status if session else None,
                'started_at': session.started_at.isoformat() if (session and session.started_at) else None,
                'completed_at': session.completed_at.isoformat() if (session and session.completed_at) else None,
                'duration': (
                    f"{int((session.completed_at - session.started_at).total_seconds() // 60)}m" 
                    if (session and session.started_at and session.completed_at) 
                    else None
                ),
                'exercises': WorkoutPlanExerciseSerializer(exercises, many=True).data,
            })

        return Response({
            'customer_workout_plan_id': cwp.id,
            'plan_id': plan.id,
            'plan_name': cwp.title or plan.plan_name,
            'description': plan.description,
            'source': plan.source,
            'trainer_name': trainer_name,
            'total_days': plan.total_days or (plan.total_weeks * 7),
            'start_date': cwp.start_date.isoformat() if cwp.start_date else None,
            'status': cwp.status,
            'days': days_data,
        })


class CustomerAssignedWorkoutSessionView(APIView):
    """Start a session for an assigned workout plan day."""
    permission_classes = [IsAuthenticated]

    def post(self, request, cwp_id):
        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            cwp = CustomerWorkoutPlan.objects.get(pk=cwp_id, customer=customer)
        except CustomerWorkoutPlan.DoesNotExist:
            return Response({'error': 'Assigned workout not found.'}, status=status.HTTP_404_NOT_FOUND)

        plan_day_id = request.data.get('plan_day_id')
        if not plan_day_id:
            # Default to current day based on plan start date
            today = timezone.localdate()
            day_offset = (today - cwp.start_date).days + 1 if cwp.start_date else 1
            plan_day = WorkoutPlanDay.objects.filter(
                plan=cwp.plan, day_number=day_offset
            ).first()
            if not plan_day:
                plan_day = WorkoutPlanDay.objects.filter(plan=cwp.plan).first()
        else:
            try:
                plan_day = WorkoutPlanDay.objects.get(pk=plan_day_id, plan=cwp.plan)
            except WorkoutPlanDay.DoesNotExist:
                return Response({'error': 'Plan day not found.'}, status=status.HTTP_404_NOT_FOUND)

        if not plan_day:
            return Response({'error': 'No plan day found for this workout.'}, status=status.HTTP_404_NOT_FOUND)

        # Reuse StartWorkoutSessionView logic by delegating
        from django.http import QueryDict
        request.data['customer_workout_plan_id'] = cwp.id
        request.data['plan_day_id'] = plan_day.id

        start_view = StartWorkoutSessionView()
        start_view.request = request
        return start_view.post(request)


# ─── Customer Workout History ────────────────────────────────────────────────


class CustomerOwnWorkoutHistoryView(APIView):
    """Customer's own workout history - completed sessions grouped by date."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from collections import defaultdict
        customer = _get_customer(request)
        if not customer:
            return Response({'error': 'Customer profile not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Date range filtering
        start_date_str = request.query_params.get('start_date')
        end_date_str = request.query_params.get('end_date')

        sessions_qs = WorkoutSession.objects.filter(
            customer=customer,
            status='completed',
        ).select_related(
            'plan_day', 'plan_day__plan', 'customer_workout_plan'
        ).order_by('-session_date', '-completed_at')

        if start_date_str:
            try:
                sessions_qs = sessions_qs.filter(session_date__gte=date.fromisoformat(start_date_str))
            except ValueError:
                pass

        if end_date_str:
            try:
                sessions_qs = sessions_qs.filter(session_date__lte=date.fromisoformat(end_date_str))
            except ValueError:
                pass

        # Limit to last 100 sessions max
        sessions_qs = sessions_qs[:100]

        grouped = defaultdict(list)
        for session in sessions_qs:
            date_key = session.session_date.isoformat()

            # Get exercise details for this session
            logs = WorkoutLog.objects.filter(
                session=session
            ).select_related('plan_exercise__workout')

            exercises = []
            total_sets = 0
            total_volume = 0

            for log in logs:
                exercise_name = log.plan_exercise.workout.name if log.plan_exercise and log.plan_exercise.workout else "Unknown"
                completed_sets = log.set_logs.filter(is_completed=True)
                sets_count = completed_sets.count()
                total_sets += sets_count

                for s in completed_sets:
                    if s.weight_kg and s.reps:
                        total_volume += float(s.weight_kg) * int(s.reps)

                exercises.append({
                    'exercise_name': exercise_name,
                    'sets_completed': sets_count,
                    'total_sets': log.set_logs.count(),
                })

            plan = session.plan_day.plan if session.plan_day else None
            source = plan.source if plan else 'customer'
            trainer_name = None
            cwp = session.customer_workout_plan
            if cwp and cwp.trainer:
                trainer_name = f"{cwp.trainer.first_name} {cwp.trainer.last_name}".strip()

            grouped[date_key].append({
                'session_id': session.id,
                'title': session.title or 'Workout',
                'source': source,
                'trainer_name': trainer_name,
                'started_at': session.started_at.isoformat() if session.started_at else None,
                'completed_at': session.completed_at.isoformat() if session.completed_at else None,
                'exercise_count': len(exercises),
                'total_sets': total_sets,
                'total_volume': round(total_volume, 2),
                'exercises': exercises,
            })

        result = [{'date': d, 'sessions': v} for d, v in sorted(grouped.items(), reverse=True)]
        return Response(result)

