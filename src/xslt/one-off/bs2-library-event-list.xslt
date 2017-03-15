<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-10-05T16:16:31-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-03-13T19:19:55-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xd exsl hh string" version="1.0"
    xmlns:exsl="http://exslt.org/common"
    xmlns:hh="http://www.hannonhill.com/XSL/Functions"
    xmlns:string="my:string"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc">
    <xsl:import href="../include/format-date.xslt"/>
    <xsl:import href="../include/string.xslt"/>
    <xsl:import href="../bs2/bs2-event-list.xslt"/>

    <xd:doc type="stylesheet">
        <xd:short/>
        <xd:detail>
            <p>This stylesheet is designed to be used directly on a page region or imported in order to override the title or specific event processing. By default, this stylesheet operates on lists of events generated from an index block and displayed in tabular format.  Only future events will be shown.  By default the events will be listed in a simple table with modal windows used to present more information.</p>
            <p>Future expandability, including nested table display using accordions or inclusion of past events, could be accomplished by wrapping the index block within a system-data-structure that contains formatting options.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <!-- What should the title be?  Can be overridden in calling stylesheet -->
    <xsl:param name="sTitle" select="'Upcoming Events'"/>

    <!-- What should the event layout look like (table or inline)? Default to tabular -->
    <xsl:param name="sLayout" select="'inline'"/>

    <!-- Define nArticleLimit but leave it blank -->
    <xsl:param name='nDateLimit' select='5'/>

    <!-- Determine the timestamp for right now (ms since 1/1/1970 UTC) -->
    <xsl:variable name="tsNow" select="hh:dateFormat('V')"/>

    <xd:doc>
        Return DateTime instances for Library events that happen in the future
    </xd:doc>
    <xsl:key match="DateTime" name="keyLibraryFilterFutureDateTime" use="(ancestor::system-page/dynamic-metadata[name='Publishers']/value = 'Egan Library') and (hh:calendarFormat(string(date), 'V') &gt; $tsNow)"/>

    <xd:doc>
        Return DateTime instances for Library events that happen in the future for a certain date.
    </xd:doc>
    <xsl:key match="DateTime" name="keyLibraryDateTimeByDate" use="date[ancestor::system-page/dynamic-metadata[name='Publishers']/value = 'Egan Library' and (hh:calendarFormat(string(.), 'V') &gt; $tsNow)]"/>

    <xd:doc>
        <xd:short>Matching template to handle index list of events</xd:short>
        <xd:detail>
            <p>Create a listing of events with date, time, event title, and location information grouped by dates. Full event information is presented to the user in the form of a modal window. Only events in the future are shown by default.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-index-block[descendant::system-data-structure[Event]]">
        <!-- Get a nodeset of all future DateTime instances for Library events -->
        <xsl:variable name="nsFutureDateTime" select="key('keyLibraryFilterFutureDateTime', 'true')"/>

        <!-- Group DateTime objects by their date, sorted by their date and walk through them -->
        <xsl:variable name="rtfEventList">
            <xsl:for-each select="$nsFutureDateTime[count( . | key('keyLibraryDateTimeByDate', date)[1]) = 1]">
                <xsl:sort select="hh:calendarFormat(string(date), 'V')"/>
                <!-- Test to see if we've gone through our limit for number of days out in advance -->
                <xsl:if test="position() &lt; $nDateLimit + 1">
                    <xsl:apply-templates select="date"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:if test="normalize-space($rtfEventList) != ''">
            <!-- Create modal windows for all future library events, even though we may not actually be listing them -->
            <!-- CTO: I wish there were a better way... -->
            <xsl:apply-templates select="$nsFutureDateTime/parent::Event" mode="modal"/>

            <div class="library-events thumbnail">
                <h2>Upcoming Events</h2>
                <xsl:copy-of select="$rtfEventList"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        Output date that has events happening on it
    </xd:doc>
    <xsl:template match="date">
        <h3><xsl:value-of select="hh:calendarFormat(string(.), 'mmm d')"/></h3>
        <ul class="unstyled">
            <xsl:apply-templates select="key('keyLibraryDateTimeByDate', .)"/>
        </ul>
    </xsl:template>

    <xd:doc>
        Output a DateTime instance as a list item
    </xd:doc>
    <xsl:template match="DateTime">
        <!-- Use the event name as the link text -->
        <xsl:variable name="sLinkText" select="ancestor::Event/Event_Name"/>
        <!-- Format of ID is from bs2-event-list -->
        <xsl:variable name="idModalDescription" select="concat(generate-id(parent::Event), '-description-modal')"/>
        <xsl:variable name="sUrlEvent" select="concat('#', $idModalDescription)"/>
        <li>
            <xsl:if test="am-pm != 'All Day' and normalize-space(hour) != ''">
                <xsl:value-of select="concat(hour, minute, ' ', am-pm)"/>&#0160;&#8212;&#0160;
            </xsl:if>
            <a data-toggle="modal" href="{$sUrlEvent}"><xsl:value-of select="$sLinkText"/></a>
        </li>
    </xsl:template>
</xsl:stylesheet>
