from rest_framework.routers import DefaultRouter

from rest_framework_extensions.routers import ExtendedSimpleRouter

from django.urls import re_path

from schools.api_view import (
    InstitutionViewSet, InstitutionCategoryListView,
    InstitutionManagementListView, InstitutionDemographics,
    InstitutionInfra, InstitutionFinance, InstitutionSummaryView,
    MergeEndpoints, OmniSearch, InstitutionLanguageListView
)
from schools.api_view import (
    StudentViewSet, StudentGroupViewSet, StudentStudentGroupViewSet,
    ProgrammeViewSet, StaffViewSet, InstituteStudentsViewSet,
    InstituteStudentGroupViewSet
)
from schools.views import SchoolPageView

nested_router = ExtendedSimpleRouter()
router = DefaultRouter()

router.register(r'teachers', StaffViewSet, basename='teacher')
router.register(r'institutestudents', InstituteStudentsViewSet, basename='institutestudent')
router.register(r'institutestudentgroups', InstituteStudentGroupViewSet, basename='institutestudentgroup')

# Institution -> StudentGroup -> Students
institution_routes = nested_router.register(
    r'institutions',
    InstitutionViewSet,
    basename='institution'
)
institution_routes.register(
    r'studentgroups',
    StudentGroupViewSet,
    basename='institution-studentgroup',
    parents_query_lookups=['institution']
)
institution_routes.register(
    r'students',
    StudentViewSet,
    basename='institution-student',
    parents_query_lookups=['institution']
)

# StudentGroups -> Students -> StudentStudentGroupRelation
nested_router.register(
    r'studentgroups',
    StudentGroupViewSet,
    basename='studentgroup',
    ).register(
        r'students',
        StudentViewSet,
        basename='studentgroup-student',
        parents_query_lookups=['studentgroups']
        ).register(
            r'enrollment',
            StudentStudentGroupViewSet,
            basename='studentstudentgrouprelation',
            parents_query_lookups=['student__studentgroups', 'student']
        )

# Programme
nested_router.register(r'programmes', ProgrammeViewSet, basename='programme')

urlpatterns = [
    re_path(r'^merge$', MergeEndpoints.as_view(), name='api_merge'),
    re_path(r'^search/$', OmniSearch.as_view(), name='api_omni_search'),
    re_path(r'^institution/categories$',
        InstitutionCategoryListView.as_view(),
        name='inst-category'),
    re_path(r'^institution/managements$',
        InstitutionManagementListView.as_view(),
        name='inst-management'),
    re_path(r'^institutions/list$',
        InstitutionSummaryView.as_view(),
        name='inst-list'),
    re_path(r'^institution/(?P<pk>[0-9]+)/languages/$',
        InstitutionLanguageListView.as_view(),
        name='inst-language'),
    re_path(r'^institutions/(?P<pk>[0-9]+)/demographics$',
        InstitutionDemographics.as_view(),
        name='inst-demographics'),
    re_path(r'^institutions/(?P<pk>[0-9]+)/infrastructure$',
        InstitutionInfra.as_view(),
        name='inst-infra'),
    re_path(r'^institutions/(?P<pk>[0-9]+)/finance$',
        InstitutionFinance.as_view(),
        name='inst-finance'),
] + router.urls + nested_router.urls

app_name="institution"