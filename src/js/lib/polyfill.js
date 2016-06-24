/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-06-21T08:49:08-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-23T17:35:25-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

(function (mymodule) {
    'use strict';
    mymodule();
}(function () {
    'use strict';

    // Add trim function if not already present
    // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/Trim
    if (!String.prototype.trim) {
        String.prototype.trim = function () {
            return this.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, '');
        };
    }
}));
