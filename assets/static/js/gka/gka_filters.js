'use strict';
(function() {


    var t = klp.gka_filters = {},
        $_filter_button,
        $trigger,
        template;

    var surveyId = 1;
    var questionGroupId = 8;

    t.init = function() {
        klp.router = new KLPRouter();
        klp.router.init();
        klp.router.start();
        //initSelect2();
        //$(".box").hide();
        $(document).ready(function(){
            initEduSearch();
        });

    }

    function format(item) {
        if (item.properties != undefined)
            return _.str.titleize(item.properties.name);
        else
            return _.str.titleize(item.name);
    }


    function populateSelect(container, data) {
        data.features.forEach(function(d) {
            if(d.properties !=undefined)
                d.id = d.properties.id;
        });
        container.select2({
            sortResults: function(results) {
                return _.sortBy(results, function(result) {
                    if (result.properties != undefined)
                        return result.properties.name;
                    else
                        return result.name;
                });
            },
            data: {
                results: data.features,
                text: function(item) {
                    if (item.properties != undefined)
                        return item.properties.name;
                    else
                        return item.name;
                }
            },
            formatSelection: format,
            formatResult: format,
        });
    }


    function clearSelect(container) {
        container.select2("val","");
        populateSelect(container, {features: []});
    }


    function setBoundaryAttributes(attr) {
        // var $search_button = $("#search_button");
        // $search_button.attr('href', '/gka/#searchmodal?' + attr);
    }


    function initEduSearch(school_type) {
        var $select_division = $("#select-division");
        var $select_district = $("#select-district");
        var $select_taluk = $("#select-taluk");
        var $select_block = $("#select-block");
        var $select_cluster = $("#select-cluster");
        var $select_school = $("#select-school");

        clearSelect($select_division);
        clearSelect($select_district);
        clearSelect($select_taluk);
        clearSelect($select_block);
        clearSelect($select_cluster);
        clearSelect($select_school);

        var url = "boundary/admin5s/?per_page=0&school_type=primary";
        var divisionsXHR = klp.api.do(url);
        divisionsXHR.done(function(data) {
            var divisions = {};
            divisions.features = _.map(data.results, function(d){
                var division = {
                    id: d.id,
                    name: d.name
                };
                return division;
            });
            populateSelect($select_division, divisions);

            var districtsXHR = klp.api.do('boundary/admin5/' + selected.val + '/admin1/?per_page=0');
            districtsXHR.done(function (data) {
                data.features = data.results;
                populateSelect($select_district, data);
            });
        });

//        var url = "boundary/admin1s/?per_page=0&school_type=primary"
//        var districtsXHR = klp.api.do(url);
//        districtsXHR.done(function(data) {
//            var districts = {};
//            districts.features = _.map(data.results, function(d){
//                var district = {
//                    id: d.id,
//                    name: d.name
//                };
//                return district;
//            });
//            populateSelect($select_district, districts);
//        });
        $select_division.on("change", function(selected) {

            clearSelect($select_district);
            clearSelect($select_block);
            clearSelect($select_taluk);
            clearSelect($select_cluster);
            clearSelect($select_school);

            var districtsXHR = klp.api.do('boundary/admin5/' + selected.val + '/admin1/?per_page=0');
            districtsXHR.done(function (data) {
                data.features = data.results;
                populateSelect($select_district, data);
            });
        });

        $select_district.on("change", function(selected) {

            clearSelect($select_block);
            clearSelect($select_taluk);
            clearSelect($select_cluster);
            clearSelect($select_school);
            setBoundaryAttributes('boundary_id=' + selected.val);

            var blockXHR = klp.api.do('boundary/admin1/' + selected.val + '/admin2/?per_page=0');
            blockXHR.done(function (data) {
                data.features = data.results;
                populateSelect($select_block, data);
            });

            var talukXHR = klp.api.do('boundary/admin1/' + selected.val + '/admin4/?per_page=0');
            talukXHR.done(function (data) {
                data.features = data.results;
                populateSelect($select_taluk, data);
            });
        });

        $select_block.on("change", function(selected) {
            clearSelect($select_taluk);
            clearSelect($select_cluster);
            clearSelect($select_school);
            setBoundaryAttributes('boundary_id=' + selected.val);

            var clusterXHR = klp.api.do('boundary/admin2/' + selected.val + '/admin3/?per_page=0');
            clusterXHR.done(function (data) {
                data.features = data.results;
                populateSelect($select_cluster, data);
            });
        });

        $select_taluk.on("change", function(selected) {
            clearSelect($select_block);
            clearSelect($select_cluster);
            clearSelect($select_school);
            setBoundaryAttributes('boundary_id=' + selected.val);

            var schoolXHR = klp.api.do('institutions/', {'admin4':selected.val, 'per_page': 0});
            schoolXHR.done(function (data) {
                data.features = data.results
                populateSelect($select_school, data);
            });
        });

        $select_cluster.on("change", function(selected) {

            clearSelect($select_school);
            setBoundaryAttributes('boundary_id=' + selected.val);

            var schoolXHR = klp.api.do('institutions/', {'admin3':selected.val, 'per_page': 0});
            schoolXHR.done(function (data) {
                data.features = data.results
                populateSelect($select_school, data);
            });
        });


        $select_school.on("change", function(selected) {
            setBoundaryAttributes('institution_id=' + selected.val);
        });
    }


    function makeResults(array, type) {
        var schoolDivisionMap = {
            'primaryschool': 'Primary School',
            'preschool': 'Preschool'
        };
        return _(array).map(function(obj) {
            var name = obj.properties.name;
            if (type === 'boundary') {
                if (obj.properties.type === 'division') {
                    name = obj.properties.name + ' - ' + schoolDivisionMap[obj.properties.school_type] + ' ' + obj.properties.type;
                } else {
                    name = obj.properties.name + ' - ' + obj.properties.type;
                }
            }

            obj.entity_type = type;
            return {
                id: obj.properties.id,
                text: _.str.titleize(name),
                data: obj
            };
        });
    }


})();


