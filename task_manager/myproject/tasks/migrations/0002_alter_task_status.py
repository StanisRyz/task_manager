# Generated by Django 5.2 on 2025-04-19 16:15

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('tasks', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='task',
            name='status',
            field=models.CharField(choices=[('in_progress', 'В работе'), ('completed', 'Выполнена'), ('archived', 'В архиве')], default='in_progress', max_length=20),
        ),
    ]
