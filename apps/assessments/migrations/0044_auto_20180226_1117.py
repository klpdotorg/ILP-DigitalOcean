# -*- coding: utf-8 -*-
# Generated by Django 1.11.7 on 2018-02-26 05:47
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('assessments', '0043_surveyboundaryelectiontypecount'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='questiongroup',
            options={'permissions': (('crud_answers', 'CRUD Answers'),)},
        ),
        migrations.AlterModelTable(
            name='surveyinstitutionquestiongroupquestionkeygendercorrectans',
            table='mvw_survey_institution_questiongroup_questionkey_gender_correct',
        ),
    ]
