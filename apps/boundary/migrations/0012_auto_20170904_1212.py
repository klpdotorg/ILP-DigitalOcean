# -*- coding: utf-8 -*-
# Generated by Django 1.11.1 on 2017-09-04 06:42
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('boundary', '0011_electionboundary_geom'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='boundarytype',
            options={'ordering': ['char_id']},
        ),
        migrations.AlterModelOptions(
            name='electionboundary',
            options={'ordering': ['const_ward_name']},
        ),
    ]
