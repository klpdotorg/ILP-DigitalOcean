import datetime, os, csv
from io import TextIOWrapper
from pprint import pprint
import pdfkit

from django.shortcuts import render, get_object_or_404
from django.http import HttpResponse
from django.views import View
from django.db.models.fields.json import KeyTextTransform
from django.db.models import Sum, Count, Case, When
from django.template.loader import render_to_string

from .links import send_link, send_recipient
from .models import Reports, Tracking
from .reportlist import reportlist
from django.utils.translation import activate, get_language_from_request, get_language_info
from django.db.models import Q
from boundary.models import Boundary, BoundaryStateCode

'''This is the view used to view the reports'''
def view_report(request, report_id, tracking_id='default'):
    try:
        report = Reports.objects.get(link_id=report_id)
        data = report.data
    except Reports.DoesNotExist:
        return render(request, 'reports/404.html', context={'data': report_id})

    try:
        tracker = Tracking.objects.get(track_id=tracking_id, report_id__link_id=report_id)
        tracker.visit_count += 1
        tracker.visited_at = datetime.datetime.now()
        tracker.save()
    except Tracking.DoesNotExist:
        pass

    return render(request, 'reports/{}.html'.format(report.report_type), context={'data':data, 'reportid': report_id,'trackid': tracking_id})
   
# '''This is the view used to view the reports'''
# def view_report(request, report_id, tracking_id='default'):
#     try:
#         report = Reports.objects.get(link_id=report_id)
#         data = report.data
#     except Reports.DoesNotExist:
#         return render(request, 'reports/404.html', context={'data': report_id})

#     try:
#         tracker = Tracking.objects.get(track_id=tracking_id, report_id__link_id=report_id)
#         tracker.visit_count += 1
#         tracker.visited_at = datetime.datetime.now()
#         tracker.save()
#     except Tracking.DoesNotExist:
#         pass

#     if request.GET.get('lang') == 'english':
#         activate('en')
#         return render(request, 'reports/{}.html'.format(report.report_type), context={'data':data, 'reportid': report_id,'trackid': tracking_id})
#     else:
#         activate('kn')
#         return render(request, 'reports/{}kannada.html'.format(report.report_type), context={'data':data,'reportid': report_id,'trackid': tracking_id})

def download_report(request, report_id, tracking_id='default'):
    try:
        report_model = Reports.objects.get(link_id=report_id)
    except Reports.DoesNotExist:
        return render(request, 'reports/404.html', context={'data': report_id})
    locale = get_language_from_request(request,check_path=True)
    lang_info = get_language_info(locale)
    report = reportlist[report_model.report_type](data=report_model.data)
    pdf_file_name = report.get_pdf(report_id, tracking_id, lang=lang_info['name'].lower())
    filename = report_model.report_type+datetime.datetime.now().strftime("%d%m%y")+'.pdf'
    try:
        tracker = Tracking.objects.get(track_id=tracking_id, report_id__link_id=report_id)
        tracker.download_count += 1
        tracker.downloaded_at = datetime.datetime.now()
        tracker.save()
    except Tracking.DoesNotExist:
        pass
    with open(pdf_file_name, 'rb') as f:
        pdf_data = f.read()
    response = HttpResponse(pdf_data, content_type="application/pdf")
    response['Content-Disposition'] = 'inline; filename=' + filename
    #Remove the temporary PDF file 
    os.remove(pdf_file_name)
    return response

def download_analytics(request, *args, **kwargs):
    template = 'reports/report_analytics_summary.html'
    data_from = request.GET.get('from')
    data_to = request.GET.get('to')
    state_code = request.GET.get('state')
    messages = []
    successfull=True
    # tracking_ids = Tracking.objects.filter(created_at__range=[data_from, data_to]).values_list('report_id', flat=True)
    # tracking = Tracking.objects.filter(created_at__range=[data_from, data_to])
    # reports = Reports.objects.filter(id__in=tracking_ids)
    #reports = Reports.objects.filter(data__today__range=[data_from, data_to])
    trackings = Tracking.objects.filter(created_at__range=[data_from, data_to]).values_list('report_id', flat=True)
    #Add check and exception here
    state_id = BoundaryStateCode.objects.get(char_id=state_code).boundary_id
    state = Boundary.objects.get(id=state_id)
    reports = Reports.objects.filter(id__in=trackings).filter(state=state_id)
    data = {'district_level':getDistrictLevel(reports),
            'block_level':getBlockLevel(reports),
            'cluster_level':getClusterLevel(reports),
            'top_summary':getTopSummary(reports),
            'by_type':getByReportType(reports),
            'by_user':getByUser(trackings),
            'state_name': state.name,
            'state_code': state
    }
    options = {
            'encoding':'utf-8',
        }
    # pdf = pdfkit.PDFKit(html, 'string', configuration=config, options=options).to_pdf()
    html = render_to_string(template, {'data':data})
    config = pdfkit.configuration()
    pdf = pdfkit.PDFKit(html, 'string', configuration=config, options=options).to_pdf()

    response = HttpResponse(pdf, content_type="application/pdf")
    response['Content-Disposition'] = 'inline; filename=' + 'REPORTANALYTICS.pdf'
    return response

class SendReport(View):
    def get(self,request):
        return render(request, 'reports/send_report.html', context={'reports':reportlist})

    def post(self,request):
        report_type = request.POST.get('report_type')
        report_from = request.POST.get('from')
        report_to = request.POST.get('to')
        dry = request.POST.get('dry_run')
        print(dry)
        recipients = TextIOWrapper(request.FILES['recipients'].file, encoding=request.encoding)
        reader = csv.reader(recipients)

        res= send_recipient(report_type, report_from, report_to, reader, dry)
        
        return render(request, 'reports/report_summary.html', context={'messages':res['messages'], 'success':res['successfull']})

    def getValue(self, person, head, i):

        index = head.index(i)
        value = person[index]
        return value

class ReportAnalytics(View):
    def get(self,request):
        if request.GET.get('from') and request.GET.get('to') :
            data_from = request.GET.get('from')
            data_to = request.GET.get('to')
            state = request.GET.get('state')
            messages = []
            successful = True
            #reports = Reports.objects.filter(data__today__range=[data_from, data_to])
            trackings = Tracking.objects.filter(created_at__range=[data_from, data_to]).values_list('report_id', flat=True)
            #Add check and exception here
            state_id = BoundaryStateCode.objects.get(char_id=state).boundary_id
            state_obj = Boundary.objects.get(id=state_id)
            reports = Reports.objects.filter(id__in=trackings).filter(state=state_id)
            states = reports.values_list('state_id', flat=True)
            data = {'district_level':getDistrictLevel(reports),
                    'block_level':getBlockLevel(reports),
                    'cluster_level':getClusterLevel(reports),
                    'top_summary':getTopSummary(reports),
                    'by_type':getByReportType(reports),
                    'by_user':getByUser(trackings),
                    'state_name': state_obj.name,
                    'state_code': state
            }
            return render(request, 'reports/report_analytics_summary.html', context={'messages':messages, 'success':successful,'data':data})
        else:
            return render(request, 'reports/report_analytics.html', context={'reports':reportlist})
    
    def getValue(self, person, head, i):

        index = head.index(i)
        value = person[index]
        return value

'''reportType can be one of DistrictReport or DistrictReportSummarized'''
def getDistrictLevel(reports):
    districtreport = reports.filter(Q(report_type='DistrictReport')|Q(report_type='DistrictReportSummarized')).annotate(district_name=KeyTextTransform('district_name', 'parameters'))
    districts = districtreport.values_list('district_name', flat=True).distinct() # Get district names
    ##for cluster replace district_name with cluster_name and similarly for block and others
    count = []
    for district in districts:
        c = districtreport.filter(district_name=district)
        sent = c.count()
        visit = c.aggregate(sum=Sum('tracking__visit_count'))['sum']
        read = c.aggregate(read_unique = Count(Case(When(tracking__visit_count__gt=0, then=1))))['read_unique']
        download = c.aggregate(sum=Sum('tracking__download_count'))['sum']
        count.append(dict(sent=sent, read=read, visit=visit, download=download,district=district))
    return count

'''reportType can be one of BlockReport or BlockReportSummarized'''
# def getBlockLevel(reports):
#     blockreport = reports.filter(Q(report_type='BlockReport')|Q(report_type='BlockReportSummarized')).annotate(district_name=KeyTextTransform('district_name', 'parameters'),
#                                                                      block_name=KeyTextTransform('block_name', 'parameters'))
#     districts = blockreport.values_list('district_name', flat=True).distinct() # Get district names
#     count = []
#     for district in districts:
#         c = blockreport.filter(district_name=district)
#         #block_num =  c.values_list('block_name', flat=True).distinct().count() # Get district names
#         #block_num = reports.filter(Q(report_type='BlockReport')|Q(report_type='BlockReportSummarized')).count()
#         sent = c.count()
#         visit = c.aggregate(sum=Sum('tracking__visit_count'))['sum']
#         read = c.aggregate(read_unique = Count(Case(When(tracking__visit_count__gt=0, then=1))))['read_unique']
#         download = c.aggregate(sum=Sum('tracking__download_count'))['sum']
#         count.append(dict(sent=sent, read=read, visit=visit, download=download,district=district,block_num=block_num))   
#     return count

def getBlockLevel(reports):
    blockreport = reports.filter(Q(report_type='BlockReport')|Q(report_type='BlockReportSummarized')).annotate(district_name=KeyTextTransform('district_name', 'parameters'),
                                                                     block_name=KeyTextTransform('block_name', 'parameters'))
    blocks = blockreport.values_list('block_name', flat=True).distinct() # Get district names
    count = []
    for block in blocks:
        #import pdb; pdb.set_trace()
        block_reports = blockreport.filter(block_name=block)
        district_name = block_reports.values_list('district_name', flat=True).distinct()[0]
        #block_obj = Boundary.objects.filter(boundary_type_id='SB').get(name=block)
        #block_num =  c.values_list('block_name', flat=True).distinct().count() # Get district names
        #block_num = reports.filter(Q(report_type='BlockReport')|Q(report_type='BlockReportSummarized')).count()
        sent = block_reports.count()
        visit = block_reports.aggregate(sum=Sum('tracking__visit_count'))['sum']
        read = block_reports.aggregate(read_unique = Count(Case(When(tracking__visit_count__gt=0, then=1))))['read_unique']
        download = block_reports.aggregate(sum=Sum('tracking__download_count'))['sum']
        count.append(dict(sent=sent, read=read, visit=visit, download=download,block=block, district=district_name))   
    return count


'''reportType can be one of ClusterReport or ClusterReportSummarized'''
def getClusterLevel(reports):
    clusterreport = reports.filter(Q(report_type='ClusterReport')|Q(report_type='ClusterReportSummarized')).annotate(cluster_name=KeyTextTransform('cluster_name', 'parameters'),
                                                                         block_name=KeyTextTransform('block_name', 'parameters'))
    clusters = clusterreport.values_list('cluster_name', flat=True).distinct() 
    count = []
    for cluster in clusters:
        c = clusterreport.filter(cluster_name=cluster)
        block_name = c.values_list('block_name', flat=True).distinct()[0]
        #cluster_num =  c.values_list('cluster_name', flat=True).distinct().count() 
        sent = c.count()
        visit = c.aggregate(sum=Sum('tracking__visit_count'))['sum']
        read = c.aggregate(read_unique = Count(Case(When(tracking__visit_count__gt=0, then=1))))['read_unique']
        download = c.aggregate(sum=Sum('tracking__download_count'))['sum']
        count.append(dict(sent=sent, read=read, visit=visit, download=download,block=block_name,cluster=cluster))  
    return count

def getTopSummary(reports):
    sent = reports.count()
    visit = reports.aggregate(sum=Sum('tracking__visit_count'))['sum']
    if visit is None:
        visit = 0
    read = reports.aggregate(read_unique = Count(Case(When(tracking__visit_count__gt=0, then=1))))['read_unique']
    download = reports.aggregate(sum=Sum('tracking__download_count'))['sum']
    if download is None:
        download = 0
    return dict(sent=sent, read=read, visit=visit, download=download)

def getByReportType(reports):
    district_report = reports.filter(report_type='DistrictReport')
    district_summarized_report = reports.filter(report_type='DistrictReportSummarized')
    block_report = reports.filter(report_type='BlockReport')
    block_report_summarized = reports.filter(report_type='BlockReportSummarized')
    clusterreport = reports.filter(report_type='ClusterReport')
    cluster_report_summarized = reports.filter(report_type='ClusterReportSummarized')
    school_report = reports.filter(report_type='SchoolReport')
    gp_report = reports.filter(report_type='GPMathContestReport')
    gp_report_summarized = reports.filter(report_type='GPMathContestReportSummarized')

    district = getTopSummary(district_report)
    district_summarized = getTopSummary(district_summarized_report)
    block = getTopSummary(block_report)
    block_summarized = getTopSummary(block_report_summarized)
    cluster = getTopSummary(clusterreport)
    cluster_summarized = getTopSummary(cluster_report_summarized)
    school = getTopSummary(school_report)
    gp = getTopSummary(gp_report)
    gp_summarized = getTopSummary(gp_report_summarized)

    return dict(district=district, district_summarized=district_summarized, block=block,\
                block_summarized=block_summarized,\
                cluster=cluster,\
                cluster_summarized=cluster_summarized,\
                school=school,\
                gp=gp,\
                gp_summarized=gp_summarized)

def getByUser(trackings):
    
    beo =  trackings.filter(role='BEO')
    brp = trackings.filter(role='BRP')
    bfc  = trackings.filter(role='BFC')
    brc = trackings.filter(role='BRC')
    ddpi = trackings.filter(role='DDPI')
    diet = trackings.filter(role='DIET')
    dfm = trackings.filter(role='DFM')
    crps = trackings.filter(role='CRP')
    hms = trackings.filter(role='HM')
    gp_members = trackings.filter(role='GP MEMBERS')
    staff = trackings.filter(role='AKSHARA STAFF')
    
    return dict(beo = getSentData(beo),\
                brp = getSentData(brp),\
                bfc = getSentData(bfc),\
                brc = getSentData(brc),\
                ddpi = getSentData(ddpi),\
                diet = getSentData(diet),\
                dfm = getSentData(dfm),\
                crps = getSentData(crps),\
                hms = getSentData(hms),\
                staff = getSentData(staff),\
                gp_member = getSentData(gp_members))

def getSentData(trackings):
    sent = trackings.count()
    visit = trackings.aggregate(sum=Sum('visit_count'))['sum']
    if visit is None:
        visit = 0
    read = trackings.aggregate(read_unique = Count(Case(When(visit_count__gt=0, then=1))))['read_unique']
    download = trackings.aggregate(sum=Sum('download_count'))['sum']
    if download is None:
        download = 0
    return dict(sent=sent, read=read, visit=visit, download=download)
