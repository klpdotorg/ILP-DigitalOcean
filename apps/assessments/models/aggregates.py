from .survey import Survey, Question, Source, SurveyTag
from users.models import User
from django.db import models
from django.contrib.contenttypes.models import ContentType
from django.utils import timezone


class SurveyInstitutionAgg(models.Model):
    """Survey Institution Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    institution_id = models.ForeignKey(
        'schools.Institution', db_column="institution_id", 
        on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    num_assessments = models.IntegerField(db_column="num_assessments")
    num_children = models.IntegerField(db_column="num_children")
    num_users = models.IntegerField(db_column="num_users")
    last_assessment = models.DateField(db_column="last_assessment")

    class Meta:
        managed = False
        db_table = 'mvw_survey_institution_agg'


class SurveyBoundaryAgg(models.Model):
    """Survey Boundary Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    boundary_id = models.ForeignKey(
        'boundary.Boundary', db_column="boundary_id", 
        on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    num_schools = models.IntegerField(db_column="num_schools")
    num_assessments = models.IntegerField(db_column="num_assessments")
    num_children = models.IntegerField(db_column="num_children")
    num_users = models.IntegerField(db_column="num_users")
    last_assessment = models.DateField(db_column="last_assessment")

    class Meta:
        managed = False
        db_table = 'mvw_survey_boundary_agg'


class SurveyElectionBoundaryAgg(models.Model):
    """Survey Election Boundary Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    eboundary_id = models.ForeignKey(
        'boundary.ElectionBoundary', db_column="electionboundary_id", 
        on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    num_schools = models.IntegerField(db_column="num_schools")
    num_assessments = models.IntegerField(db_column="num_assessments")
    num_children = models.IntegerField(db_column="num_children")
    num_users = models.IntegerField(db_column="num_users")
    last_assessment = models.DateField(db_column="last_assessment")

    class Meta:
        managed = False
        db_table = 'mvw_survey_electionboundary_agg'


class SurveyBoundaryRespondentTypeAgg(models.Model):
    """Survey Boundary RespondentType Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    boundary_id = models.ForeignKey(
        'boundary.Boundary', db_column="boundary_id", 
        on_delete=models.DO_NOTHING)
    respondent_type = models.ForeignKey(
        'common.RespondentType', db_column="respondent_type", 
        on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    num_schools = models.IntegerField(db_column="num_schools")
    num_assessments = models.IntegerField(db_column="num_assessments")
    num_children = models.IntegerField(db_column="num_children")
    last_assessment = models.DateField(db_column="last_assessment")

    class Meta:
        managed = False
        db_table = 'mvw_survey_boundary_respondenttype_agg'


class SurveyInstitutionRespondentTypeAgg(models.Model):
    """Survey RespondentType Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    institution_id = models.ForeignKey(
        'schools.Institution', db_column="institution_id", 
        on_delete=models.DO_NOTHING)
    respondent_type = models.ForeignKey(
        'common.RespondentType', db_column="respondent_type", 
        on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    num_schools = models.IntegerField(db_column="num_schools")
    num_assessments = models.IntegerField(db_column="num_assessments")
    num_children = models.IntegerField(db_column="num_children")
    last_assessment = models.DateField(db_column="last_assessment")

    class Meta:
        managed = False
        db_table = 'mvw_survey_institution_respondenttype_agg'


class SurveyBoundaryUserTypeAgg(models.Model):
    """Survey UserType Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    boundary_id = models.ForeignKey(
        'boundary.Boundary', db_column="boundary_id", 
        on_delete=models.DO_NOTHING)
    user_type = models.CharField(max_length=100, db_column="user_type")
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    num_schools = models.IntegerField(db_column="num_schools")
    num_assessments = models.IntegerField(db_column="num_assessments")
    num_children = models.IntegerField(db_column="num_children")
    last_assessment = models.DateField(db_column="last_assessment")

    class Meta:
        managed = False
        db_table = 'mvw_survey_boundary_usertype_agg'


class SurveyInstitutionUserTypeAgg(models.Model):
    """Survey UserType Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    institution_id = models.ForeignKey(
        'schools.Institution', db_column="institution_id", 
        on_delete=models.DO_NOTHING)
    user_type = models.CharField(max_length=100, db_column="user_type")
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    num_assessments = models.IntegerField(db_column="num_assessments")
    num_children = models.IntegerField(db_column="num_children")
    last_assessment = models.DateField(db_column="last_assessment")

    class Meta:
        managed = False
        db_table = 'mvw_survey_institution_usertype_agg'


class SurveyBoundaryQuestionKeyAgg(models.Model):
    """Survey QuestionKey Agg"""
    survey_id = models.ForeignKey('Survey', db_column="survey_id", 
                                  on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    boundary_id = models.ForeignKey(
        'boundary.Boundary', db_column="boundary_id",
        on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    question_key = models.CharField(max_length=100, db_column="question_key")
    lang_question_key = models.CharField(
        max_length=100, db_column="lang_question_key")
    num_assessments = models.IntegerField(db_column="num_assessments")

    class Meta:
        managed = False
        db_table = 'mvw_survey_boundary_questionkey_agg'


class SurveyInstitutionQuestionKeyAgg(models.Model):
    """Survey QuestionKey Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    institution_id = models.ForeignKey(
        'schools.Institution', db_column="institution_id",
        on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    question_key = models.CharField(max_length=100, db_column="question_key")
    lang_question_key = models.CharField(
        max_length=100, db_column="lang_question_key")
    num_assessments = models.IntegerField(db_column="num_assessments")

    class Meta:
        managed = False
        db_table = 'mvw_survey_institution_questionkey_agg'


class SurveyEBoundaryQuestionGroupQuestionKeyAgg(models.Model):
    """Survey QuestionKey Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    eboundary_id = models.ForeignKey(
        'boundary.ElectionBoundary', db_column="eboundary_id", 
        on_delete=models.DO_NOTHING)
    const_ward_type = models.ForeignKey(
        'boundary.BoundaryType', db_column="const_ward_type_id", 
        on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    questiongroup_name = models.CharField(
        max_length=100, db_column="questiongroup_name")
    yearmonth = models.IntegerField(db_column="yearmonth")
    question_key = models.CharField(max_length=100, db_column="question_key")
    lang_question_key = models.CharField(
        max_length=100, db_column="lang_question_key")
    num_assessments = models.IntegerField(db_column="num_assessments")

    class Meta:
        managed = False
        db_table = 'mvw_survey_eboundary_questiongroup_questionkey_agg'


class SurveyBoundaryQuestionGroupQuestionKeyAgg(models.Model):
    """Survey QuestionKey Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    boundary_id = models.ForeignKey(
        'boundary.Boundary', db_column="boundary_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    questiongroup_name = models.CharField(
        max_length=100, db_column="questiongroup_name")
    yearmonth = models.IntegerField(db_column="yearmonth")
    question_key = models.CharField(max_length=100, db_column="question_key")
    lang_question_key = models.CharField(
        max_length=100, db_column="lang_question_key")
    num_assessments = models.IntegerField(db_column="num_assessments")

    class Meta:
        managed = False
        db_table = 'mvw_survey_boundary_questiongroup_questionkey_agg'


class SurveyInstitutionQuestionGroupQuestionKeyAgg(models.Model):
    """Survey QuestionKey Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    institution_id = models.ForeignKey(
        'schools.Institution', db_column="institution_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    questiongroup_name = models.CharField(
        max_length=100, db_column="questiongroup_name")
    yearmonth = models.IntegerField(db_column="yearmonth")
    question_key = models.CharField(max_length=100, db_column="question_key")
    lang_question_key = models.CharField(
        max_length=100, db_column="lang_question_key")
    num_assessments = models.IntegerField(db_column="num_assessments")

    class Meta:
        managed = False
        db_table = 'mvw_survey_institution_questiongroup_questionkey_agg'


class SurveyEBoundaryQuestionGroupGenderAgg(models.Model):
    """Survey QuestionGroup Gender Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    eboundary_id = models.ForeignKey(
        'boundary.ElectionBoundary', db_column="eboundary_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    questiongroup_name = models.CharField(
        max_length=100, db_column="questiongroup_name")
    gender = models.ForeignKey(
        "common.Gender", db_column="gender", on_delete=models.DO_NOTHING)
    num_assessments = models.IntegerField(db_column="num_assessments")

    class Meta:
        managed = False
        db_table = 'mvw_survey_eboundary_questiongroup_gender_agg'


class SurveyBoundaryQuestionGroupGenderAgg(models.Model):
    """Survey QuestionGroup Gender Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    boundary_id = models.ForeignKey(
        'boundary.Boundary', db_column="boundary_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    questiongroup_name = models.CharField(
        max_length=100, db_column="questiongroup_name")
    gender = models.ForeignKey(
        "common.Gender", db_column="gender", on_delete=models.DO_NOTHING)
    num_assessments = models.IntegerField(db_column="num_assessments")

    class Meta:
        managed = False
        db_table = 'mvw_survey_boundary_questiongroup_gender_agg'


class SurveyInstitutionQuestionGroupGenderAgg(models.Model):
    """Survey QuestionGroup Gender Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    institution_id = models.ForeignKey(
        'schools.Institution', db_column="institution_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    questiongroup_name = models.CharField(
        max_length=100, db_column="questiongroup_name")
    gender = models.ForeignKey(
        "common.Gender", db_column="gender", on_delete=models.DO_NOTHING)
    num_assessments = models.IntegerField(db_column="num_assessments")

    class Meta:
        managed = False
        db_table = 'mvw_survey_institution_questiongroup_gender_agg'


class SurveyEBoundaryQuestionKeyCorrectAnsAgg(models.Model):
    """Survey QuestionKey CorrectAns Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    eboundary_id = models.ForeignKey(
        'boundary.ElectionBoundary', db_column="eboundary_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    question_key = models.CharField(max_length=100, db_column="question_key")
    lang_question_key = models.CharField(
        max_length=100, db_column="lang_question_key")
    yearmonth = models.IntegerField(db_column="yearmonth")
    average = models.IntegerField(db_column="average")
    numcorrect = models.IntegerField(db_column="numcorrect")
    numtotal = models.IntegerField(db_column="numtotal")

    class Meta:
        managed = False
        db_table = 'mvw_survey_eboundary_questionkey_correctans_agg'


class SurveyBoundaryQuestionKeyCorrectAnsAgg(models.Model):
    """Survey QuestionKey CorrectAns Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    boundary_id = models.ForeignKey(
        'boundary.Boundary', db_column="boundary_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    question_key = models.CharField(max_length=100, db_column="question_key")
    lang_question_key = models.CharField(
        max_length=100, db_column="lang_question_key")
    yearmonth = models.IntegerField(db_column="yearmonth")
    average = models.IntegerField(db_column="average")
    numcorrect = models.IntegerField(db_column="numcorrect")
    numtotal = models.IntegerField(db_column="numtotal")

    class Meta:
        managed = False
        db_table = 'mvw_survey_boundary_questionkey_correctans_agg'


class SurveyInstitutionQuestionKeyCorrectAnsAgg(models.Model):
    """Survey QuestionKey CorrectAns Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    institution_id = models.ForeignKey(
        'schools.Institution', db_column="institution_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    question_key = models.CharField(max_length=100, db_column="question_key")
    lang_question_key = models.CharField(
        max_length=100, db_column="lang_question_key")
    yearmonth = models.IntegerField(db_column="yearmonth")
    average = models.IntegerField(db_column="average")
    numcorrect = models.IntegerField(db_column="numcorrect")
    numtotal = models.IntegerField(db_column="numtotal")

    class Meta:
        managed = False
        db_table = 'mvw_survey_institution_questionkey_correctans_agg'


class SurveyEBoundaryQuestionGroupQuestionKeyCorrectAnsAgg(models.Model):
    """Survey QuestionGroup QuestionKey CorrectAns Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    eboundary_id = models.ForeignKey(
        'boundary.ElectionBoundary', db_column="eboundary_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    questiongroup_name = models.CharField(
        max_length=100, db_column="questiongroup_name")
    question_key = models.CharField(max_length=100, db_column="question_key")
    lang_question_key = models.CharField(
        max_length=100, db_column="lang_question_key")
    yearmonth = models.IntegerField(db_column="yearmonth")
    average = models.IntegerField(db_column="average")
    numcorrect = models.IntegerField(db_column="numcorrect")
    numtotal = models.IntegerField(db_column="numtotal")

    class Meta:
        managed = False
        db_table = \
            'mvw_survey_eboundary_questiongroup_questionkey_correctans_agg'


class SurveyBoundaryQuestionGroupQuestionKeyCorrectAnsAgg(models.Model):
    """Survey QuestionGroup QuestionKey CorrectAns Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    boundary_id = models.ForeignKey(
        'boundary.Boundary', db_column="boundary_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    questiongroup_name = models.CharField(
        max_length=100, db_column="questiongroup_name")
    question_key = models.CharField(max_length=100, db_column="question_key")
    lang_question_key = models.CharField(
        max_length=100, db_column="lang_question_key")
    yearmonth = models.IntegerField(db_column="yearmonth")
    average = models.IntegerField(db_column="average")
    numcorrect = models.IntegerField(db_column="numcorrect")
    numtotal = models.IntegerField(db_column="numtotal")

    class Meta:
        managed = False
        db_table = \
            'mvw_survey_boundary_questiongroup_questionkey_correctans_agg'


class SurveyInstitutionQuestionGroupQuestionKeyCorrectAnsAgg(models.Model):
    """Survey QuestionGroup QuestionKey CorrectAns Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    institution_id = models.ForeignKey(
        'schools.Institution', db_column="institution_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    questiongroup_name = models.CharField(
        max_length=100, db_column="questiongroup_name")
    question_key = models.CharField(max_length=100, db_column="question_key")
    lang_question_key = models.CharField(
        max_length=100, db_column="lang_question_key")
    yearmonth = models.IntegerField(db_column="yearmonth")
    average = models.IntegerField(db_column="average")
    numcorrect = models.IntegerField(db_column="numcorrect")
    numtotal = models.IntegerField(db_column="numtotal")

    class Meta:
        managed = False
        db_table = \
            'mvw_survey_institution_questiongroup_questionkey_correctans_agg'


class SurveyEBoundaryQuestionGroupGenderCorrectAnsAgg(models.Model):
    """Survey QuestionGroup Gender CorrectAns Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    eboundary_id = models.ForeignKey(
        'boundary.ElectionBoundary', db_column="eboundary_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    questiongroup_name = models.CharField(
        max_length=100, db_column="questiongroup_name")
    gender = models.ForeignKey(
        "common.Gender", db_column="gender", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    num_assessments = models.IntegerField(db_column="num_assessments")

    class Meta:
        managed = False
        db_table = 'mvw_survey_eboundary_questiongroup_gender_correctans_agg'


class SurveyBoundaryQuestionGroupGenderCorrectAnsAgg(models.Model):
    """Survey QuestionGroup Gender CorrectAns Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    boundary_id = models.ForeignKey(
        'boundary.Boundary', db_column="boundary_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    questiongroup_name = models.CharField(
        max_length=100, db_column="questiongroup_name")
    gender = models.ForeignKey(
        "common.Gender", db_column="gender", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    num_assessments = models.IntegerField(db_column="num_assessments")

    class Meta:
        managed = False
        db_table = 'mvw_survey_boundary_questiongroup_gender_correctans_agg'


class SurveyInstitutionQuestionGroupGenderCorrectAnsAgg(models.Model):
    """Survey QuestionGroup Gender CorrectAns Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    institution_id = models.ForeignKey(
        'schools.Institution', db_column="institution_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    questiongroup_name = models.CharField(
        max_length=100, db_column="questiongroup_name")
    gender = models.ForeignKey(
        "common.Gender", db_column="gender", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    num_assessments = models.IntegerField(db_column="num_assessments")

    class Meta:
        managed = False
        db_table = 'mvw_survey_institution_questiongroup_gender_correctans_agg'


class SurveyEBoundaryQuestionGroupAnsAgg(models.Model):
    """Survey Answer Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    eboundary_id = models.ForeignKey(
        'boundary.ElectionBoundary', db_column="eboundary_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    question_id = models.ForeignKey(
        'Question', db_column="question_id", on_delete=models.DO_NOTHING)
    question_desc = models.CharField(max_length=200, db_column="question_desc")
    answer_option = models.CharField(max_length=100, db_column="answer_option")
    num_answers = models.IntegerField(db_column="num_answers")

    class Meta:
        managed = False
        db_table = 'mvw_survey_eboundary_questiongroup_ans_agg'


class SurveyBoundaryQuestionGroupAnsAgg(models.Model):
    """Survey Answer Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    boundary_id = models.ForeignKey(
        'boundary.Boundary', db_column="boundary_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    question_id = models.ForeignKey(
        'Question', db_column="question_id", on_delete=models.DO_NOTHING)
    question_desc = models.CharField(max_length=200, db_column="question_desc")
    answer_option = models.CharField(max_length=100, db_column="answer_option")
    num_answers = models.IntegerField(db_column="num_answers")

    class Meta:
        managed = False
        db_table = 'mvw_survey_boundary_questiongroup_ans_agg'


class SurveyInstitutionQuestionGroupAnsAgg(models.Model):
    """Survey Answer Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    institution_id = models.ForeignKey(
        'schools.Institution', db_column="institution_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    question_id = models.ForeignKey(
        'Question', db_column="question_id", on_delete=models.DO_NOTHING)
    question_desc = models.CharField(max_length=200, db_column="question_desc")
    lang_questiontext = models.CharField(
        max_length=200, db_column="lang_questiontext")
    answer_option = models.CharField(max_length=100, db_column="answer_option")
    num_answers = models.IntegerField(db_column="num_answers")

    class Meta:
        managed = False
        db_table = 'mvw_survey_institution_questiongroup_ans_agg'


class SurveyInstitutionQuestionGroupAgg(models.Model):
    """Survey Institution QuestionGroup Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    institution_id = models.ForeignKey(
        'schools.Institution', db_column="institution_id", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    num_assessments = models.IntegerField(db_column="num_assessments")
    num_children = models.IntegerField(db_column="num_children")
    num_users = models.IntegerField(db_column="num_users")
    last_assessment = models.DateField(db_column="last_assessment")

    class Meta:
        managed = False
        db_table = 'mvw_survey_institution_questiongroup_agg'


class SurveyEBoundaryQuestionGroupAgg(models.Model):
    """Survey Election Boundary QuestionGroup Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    eboundary_id = models.ForeignKey(
        'boundary.ElectionBoundary', db_column="eboundary_id", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    num_schools = models.IntegerField(db_column="num_schools")
    num_assessments = models.IntegerField(db_column="num_assessments")
    num_children = models.IntegerField(db_column="num_children")
    num_users = models.IntegerField(db_column="num_users")
    last_assessment = models.DateField(db_column="last_assessment")

    class Meta:
        managed = False
        db_table = 'mvw_survey_eboundary_questiongroup_agg'


class SurveyBoundaryQuestionGroupAgg(models.Model):
    """Survey Boundary QuestionGroup Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    boundary_id = models.ForeignKey(
        'boundary.Boundary', db_column="boundary_id", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    num_schools = models.IntegerField(db_column="num_schools")
    num_assessments = models.IntegerField(db_column="num_assessments")
    num_children = models.IntegerField(db_column="num_children")
    num_users = models.IntegerField(db_column="num_users")
    last_assessment = models.DateField(db_column="last_assessment")

    class Meta:
        managed = False
        db_table = 'mvw_survey_boundary_questiongroup_agg'


class SurveyTagMappingAgg(models.Model):
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    boundary_id = models.ForeignKey(
        'boundary.Boundary', db_column="boundary_id", on_delete=models.DO_NOTHING)
    academic_year_id = models.ForeignKey(
        'common.AcademicYear', db_column="academic_year_id", on_delete=models.DO_NOTHING)
    num_schools = models.IntegerField(db_column="num_schools")
    num_students = models.IntegerField(db_column="num_students")

    class Meta:
        managed = False
        db_table = 'mvw_survey_tagmapping_agg'


class SurveyBoundaryElectionTypeCount(models.Model):
    """Survey Boundary ElectionType Count"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    boundary_id = models.ForeignKey(
        'boundary.Boundary', db_column="boundary_id", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    const_ward_type = models.ForeignKey(
        'boundary.BoundaryType', db_column="const_ward_type", on_delete=models.DO_NOTHING)
    electionboundary_count = models.IntegerField(
        db_column="electionboundary_count")

    class Meta:
        managed = False
        db_table = 'mvw_survey_boundary_electiontype_count'


class SurveyEBoundaryElectionTypeCount(models.Model):
    """Survey Election Boundary ElectionType Count"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    eboundary_id = models.ForeignKey(
        'boundary.ElectionBoundary', db_column="eboundary_id", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    const_ward_type = models.ForeignKey(
        'boundary.BoundaryType', db_column="const_ward_type", on_delete=models.DO_NOTHING)
    electionboundary_count = models.IntegerField(
        db_column="electionboundary_count")

    class Meta:
        managed = False
        db_table = 'mvw_survey_eboundary_electiontype_count'


class SurveyInstitutionElectionTypeCount(models.Model):
    """Survey Institution ElectionType Count"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    institution_id = models.ForeignKey(
        'schools.Institution', db_column="institution_id", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    const_ward_type = models.ForeignKey(
        'boundary.BoundaryType', db_column="const_ward_type", on_delete=models.DO_NOTHING)
    electionboundary_count = models.IntegerField(
        db_column="electionboundary_count")

    class Meta:
        managed = False
        db_table = 'mvw_survey_institution_electiontype_count'


class SurveyEBoundaryQDetailsAgg(models.Model):
    """Survey Election Boundary Question Details Aggregates (for concept, 
    microconcept, microconceptgroup)"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    eboundary_id = models.ForeignKey(
        'boundary.ElectionBoundary', db_column="eboundary_id", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    concept = models.ForeignKey(
        'Concept', db_column="concept", on_delete=models.DO_NOTHING)
    microconcept_group = models.ForeignKey(
        'MicroConceptGroup', db_column="microconcept_group", on_delete=models.DO_NOTHING)
    microconcept = models.ForeignKey(
        'MicroConcept', db_column="microconcept", on_delete=models.DO_NOTHING)
    num_assessments = models.IntegerField(db_column="num_assessments")

    class Meta:
        managed = False
        db_table = 'mvw_survey_eboundary_qdetails_agg'


class SurveyBoundaryQDetailsAgg(models.Model):
    """Survey Boundary Question Details Aggregates 
    (for concept, microconcept, microconceptgroup)"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    boundary_id = models.ForeignKey(
        'boundary.Boundary', db_column="boundary_id", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    concept = models.ForeignKey(
        'Concept', db_column="concept", on_delete=models.DO_NOTHING)
    microconcept_group = models.ForeignKey(
        'MicroConceptGroup', db_column="microconcept_group", on_delete=models.DO_NOTHING)
    microconcept = models.ForeignKey(
        'MicroConcept', db_column="microconcept", on_delete=models.DO_NOTHING)
    num_assessments = models.IntegerField(db_column="num_assessments")

    class Meta:
        managed = False
        db_table = 'mvw_survey_boundary_qdetails_agg'


class SurveyInstitutionQDetailsAgg(models.Model):
    """Survey Institution Question Details Aggregates (for concept, 
    microconcept, microconceptgroup)"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    institution_id = models.ForeignKey(
        'schools.Institution', db_column="boundary_id", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    concept = models.ForeignKey(
        'Concept', db_column="concept", on_delete=models.DO_NOTHING)
    microconcept_group = models.ForeignKey(
        'MicroConceptGroup', db_column="microconcept_group", on_delete=models.DO_NOTHING)
    microconcept = models.ForeignKey(
        'MicroConcept', db_column="microconcept", on_delete=models.DO_NOTHING)
    num_assessments = models.IntegerField(db_column="num_assessments")

    class Meta:
        managed = False
        db_table = 'mvw_survey_institution_qdetails_agg'


class SurveyEBoundaryQuestionGroupQDetailsAgg(models.Model):
    """Survey Election Boundary QuestionGroup Question Details Aggregates 
    (for concept, microconcept, microconceptgroup)"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    eboundary_id = models.ForeignKey(
        'boundary.ElectionBoundary', db_column="eboundary_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    questiongroup_name = models.CharField(
        max_length=100, db_column="questiongroup_name")
    yearmonth = models.IntegerField(db_column="yearmonth")
    concept = models.ForeignKey(
        'Concept', db_column="concept", on_delete=models.DO_NOTHING)
    microconcept_group = models.ForeignKey(
        'MicroConceptGroup', db_column="microconcept_group", on_delete=models.DO_NOTHING)
    microconcept = models.ForeignKey(
        'MicroConcept', db_column="microconcept", on_delete=models.DO_NOTHING)
    num_assessments = models.IntegerField(db_column="num_assessments")

    class Meta:
        managed = False
        db_table = 'mvw_survey_eboundary_questiongroup_qdetails_agg'


class SurveyBoundaryQuestionGroupQDetailsAgg(models.Model):
    """Survey Boundary QuestionGroup Question Details Aggregates (
        for concept, microconcept, microconceptgroup)"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    boundary_id = models.ForeignKey(
        'boundary.Boundary', db_column="boundary_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    questiongroup_name = models.CharField(
        max_length=100, db_column="questiongroup_name")
    yearmonth = models.IntegerField(db_column="yearmonth")
    concept = models.ForeignKey(
        'Concept', db_column="concept", on_delete=models.DO_NOTHING)
    microconcept_group = models.ForeignKey(
        'MicroConceptGroup', db_column="microconcept_group", on_delete=models.DO_NOTHING)
    microconcept = models.ForeignKey(
        'MicroConcept', db_column="microconcept", on_delete=models.DO_NOTHING)
    num_assessments = models.IntegerField(db_column="num_assessments")

    class Meta:
        managed = False
        db_table = 'mvw_survey_boundary_questiongroup_qdetails_agg'


class SurveyInstitutionQuestionGroupQDetailsAgg(models.Model):
    """Survey Institution QuestionGroup Question Details Aggregates (
        for concept, microconcept, microconceptgroup)"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    institution = models.ForeignKey(
        'schools.Institution', on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    questiongroup_name = models.CharField(
        max_length=100, db_column="questiongroup_name")
    yearmonth = models.IntegerField(db_column="yearmonth")
    concept = models.ForeignKey(
        'Concept', db_column="concept", on_delete=models.DO_NOTHING)
    microconcept_group = models.ForeignKey(
        'MicroConceptGroup', db_column="microconcept_group", on_delete=models.DO_NOTHING)
    microconcept = models.ForeignKey(
        'MicroConcept', db_column="microconcept", on_delete=models.DO_NOTHING)
    num_assessments = models.IntegerField(db_column="num_assessments")

    class Meta:
        managed = False
        db_table = 'mvw_survey_institution_questiongroup_qdetails_agg'


class SurveyEBoundaryQDetailsCorrectAnsAgg(models.Model):
    """Survey Election Boundary Question Details CorrectAns Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    eboundary_id = models.ForeignKey(
        'boundary.ElectionBoundary', db_column="eboundary_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    concept = models.ForeignKey(
        'Concept', db_column="concept", on_delete=models.DO_NOTHING)
    microconcept_group = models.ForeignKey(
        'MicroConceptGroup', db_column="microconcept_group", on_delete=models.DO_NOTHING)
    microconcept = models.ForeignKey(
        'MicroConcept', db_column="microconcept", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    average = models.IntegerField(db_column="average")
    numcorrect = models.IntegerField(db_column="numcorrect")
    numtotal = models.IntegerField(db_column="numtotal")

    class Meta:
        managed = False
        db_table = 'mvw_survey_eboundary_qdetails_correctans_agg'


class SurveyBoundaryQDetailsCorrectAnsAgg(models.Model):
    """Survey Boundary Question Details CorrectAns Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    boundary_id = models.ForeignKey(
        'boundary.Boundary', db_column="boundary_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    concept = models.ForeignKey(
        'Concept', db_column="concept", on_delete=models.DO_NOTHING)
    microconcept_group = models.ForeignKey(
        'MicroConceptGroup', db_column="microconcept_group", on_delete=models.DO_NOTHING)
    microconcept = models.ForeignKey(
        'MicroConcept', db_column="microconcept", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    average = models.IntegerField(db_column="average")
    numcorrect = models.IntegerField(db_column="numcorrect")
    numtotal = models.IntegerField(db_column="numtotal")

    class Meta:
        managed = False
        db_table = 'mvw_survey_boundary_qdetails_correctans_agg'


class SurveyInstitutionQDetailsCorrectAnsAgg(models.Model):
    """Survey Institution Question Details CorrectAns Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    institution_id = models.ForeignKey(
        'schools.Institution', db_column="boundary_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    concept = models.ForeignKey(
        'Concept', db_column="concept", on_delete=models.DO_NOTHING)
    microconcept_group = models.ForeignKey(
        'MicroConceptGroup', db_column="microconcept_group", on_delete=models.DO_NOTHING)
    microconcept = models.ForeignKey(
        'MicroConcept', db_column="microconcept", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    average = models.IntegerField(db_column="average")
    numcorrect = models.IntegerField(db_column="numcorrect")
    numtotal = models.IntegerField(db_column="numtotal")

    class Meta:
        managed = False
        db_table = 'mvw_survey_institution_qdetails_correctans_agg'


class SurveyEBoundaryQuestionGroupQDetailsCorrectAnsAgg(models.Model):
    """Survey Election Boundary QuestionGroup Question Details 
    CorrectAns Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    eboundary_id = models.ForeignKey(
        'boundary.ElectionBoundary', db_column="eboundary_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    questiongroup_name = models.CharField(
        max_length=100, db_column="questiongroup_name")
    yearmonth = models.IntegerField(db_column="yearmonth")
    concept = models.ForeignKey(
        'Concept', db_column="concept", on_delete=models.DO_NOTHING)
    microconcept_group = models.ForeignKey(
        'MicroConceptGroup', db_column="microconcept_group", on_delete=models.DO_NOTHING)
    microconcept = models.ForeignKey(
        'MicroConcept', db_column="microconcept", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    average = models.IntegerField(db_column="average")
    numcorrect = models.IntegerField(db_column="numcorrect")
    numtotal = models.IntegerField(db_column="numtotal")

    class Meta:
        managed = False
        db_table = 'mvw_survey_eboundary_questiongroup_qdetails_correctans_agg'


class SurveyBoundaryQuestionGroupQDetailsCorrectAnsAgg(models.Model):
    """Survey Boundary QuestionGroup Question Details CorrectAns Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    boundary_id = models.ForeignKey(
        'boundary.Boundary', db_column="boundary_id", on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    questiongroup_name = models.CharField(
        max_length=100, db_column="questiongroup_name")
    yearmonth = models.IntegerField(db_column="yearmonth")
    concept = models.ForeignKey(
        'Concept', db_column="concept", on_delete=models.DO_NOTHING)
    microconcept_group = models.ForeignKey(
        'MicroConceptGroup', db_column="microconcept_group", on_delete=models.DO_NOTHING)
    microconcept = models.ForeignKey(
        'MicroConcept', db_column="microconcept", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    average = models.IntegerField(db_column="average")
    numcorrect = models.IntegerField(db_column="numcorrect")
    numtotal = models.IntegerField(db_column="numtotal")

    class Meta:
        managed = False
        db_table = 'mvw_survey_boundary_questiongroup_qdetails_correctans_agg'


class SurveyInstitutionQuestionGroupQDetailsCorrectAnsAgg(models.Model):
    """Survey Institution QuestionGroup Question Details CorrectAns Agg"""
    survey_id = models.ForeignKey(
        'Survey', db_column="survey_id", on_delete=models.DO_NOTHING)
    survey_tag = models.ForeignKey(
        'SurveyTag', db_column="survey_tag", on_delete=models.DO_NOTHING)
    institution = models.ForeignKey(
        'schools.Institution', on_delete=models.DO_NOTHING)
    source = models.ForeignKey(
        'Source', db_column="source", on_delete=models.DO_NOTHING)
    questiongroup_id = models.ForeignKey(
        'QuestionGroup', db_column="questiongroup_id", on_delete=models.DO_NOTHING)
    questiongroup_name = models.CharField(
        max_length=100, db_column="questiongroup_name")
    yearmonth = models.IntegerField(db_column="yearmonth")
    concept = models.ForeignKey(
        'Concept', db_column="concept", on_delete=models.DO_NOTHING)
    microconcept_group = models.ForeignKey(
        'MicroConceptGroup', db_column="microconcept_group", on_delete=models.DO_NOTHING)
    microconcept = models.ForeignKey(
        'MicroConcept', db_column="microconcept", on_delete=models.DO_NOTHING)
    yearmonth = models.IntegerField(db_column="yearmonth")
    average = models.IntegerField(db_column="average")
    numcorrect = models.IntegerField(db_column="numcorrect")
    numtotal = models.IntegerField(db_column="numtotal")

    class Meta:
        managed = False
        db_table = \
            'mvw_survey_institution_questiongroup_qdetails_correctans_agg'
