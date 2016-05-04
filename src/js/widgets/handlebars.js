;(function(mymodule) {
    'use strict';

    mymodule(window.jQuery, window, document);
}(function($, window, document) {
    'use strict';

    $(function () {
        // Link up the Handlebars form helpers
        if (typeof Handlebars !== 'undefined' && typeof HandlebarsFormHelpers !== 'undefined') {
            HandlebarsFormHelpers.register(Handlebars);
        }
    });
}));
