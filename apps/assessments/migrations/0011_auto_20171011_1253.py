# -*- coding: utf-8 -*-
# Generated by Django 1.11.1 on 2017-10-11 07:23
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('assessments', '0010_auto_20171006_1443'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='survey',
            options={'ordering': ['name']},
        ),
    ]
