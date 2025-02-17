from rest_framework.response import Response
from boundary.models import Boundary, BoundaryNeighbours
from common.models import AcademicYear
from . import BaseBoundaryReport
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.exceptions import APIException


class DiseBoundaryDetails(APIView, BaseBoundaryReport):

    reportInfo = {}

    def get_boundary_info(self, boundaryid):
        year = self.request.GET.get('year', settings.DISE_ACADEMIC_YEAR).replace('-','')
        print(year)
        try:
            academic_year = AcademicYear.objects.get(char_id=year)
        except AcademicYear.DoesNotExist:
            raise APIException('Academic year is not valid.\
                    It should be in the form of 1516.', 404)
        self.reportInfo["academic_year"] = academic_year.year
        try:
            boundary = Boundary.objects.get(pk=boundaryid)
        except Exception:
            raise APIException('Boundary not found', 404)
        self.get_boundary_summary_data(boundary, self.reportInfo)
        if boundary.boundary_type_id == 'SD':
            self.reportInfo["neighbours"] = []
            neighbourlist = BoundaryNeighbours.objects.filter(boundary=boundary).values_list("neighbour_id", flat=True)
            if neighbourlist:
                neighbours = Boundary.objects.filter(id__in = list(neighbourlist))
                if neighbours:
                    for neighbour in neighbours:
                        self.reportInfo["neighbours"].append({
                        "dise": neighbour.dise_slug, "type": "district"})


    def get(self, request):
        mandatoryparams = {'id': []}
        self.check_mandatory_params(mandatoryparams)

        id = self.request.GET.get("id")
        reportlang = self.request.GET.get("language", "english")

        self.reportInfo["report_info"] = {"report_lang": reportlang}
        self.get_boundary_info(id)
        return Response(self.reportInfo)
