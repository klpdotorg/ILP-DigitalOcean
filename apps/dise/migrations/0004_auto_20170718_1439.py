# -*- coding: utf-8 -*-
# Generated by Django 1.11.1 on 2017-07-18 09:09
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('dise', '0003_auto_20170718_1437'),
    ]

    operations = [
        migrations.AlterField(
            model_name='basicdata',
            name='village_name',
            field=models.CharField(blank=True, max_length=50, null=True),
        ),
    ]
