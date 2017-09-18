<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-08-26T12:40:55-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-09-18T13:44:53-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:exsl="http://exslt.org/common"
                xmlns:string="my:string"
                xmlns:hh="http://www.hannonhill.com/XSL/Functions"
                exclude-result-prefixes="xd exsl hh string"
                >

    <xsl:import href="../include/format-date.xslt"/>
    <xsl:import href="../include/string.xslt"/>
    <xsl:import href="../include/locations.xslt"/>
    <xsl:import href="../modules/mapdisplay.xslt"/>
    <xsl:import href="bs2-modal-simple.xslt"/>

    <xd:doc type="stylesheet">
        <xd:short></xd:short>
        <xd:detail>
            <p>This stylesheet can operate either directly on a page region or as part of the bs2-default import process to operate on lists of events.  These events will be displayed in tabular format.  Only upcoming events will be shown.  By default the events will be listed in a simple table with modal windows used to present more information.</p>
            <p>Future expandability, including nested table display using accordions or inclusion of past events, could be accomplished by wrapping the index block within a system-data-structure that contains formatting options.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <!-- Determine the timestamp for right now (ms since 1/1/1970 UTC) -->
    <xsl:variable name="tsNow" select="hh:dateFormat('V')"/>

    <xsl:param name="tsFilter" select="$tsNow"/>
    <xsl:param name="sDateFormat" select="'mediumDate'"/>

    <xd:doc>
        Filter out all the events that happen in the future
    </xd:doc>
    <xsl:key match="Event/DateTime/date" name="keyFilterFutureDate" use="text() and (hh:calendarFormat(string(.), 'V') + 86400000) &gt; $tsFilter"/>

    <xd:doc>
        Grab all valid date objects irrespective of whether they occur in the past, present, or future
    </xd:doc>
    <xsl:key match="Event/DateTime/date" name="keyDate" use="text()"/>

    <xd:doc>
        Used for duplicate detection, in case references exist which would provide for multiple results
    </xd:doc>
    <xsl:key match="system-page" name="keySystemPageById" use="@id"/>

    <xd:doc>
        <xd:short>Matching template to handle index list of events</xd:short>
        <xd:detail>
            <p>Create a table of events with date, time, event title, and location information. Full event information is presented to the user in the form of a modal window. Only events in the future are shown by default. No header is shown by default.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-index-block[descendant::system-data-structure[Event]]">
        <xsl:variable name="nsDate" select="key('keyFilterFutureDate', 'true')"/>
        <xsl:variable name="nsEvents" select="$nsDate/ancestor::Event"/>

        <!-- Determine if we have events in the future. If so, create the description / map modals and then a table with information -->
        <xsl:if test="$nsDate">
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
                    <xsl:apply-templates select="$nsDate">
                        <xsl:sort data-type='text' order='ascending' select="hh:calendarFormat(string(.), 'V')"/>
                        <xsl:sort data-type='text' order='ascending' select="parent::DateTime/am-pm"/>
                        <xsl:sort data-type='number' order='ascending' select='number(parent::DateTime/hour)'/>
                    </xsl:apply-templates>
                </tbody>
            </table>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        Helper utility template to generate modal ID for the location modal
    </xd:doc>
    <xsl:template name="event-generate-location-modal-id">
        <xsl:value-of select="concat(generate-id(), '-location-modal')"/>
    </xsl:template>

    <xd:doc>
        Helper utility template to generate modal ID for the description modal
    </xd:doc>
    <xsl:template name="event-generate-description-modal-id">
        <xsl:value-of select="concat(generate-id(), '-description-modal')"/>
    </xsl:template>

    <xd:doc>
        <xd:short>Create modal windows for event info and map location that will be linked to from the table.</xd:short>
        <xd:detail>
            <p>Each event will have a separate row in the table with information on the date, time, event name, and location displayed.  Event information is available via a modal window, and a location map is available via a separate modal.  This template creates those modal windows.  Modal windows can be activated via links with the attribute data-toggle="modal" and href generated by concatenating the Event id (obtained through generate-id()) along with the string '-description-modal' or '-location-modal'.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="Event" mode="modal">
        <!-- Create supporting modal IDs -->
        <xsl:variable name="idModalDescription">
            <xsl:call-template name="event-generate-description-modal-id"/>
        </xsl:variable>
        <xsl:variable name="idModalDescriptionTitle" select="concat($idModalDescription, '-title')"/>
        <xsl:variable name="idModalLocation">
            <xsl:call-template name="event-generate-location-modal-id"/>
        </xsl:variable>
        <xsl:variable name="idModalLocationTitle" select="concat($idModalLocation, '-title')"/>
        <xsl:variable name="sEventLocation" select="locationSelect"/>
        <xsl:variable name="sLocationDescription">
            <xsl:choose>
                <!-- Check for drop down building location + room number -->
                <xsl:when test="normalize-space(locationSelect) != '' and normalize-space(Room) != ''">
                    <xsl:value-of select="concat(locationSelect, ' ', Room)"/>
                </xsl:when>
                <!-- Check for drop down building location -->
                <xsl:when test="normalize-space(locationSelect)">
                    <xsl:value-of select="locationSelect"/>
                </xsl:when>
                <!-- Check for non-placeholder value on the Location free form field -->
                <xsl:when test="normalize-space(Location) != '...'">
                    <xsl:value-of select="Location"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!-- Determine the location shortcode using the variable $rtfLocations defined in ../include/locations.xslt -->
        <xsl:variable name="sLocation">
            <xsl:for-each select="$nsLocations">
                <xsl:value-of select="key('keyLocationToShortCode', $sEventLocation)[1]/shortcode"/>
            </xsl:for-each>
        </xsl:variable>

        <!-- Create modal body for the event description -->
        <xsl:variable name="rtfModalDescriptionBody">
            <!-- If picture exists then output that -->
            <xsl:if test="image[@type='file']">
                <img src="{image/path}" alt="" class="pull-right event-thumbnail"/>
            </xsl:if>

            <!-- Wrap description in paragraph -->
            <xsl:call-template name="paragraph-wrap">
                <xsl:with-param name="nodeToWrap" select="Description"/>
                <xsl:with-param name="classWrap" select="'clearfix'"/>
            </xsl:call-template>

            <!-- Create description list for logistics information -->
            <dl class="dl-horizontal">
                <xsl:if test="normalize-space($sLocationDescription) != ''">
                    <dt class="event-location">Location</dt>
                    <dd class="event-location"><xsl:value-of select="$sLocationDescription"/></dd>
                </xsl:if>
                <xsl:if test="normalize-space(Sponsor) != ''">
                    <dt class="event-sponsor">Sponsor</dt>
                    <dd class="event-sponsor"><xsl:value-of select="Sponsor"/></dd>
                </xsl:if>
                <xsl:if test="normalize-space(Cost) != ''">
                    <dt class="event-cost">Cost</dt>
                    <dd class="event-cost"><xsl:value-of select="Cost"/></dd>
                </xsl:if>
                <xsl:if test="normalize-space(URL) != ''">
                    <dt class="event-url">Event link</dt>
                    <dd class="event-url"><a href="{URL}" title="{concat('More information about the event: ', Event_Name)}"><xsl:value-of select="URL"/></a></dd>
                </xsl:if>
                <xsl:if test="normalize-space(Phone) != ''">
                    <dt class="event-phone">Phone</dt>
                    <dd class="event-phone"><a href="{concat('tel:+1-', Phone)}" title="{concat('Contact event sponsor for event: ', Event_Name)}"><xsl:value-of select="Phone"/></a></dd>
                </xsl:if>
                <xsl:if test="normalize-space(Email) != ''">
                    <dt class="event-email">Email</dt>
                    <dd class="event-email"><a href="{concat('mailto:', Email)}" title="{concat('Contact event sponsor for event: ', Event_Name, ' via email')}"><xsl:value-of select="Email"/></a></dd>
                </xsl:if>
            </dl>
        </xsl:variable>

        <!-- Create modal body for event map (if location is known) -->
        <xsl:if test="$sLocation != ''">
            <xsl:variable name="rtfModalLocationBody">
                <!-- Only create if the location isn't blank or other -->
                <xsl:call-template name="mapdisplay">
                    <xsl:with-param name="urlSrc" select="$sUrlLocationData"/>
                    <xsl:with-param name="idShow" select="$sLocation"/>
                </xsl:call-template>
            </xsl:variable>

            <!-- Create event map modal -->
            <xsl:call-template name="modal">
                <xsl:with-param name="id" select="$idModalLocation"/>
                <xsl:with-param name="sIdTitle" select="$idModalLocationTitle"/>
                <xsl:with-param name="title" select="Event_Name"/>
                <xsl:with-param name="content" select="exsl:node-set($rtfModalLocationBody)"/>
                <xsl:with-param name="sClassExtra" select="event-list-map"/>
            </xsl:call-template>
        </xsl:if>

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
            <p>Each DateTime in the entire document needs to have an entry in the table. This template creates a row in the table and will link to the modals that correspond to the event, one for the description, and if the location is known, one for the mapdisplay.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="Event/DateTime/date">
        <!-- Determine URLs to pop up modals -->
        <xsl:variable name="idModalDescription" select="concat(generate-id(ancestor::Event), '-description-modal')"/>
        <xsl:variable name="idModalLocation" select="concat(generate-id(ancestor::Event), '-location-modal')"/>
        <!-- Used for duplicate detection, in case references exist which would provide for multiple results -->
        <xsl:variable name="nsSystemPage" select="key('keySystemPageById', ancestor::system-page/@id)"/>

        <!-- Determine the location shortcode using the variable $rtfLocations defined in ../include/locations.xslt -->
        <xsl:variable name="sEventLocation" select="ancestor::Event/locationSelect"/>
        <xsl:variable name="sLocation">
            <xsl:for-each select="$nsLocations">
                <xsl:value-of select="key('keyLocationToShortCode', $sEventLocation)[1]/shortcode"/>
            </xsl:for-each>
        </xsl:variable>

        <!-- Set up date / time string values for display on the table row -->
        <xsl:variable name="sDate" select="hh:calendarFormat(string(.), $sDateFormat)"/>
        <xsl:variable name="sTime">
            <xsl:choose>
                <xsl:when test="parent::DateTime/minute != ':00'">
                    <xsl:value-of select="concat(normalize-space(parent::DateTime/hour), parent::DateTime/minute, ' ', parent::DateTime/am-pm)"/>
                </xsl:when>
                <xsl:when test="normalize-space(parent::DateTime/hour) != ''">
                    <xsl:value-of select="concat(normalize-space(parent::DateTime/hour), ' ', parent::DateTime/am-pm)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(parent::DateTime/am-pm)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Figure out what to call the location -->
        <xsl:variable name="rtfLocationText">
            <!-- Hide the "Other" -->
            <xsl:if test="ancestor::Event/locationSelect != 'Other'">
                <node>
                    <xsl:value-of select="ancestor::Event/locationSelect"/>
                </node>
            </xsl:if>
            <!-- We'll use the Location and Room if they're set -->
            <xsl:if test="normalize-space(ancestor::Event/Location)">
                <node>
                    <xsl:value-of select="ancestor::Event/Location"/>
                </node>
            </xsl:if>
            <xsl:if test="normalize-space(ancestor::Event/Room)">
                <node>
                    <xsl:value-of select="concat('Room: ', ancestor::Event/Room)"/>
                </node>
            </xsl:if>
        </xsl:variable>

        <!-- Set up location text for display on the table row -->
        <xsl:variable name="sLocationText">
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns" select="exsl:node-set($rtfLocationText)/*"/>
                <xsl:with-param name="glue" select="', '"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Create modal with location map, but only for the first one -->
        <xsl:if test="generate-id(ancestor::system-page) = generate-id($nsSystemPage[1])">
            <tr>
                <td><xsl:value-of select="normalize-space($sDate)"/></td>
                <td><xsl:value-of select="normalize-space($sTime)"/></td>
                <td><a data-toggle="modal" href="{concat('#', $idModalDescription)}" title="{concat('Open up description for event: ', ancestor::Event/Event_Name)}"><xsl:value-of select="ancestor::Event/Event_Name"/></a></td>
                <td>
                    <!-- If we have pinpointed a location then set the location as a link to popup the modal map -->
                    <xsl:choose>
                        <xsl:when test="$sLocation != ''">
                            <a data-toggle="modal" href="{concat('#', $idModalLocation)}" title="{concat('Open up map for event: ', ancestor::Event/Event_Name)}"><xsl:value-of select="$sLocationText"/></a>
                        </xsl:when>
                        <xsl:otherwise><xsl:value-of select="$sLocationText"/></xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
