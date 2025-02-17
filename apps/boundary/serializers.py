from rest_framework import serializers

from common.serializers import ILPSerializer
from boundary.models import (
    Boundary, ElectionBoundary, BoundaryHierarchy,
    BoundaryType, ElectionParty, BoundaryStateCode
)

from rest_framework_gis.serializers import (
    GeoFeatureModelSerializer,
    GeometrySerializerMethodField
)


class BoundarySerializer(ILPSerializer):

    class Meta:
        model = Boundary
        fields = (
            'id', 'name', 'parent', 'dise_slug', 'boundary_type', 'type',
            'status', 'lang_name',
        )


class BoundaryWithParentSerializer(ILPSerializer):
    parent_boundary = BoundarySerializer(source='parent')

    class Meta:
        model = Boundary
        fields = (
            'id', 'name', 'dise_slug', 'type', 'boundary_type',
            'parent_boundary', 'lang_name'
        )


class BoundaryHierarchySerializer(ILPSerializer):
    class Meta:
        model = BoundaryHierarchy()
        fields = (
            'admin0_name', 'admin0_id', 'admin1_name', 'admin1_id',
            'admin2_name', 'admin2_id', 'admin3_name', 'admin3_id',
            'admin4_name', 'admin4_id', 'admin5_name', 'admin5_id'
        )


class ElectionBoundarySerializer(ILPSerializer):
    name = serializers.CharField(source='const_ward_name')

    class Meta:
        model = ElectionBoundary
        fields = (
            'id', 'name',  'const_ward_type', 'dise_slug',
            'elec_comm_code', 'current_elected_rep',
            'current_elected_party', 'state'
        )


class BoundaryTypeSerializer(serializers.ModelSerializer):

    class Meta:
        model = BoundaryType
        fields = ('char_id', 'name')


class ElectionParty(serializers.ModelSerializer):

    class Meta:
        model = ElectionParty
        fields = ('char_id', 'name')


class StateListSerializer(serializers.ModelSerializer):
    state_name = serializers.CharField(source='boundary.name')
    boundary_id = serializers.CharField(source='boundary.id')

    class Meta:
        model = BoundaryStateCode
        fields = ('char_id', 'boundary_id', 'state_name')

