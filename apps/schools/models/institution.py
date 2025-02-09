import json

from django.contrib.gis.db import models
from django.db.models import Q
from common.models import (Status, AcademicYear)
from django.conf import settings
from assessments.models import InstitutionImages


class InstitutionCategory(models.Model):
    """ Category for institution """
    name = models.CharField(max_length=300)
    institution_type = models.ForeignKey('common.InstitutionType', on_delete=models.DO_NOTHING)

    def __unicode__(self):
        return "%s" % self.name


class Management(models.Model):
    """ The school management """
    name = models.CharField(max_length=300)

    def __unicode__(self):
        return "%s" % self.name


class PinCode(models.Model):
    """ Pincodes """
    geom = models.GeometryField(null=True)

    def __unicode__(self):
        return "%s" % self.geom


class Institution(models.Model):
    """ An educational institution """
    dise = models.ForeignKey('dise.BasicData', null=True, blank=True, on_delete=models.DO_NOTHING)
    name = models.CharField(max_length=300)
    category = models.ForeignKey('InstitutionCategory', on_delete=models.DO_NOTHING)
    gender = models.ForeignKey('common.InstitutionGender', on_delete=models.DO_NOTHING)
    institution_type = models.ForeignKey('common.InstitutionType', on_delete=models.DO_NOTHING)
    management = models.ForeignKey('Management', on_delete=models.DO_NOTHING)
    year_established = models.CharField(max_length=5, null=True, blank=True)
    rural_urban = models.CharField(max_length=50, null=True, blank=True)
    phone_number = models.CharField(max_length=50, null=True, blank=True)
    address = models.CharField(max_length=1000, null=True, blank=True)
    area = models.CharField(max_length=1000, null=True, blank=True)
    village = models.CharField(max_length=1000, null=True, blank=True)
    pincode = models.ForeignKey('PinCode', null=True, blank=True, on_delete=models.DO_NOTHING)
    landmark = models.CharField(max_length=1000, null=True, blank=True)
    instidentification = models.CharField(
        max_length=1000, null=True, blank=True)
    instidentification2 = models.CharField(
        max_length=1000, null=True, blank=True)
    route_information = models.CharField(
        max_length=1000, null=True, blank=True)
    admin5 = models.ForeignKey(
        'boundary.Boundary', related_name='institution_admin5',
        on_delete=models.DO_NOTHING, null=True, blank=True)
    admin4 = models.ForeignKey(
        'boundary.Boundary', related_name='institution_admin4',
        on_delete=models.DO_NOTHING, null=True, blank=True)
    admin3 = models.ForeignKey(
        'boundary.Boundary', related_name='institution_admin3',
        on_delete=models.DO_NOTHING)
    admin2 = models.ForeignKey(
        'boundary.Boundary', related_name='institution_admin2',
        on_delete=models.DO_NOTHING)
    admin1 = models.ForeignKey(
        'boundary.Boundary', related_name='institution_admin1',
        on_delete=models.DO_NOTHING)
    admin0 = models.ForeignKey(
        'boundary.Boundary', related_name='institution_admin0',
        on_delete=models.DO_NOTHING)
    mp = models.ForeignKey(
        'boundary.ElectionBoundary', related_name='institution_mp', null=True,
        on_delete=models.DO_NOTHING)
    mla = models.ForeignKey(
        'boundary.ElectionBoundary', related_name='institution_mla', null=True,
        on_delete=models.DO_NOTHING)
    gp = models.ForeignKey(
        'boundary.ElectionBoundary', related_name='institution_gp', null=True,
        on_delete=models.DO_NOTHING)
    ward = models.ForeignKey(
        'boundary.ElectionBoundary', related_name='institution_ward',
        null=True, on_delete=models.DO_NOTHING)
    coord = models.GeometryField(null=True)
    last_verified_year = models.ForeignKey('common.AcademicYear', null=True,
                                           on_delete=models.DO_NOTHING)
    status = models.ForeignKey(
        'common.Status', default=Status.ACTIVE,
        on_delete=models.DO_NOTHING)

    '''Returns images associated via SYS. Note questiongroup_id is hardcoded to SYS'''

    def get_images(self):
        images_queryset = InstitutionImages.objects.filter(
            is_verified=True, answergroup__institution=self).filter(
            Q(answergroup__questiongroup_id=6) |
            Q(answergroup__questiongroup_id=1)
        )
        print("Queryset count: ", images_queryset.count())
        images = []
        for image in images_queryset:
            print("Image URL is: ", image.image.url)
            images.append(image.image.url)
        return images

    def get_grades(self):
        from .student_staff import (Student, StudentStudentGroupRelation, StudentGroup)
        group_queryset = StudentGroup.objects.filter(institution_id=self, status='AC', group_type='class')
        grades = []
        for grp in group_queryset:
            gradesdict = {}
            gradesdict['grpid'] = grp.id
            gradesdict['grpname'] = grp.name
            grades.append(gradesdict)
        return grades

    def get_geometry(self):
        if hasattr(self, 'coord') and self.coord is not None:
            return json.loads(self.coord.geojson)
        else:
            return {}

    def get_mt_profile(self):
        profile = {}
        aggregation = self.institutionaggregation_set.filter(academic_year=settings.DEFAULT_ACADEMIC_YEAR)
        for agg in aggregation:
            if agg.mt in profile:
                profile[agg.mt.name] += agg.num
            else:
                profile[agg.mt.name] = agg.num
        return profile

    class Meta:
        unique_together = (('name', 'dise', 'admin3'),)
        permissions = (
            ('crud_student_class_staff', 'CRUD Student Class and Staff'),
        )

    def __unicode__(self):
        return "%s" % self.name


class InstitutionLanguage(models.Model):
    institution = models.ForeignKey(
        'Institution', related_name='institution_languages',
        on_delete=models.DO_NOTHING)
    moi = models.ForeignKey('common.Language', on_delete=models.DO_NOTHING)

    class Meta:
        unique_together = (('institution', 'moi'),)



