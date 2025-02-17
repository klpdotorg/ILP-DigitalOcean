# -*- coding: utf-8 -*-
# Generated by Django 1.11.1 on 2018-01-22 08:49
from __future__ import unicode_literals

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('boundary', '0015_boundarystatecode'),
        ('users', '0005_auto_20180122_1144'),
    ]

    operations = [
        migrations.CreateModel(
            name='UserBoundary',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('boundary', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='boundary.Boundary')),
            ],
        ),
        migrations.AlterField(
            model_name='user',
            name='user_type',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, to='common.RespondentType'),
        ),
        migrations.AddField(
            model_name='userboundary',
            name='user',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL),
        ),
        migrations.AlterUniqueTogether(
            name='userboundary',
            unique_together=set([('user', 'boundary')]),
        ),
    ]
