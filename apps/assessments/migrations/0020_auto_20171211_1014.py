# -*- coding: utf-8 -*-
# Generated by Django 1.11.1 on 2017-12-11 04:44
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('assessments', '0019_auto_20171211_1000'),
    ]

    operations = [
        migrations.AlterField(
            model_name='question',
            name='pass_score',
            field=models.CharField(max_length=100, null=True),
        ),
    ]
