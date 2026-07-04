from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('customers', '0020_membershiprequest_accepted_amount_and_more'),
        ('trainer', '0017_organizationtrainerlink_invited_by_org'),
    ]

    operations = [
        migrations.CreateModel(
            name='TrainerReview',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False)),
                ('rating', models.PositiveSmallIntegerField(help_text='Rating out of 5')),
                ('comment', models.TextField(blank=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('trainer', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='reviews', to='trainer.trainer')),
                ('customer', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='trainer_reviews', to='customers.customer')),
            ],
            options={
                'unique_together': {('trainer', 'customer')},
            },
        ),
    ]
