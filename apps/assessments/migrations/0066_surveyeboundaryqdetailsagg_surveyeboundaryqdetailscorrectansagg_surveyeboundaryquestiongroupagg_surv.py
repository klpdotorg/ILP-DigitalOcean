# -*- coding: utf-8 -*-
# Generated by Django 1.11.5 on 2018-09-21 13:44
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('assessments', '0065_merge_20180912_1010'),
    ]

    operations = [
        migrations.CreateModel(
            name='SurveyEBoundaryQDetailsAgg',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('yearmonth', models.IntegerField(db_column='yearmonth')),
                ('num_assessments', models.IntegerField(db_column='num_assessments')),
            ],
            options={
                'managed': False,
                'db_table': 'mvw_survey_eboundary_qdetails_agg',
            },
        ),
        migrations.CreateModel(
            name='SurveyEBoundaryQDetailsCorrectAnsAgg',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('yearmonth', models.IntegerField(db_column='yearmonth')),
                ('num_assessments', models.IntegerField(db_column='num_assessments')),
            ],
            options={
                'managed': False,
                'db_table': 'mvw_survey_eboundary_qdetails_correctans_agg',
            },
        ),
        migrations.CreateModel(
            name='SurveyEBoundaryQuestionGroupAgg',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('yearmonth', models.IntegerField(db_column='yearmonth')),
                ('num_schools', models.IntegerField(db_column='num_schools')),
                ('num_assessments', models.IntegerField(db_column='num_assessments')),
                ('num_children', models.IntegerField(db_column='num_children')),
                ('num_users', models.IntegerField(db_column='num_users')),
                ('last_assessment', models.DateField(db_column='last_assessment')),
            ],
            options={
                'managed': False,
                'db_table': 'mvw_survey_eboundary_questiongroup_agg',
            },
        ),
        migrations.CreateModel(
            name='SurveyEBoundaryQuestionGroupAnsAgg',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('yearmonth', models.IntegerField(db_column='yearmonth')),
                ('question_desc', models.CharField(db_column='question_desc', max_length=200)),
                ('answer_option', models.CharField(db_column='answer_option', max_length=100)),
                ('num_answers', models.IntegerField(db_column='num_answers')),
            ],
            options={
                'managed': False,
                'db_table': 'mvw_survey_eboundary_questiongroup_ans_agg',
            },
        ),
        migrations.CreateModel(
            name='SurveyEBoundaryQuestionGroupGenderAgg',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('yearmonth', models.IntegerField(db_column='yearmonth')),
                ('questiongroup_name', models.CharField(db_column='questiongroup_name', max_length=100)),
                ('num_assessments', models.IntegerField(db_column='num_assessments')),
            ],
            options={
                'managed': False,
                'db_table': 'mvw_survey_eboundary_questiongroup_gender_agg',
            },
        ),
        migrations.CreateModel(
            name='SurveyEBoundaryQuestionGroupGenderCorrectAnsAgg',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('questiongroup_name', models.CharField(db_column='questiongroup_name', max_length=100)),
                ('yearmonth', models.IntegerField(db_column='yearmonth')),
                ('num_assessments', models.IntegerField(db_column='num_assessments')),
            ],
            options={
                'managed': False,
                'db_table': 'mvw_survey_eboundary_questiongroup_gender_correctans_agg',
            },
        ),
        migrations.CreateModel(
            name='SurveyEBoundaryQuestionGroupQDetailsAgg',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('questiongroup_name', models.CharField(db_column='questiongroup_name', max_length=100)),
                ('yearmonth', models.IntegerField(db_column='yearmonth')),
                ('num_assessments', models.IntegerField(db_column='num_assessments')),
            ],
            options={
                'managed': False,
                'db_table': 'mvw_survey_eboundary_questiongroup_qdetails_agg',
            },
        ),
        migrations.CreateModel(
            name='SurveyEBoundaryQuestionGroupQDetailsCorrectAnsAgg',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('questiongroup_name', models.CharField(db_column='questiongroup_name', max_length=100)),
                ('yearmonth', models.IntegerField(db_column='yearmonth')),
                ('num_assessments', models.IntegerField(db_column='num_assessments')),
            ],
            options={
                'managed': False,
                'db_table': 'mvw_survey_eboundary_questiongroup_qdetails_correctans_agg',
            },
        ),
        migrations.CreateModel(
            name='SurveyEBoundaryQuestionGroupQuestionKeyAgg',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('questiongroup_name', models.CharField(db_column='questiongroup_name', max_length=100)),
                ('yearmonth', models.IntegerField(db_column='yearmonth')),
                ('question_key', models.CharField(db_column='question_key', max_length=100)),
                ('num_assessments', models.IntegerField(db_column='num_assessments')),
            ],
            options={
                'managed': False,
                'db_table': 'mvw_survey_eboundary_questiongroup_questionkey_agg',
            },
        ),
        migrations.CreateModel(
            name='SurveyEBoundaryQuestionGroupQuestionKeyCorrectAnsAgg',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('questiongroup_name', models.CharField(db_column='questiongroup_name', max_length=100)),
                ('question_key', models.CharField(db_column='question_key', max_length=100)),
                ('yearmonth', models.IntegerField(db_column='yearmonth')),
                ('num_assessments', models.IntegerField(db_column='num_assessments')),
            ],
            options={
                'managed': False,
                'db_table': 'mvw_survey_eboundary_questiongroup_questionkey_correctans_agg',
            },
        ),
        migrations.CreateModel(
            name='SurveyEBoundaryQuestionKeyCorrectAnsAgg',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('question_key', models.CharField(db_column='question_key', max_length=100)),
                ('yearmonth', models.IntegerField(db_column='yearmonth')),
                ('num_assessments', models.IntegerField(db_column='num_assessments')),
            ],
            options={
                'managed': False,
                'db_table': 'mvw_survey_eboundary_questionkey_correctans_agg',
            },
        ),
    ]
