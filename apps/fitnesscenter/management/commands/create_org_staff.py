"""
Management command to create a restricted staff user for managing
specific Organization(s) in the Django admin.

Usage
-----
    # Create staff user assigned to org id 3
    python manage.py create_org_staff staffuser1 Password@123 --org-id 3

    # Create staff user assigned to multiple orgs
    python manage.py create_org_staff staffuser1 Password@123 --org-id 3 --org-id 7

    # Create staff user assigned to org by name (partial match)
    python manage.py create_org_staff staffuser1 Password@123 --org-name "Gold Gym"

The created user will:
  • Be a Django staff user (is_staff=True)
  • Have ONLY change permission on Organization, Location, WorkingDay, 
    OrganizationPhoto, SocialMedia
  • NOT be a superuser
  • See only the assigned Organization(s) in the admin panel
"""

from django.core.management.base import BaseCommand, CommandError
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission, Group
from django.contrib.contenttypes.models import ContentType

from apps.fitnesscenter.models import (
    Organization,
    Location,
    WorkingDay,
    OrganizationPhoto,
    SocialMedia,
    OrganizationTimeSlot,
    organizationAmenity,
)
from apps.mentors.models import MentorProfile

User = get_user_model()

# Name of the Django auth Group for restricted org editors
GROUP_NAME = 'Organization Editor'


def get_or_create_editor_group():
    """
    Create (or fetch) an auth Group named 'Organization Editor'
    with exactly the permissions a restricted staff user needs.
    """
    group, created = Group.objects.get_or_create(name=GROUP_NAME)

    # Re-apply/update permissions every time to make sure they are current
    # Models the restricted user can manage
    editable_models = [
        Organization,
        Location,
        WorkingDay,
        OrganizationPhoto,
        SocialMedia,
        OrganizationTimeSlot,
        organizationAmenity,
    ]

    perms = []
    for model in editable_models:
        ct = ContentType.objects.get_for_model(model)
        # Allow view, change, add, delete
        for codename_prefix in ['view', 'change', 'add', 'delete']:
            codename = f'{codename_prefix}_{model._meta.model_name}'
            perm = Permission.objects.filter(
                content_type=ct,
                codename=codename,
            ).first()
            if perm:
                perms.append(perm)

    group.permissions.set(perms)
    group.save()

    return group


class Command(BaseCommand):
    help = 'Create a restricted staff user who can only edit specific Organization fields in admin.'

    def add_arguments(self, parser):
        parser.add_argument('username', type=str, help='Username for the new staff user')
        parser.add_argument('password', type=str, help='Password for the new staff user')
        parser.add_argument(
            '--org-id',
            type=int,
            action='append',
            dest='org_ids',
            help='ID of the Organization to assign (can be repeated)',
        )
        parser.add_argument(
            '--org-name',
            type=str,
            dest='org_name',
            help='Partial name match for the Organization to assign',
        )
        parser.add_argument(
            '--email',
            type=str,
            default='',
            help='Optional email for the new staff user',
        )
        parser.add_argument(
            '--mobile',
            type=str,
            default='',
            help='Optional mobile number (e.g. +919999999999)',
        )

    def handle(self, *args, **options):
        username = options['username']
        password = options['password']
        org_ids = options.get('org_ids') or []
        org_name = options.get('org_name')
        email = options.get('email') or ''
        mobile = options.get('mobile') or ''

        # ── Resolve organizations ──
        orgs = []

        if org_ids:
            orgs = list(Organization.objects.filter(id__in=org_ids))
            found_ids = {o.id for o in orgs}
            missing = set(org_ids) - found_ids
            if missing:
                raise CommandError(f'Organization(s) not found: {missing}')

        if org_name:
            matched = list(Organization.objects.filter(name__icontains=org_name))
            if not matched:
                raise CommandError(f'No Organization matching "{org_name}"')
            orgs.extend(matched)

        if not orgs:
            self.stdout.write(self.style.WARNING(
                'No organization specified. The user will be created but won\'t see any orgs in admin.\n'
                'You can later assign them via: Organization.mentor → link to their MentorProfile.'
            ))

        # ── Create or update the User ──
        user, user_created = User.objects.get_or_create(
            username=username,
            defaults={
                'email': email,
                'is_staff': True,
                'is_superuser': False,
                'user_role': User.MENTOR_STAFF,  # role 25 — staff level
            }
        )

        if user_created:
            user.set_password(password)
            if mobile:
                user.mobile_number = mobile
            user.save()
            self.stdout.write(self.style.SUCCESS(f'✓ Created staff user: {username}'))
        else:
            self.stdout.write(self.style.WARNING(f'User "{username}" already exists — updating permissions.'))
            user.is_staff = True
            user.is_superuser = False
            user.save(update_fields=['is_staff', 'is_superuser'])

        # ── Assign to the Organization Editor group ──
        group = get_or_create_editor_group()
        user.groups.add(group)
        self.stdout.write(self.style.SUCCESS(f'✓ Added to group: {GROUP_NAME}'))

        # ── Link user to Organization(s) via MentorProfile ──
        if orgs:
            mentor_profile, _ = MentorProfile.objects.get_or_create(user=user)
            for org in orgs:
                if org.mentor != mentor_profile:
                    org.mentor = mentor_profile
                    org.save(update_fields=['mentor'])
                    self.stdout.write(self.style.SUCCESS(
                        f'✓ Assigned org: "{org.name}" (ID: {org.id}) → {username}'
                    ))
                else:
                    self.stdout.write(f'  (org "{org.name}" already assigned)')

        # ── Summary ──
        self.stdout.write('')
        self.stdout.write(self.style.SUCCESS('═' * 50))
        self.stdout.write(self.style.SUCCESS('  RESTRICTED ADMIN USER READY'))
        self.stdout.write(self.style.SUCCESS('═' * 50))
        self.stdout.write(f'  Username : {username}')
        self.stdout.write(f'  Password : {password}')
        self.stdout.write(f'  Login URL: /admin/')
        self.stdout.write(f'  Can edit : name, phone, email, description, logo,')
        self.stdout.write(f'             location, working days, photos, social media')
        self.stdout.write(f'  Cannot   : delete orgs, view bank details, membership plans,')
        self.stdout.write(f'             categories, amenities, or other app data')
        if orgs:
            self.stdout.write(f'  Assigned : {", ".join(o.name for o in orgs)}')
        self.stdout.write(self.style.SUCCESS('═' * 50))
