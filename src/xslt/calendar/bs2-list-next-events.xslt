<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-10-05T16:16:31-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-09-25T16:55:40-08:00
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
    <xsl:import href="../include/locations.xslt"/>
    <xsl:import href="../bs2/bs2-event-list.xslt"/>
    <xsl:output
                method='html'
                indent='yes'
                omit-xml-declaration='yes'
                />

    <xd:doc type="stylesheet">
        <xd:short/>
        <xd:detail>
            <p>This stylesheet is designed to be used directly on a page region or imported in order to override the title or specific event processing. By default, this stylesheet operates on lists of events generated from an index block and displayed in tabular format.  Only future events will be shown.  By default the events will be listed in a simple table with modal windows used to present more information.</p>
            <p>Future expandability, including nested table display using accordions or inclusion of past events, could be accomplished by wrapping the index block within a system-data-structure that contains formatting options.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <!-- How many DateTime objects into the future should we list, which is a stand-in for Events as we don't need to be exact -->
    <xsl:param name="nEventLimit" select="14"/>

    <xd:doc>
        Filter out all the events that happen in the future
    </xd:doc>
    <xsl:key match="Event/DateTime/date[not(ancestor::system-page/@reference)]" name="keyFilterFutureDate" use="text() and (hh:calendarFormat(string(.), 'V') + 86400000) &gt; $tsNow"/>

    <xd:doc>
        Used for duplicate detection, in case references exist which would provide for multiple results
    </xd:doc>
    <xsl:key match="system-page" name="keySystemPageById" use="@id"/>

    <xd:doc>
        <xd:short>Matching template to handle index list of events</xd:short>
        <xd:detail>
            <p>Create a listing of events with date, time, event title, and location information grouped by dates. Full event information is presented to the user in the form of a modal window. Only events in the future are shown by default.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-index-block[descendant::system-data-structure[Event]]">
        <!-- Get a nodeset of all future date instances for events -->
        <xsl:variable name="nsFutureDate" select="key('keyFilterFutureDate', 'true')"/>

        <!-- Build out the table, represented as a RTF in a variable -->
        <xsl:variable name="rtfEventList">
            <xsl:if test="count($nsFutureDate) &gt; 0">
                <table class="table table-bordered table-striped table-list-next-events">
                    <caption class="sr-only">Upcoming events</caption>
                    <thead>
                        <tr>
                            <th scope="col">Date / Time</th>
                            <th scope="col">Title</th>
                            <th scope="col">Location</th>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:for-each select="$nsFutureDate">
                            <xsl:sort select="hh:calendarFormat(string(.), 'V')"/>
                            <xsl:sort data-type='text' order='ascending' select="parent::DateTime/am-pm"/>
                            <xsl:sort data-type='number' order='ascending' select='number(parent::DateTime/hour)'/>
                            <!-- Test to see if we've gone through our limit for number of events out in advance -->
                            <xsl:if test="position() &lt; $nEventLimit + 1">
                                <xsl:apply-templates select="ancestor::Event" mode="modal"/>
                                <xsl:apply-templates select="." mode="table-row"/>
                            </xsl:if>
                        </xsl:for-each>
                    </tbody>
                </table>
            </xsl:if>
        </xsl:variable>

        <!-- If we have events to output then do so along with header to that effect -->
        <xsl:if test="normalize-space($rtfEventList) != ''">
            <h2>Upcoming Events</h2>
            <xsl:copy-of select="$rtfEventList"/>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        Output row for each DateTime item. The Description and Location fields will contain links to modal windows.
    </xd:doc>
    <xsl:template match="Event/DateTime/date" mode="table-row">
        <!-- Used for duplicate detection, in case references exist which would provide for multiple results -->
        <xsl:variable name="nsSystemPage" select="key('keySystemPageById', ancestor::system-page/@id)"/>

        <!-- Build out the time string differently depending on whether or not this is an all-day affair -->
        <xsl:variable name="sTime">
            <xsl:choose>
                <xsl:when test="parent::DateTime/am-pm != 'All Day' and normalize-space(parent::DateTime/hour) != ''">
                    <xsl:value-of select="concat(parent::DateTime/hour, parent::DateTime/minute, ' ', parent::DateTime/am-pm)"/>
                </xsl:when>
                <xsl:when test="parent::DateTime/am-pm = 'All Day'">All Day</xsl:when>
                <!-- Something strange - it's not all-day but there's also no hour field listed -->
                <xsl:otherwise>
                    See event details
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Sample date time: "Aug 9 7:30 PM" -->
        <xsl:variable name="sDateTime">
            <xsl:value-of select="hh:calendarFormat(string(.), 'mmm d')"/>
            <br/>
            <xsl:value-of select="$sTime"/>
        </xsl:variable>

        <!-- Build IDs for the two modal windows (description and location). Use helper templates defined elsewhere for the task -->
        <xsl:variable name="idModalDescription">
            <xsl:for-each select="ancestor::Event">
                <xsl:call-template name="event-generate-description-modal-id"/>
            </xsl:for-each>
        </xsl:variable>

        <!-- Determine the location shortcode using the variable $rtfLocations defined in ../include/locations.xslt -->
        <xsl:variable name="sEventLocation" select="ancestor::Event/locationSelect"/>

        <xsl:variable name="sLocation">
            <xsl:for-each select="$nsLocations">
                <xsl:value-of select="key('keyLocationToShortCode', $sEventLocation)[1]/shortcode"/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="idModalLocation">
            <xsl:if test="$sLocation != ''">
                <xsl:for-each select="ancestor::Event">
                    <xsl:call-template name="event-generate-location-modal-id"/>
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>

        <!-- Build out the URLs based on the IDs for the two modal windows -->
        <xsl:variable name="sUrlModalDescription" select="concat('#', $idModalDescription)"/>
        <xsl:variable name="sUrlModalLocation" select="concat('#', $idModalLocation)"/>

        <!-- The title for the event is just the "Event_Name" -->
        <xsl:variable name="sTitle" select="ancestor::Event/Event_Name" />

        <!-- If we have a sub-location ("Location") listed then put that into parentheses -->
        <xsl:variable name="sLocationTitle">
            <xsl:choose>
                <xsl:when test="ancestor::Event/Location != '...' and normalize-space(ancestor::Event/Location) != ''">
                    <xsl:value-of select="concat(ancestor::Event/locationSelect, ' (', ancestor::Event/Location, ')')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ancestor::Event/locationSelect"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Output the row with three columns: date/time, title, and location -->
        <xsl:if test="generate-id(ancestor::system-page) = generate-id($nsSystemPage[1])">
            <tr>
                <td><xsl:copy-of select="$sDateTime"/></td>
                <td><a href="{$sUrlModalDescription}" data-toggle="modal"><xsl:value-of select="$sTitle"/></a></td>
                <td>
                    <!-- If we've found the location in our lookup table then display title location as a link to the modal window, otherwise, just display location title -->
                    <xsl:choose>
                        <xsl:when test="$sLocation != ''">
                            <a href="{$sUrlModalLocation}" data-toggle="modal"><xsl:value-of select="$sLocationTitle"/></a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$sLocationTitle"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
