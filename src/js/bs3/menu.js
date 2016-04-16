// IIFE - prep sliding menus 
;(function(mymodule) {
    mymodule(window.jQuery, window, document);
}(function($, window, document) {
    $(function() {
        // DOM is ready
        $('.menu-sliding').slinky();
    });
}));
