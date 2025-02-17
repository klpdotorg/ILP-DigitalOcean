import logging
from django.db.models import Q
from boundary.serializers import (
    BoundarySerializer, BoundaryTypeSerializer,
    StateListSerializer
)

from boundary.filters import BoundaryFilter
from boundary.models import (
    Boundary, BoundaryType, BoundaryStateCode
)

from common.views import ILPListAPIView, ILPDetailAPIView
from common.mixins import ILPStateMixin
from common.models import Status
from rest_framework import viewsets
from permissions.permissions import IlpBasePermission

logger = logging.getLogger(__name__)


class BoundaryViewSet(ILPStateMixin, viewsets.ModelViewSet):
    '''Boundary endpoint for all CRUD related to boundaries'''
    queryset = Boundary.objects.exclude(status=Status.DELETED)
    serializer_class = BoundarySerializer
    filter_class = BoundaryFilter
    bbox_filter_field = "geom"
    permission_classes = (IlpBasePermission,)

    def get_queryset(self):
        state = self.get_state()
        if state:
            boundaries = self.queryset.filter(
                Q(parent=state) |
                Q(parent__parent=state) |
                Q(parent__parent__parent=state)
            )
        else:
            boundaries = self.queryset
        return boundaries

    def perform_destroy(self, instance):
        instance.status_id = Status.DELETED
        instance.save()


class BoundaryTypeViewSet(viewsets.ModelViewSet):
    """
        Endpoint handling all operations related to BoundaryType (SD, SC, SB, PD, PP, PC)
    """
    queryset = BoundaryType.objects.all()
    serializer_class = BoundaryTypeSerializer


class StateListAPIView(ILPListAPIView):
    queryset = BoundaryStateCode.objects.all()
    serializer_class = StateListSerializer
