/*http://www.jacklmoore.com/notes/jquery-accordion-tutorial/*/
(function() {
    var t = klp.accordion = {};
    t.init = function() {
        $('.js-accordion-container .js-accordion-header').click(function(e){
            e.preventDefault();
            $(this)
                .closest('li')
                .find('.content')
                .not(':animated')
                .slideToggle('fast', function(){
                    klp.GKA.accordionClicked($(this));
                });

            //Update the chartist charts in this accordian section
            $(this).closest('li').find('.ct-chart').each(function(i, e) {
                if(e && e.__chartist__) { e.__chartist__.update(); }
            });
        });
    };
})();
