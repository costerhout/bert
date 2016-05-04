// IIFE - prep sliding menus
;(function(mymodule) {
    'use strict';

    mymodule(window.jQuery, window, document);
}(function($, window, document) {
    'use strict';

    $(function() {
        // DOM is ready
        $('.menu-sliding').slinky();
    });
}));
