<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-08-26T12:40:55-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-08-23T11:04:17-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:hh="http://www.hannonhill.com/XSL/Functions"
                exclude-result-prefixes="xd hh"
                >

    <xsl:import href="../include/format-date.xslt"/>
    <xsl:import href="../include/string.xslt"/>
    <xsl:import href="../bs2/bs2-event-list.xslt"/>

    <xd:doc type="stylesheet">
        <xd:short>Format a table for library events</xd:short>
        <xd:detail>
            Create a custom table of events that only outputs events published by the library. Leverages existing code from the bs2-event-list.xslt stylesheet to handle the modal generation and row output logic.
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <!-- Use the xsl:key element to help filter out all the events that happen in the future -->
    <xsl:key match="Event/DateTime/date" name="keyFilterFutureDateLibrary" use="ancestor::system-page/dynamic-metadata[name='Publishers']/value = 'Egan Library' and text() and (hh:calendarFormat(string(.), 'V') + 86400000) &gt; $tsNow"/>

    <xd:doc>
        <xd:short>Matching template to handle index list of events</xd:short>
        <xd:detail>
            <p>Create a table of events with date, time, event title, and location information. Full event information is presented to the user in the form of a modal window. Only events in the future are shown by default. No header is shown by default.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-index-block[descendant::system-data-structure[Event]]">
        <xsl:variable name="nsFutureDate" select="key('keyFilterFutureDateLibrary', 'true')"/>
        <xsl:variable name="nsEvents" select="$nsFutureDate/ancestor::Event"/>

        <!-- Determine if we have events in the future. If so, create the description / map modals and then a table with information -->
        <xsl:if test="$nsFutureDate">
            <xsl:apply-templates select="$nsEvents" mode="modal"/>

            <table class="table table-bordered table-striped table-events">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Time</th>
                        <th>Event</th>
                        <th>Location</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- Apply event template to display a row for each future DateTime, arranged by date of event, am/pm, and then hour of the day, all ascending -->
                    <xsl:apply-templates select="$nsFutureDate">
                        <xsl:sort data-type='text' order='ascending' select="hh:calendarFormat(string(.), 'V')"/>
                        <xsl:sort data-type='text' order='ascending' select="parent::DateTime/am-pm"/>
                        <xsl:sort data-type='number' order='ascending' select='number(parent::DateTime/hour)'/>
                    </xsl:apply-templates>
                </tbody>
            </table>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
