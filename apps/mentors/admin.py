from django.contrib import admin
from apps.mentors.models import MentorProfile, TrainerCertificate

# Register your models here.

class TrainerCertificateInline(admin.TabularInline):
    model = TrainerCertificate
    extra = 1
    readonly_fields = ('uploaded_at',)


@admin.register(MentorProfile)
class MentorProfileAdmin(admin.ModelAdmin):
    list_display = ('id', 'get_user_name', 'organization', 'designation', 'experience', 'emergency_contact', 'is_active')
    list_filter = ('designation', 'organization')
    search_fields = ('user__first_name', 'user__last_name', 'user__mobile_number', 'organization__name')
    inlines = [TrainerCertificateInline]

    def get_user_name(self, obj):
        if obj.user:
            return f"{obj.user.first_name} {obj.user.last_name}"
        return "-"
    get_user_name.short_description = "Mentor"

    def is_active(self, obj):
        return obj.user.is_active if obj.user else False
    is_active.boolean = True


@admin.register(TrainerCertificate)
class TrainerCertificateAdmin(admin.ModelAdmin):
    list_display = ('id', 'mentor_profile', 'uploaded_at')
    list_filter = ('uploaded_at',)
    search_fields = ('mentor_profile__user__first_name', 'mentor_profile__user__last_name')