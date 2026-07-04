from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('trainer', '0003_workout_base_models'),
        ('user', '0003_coupon_and_commission_models'),
    ]

    operations = [

        migrations.CreateModel(
            name='WorkoutGroup',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=255)),
                ('name_internal', models.CharField(max_length=255, null=True, blank=True)),
                ('type', models.CharField(
                    max_length=20,
                    choices=[('single_day', 'Single-Day'), ('multi_day', 'Multi-Day')],
                    default='single_day'
                )),
                ('status', models.BooleanField(default=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('trainer', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='workout_groups',
                    to='trainer.trainer'
                )),
            ],
        ),

        migrations.AddField(
            model_name='workoutplan',
            name='group',
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.SET_NULL,
                null=True, blank=True,
                related_name='plans',
                to='trainer.workoutgroup'
            ),
        ),

        migrations.AddField(
            model_name='workoutplan',
            name='plan_name_internal',
            field=models.CharField(max_length=255, null=True, blank=True),
        ),

        migrations.AddField(
            model_name='workoutplan',
            name='total_days',
            field=models.IntegerField(null=True, blank=True),
        ),

        migrations.AlterField(
            model_name='workoutplanday',
            name='week',
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE,
                related_name='days',
                to='trainer.workoutplanweek',
                null=True,
                blank=True
            ),
        ),

        migrations.AddField(
            model_name='workoutplanday',
            name='plan',
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE,
                related_name='days',
                to='trainer.workoutplan',
                null=True,
                blank=True
            ),
        ),

        migrations.CreateModel(
            name='WorkoutLog',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('logged_at', models.DateTimeField(auto_now_add=True)),
                ('notes', models.TextField(null=True, blank=True)),
                ('customer', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='workout_logs',
                    to='user.user'
                )),
                ('session', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='logs',
                    to='trainer.workoutsession',
                    null=True,
                    blank=True
                )),
                ('plan_exercise', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='logs',
                    to='trainer.workoutplanexercise'
                )),
            ],
        ),

        migrations.CreateModel(
            name='ExerciseSetLog',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('set_number', models.IntegerField()),
                ('reps', models.IntegerField(null=True, blank=True)),
                ('weight_kg', models.DecimalField(max_digits=6, decimal_places=2, null=True, blank=True)),
                ('previous_weight_kg', models.DecimalField(max_digits=6, decimal_places=2, null=True, blank=True)),
                ('workout_log', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='set_logs',
                    to='trainer.workoutlog'
                )),
            ],
        ),

        migrations.CreateModel(
            name='PRRecord',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('value', models.DecimalField(max_digits=6, decimal_places=2)),
                ('unit', models.CharField(max_length=10, default='kg')),
                ('verified_at', models.DateField(null=True, blank=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('customer', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='pr_records',
                    to='user.user'
                )),
                ('workout', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='pr_records',
                    to='trainer.workout'
                )),
            ],
        ),
    ]
