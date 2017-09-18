<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-10-05T16:16:31-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-08-23T10:44:35-08:00
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
    <xsl:import href="bs2-modal-simple.xslt"/>

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
    <xsl:param name="sLayout" select="'table'"/>

    <!-- Define nArticleLimit but leave it blank -->
    <xsl:param name='nArticleLimit'/>


    <!-- Determine the timestamp for right now (ms since 1/1/1970 UTC) -->
    <xsl:variable name="tsNow" select="hh:dateFormat('V')"/>
    <!-- Use the xsl:key element to help filter out all the events that happen in the future (we use the next day as a cutoff) -->
    <xsl:key match="Event/DateTime/date" name="keyFilterFutureDate" use="text() and (hh:calendarFormat(string(.), 'V') + 86400000) &gt; $tsNow"/>
    <xsl:key match="Event" name="keyEvent" use="."/>
    <xd:doc>
        <xd:short>Matching template to handle index list of events</xd:short>
        <xd:detail>
            <p>Create a table of events with date, time, event title, and location information. Full event information is presented to the user in the form of a modal window. Only events in the future are shown by default. No header is shown by default.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-index-block[descendant::system-data-structure[Event]]">
        <xsl:param name="nLimit">
            <xsl:choose>
                <xsl:when test="$nArticleLimit != ''"><xsl:value-of select="$nArticleLimit"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="count(key('keyFilterFutureDate', 'true')/ancestor::Event) + 1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <xsl:variable name="nsFutureDate" select="key('keyFilterFutureDate', 'true')[position() &lt; $nLimit]"/>
        <xsl:variable name="nsEvents" select="$nsFutureDate/ancestor::Event"/>

        <!-- Determine if we have events in the future. If so, create the description / map modals and then a table with information -->
        <xsl:if test="$nsFutureDate">
            <xsl:apply-templates mode="modal" select="$nsEvents[Description/text() or Description/node()]"/>

            <xsl:choose>
                <xsl:when test="$sLayout = 'table'">
                    <xsl:call-template name="event-list-table">
                        <xsl:with-param name="nsFutureDateTime" select="$nsFutureDateTime"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$sLayout = 'inline'">
                    <xsl:call-template name="event-list-inline">
                        <xsl:with-param name="nsFutureDateTime" select="$nsFutureDateTime"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template name="event-list-table">
        <xsl:param name="nsFutureDate"/>

        <xsl:if test="$sTitle != ''">
            <h2><xsl:value-of select="$sTitle"/></h2>
        </xsl:if>
        <table class="table table-bordered table-striped">
            <caption class="sr-only">Upcoming events</caption>
            <thead>
                <tr>
                    <th scope="col">Date</th>
                    <th scope="col">Description</th>
                </tr>
            </thead>
            <tbody>
                <!-- Apply event template to display a row for each future DateTime, arranged by date of event, am/pm, and then hour of the day, all ascending -->
                <xsl:apply-templates select="$nsFutureDate">
                    <xsl:sort data-type="text" order="ascending" select="hh:calendarFormat(string(.), 'V')"/>
                    <xsl:sort data-type='text' order='ascending' select="parent::DateTime/am-pm"/>
                    <xsl:sort data-type='number' order='ascending' select='number(parent::DateTime/hour)'/>
                </xsl:apply-templates>
            </tbody>
        </table>
    </xsl:template>

    <xsl:template name="event-list-inline">
        <xsl:param name="nsFutureDate"/>

        <xsl:apply-templates select="$nsFutureDate">
            <xsl:sort data-type='text' order='ascending' select="hh:calendarFormat(string(.), 'V')"/>
            <xsl:sort data-type='text' order='ascending' select="parent::DateTime/am-pm"/>
            <xsl:sort data-type='number' order='ascending' select='number(parent::DateTime/hour)'/>
        </xsl:apply-templates>
    </xsl:template>

    <xd:doc>
        <xd:short>Create modal windows for event info that will be linked to from the table.</xd:short>
        <xd:detail>
            <p>Each event will have a separate row in the table with information on the date and description displayed.  Event information is available via a modal window.  This template creates the modal window.  The modal window can be activated via links with the attribute data-toggle="modal" and href generated by concatenating the Event id (obtained through generate-id()) along with the string '-description-modal'.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="Event" mode="modal">
        <!-- Create supporting modal IDs -->
        <xsl:variable name="idModalDescription" select="concat(generate-id(), '-description-modal')"/>
        <xsl:variable name="idModalDescriptionTitle" select="concat(generate-id(), '-description-title')"/>
        <!-- Create modal body for the event description -->
        <xsl:variable name="rtfModalDescriptionBody">
            <!-- If picture exists then output that -->
            <xsl:if test="image[@type='file']">
                <img alt="" class="pull-right event-thumbnail" src="{image/path}"/>
            </xsl:if>
            <!-- Wrap description in paragraph -->
            <xsl:call-template name="paragraph-wrap">
                <xsl:with-param name="nodeToWrap" select="Description"/>
                <xsl:with-param name="classWrap" select="'clearfix'"/>
            </xsl:call-template>
            <xsl:if test="normalize-space(URL) != ''">
                <p>
                    <a href="{URL}">Find out more information about this event online.</a>
                </p>
            </xsl:if>
        </xsl:variable>
        <!-- Create event description modal -->
        <xsl:call-template name="modal">
            <xsl:with-param name="id" select="$idModalDescription"/>
            <xsl:with-param name="sIdTitle" select="$idModalDescriptionTitle"/>
            <xsl:with-param name="title" select="Event_Name"/>
            <xsl:with-param name="content" select="exsl:node-set($rtfModalDescriptionBody)"/>
            <xsl:with-param name="sClassExtra" select="event-list-description"/>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:short>Create separate table row for each event DateTime</xd:short>
        <xd:detail>
            <p>Each DateTime in the entire document needs to have an entry in the table (or block output if layout mode is 'inline'). This template creates a row in the table and will link to the modals that correspond to the event, one for the description, and if the location is known, one for the mapdisplay.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="Event/DateTime/date">
        <!-- Determine URLs to pop up modals -->
        <xsl:variable name="idModalDescription" select="concat(generate-id(ancestor::Event), '-description-modal')"/>
        <!-- Set up date / time string values for display on the table row -->
        <xsl:variable name="sDate" select="hh:calendarFormat(string(.), 'mediumDate')"/>
        <!-- If there's a description present then create a link to the modal window for it -->
        <xsl:variable name="rtfDescriptionField">
            <xsl:choose>
                <xsl:when test="ancestor::Event/Description[text() or node()]">
                    <a data-toggle="modal" href="{concat('#', $idModalDescription)}" title="{concat('Open up description for event: ', ancestor::Event/Event_Name)}">
                        <xsl:value-of select="ancestor::Event/Event_Name"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ancestor::Event/Event_Name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$sLayout = 'table'">
                <!-- Create row with Date and Description fields -->
                <tr>
                    <td>
                        <xsl:value-of select="$sDate"/>
                    </td>
                    <td>
                        <xsl:copy-of select="$rtfDescriptionField"/>
                    </td>
                </tr>
            </xsl:when>
            <xsl:when test="$sLayout = 'inline'">
                <h2><xsl:value-of select="$sDate"/></h2>
                <p><xsl:copy-of select="$rtfDescriptionField"/></p>
            </xsl:when>
        </xsl:choose>

    </xsl:template>
</xsl:stylesheet>
