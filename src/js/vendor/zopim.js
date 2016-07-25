/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-07-22T09:30:27-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-07-22T09:30:42-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/

window.$zopim || (function(d, s) {
    var z = $zopim = function(c) {
            z._.push(c)
        },
        $ = z.s = d.createElement(s),
        e = d.getElementsByTagName(s)[0];

    z.set = function(o) {
        z.set._.push(o)
    };
    z._ = [];
    z.set._ = [];
    $.async = !0;
    $.setAttribute("charset", "utf-8");
    $.src = "//v2.zopim.com/?59dOH072zniIhMercLEhZ9HV5ZhYbRDl";
    z.t = +new Date;
    $.type = "text/javascript";
    e.parentNode.insertBefore($, e)
})(document, "script");
