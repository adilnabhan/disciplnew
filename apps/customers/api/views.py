from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.generics import ListAPIView, RetrieveAPIView
from rest_framework import viewsets
from rest_framework.decorators import (
    api_view,
    permission_classes,
)

from apps.customers.api.serializers import ActiveCustomerMembershipDetailSerializer, CustomerDetailSerializer, CustomerHealthUpdateSerializer, CustomerReviewSerializer, CustomerSerializer, CustomerTransactionSerializer, FitnesscenterDetailSerializer, MembershipPlanSerializer, OrganizationSerializer, ChoicesSerializer, PaymentHistorySerializer
from apps.customers.models import Customer, CustomerMembership, CustomerMembershipTransaction, CustomerReview, Injury, MedicalCondition, Profession, JobSatisfaction, WorkingHours
from django.db import transaction

from apps.fitnesscenter.models import BankAccountDetails, MembershipPlan, Organization
from apps.utils.distance_calculation import get_distance_from_google
from apps.utils.pagination import CustomPagination
from apps.utils.permission import CustomerOnlyPermission, MentorOnlyPermission
import math

from django.db.models import Q, Prefetch
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
from datetime import datetime, timedelta
from django.utils.timezone import now

from django.contrib.gis.db.models.functions import Distance
from django.contrib.gis.geos import Point




class CustomerCreateView(APIView):
    permission_classes = [MentorOnlyPermission]

    def post(self, request):
        membership_plan_id = request.data.get('membership_plan_id')
        serializer = CustomerSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        customer = serializer.save(membership_plan_id=membership_plan_id)
        return Response(
            CustomerDetailSerializer(customer, context={'request': request}).data,
            status=status.HTTP_201_CREATED
        )

class CustomerUpdateView(APIView):
    permission_classes = [AllowAny]
    
    @transaction.atomic
    def patch(self, request, pk):
        """Partial update: only provided fields are updated"""
        try:
            customer = Customer.objects.get(pk=pk)
        except Customer.DoesNotExist:
            return Response(
                {"error": "Customer not found"},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Use the main serializer with partial=True to allow updating any field
        serializer = CustomerSerializer(customer, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        customer = serializer.save()
        return Response(CustomerDetailSerializer(customer, context={'request': request}).data)
    
    @transaction.atomic
    def put(self, request, pk):
        """Full update: all required fields must be provided"""
        try:
            customer = Customer.objects.get(pk=pk)
        except Customer.DoesNotExist:
            return Response(
                {"error": "Customer not found"},
                status=status.HTTP_404_NOT_FOUND
            )
        
        serializer = CustomerSerializer(customer, data=request.data)
        serializer.is_valid(raise_exception=True)
        customer = serializer.save()
        return Response(CustomerDetailSerializer(customer, context={'request': request}).data)
    

class CustomerDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        try:
            customer = Customer.objects.get(pk=pk)
        except Customer.DoesNotExist:
            return Response(
                {"error": "Customer not found"},
                status=status.HTTP_404_NOT_FOUND
            )
        return Response(CustomerDetailSerializer(customer, context={'request': request}).data)


    

class NearestFitnessCenterListAPIView(ListAPIView):
    serializer_class = OrganizationSerializer
    permission_classes = [AllowAny]
    pagination_class = CustomPagination

    def get_queryset(self):
        lat = self.request.query_params.get("lat")
        lon = self.request.query_params.get("lon")
        registration_status = self.request.query_params.get('registration_status')

        # Default: show all active public gyms regardless of registration status
        # Use ?registration_status=verified to show only bank-verified gyms
        queryset = Organization.objects.filter(
            active=True,
            is_public=True,
        ).select_related("location").prefetch_related("category")

        if registration_status:
            queryset = queryset.filter(registration_status=registration_status)

        search = self.request.query_params.get('search')
        category_id = self.request.query_params.get('category_id')

        if search:
            queryset = queryset.filter(
                Q(name__icontains=search) |
                Q(location__city__icontains=search) |
                Q(location__state__icontains=search) |
                Q(location__building_name__icontains=search)
            )
        if category_id:
            queryset = queryset.filter(category__id=category_id)

        if lat and lon:
            try:
                user_location = Point(float(lon), float(lat), srid=4326)
                queryset = queryset.annotate(
                    distance=Distance("location__location", user_location)
                ).order_by("distance")
            except (ValueError, TypeError):
                pass

        return queryset

    # Haversine formula for fallback distance calculation
    def calculate_distance(self, lat1, lon1, lat2, lon2):
        R = 6371  # Earth radius in KM
        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lon2 - lon1)
        a = (
            math.sin(dlat / 2) ** 2
            + math.cos(math.radians(lat1))
            * math.cos(math.radians(lat2))
            * math.sin(dlon / 2) ** 2
        )
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        return R * c

    def list(self, request, *args, **kwargs):
        lat = request.query_params.get("lat")
        lon = request.query_params.get("lon")
        radius_km = request.query_params.get("radius_km", 50)

        try:
            radius_km = float(radius_km)
        except ValueError:
            radius_km = 50

        queryset = self.get_queryset()

        # If coordinates not given → return all gyms with pagination
        if not lat or not lon:
            page = self.paginate_queryset(queryset)
            if page is not None:
                serializer = self.get_serializer(page, many=True)
                return self.get_paginated_response(serializer.data)
            serializer = self.get_serializer(queryset, many=True)
            return Response(serializer.data)

        try:
            lat = float(lat)
            lon = float(lon)
        except ValueError:
            return Response({"error": "Invalid latitude or longitude"}, status=400)

        gyms = []
        for org in queryset:
            location = getattr(org, "location", None)
            if not location:
                continue
            if location.latitude is None or location.longitude is None:
                continue
            try:
                lat2 = float(location.latitude)
                lon2 = float(location.longitude)
            except (ValueError, TypeError):
                continue

            distance_km = self.calculate_distance(lat, lon, lat2, lon2)
            if distance_km <= radius_km:
                data = self.get_serializer(org).data
                data["distance_km"] = round(distance_km, 2)
                gyms.append(data)

        gyms.sort(key=lambda x: x["distance_km"])

        return Response({
            "count": len(gyms),
            "next": None,
            "previous": None,
            "results": gyms
        })
    
    
class OrganizationDetailAPIView(RetrieveAPIView):
    queryset = Organization.objects.select_related('location').prefetch_related(
        'working_days', 'social_media', 'amenities__amenity',
        'category', 'photos', 'packages'
    )
    serializer_class = FitnesscenterDetailSerializer
    permission_classes = [AllowAny]
    lookup_field = 'id'

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context
    

@api_view()
@permission_classes((IsAuthenticated,))
def get_injuries(request):
    name = request.GET.get('name', '')
    queryset = Injury.objects.filter(is_active=True)
    if name:
        queryset = queryset.filter(name__icontains=name)
    data = queryset.values('id', 'name').order_by('display_order')
    return JsonResponse({
        'results': list(data)
    }, safe=False)
    
    
@api_view()
@permission_classes((IsAuthenticated,))
def get_medical_conditions(request):
    name = request.GET.get('name', '')
    queryset = MedicalCondition.objects.all()
    if name:
        queryset = queryset.filter(name__icontains=name)
    data = queryset.values('id', 'name').order_by('display_order')
    return JsonResponse({
        'results': list(data)
    }, safe=False)
    
    
class UpdateCustomerHealthAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get_customer(self, request):
        try:
            return request.user.customer
        except Customer.DoesNotExist:
            return None

    def patch(self, request):
        customer = self.get_customer(request)
        if not customer:
            return Response({"detail": "Customer profile not found."}, status=status.HTTP_404_NOT_FOUND)

        serializer = CustomerHealthUpdateSerializer(customer, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({"detail": "Customer profile updated.",})
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class CustomerReviewViewSet(viewsets.ModelViewSet):
    permission_classes = [CustomerOnlyPermission]
    serializer_class = CustomerReviewSerializer

    def get_queryset(self):
        return CustomerReview.objects.filter(customer=self.request.user.customer)

    def perform_create(self, serializer):
        serializer.save(
            customer=self.request.user.customer,
            organization_id=self.request.data.get('organization')
        )
        
        
class OrganizationMembershipPlansAPIView(APIView):
    """
    Get the active membership plan against an organization.
    """
    permission_classes = [CustomerOnlyPermission]
    
    def get(self, request, organization_id):
        organization = get_object_or_404(Organization, id=organization_id)
        plans = MembershipPlan.objects.filter(organization=organization, is_active=True)
        serializer = MembershipPlanSerializer(plans, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    
class ActiveCustomerMembershipAPIView(APIView):
    """
    Get the active membership for a customer (with organization details).
    """
    permission_classes = [CustomerOnlyPermission]

    def get(self, request, customer_id):
        customer = get_object_or_404(Customer, id=customer_id)
        customer.check_and_update_membership_status()
        
        active_membership = (
            CustomerMembership.objects
            .filter(customer=customer, status__in=['Active', 'Trial'], is_active=True)
            .select_related('membership__organization')
            .first()
        )
        
        if not active_membership:
            # Fallback to the most recent expired membership so the client app can display expired details
            active_membership = (
                CustomerMembership.objects
                .filter(customer=customer, status='Expired')
                .select_related('membership__organization')
                .order_by('-end_date')
                .first()
            )

        if not active_membership:
            if customer.organization:
                from apps.customers.api.serializers import OrganizationNestedSerializer
                org_data = OrganizationNestedSerializer(customer.organization, context={'request': request}).data
                fallback_data = {
                    'id': None,
                    'organization': org_data,
                    'plan_id': None,
                    'plan_name': None,
                    'package_type': None,
                    'amount': "0.00",
                    'start_date': None,
                    'end_date': None,
                    'is_emi_available': False,
                    'status': 'Pending',
                    'payment_type': 'Full Payment',
                    'payment_status': 'Pending',
                    'is_active': False,
                    'created_at': None,
                    'updated_at': None
                }
                return Response(fallback_data, status=status.HTTP_200_OK)
            return Response({"detail": "No active membership found."}, status=status.HTTP_404_NOT_FOUND)

        serializer = ActiveCustomerMembershipDetailSerializer(active_membership, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    
class CustomerMembershipOrganizationListAPIView(APIView):
    """
        Customer previous and current organization with review
    """
    permission_classes = [CustomerOnlyPermission]

    def get(self, request):
        customer = request.user.customer
        status_param = request.GET.get("status", "all").lower()  # 'active', 'expired', 'all'

        status_filter = {
            "active": ["Active"],
            "expired": ["Expired"],
            "all": ["Active", "Expired"]
        }.get(status_param, ["Active", "Expired"])

        memberships = CustomerMembership.objects.filter(
            customer=customer,
            status__in=status_filter
        ).select_related('membership__organization')

        reviews = CustomerReview.objects.filter(customer=customer)
        review_map = {review.organization_id: review for review in reviews}

        response_data = []

        for membership in memberships:
            org = membership.membership.organization
            org_review = review_map.get(org.id)

            data = {
                "organization_id": org.id,
                "organization_name": org.name,
                "logo": org.logo.url if org.logo else None,
                "membership_status": membership.status,
                "review_added": bool(org_review),
                "review": {
                    "rating": org_review.rating,
                    "comment": org_review.comment
                } if org_review else None
            }

            response_data.append(data)

        return Response({
            "status": status_param,
            "memberships": response_data
        })
        

class CustomerPaymentHistoryAPIView(APIView):
    permission_classes = [CustomerOnlyPermission]

    def get(self, request):
        customer = request.user.customer
        sort_type = request.query_params.get('sort', 'last_6_months')
        now_dt = now()

        # --- FILTER FUNCTIONS SHARED BY BOTH MODELS ---
        def apply_filters(queryset):
            """Applies the same filters to both Transaction and Membership models"""

            if sort_type == 'last_6_months':
                cutoff = now_dt - timedelta(days=180)
                return queryset.filter(created_at__gte=cutoff) if hasattr(queryset.model, 'created_at') \
                    else queryset.filter(payment_date__gte=cutoff)

            elif sort_type == 'year':
                year = request.query_params.get('year')
                if not year:
                    raise ValueError("year_required")
                try:
                    year = int(year)
                except:
                    raise ValueError("invalid_year")

                start = datetime(year, 1, 1)
                end = datetime(year, 12, 31, 23, 59, 59)

                return queryset.filter(created_at__range=(start, end)) if hasattr(queryset.model, 'created_at') \
                    else queryset.filter(payment_date__range=(start, end))

            elif sort_type == 'custom':
                start = request.query_params.get('start_date')
                end = request.query_params.get('end_date')
                if not (start and end):
                    raise ValueError("custom_required")

                try:
                    start_dt = datetime.strptime(start, '%Y-%m-%d')
                    end_dt = datetime.strptime(end, '%Y-%m-%d')
                except:
                    raise ValueError("invalid_date")

                return queryset.filter(created_at__range=(start_dt, end_dt)) if hasattr(queryset.model, 'created_at') \
                    else queryset.filter(payment_date__range=(start_dt, end_dt))

            else:
                raise ValueError("invalid_sort")

        # -------------------------------
        # 1️⃣ FIRST TRY TO FETCH TRANSACTIONS
        # -------------------------------

        tx_qs = CustomerMembershipTransaction.objects.select_related(
            'membership__organization'
        ).filter(customer=customer)

        # Apply filters safely
        try:
            tx_qs = apply_filters(tx_qs)
        except ValueError as e:
            if str(e) == "year_required":
                return Response({"error": "year parameter is required for sort=year"}, status=400)
            if str(e) == "invalid_year":
                return Response({"error": "Invalid year format"}, status=400)
            if str(e) == "custom_required":
                return Response({"error": "start_date and end_date are required for sort=custom"}, status=400)
            if str(e) == "invalid_date":
                return Response({"error": "Invalid date format, use YYYY-MM-DD"}, status=400)
            return Response({"error": "Invalid sort type"}, status=400)

        tx_qs = tx_qs.order_by('-payment_date')

        if tx_qs.exists():
            paginator = CustomPagination()
            page = paginator.paginate_queryset(tx_qs, request)
            serializer = CustomerTransactionSerializer(page, many=True)
            return paginator.get_paginated_response(serializer.data)

        # -------------------------------
        # 2️⃣ OTHERWISE RETURN PENDING MEMBERSHIP ("Processing Payment")
        # -------------------------------

        membership_qs = CustomerMembership.objects.select_related(
            'membership__organization'
        ).filter(
            customer=customer,
            # payment_status='initiated'    # adjust to your field
        )
        print("membership", membership_qs, customer)

        # Apply same filters
        try:
            membership_qs = apply_filters(membership_qs)
        except:
            pass  # ignore because no results is fine

        membership_qs = membership_qs.order_by('-created_at')

        paginator = CustomPagination()
        page = paginator.paginate_queryset(membership_qs, request)
        serializer = CustomerTransactionSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)

        
        
class CustomerHomePageAPIView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        customer = getattr(request.user, 'customer', None)
        if customer:
            from apps.customers.api.workout_views import _cleanup_empty_sessions
            _cleanup_empty_sessions(customer)

        # image_filenames = ["gym_image_1.png", "gym_image_2.png"]
        # image_filenames_2 = ["banner1.png", "banner2.png", "banner3.png"]
        # home_banners = [request.build_absolute_uri(f"/cdn/images/{filename}") for filename in image_filenames]
        # discipl_banners = [request.build_absolute_uri(f"/cdn/images/{filename}") for filename in image_filenames_2]
        home_banners = ["https://s3.ap-southeast-1.wasabisys.com/discipl-habitoz/media/banner_images/gym_image_1.png",
                        "https://s3.ap-southeast-1.wasabisys.com/discipl-habitoz/media/banner_images/gym_image_2.png"]
        
        discipl_banners = ["https://s3.ap-southeast-1.wasabisys.com/discipl-habitoz/media/banner_images/gym_banner1.png",
                           "https://s3.ap-southeast-1.wasabisys.com/discipl-habitoz/media/banner_images/gym_banner2.png",
                           "https://s3.ap-southeast-1.wasabisys.com/discipl-habitoz/media/banner_images/gymbanner3.png"]

        data = {
            "is_subscribed": False,
            "subscription": None,
            "banners": home_banners,
            "discipl_banners": discipl_banners
        }
        if customer is not None:

            active_membership = (
                CustomerMembership.objects
                .select_related('membership__organization')
                .filter(customer=customer, status='Active', is_active=True)
                .first()
            )

            if active_membership:
                membership = active_membership.membership
                org = membership.organization

                data["is_subscribed"] = True
                data["subscription"] = {
                    "organization_name": org.name,
                    "organization_logo": org.logo.url if org.logo else None,
                    "plan_name": membership.name,
                    "duration_days": membership.duration_days,
                    "start_date": active_membership.start_date,
                    "end_date": active_membership.end_date,
                }

            if customer.trainer:
                from apps.trainer.models import TrainerSpecialization
                specializations = list(
                    TrainerSpecialization.objects.filter(trainer=customer.trainer)
                    .values_list('specialization__name', flat=True)
                )
                data["assigned_trainer"] = {
                    "id": customer.trainer.id,
                    "name": f"{customer.trainer.first_name} {customer.trainer.last_name}".strip(),
                    "profile_image": customer.trainer.profile_image.url if customer.trainer.profile_image else None,
                    "mobile": customer.trainer.mobile,
                    "experience_years": customer.trainer.experience_years,
                    "bio": customer.trainer.bio,
                    "specializations": specializations,
                }
            else:
                data["assigned_trainer"] = None

        return Response(data, status=status.HTTP_200_OK)
    


# choice view

    
class ChoicesAPIView(APIView):
    """
    API to get all profession, job satisfaction, and working hours choices
    """
   
    permission_classes = [AllowAny]  
    
    def get(self, request):
        """Return all choices for dropdown"""
        serializer = ChoicesSerializer({})
        return Response({
            'success': True,
            'data': serializer.data
        }, status=status.HTTP_200_OK)
    

class CustomerPaymentDetailHistoryAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        try:
            customer = Customer.objects.get(user=user)
        except Customer.DoesNotExist:
            return Response({"error": "Customer not found"}, status=404)

        memberships = (
            CustomerMembership.objects
            .filter(customer=customer)
            .select_related("membership", "emi_plan")
            .prefetch_related("payments")
            .order_by("-created_at")
        )

        serializer = PaymentHistorySerializer({
            "customer_id": customer.id,
            "memberships": memberships
        })
        return Response(serializer.data)


# ============================================
# Membership Request Views (Customer-side)
# ============================================

from apps.customers.api.serializers import MembershipRequestCreateSerializer, MembershipRequestSerializer
from apps.customers.models import MembershipRequest


class MembershipRequestCreateView(APIView):
    """Customer creates a membership request for a gym."""
    permission_classes = [CustomerOnlyPermission]

    def post(self, request):
        from apps.communication.notifications import send_push_to_organization_mentor
        serializer = MembershipRequestCreateSerializer(
            data=request.data,
            context={'request': request}
        )
        serializer.is_valid(raise_exception=True)
        membership_request = serializer.save()

        # Send push notification to the gym's mentor
        send_push_to_organization_mentor(
            organization=membership_request.organization,
            title="New Membership Request! 🏋️",
            body=f"{request.user.full_name} has requested a membership at your gym.",
            data={
                "type": "membership_request_received",
                "request_id": str(membership_request.id),
                "organization_id": str(membership_request.organization.id),
            }
        )

        return Response(
            MembershipRequestSerializer(membership_request, context={'request': request}).data,
            status=status.HTTP_201_CREATED
        )


class CustomerMembershipRequestListView(APIView):
    """Customer views their own membership requests."""
    permission_classes = [CustomerOnlyPermission]

    def get(self, request):
        customer = request.user.customer
        status_filter = request.query_params.get('status')

        queryset = MembershipRequest.objects.filter(
            customer=customer
        ).select_related(
            'organization', 'membership_plan', 'selected_plan'
        )

        if status_filter:
            queryset = queryset.filter(status=status_filter)

        queryset = queryset.order_by('-requested_at')

        serializer = MembershipRequestSerializer(
            queryset, many=True, context={'request': request}
        )
        return Response(serializer.data, status=status.HTTP_200_OK)




