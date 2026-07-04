from rest_framework import viewsets, permissions

from apps.mentors.api.serializers import TrainerReadSerializer, TrainerSerializer
from apps.user.models import User
from rest_framework.decorators import action
from apps.fitnesscenter.models import Category
from rest_framework.response import Response
from rest_framework import status

from apps.utils.permission import MentorOnlyPermission


class TrainerViewSet(viewsets.ModelViewSet):
    queryset = User.objects.filter(user_role=User.MENTOR_TRAINER)
    permission_classes = [MentorOnlyPermission]

    def get_serializer_class(self):
        if self.request.method in ['GET', 'HEAD']:
            return TrainerReadSerializer
        return TrainerSerializer
    
    @action(detail=True, methods=['post'])
    def add_categories(self, request, pk=None):
        trainer = self.get_object()
        mentor = trainer.mentor_profile
        
        category_ids = request.data.get('category_ids', [])
        if not category_ids:
            return Response(
                {"detail": "No category IDs provided"}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        invalid_ids = []
        valid_ids = []
        for category_id in category_ids:
            if not Category.objects.filter(id=category_id).exists():
                invalid_ids.append(category_id)
            else:
                valid_ids.append(category_id)
        
        if invalid_ids:
            return Response(
                {
                    "detail": "Invalid category IDs provided",
                    "invalid_ids": invalid_ids
                },
                status=status.HTTP_400_BAD_REQUEST
            )
            
        categories = Category.objects.filter(id__in=valid_ids)
        for category in categories:
            mentor.categories.add(category)
            
        serializer = self.get_serializer(trainer)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def remove_categories(self, request, pk=None):
        trainer = self.get_object()
        mentor = trainer.mentor_profile
        
        category_ids = request.data.get('category_ids', [])
        if not category_ids:
            return Response(
                {"detail": "No category IDs provided"}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        invalid_ids = []
        valid_ids = []
        existing_category_ids = mentor.categories.values_list('id', flat=True)
        
        for category_id in category_ids:
            if not Category.objects.filter(id=category_id).exists():
                invalid_ids.append(category_id)
            elif category_id not in existing_category_ids:
                invalid_ids.append(category_id)
            else:
                valid_ids.append(category_id)
        
        if invalid_ids:
            return Response(
                {
                    "detail": "Invalid or unassigned category IDs provided",
                    "invalid_ids": invalid_ids
                },
                status=status.HTTP_400_BAD_REQUEST
            )
            
        # Remove specified valid categories
        mentor.categories.remove(*valid_ids)
            
        serializer = self.get_serializer(trainer)
        return Response(serializer.data)