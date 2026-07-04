import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from apps.trainer.models import Trainer, OrganizationTrainerLink
from apps.fitnesscenter.models import Organization

org = Organization.objects.get(id=1022)
print("Organization:", org.name)

links = OrganizationTrainerLink.objects.filter(organization=org)
print(f"Total links for org: {links.count()}")
for link in links:
    print(f"Trainer: {link.trainer.first_name} {link.trainer.last_name} (ID: {link.trainer.id}), Status: {link.status}")

trainers = Trainer.objects.filter(organization_links__organization=org, organization_links__status='approved')
print(f"Total approved trainers: {trainers.count()}")
for t in trainers:
    print(f"Approved Trainer: {t.first_name} {t.last_name} (ID: {t.id})")
