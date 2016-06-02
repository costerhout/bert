/**
* @Author: Colin Osterhout <ctosterhout>
* @Date:   2016-05-19T13:48:55-08:00
* @Email:  ctosterhout@alaska.edu
* @Project: BERT
* @Last modified by:   ctosterhout
* @Last modified time: 2016-06-01T23:05:37-08:00
* @License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
*/


define(
    ['jquery'], function ($) {
    'use strict';

    var initTabs = function () {
        /* Check to see if the requesting URL has an anchor specifying a tab */
        $(function () {
            /* Find the tab in the menu structure */
            var activeTab = $(".nav.nav-tabs a[href='" + location.hash + "']");

            if (activeTab.length) {
                /* Tab found, show it and then wait a very short amount of time and scroll the window to the top */
                activeTab.first().tab('show');
                setTimeout(function(){
                    $(window).scrollTop(5);
                }, 5);
            }

            $('a.tab-link').click(function (e) {
                /* Parse the URI to find the tab ID */
                var activeTab = $(".nav.nav-tabs a[href='" + location.hash + "']");

                if (activeTab.length) {
                    /* Tab found. Stop events bubbling which scroll the window down if the window is already at the top
                    and then show the tab */
                    if ($(window).scrollTop() == 0) {
                        e.preventDefault();
                        e.stopImmediatePropagation();
                    }

                    activeTab.first().tab('show');
                }
            });
        });
    };


    // Instead of a constructor function we are returning a singleton module
    var module = {
        initialize: function () {
            initTabs();
        }
    };

    return module;
});
