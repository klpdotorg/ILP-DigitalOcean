# -*- coding: utf-8 -*-
# Generated by Django 1.11.1 on 2018-01-23 17:09
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('assessments', '0037_merge_20180123_0930'),
        ('common', '0003_respondenttype'),
    ]

    operations = [
        migrations.AlterField(
            model_name='answergroup_institution',
            name='respondent_type',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, to='common.RespondentType'),
        ),
        migrations.AlterField(
            model_name='answergroup_student',
            name='respondent_type',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, to='common.RespondentType'),
        ),
        migrations.AlterField(
            model_name='answergroup_studentgroup',
            name='respondent_type',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, to='common.RespondentType'),
        ),
        migrations.DeleteModel(
            name='RespondentType',
        ),
    ]
