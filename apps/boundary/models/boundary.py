import json

from django.contrib.gis.db import models
from common.models import common
from schools.models import Institution
from django.contrib.gis.db.models.functions import AsGeoJSON
from django.db.models import Q


class BoundaryType(models.Model):
    '''
    Aligned to constants defined in the DB models. When those change,
    these will also have to
    change
    '''
    SCHOOL_DIVISION = 'DV'
    SCHOOL_DISTRICT = 'SD'
    SCHOOL_TALUK = 'TA'
    SCHOOL_BLOCK = 'SB'
    SCHOOL_CLUSTER = 'SC'
    PRESCHOOL_DISTRICT = 'PD'
    PRESCHOOL_PROJECT = 'PP'
    PRESCHOOL_CIRCLE = 'PC'

    """ Boundary type """
    char_id = models.CharField(max_length=300, primary_key=True)
    name = models.CharField(max_length=300)

    class Meta:
        ordering = ['char_id', ]


class Boundary(models.Model):
    """ educational boundaries """
    parent = models.ForeignKey('self', null=True, on_delete=models.DO_NOTHING)
    name = models.CharField(max_length=300)
    lang_name = models.CharField(max_length=300, null=True)
    boundary_type = models.ForeignKey('BoundaryType', on_delete=models.DO_NOTHING)
    type = models.ForeignKey('common.InstitutionType', null=True, on_delete=models.DO_NOTHING)
    dise_slug = models.CharField(max_length=300, blank=True)
    geom = models.GeometryField(null=True)
    status = models.ForeignKey('common.Status', on_delete=models.DO_NOTHING)
    objects = common.StatusManager()

    def get_geometry(self):
        if hasattr(self, 'geom') and self.geom is not None:
            return json.loads(self.geom.geojson)
        else:
            return {}

    def get_clusters(self):
        if self.boundary_type.char_id == 'SD':
            return Boundary.objects.filter(parent__parent=self.id)
        elif self.boundary_type.char_id in ['SB', 'PP']:
            return Boundary.objects.filter(parent=self.id)
        else:
            return Boundary.objects.filter(id=self.id)

    def schools(self):
        return Institution.objects.filter(
            Q(status='AC'),
            Q(admin1=self) | Q(admin2=self) | Q(admin3=self)
        )

    class Meta:
        unique_together = (('name', 'parent', 'type'), )
        ordering = ['name', ]
        permissions = (
            ('add_institution', 'Add Institution'),
        )

    def __unicode__(self):
        return '%s' % self.name


class BoundaryNeighbours(models.Model):
    """Neighbouring boundaries"""
    boundary = models.ForeignKey('Boundary', on_delete=models.DO_NOTHING)
    neighbour = models.ForeignKey(
        'Boundary', related_name='boundary_neighbour', on_delete=models.DO_NOTHING)

    class Meta:
        unique_together = (('boundary', 'neighbour'), )


class BoundaryHierarchy(models.Model):
    """boundary hierarchy details"""
    admin5_id = models.OneToOneField(
        'Boundary', related_name='admin5_id',
        db_column='admin5_id', on_delete=models.DO_NOTHING)
    admin5_name = models.CharField(max_length=300)

    admin3_id = models.OneToOneField(
        'Boundary', related_name='admin3_id',
        db_column='admin3_id', primary_key=True, on_delete=models.DO_NOTHING)
    admin3_name = models.CharField(max_length=300)

    admin2_id = models.ForeignKey(
        'Boundary', related_name='admin2_id',
        db_column='admin2_id', on_delete=models.DO_NOTHING)
    admin2_name = models.CharField(max_length=300)

    admin1_id = models.ForeignKey(
        'Boundary', related_name='admin1_id', db_column='admin1_id', on_delete=models.DO_NOTHING)
    admin1_name = models.CharField(max_length=300)

    admin0_id = models.ForeignKey(
        'Boundary', related_name='admin0_id', db_column='admin0_id', on_delete=models.DO_NOTHING)
    admin0_name = models.CharField(max_length=300)

    type_id = models.ForeignKey('common.InstitutionType', db_column='type_id', on_delete=models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'mvw_boundary_hierarchy'


class BoundaryStateCode(models.Model):
    """stores the state codes"""
    char_id = models.CharField(max_length=10, primary_key=True)
    boundary = models.ForeignKey('Boundary', on_delete=models.DO_NOTHING)
    language = models.ForeignKey('common.Language', on_delete=models.DO_NOTHING)

    class Meta:
        ordering = ['char_id', ]
