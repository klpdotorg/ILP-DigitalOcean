# -*- coding: utf-8 -*-
# Generated by Django 1.11.1 on 2017-09-29 04:05
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('assessments', '0006_auto_20170928_0918'),
    ]

    operations = [
        migrations.AlterField(
            model_name='questiongroup_questions',
            name='sequence',
            field=models.IntegerField(null=True),
        ),
    ]
