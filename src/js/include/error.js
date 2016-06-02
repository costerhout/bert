/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-03-16T13:13:13-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-01T22:48:58-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/



// IIFE - Immediately Invoked Function Expression
(function (iife) {
    'use strict';

    // The global jQuery object is passed as a parameter
    iife(window.jQuery, window, document);

}(function ($, window, document) {
    'use strict';

    function getQueryString() {
        var result = {}, queryString = location.search.slice(1),
            re = /([^&=]+)=([^&]*)/g, m;

        m = re.exec(queryString);

        while (m) {
            result[decodeURIComponent(m[1])] = decodeURIComponent(m[2]);
            m = re.exec(queryString);
        }

        return result;
    }

    // Listen for the jQuery ready event on the document
    $(function () {
        var aGetParam = getQueryString(),
            sLevel = aGetParam.error_level,
            selector = 'proc-msg';

        if (sLevel !== undefined) {
            switch (sLevel) {
            case 'warning':
                selector = "proc-msg[level='warning'], proc-msg[level='error']";
                break;
            case 'error':
                selector = "proc-msg[level='error']";
                break;
            }

            $(selector).each(function (i, el) {
                if (aGetParam.error_inline !== undefined) {
                    $(el).show();
                }

                console.log($(el).html());
            });
        }
    });
}
));
