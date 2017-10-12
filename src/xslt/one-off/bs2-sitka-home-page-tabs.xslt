<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2017-09-06T10:28:53-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-09-06T11:19:10-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:hh="http://www.hannonhill.com/XSL/Functions"
    exclude-result-prefixes="exsl xd hh"
    >
    <xsl:import href="../bs2/bs2-default.xslt"/>
    <xsl:import href="../bs2/bs2-event-list.xslt"/>
    <xsl:import href="../include/format-date.xslt"/>
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="html"/>

    <xd:doc>
        Determine what events are OK to show (future events)
    </xd:doc>
    <xsl:key match="Event/DateTime/date" name="keyFilterFutureDateSitka" use="text() and (hh:calendarFormat(string(.), 'V') + 86400000) &gt; $tsNow"/>

    <xd:doc>
        Limit the number of events to display
    </xd:doc>
    <xsl:variable name="nEventLimit">6</xsl:variable>

    <xd:doc>
        Match the top level system-data-structure which should contain a tab data definition
    </xd:doc>
    <xsl:template match="/system-data-structure[tab]">
        <xsl:variable name="rtfTabs">
            <!-- Operate differently depending on which tab this is -->
            <xsl:for-each select="tab">
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <!-- Create the tab definition for the first tab (news) -->
                        <xsl:call-template name="generate-tab-news"/>
                    </xsl:when>
                    <xsl:when test="position() = 2">
                        <!-- Create the tab definition for the second tab (calendar / events) -->
                        <xsl:call-template name="generate-tab-calendar"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <!-- Invoke the Bootstrap code to create the tabs -->
        <xsl:for-each select="exsl:node-set($rtfTabs)">
            <xsl:call-template name="tab">
                <xsl:with-param name="sClassTabs" select="'nav-pills'"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        Helper template to generate the tab definition for the news tab
    </xd:doc>
    <xsl:template name="generate-tab-news">
        <xsl:variable name="sId" select="generate-id()" />
        <xsl:variable name="sLabel" select="tab_label" />
        <xsl:variable name="rtfTabContent">
            <!-- Generate an article element for each news item contained within -->
            <div class="newsbox">
                <xsl:apply-templates select=".//system-page/system-data-structure"/>

                <br class="clearfix"/>
                <div>
                    <a href="events/news.html">More News and Events &#187;</a>
                </div>
                <br class="clearfix"/>
            </div>
        </xsl:variable>

        <!-- Output the tab definition -->
        <tab>
            <tab_id><xsl:value-of select="$sId"/></tab_id>
            <tab_label><xsl:value-of select="tab_label"/></tab_label>
            <tab_content><xsl:copy-of select="$rtfTabContent"/></tab_content>
            <tab_active>true</tab_active>
        </tab>
    </xsl:template>

    <xd:doc>
        Helper template to generate the tab definition for the calendar tab
    </xd:doc>
    <xsl:template name="generate-tab-calendar">
        <xsl:variable name="sId" select="generate-id()" />
        <xsl:variable name="sLabel" select="tab_label" />
        <xsl:variable name="nsFutureDate" select="key('keyFilterFutureDateSitka', 'true')"/>
        <xsl:variable name="rtfTabContent">
            <xsl:for-each select="$nsFutureDate">
                <xsl:sort select="hh:calendarFormat(string(.), 'V')"/>
                <xsl:sort data-type='text' order='ascending' select="parent::DateTime/am-pm"/>
                <xsl:sort data-type='number' order='ascending' select='number(parent::DateTime/hour)'/>
                <!-- Test to see if we've gone through our limit for number of events out in advance -->
                <xsl:if test="position() &lt; $nEventLimit + 1">
                    <!-- Generate modals for events items -->
                    <xsl:apply-templates select="ancestor::Event" mode="modal"/>
                    <!-- Generate line for the event -->
                    <xsl:apply-templates select="." mode="sitka-event-entry"/>
                </xsl:if>
            </xsl:for-each>

            <!-- Footer text for this particular tab -->
            <div align="center" style="padding:0 30px;"><hr/></div>
            <p>
                <a href="/calendar/academic/">View full Academic Calendar</a>
            </p>
        </xsl:variable>

        <!-- Output the tab definition -->
        <tab>
            <tab_id><xsl:value-of select="$sId"/></tab_id>
            <tab_label><xsl:value-of select="tab_label"/></tab_label>
            <tab_content><xsl:copy-of select="$rtfTabContent"/></tab_content>
            <tab_active>false</tab_active>
        </tab>
    </xsl:template>

    <xd:doc>
        Matching template to create a separate &lt;div&gt; each Date item (event instance)
    </xd:doc>
    <xsl:template match="date" mode="sitka-event-entry">
        <!-- Call helper template to get the ID of the modal window that is generated earlier -->
        <xsl:variable name="idModal">
            <xsl:for-each select="ancestor::Event[1]">
                <xsl:call-template name="event-generate-description-modal-id"/>
            </xsl:for-each>
        </xsl:variable>

        <!-- Create a date in the format "Sep 9" if there's no time set, otherwise like "Sep 9, 4:30 PM" -->
        <xsl:variable name="sDate">
            <xsl:choose>
                <xsl:when test="parent::DateTime/am-pm = 'All Day'">
                    <xsl:value-of select="hh:calendarFormat(string(.), 'mmm d')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="hh:calendarFormat(string(.), 'mmm d, h:MM TT')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Output the event entry along with link to a modal window with description -->
        <div class="vevent">
            <span class="dtstart">
                <xsl:value-of select="$sDate"/>:</span>&#160;
            <a data-toggle="modal" href="{concat('#', $idModal)}">
                <xsl:value-of select="ancestor::Event/Event_Name" />
            </a>
        </div>
    </xsl:template>

    <xd:doc>
        Helper template to create an article item for each news item
    </xd:doc>
    <xsl:template match="system-page/system-data-structure[Title][Description]">
        <xsl:variable name="sAlt" select="normalize-space(image-label)" />
        <xsl:variable name="sTitle" select="Title" />

        <article>
            <xsl:if test="normalize-space(image/path) != '/'">
                <div class="pull-right">
                    <img class="img-rounded" src="{image/path}" alt="{$sAlt}"/>
                </div>
            </xsl:if>
            <h4>
                <xsl:choose>
                    <xsl:when test="normalize-space(Link) != ''">
                        <a href="{normalize-space(Link)}"><xsl:value-of select="$sTitle"/></a>
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="$sTitle"/></xsl:otherwise>
                </xsl:choose>
            </h4>
            <p>
               <xsl:value-of select="Description"/>
            </p>
            <div align="center" style="padding:0 30px;"><hr/></div>
        </article>
    </xsl:template>
</xsl:stylesheet>
