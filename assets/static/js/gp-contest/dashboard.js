'use strict';

(function() {
    klp.init = function() {
        // All GKA related data are stored in GKA
        klp.GP = {};
        klp.GP.routerParams = {};

        var searchByGPs = false;
        var selectedCoverageTab = '2018';
        var selectedPerformanceTab = 'basic';
        var selectedComparisonTab = 'year';
        var years = ["2016", "2017", "2018"];
        var performanceTabs = [
            {
                text: 'Basic',
                value: 'basic',
            },
            // {
            //     text: 'Details',
            //     value: 'details',
            // }
        ];
        var comparisonTabs = [
            {
                text: 'Year',
                value: 'year'
            }
        ];
        var tabs = _.map(years, function(tab) {
            return {
                value: tab,
                start_date: `${tab}-06-01`,
                end_date: `${Number(tab) + 1}-04-30`
            }
        })
        var $educational_hierarchy_checkbox = $("#select-educational-hrc");
        var $gp_checkbox = $("#select-gp-checkbox");
        var $select_school_cont = $("#select-school-cont");
        var $select_cluster_cont = $("#select-cluster-cont");
        var $select_gp_cont = $("#select-gp-cont");

        // This function is used as a callback to accordion init function
        // to determine which section to load when a user clicks a
        // section
        klp.GP.accordionClicked = function($el) {
            var isSectionVisible = $el.is(':visible'),
            elId = $el.attr('id'),
            functionMap = {
                "class-4-performance": loadPerformance,
                "class-5-performance": loadPerformance,
                "class-6-performance": loadPerformance,
            };
            if (!isSectionVisible) { return; }

            if (typeof(functionMap[elId]) === 'function') {
                functionMap[elId](klp.GP.routerParams);
            } else {
                console.log('Accordion event handler returned an unknow id');
            }
        }

        // Initialize accordion, filters and router
        klp.accordion.init();
        klp.gp_filters.init();
        klp.router = new KLPRouter();
        klp.router.init();
        klp.router.events.on('hashchange', function(event, params) {
            hashChanged(params);
        });
        klp.router.start();

        $('#startDate').yearMonthSelect("init", {validYears: ['2016', '2017', '2018', '2019','2020','2021','2022']});
        $('#endDate').yearMonthSelect("init", {validYears: ['2016', '2017', '2018', '2019','2020','2021','2022']});
        $('#startDate').yearMonthSelect("setDate", moment("20180601", "YYYYMMDD"));
        $('#endDate').yearMonthSelect("setDate", moment("20190331", "YYYYMMDD"));

        // Triggers hash changes into appropriate function calls
        function hashChanged(params) {
            var queryParams = params.queryParams;

            klp.GP.routerParams = queryParams;

            loadPerformance();
            loadCoverage();

            if (window.location.hash) {
                if (window.location.hash == '#resetButton') {
                    window.location.href = '/gp-contest';
                }
                else if(window.location.hash != '#datemodal' && window.location.hash !='#close' && window.location.hash != '#searchmodal') {
                }
            }
        }

        function showDefaultFilters() {
            // Setting educational_hierarchy by default true
            $educational_hierarchy_checkbox.prop("checked", true)
        }

        // hideSearchFields to hide search fields based on searchByGPs filter
        function hideSearchFields() {
            if (searchByGPs) {
                $select_school_cont.css("display", "none");
                $select_cluster_cont.css("display", "none");
                $select_gp_cont.css("display", "block");
            } else {
                $select_school_cont.css("display", "block");
                $select_cluster_cont.css("display", "block");
                $select_gp_cont.css("display", "none");
            }
        }

        // This function renders coverage tabs
        function renderYearsTabs() {
            var tplYearTab = swig.compile($('#tpl-tabs').html());
            var yearTabHTML = tplYearTab({ tabs: _.map(tabs, function(tab) {
                return { text: tab.value, value: tab.value };
            })});

            $('#year-tabs').html(yearTabHTML);
        }

        // This function renders performance tabs
        function renderPerformanceTabs() {
            var tplPerformanceTab = swig.compile($('#tpl-tabs').html());
            var performanceTabHTML = tplPerformanceTab({ tabs: performanceTabs });

            $('#performance-tabs').html(performanceTabHTML);
        }

        // this function renders comparison tabs
        function renderComaprisonTabs() {
            var tplComparisonTab = swig.compile($('#tpl-tabs').html());
            var comparisonTabHTML = tplComparisonTab({ tabs: comparisonTabs });

            $('#comparison-tabs').html(comparisonTabHTML);
        }

        function selectTab(tab, goingToSelectTab) {
            var $currentTab = $(`#${tab.value}`);
            if (tab.value === goingToSelectTab) {
                $currentTab.addClass("selected-gp-tab");
            } else {
                $currentTab.removeClass("selected-gp-tab");
            }
        }

        // This function select the tab
        function selectCoverageTab(goingToSelectTab) {
            _.forEach(tabs, function(tab) {
                selectTab(tab, goingToSelectTab);
            });
        }

        // This function select the performance tab
        function selectPerformanceTab(goingToSelectTab) {
            _.forEach(performanceTabs, function(tab) {
                selectTab(tab, goingToSelectTab);
            });
        }

        // This function select the Comparison Tab
        function selectComparisonTab(goingToSelectTab) {
            _.forEach(comparisonTabs, function(tab) {
                selectTab(tab, goingToSelectTab);
            });
        }

        $('#search_button').click(function(e){
            var district_id = $("#select-district").val(),
                block_id = $("#select-block").val(),
                cluster_id = $("#select-cluster").val(),
                institution_id = $("#select-school").val(),
                gp_id = $("#select-gp").val(),
                start_date = $('#startDate').yearMonthSelect("getFirstDay"),
                end_date = $('#endDate').yearMonthSelect("getLastDay"),
                url = '/gp-contest/#searchmodal';

            if (start_date && end_date) {
                url += '?from=' + start_date + '&to=' + end_date;
            } else {
                // url += 'default_date=true';
            }

            if (searchByGPs) {
                if (gp_id) {
                    url += '&electionboundary_id=' + gp_id;
                } else {
                    if (block_id) {
                        url += '&boundary_id' + block_id;
                    } else if (district_id) {
                        url += '&boundary_id' + district_id;
                    }
                }
            } else {
                if (institution_id) {
                    url += '&institution_id=' + institution_id;
                } else {
                    if (cluster_id) {
                        url += '&boundary_id=' + cluster_id;
                    } else if(block_id) {
                        url += '&boundary_id=' + block_id;
                    } else if(district_id) {
                        url += '&boundary_id=' + district_id;
                    }
                }
            }

            // Update coverage tab with filter start_date year and loading coverage
            var dateObject = new Date(start_date);
            selectedCoverageTab = String(dateObject.getFullYear());
            selectCoverageTab(selectedCoverageTab);
            loadCoverage();

            e.originalEvent.currentTarget.href = url;
        });

        // This returns search entity type and entity Id
        function getSearchedEntityInfo() {
            var routerParams = klp.GP.routerParams;

            if (routerParams.electionboundary_id) {
                return {
                    type: 'electionboundary_id',
                    value: routerParams.electionboundary_id,
                }
            }

            if (routerParams.institution_id) {
                return {
                    type: 'institution_id',
                    value: routerParams.institution_id,
                }
            }

            if (routerParams.boundary_id) {
                return {
                    type: 'boundary_id',
                    value: routerParams.boundary_id,
                }
            }

            return null;
        }

        // This function check for selected boundary and update that in the post url
        function checkForUrlParams(url) {
            var entityInfo = getSearchedEntityInfo();
            if (!entityInfo) {
                return url;
            }

            return `${url}&${entityInfo.type}=${entityInfo.value}`;
        };

        // Fetch coverage information
        function loadCoverage() {
            $("#gp-coverage").startLoading();

            var selectedYearInfo = tabs.find(function(tab) {
                return tab.value === selectedCoverageTab;
            });
            var coverageUrl = checkForUrlParams(`survey/summary/?survey_id=2&from=${selectedYearInfo.start_date}&to=${selectedYearInfo.end_date}`);
            var fetchGPUrl = checkForUrlParams(`survey/detail/electionboundary/?survey_id=2&from=${selectedYearInfo.start_date}&to=${selectedYearInfo.end_date}`);
            var $coverageXHR = klp.api.do(
                coverageUrl
            );
            $coverageXHR.done(function(result) {
                var $gpXHR = klp.api.do(
                    fetchGPUrl
                );

                $gpXHR.done(function(gpData) {
                    var tplCoverage = swig.compile($('#tpl-coverage').html());
                    var coverageHTML = tplCoverage({ data: result.summary, gp: gpData.GP });

                    $('#gp-coverage').html(coverageHTML);
                    $("#gp-coverage").stopLoading();
                });
            });
        }

        function getConcepts(conceptsData, classNumber) {
            var assessments = conceptsData[`Class ${classNumber} Assessment`];
            return Object.keys(assessments).map(function(key) {
                return assessments[key];
            })
        }

        function getConceptGroupChartData(conceptData) {
            var chartData = _.reduce(conceptData, function(soFar, value, key) {
                if (typeof value === 'object') {
                    soFar.labels.push(key);
                    soFar.series.push(Math.round((value.score / value.total ) * 100));
                }

                return soFar;
            }, { labels: [], series: []});

            return {
                labels: chartData.labels,
                series: [chartData.series]
            };
        }

        function getConceptGroups(concepts, selectedConceptGroupIndex) {
            return _.reduce(concepts[selectedConceptGroupIndex], function(soFar, value, index) {
                if (typeof value === 'object') {
                    soFar.push(value);
                }
                return soFar;
            }, []);
        }

        // This function creates graph element
        function createGraphElement(id, appendToId) {
            $('<div/>', {
                id: id,
                class: 'ct-chart ct-minor-seventh js-detail-container chartist-container bar-chart one-row-chart',
            }).appendTo(`#${appendToId}`);
        }

        // This function shows concepts groups and micro concepts
        function handleConcepts(clickedConceptValue, chartData, performanceResult, classNumber) {
            var seriesValues = chartData[`class${classNumber}`].series[0];
            var selectedConceptIndex = seriesValues.indexOf(Number(clickedConceptValue));

            var concepts = getConcepts(performanceResult, classNumber);
            var conceptGroupChartData = getConceptGroupChartData(concepts[selectedConceptIndex]);

            if ($(`#gp-performance-class-${classNumber}-concept-group`).length !== 0) {
                $(`#gp-performance-class-${classNumber}-concept-group`).remove();
            }
            createGraphElement(`gp-performance-class-${classNumber}-concept-group`, `concept-groups-class-${classNumber}`);

            renderBarChart(`#gp-performance-class-${classNumber}-concept-group`, conceptGroupChartData);

            $(`#close-concept-group-class-${classNumber}`).css('display', 'inline-block');
            $(`#concept-group-header-class-${classNumber}`).css('display', 'block');

            $(`#close-concept-group-class-${classNumber}`).click(() => {
                $(`#gp-performance-class-${classNumber}-concept-group`).remove();
                $(`#close-concept-group-class-${classNumber}`).css('display', 'none');
                $(`#concept-group-header-class-${classNumber}`).css('display', 'none');
            })

            $(`#gp-performance-class-${classNumber}-concept-group`).click(function(conceptGroupEvent) {
                var clickedConceptGroupValue = conceptGroupEvent.target.getAttribute('ct:value');
                var conceptGroups = getConceptGroups(concepts, selectedConceptIndex);
                var selectedConceptGroupIndex = conceptGroupChartData.series[0].indexOf(Number(clickedConceptGroupValue))
                var selectedConceptGroup = conceptGroups[selectedConceptGroupIndex]
                var microConceptChartData = getConceptGroupChartData(selectedConceptGroup);

                if ($(`#gp-performance-class-${classNumber}-micro-concept`).length !== 0) {
                    $(`#gp-performance-class-${classNumber}-micro-concept`).remove();
                }
                createGraphElement(`gp-performance-class-${classNumber}-micro-concept`, `micro-concepts-class-${classNumber}`);

                renderBarChart(`#gp-performance-class-${classNumber}-micro-concept`, microConceptChartData);

                // showing close button and header
                $(`#close-micro-concept-class-${classNumber}`).css('display', 'inline-block');
                $(`#micro-concept-header-class-${classNumber}`).css('display', 'block');

                $(`#close-micro-concept-class-${classNumber}`).click(() => {
                    $(`#gp-performance-class-${classNumber}-micro-concept`).remove();
                    $(`#close-micro-concept-class-${classNumber}`).css('display', 'none');
                    $(`#micro-concept-header-class-${classNumber}`).css('display', 'none');
                })
            })
        }

        // For resetting the details graph
        function resetDetailsGraph(value) {
            if (value !== 'details') {
                for (var i = 4; i <= 6; i++) {
                    $(`#gp-performance-class-${i}-micro-concept`).remove();
                    $(`#close-micro-concept-class-${i}`).css('display', 'none');
                    $(`#gp-performance-class-${i}-concept-group`).remove();
                    $(`#close-concept-group-class-${i}`).css('display', 'none');
                    $(`#concepts-header-class-${i}`).css('display', 'none');
                    $(`#concept-group-header-class-${i}`).css('display', 'none');
                    $(`#micro-concept-header-class-${i}`).css('display', 'none');
                }
            }

            if (value === "details") {
                for (var i = 4; i <= 6; i++) {
                    $(`#concepts-header-class-${i}`).css('display', 'block');
                }
            }
        }

        // return sorted labels based on order field
        function getSortedCompetancyLabelsBasedOnOrder(classData) {
            if (classData && !Object.keys(classData)) {
                return [];
            }

            classData = _.map(classData, function(value, key) {
                value.label = key;
                return value
            });
            var sortedClassData = _.sortBy(
                classData,
                function(d){return d.order}
            );
            return _.map(sortedClassData, function(value) {
                return value.label
            })
        }

        // Fetch performance info
        function loadPerformance() {
            // Starting all spinners
            $("#gp-performance-class-4").startLoading();
            $("#gp-performance-class-5").startLoading();
            $("#gp-performance-class-6").startLoading();

            var routerParams = klp.GP.routerParams;
            var dateParams = {};

            var selectedYearInfo = tabs.find(function(tab) {
                return tab.value === selectedCoverageTab;
            });

            if (routerParams.from && routerParams.to) {
                dateParams.from = routerParams.from;
                dateParams.to = routerParams.to;
            } else {
                var defaultDateParams = getDefaultAcademicYear();
                dateParams.from = defaultDateParams.from;
                dateParams.to = defaultDateParams.to;
            }

            if (selectedPerformanceTab === 'basic') {
                var basicPerformanceUrl = checkForUrlParams(`survey/detail/questiongroup/key/?survey_id=2&from=${dateParams.from}&to=${dateParams.to}`);
                var $performanceXHR = klp.api.do(basicPerformanceUrl);

                $performanceXHR.done(function(result) {
                    var chartData = {},
                        labels = [],
                        series = [];

                    for (var i = 4; i <= 6; i++) {
                        var sortedLabels = getSortedCompetancyLabelsBasedOnOrder(result['Class ' + i +' Assessment']);

                        if (Object.keys(result).length) {
                            labels = sortedLabels;
                            series = _.map(sortedLabels, function(label) {
                                var graphVals = result['Class ' + i +' Assessment'];
                                if (!graphVals[label]) {
                                    return 0;
                                }

                                return Math.round((graphVals[label].score / graphVals[label].total) * 100);
                            });
                        } else {
                            labels = [];
                            series = [];
                        }


                        chartData['class' + i] = {labels: [], series: [[]]};
                        _.forEach(sortedLabels, function(l, index) {
                            if(!_.includes(sortedLabels, l)) { return; }

                            chartData['class' + i].labels.push(l);
                            chartData['class' + i].series[0].push(series[index]);
                        });

                    // chartData['class' + i] = {
                    //   labels: _.keys(result['Class ' + i +' Assessment']),
                    //   series: [_.map(result['Class ' + i +' Assessment'], function(r){
                    //     return Math.round((r.score / r.total) * 100);
                    //   })]
                // };
                    }

                    renderBarChart('#gp-performance-class-4', chartData.class4);
                    renderBarChart('#gp-performance-class-5', chartData.class5);
                    renderBarChart('#gp-performance-class-6', chartData.class6);

                    // Stoping all spinners
                    $("#gp-performance-class-4").stopLoading();
                    $("#gp-performance-class-5").stopLoading();
                    $("#gp-performance-class-6").stopLoading();
                });
            } else {
                var detailsPerformanceUrl = checkForUrlParams(`survey/detail/questiongroup/qdetails/?survey_id=2&from=${selectedYearInfo.start_date}&to=${selectedYearInfo.end_date}`);
                var $performanceXHR = klp.api.do(detailsPerformanceUrl);

                $performanceXHR.done(function(performanceResult) {
                    var chartData = {};
                    for(var i = 4; i <= 6; i++) {
                        chartData['class' + i] = {
                            labels: _.keys(performanceResult['Class ' + i +' Assessment']),
                            series: [_.map(performanceResult['Class ' + i +' Assessment'], function(r, index){
                                return Math.round((r.score / r.total) * 100);
                            })]
                        };
                    }

                    // Rendering the all the graphs
                    renderBarChart('#gp-performance-class-4', chartData.class4);
                    renderBarChart('#gp-performance-class-5', chartData.class5);
                    renderBarChart('#gp-performance-class-6', chartData.class6);

                    // Stoping all spinners
                    $("#gp-performance-class-4").stopLoading();
                    $("#gp-performance-class-5").stopLoading();
                    $("#gp-performance-class-6").stopLoading();

                    // concepts graph listeners
                    $('#gp-performance-class-4').click(function(conceptEvent) {
                        var clickedConceptValue = conceptEvent.target.getAttribute('ct:value');
                        handleConcepts(clickedConceptValue, chartData, performanceResult, '4');
                    });
                    $('#gp-performance-class-5').click(function(value) {
                        var clickedConceptValue = value.target.getAttribute('ct:value');
                        handleConcepts(clickedConceptValue, chartData, performanceResult, '5');
                    });
                    $('#gp-performance-class-6').click(function(value) {
                        var clickedConceptValue = value.target.getAttribute('ct:value');
                        handleConcepts(clickedConceptValue, chartData, performanceResult, '6');
                    });
               });
            } /* if else ends */
        }

        // Calling all functions
        hideSearchFields();
        showDefaultFilters();
        renderYearsTabs();
        selectCoverageTab(selectedCoverageTab);
        renderPerformanceTabs();
        selectPerformanceTab(selectedPerformanceTab);
        renderComaprisonTabs();
        selectComparisonTab(selectedComparisonTab);

        // Start filling the default views/tabs
        loadCoverage();
        // loadPerformance();

        // listeners for checkboxes
        $educational_hierarchy_checkbox.on("change", function(value) {
            searchByGPs = false;
            $gp_checkbox.prop("checked", false);

            hideSearchFields();
        })

        $gp_checkbox.on("change", function(value) {
            searchByGPs = true;
            $educational_hierarchy_checkbox.prop("checked", false)

            hideSearchFields();
        })

        // Coverage tabs listener
        _.forEach(tabs, function(tab) {
            var $tabId = $(`#${tab.value}`);
            $tabId.on("click", function(e) {
                selectedCoverageTab = e.target.dataset.value;
                selectCoverageTab(selectedCoverageTab);
                loadCoverage();
            });
        })

        // Performance tabs listener
        _.forEach(performanceTabs, function(tab) {
            var $tabId = $(`#${tab.value}`);
            $tabId.on("click", function(e) {
                selectedPerformanceTab = e.target.dataset.value;
                selectPerformanceTab(selectedPerformanceTab);

                // removing if user has opened the details graph
                resetDetailsGraph(tab.value);

                // Loading performance
                loadPerformance();
            })
        })

        // Comparison tab listener
        _.forEach(comparisonTabs, function(tab) {
            var $tabId = $(`#${tab.value}`);
            $tabId.on("click", function(e) {
                selectedComparisonTab = e.target.dataset.value;
                selectComparisonTab(selectedComparisonTab);
            })
        })

        // Charts renderers
        function renderBarChart(elementId, data, yTitle=' ') {
            var options = {
                seriesBarDistance: 10,
                axisX: {
                    showGrid: true,
                    offset: 80
                },
                axisY: {
                    showGrid: true,
                    // offset: 80
                },
                position: 'start',
                plugins: [
                    Chartist.plugins.tooltip(),
                    Chartist.plugins.ctAxisTitle({
                    axisX: {
                        //No label
                    },
                    axisY: {
                        axisTitle: yTitle,
                        axisClass: 'ct-axis-title',
                        offset: {
                        x: 0,
                        y: 0
                        },
                        textAnchor: 'middle',
                        flipTitle: false
                    }
                    })
                ]
            };

            var responsiveOptions = [
                ['screen and (max-width: 749px)', {
                    seriesBarDistance: 5,
                    height: '200px',
                    axisX: {
                    labelInterpolationFnc: function (value) {
                        if (value.length > klp.GKA.GRAP_LABEL_MAX_CHAR) {
                        return value.slice(0, klp.GKA.GRAP_LABEL_MAX_CHAR) + '..'
                        }

                        return value;
                    },
                    offset: 80
                    }
                }]
            ];

            var $chart_element = Chartist.Bar(elementId, data, options, responsiveOptions).on('draw', function(chartData) {
                if (chartData.type === 'bar') {
                    chartData.element.attr({
                        style: 'stroke-width: 15px;'
                    });
                }
                if (chartData.type === 'label' && chartData.axis === 'x') {
                    chartData.element.attr({
                        width: 200
                    })
                }
            });
        }

    }

    /* Helper function */
    $.fn.startLoading = function() {
        var $this = $(this);
        var $loading = $('<div />').addClass('fa fa-cog fa-spin loading-icon-base js-loading');
        $this.empty().append($loading);
    }

    $.fn.stopLoading = function() {
        var $this = $(this);
        $this.find('.js-loading').remove();
    }

    function getDefaultAcademicYear() {
        var currentDate = new Date();
        var currentYear = currentDate.getFullYear();
        return {
            from: currentYear + '-06-01',
            to: (currentYear + 1) + '-04-30',
        }
    }
})()


