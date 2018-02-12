<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2017-08-21T16:21:05-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-11-08T16:59:28-09:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:hh="http://www.hannonhill.com/XSL/Functions"
                exclude-result-prefixes="xd hh exsl"
                >
    <xsl:import href='../bs2/bs2-event-list.xslt'/>
    <xsl:import href='../include/format-date.xslt'/>
    <xsl:import href="../include/class-variables-term.xslt"/>
    <xsl:include href='../bs2/bs2-default.xslt'/>

    <xsl:strip-space elements="*"/>
    <xsl:output
                method='xml'
                indent='yes'
                omit-xml-declaration='yes'
                />

    <xd:doc type="stylesheet">
        <xd:short>Create BS2 tabset with tabs for each semester of the Academic Calendar, each with a table display of dates.</xd:short>
        <xd:detail>
            <p>Leverages existing BS2 logic to create tabsets and other imported stylesheets to create modal boxes for events. This stylesheet takes care of creating a table of Academic Calendar events, one for each semester in the academic year.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2017</xd:copyright>
    </xd:doc>

    <xd:doc>
        Invoked via apply-templates call from the bs2-tabs.xslt stylesheet.
    </xd:doc>
    <xsl:template match="system-data-structure[semester]">
        <!-- Build the tabs variable for later call to the BERT tab generator -->
        <xsl:variable name="rtfTabs">
            <xsl:apply-templates select="semester"/>
        </xsl:variable>
        <xsl:for-each select="exsl:node-set($rtfTabs)">
            <xsl:call-template name="tab"/>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        Create a tab definition for a semester
    </xd:doc>
    <xsl:template match="semester">
        <xsl:variable name="sId" select="generate-id()"/>
        <xsl:variable name="sLabel" select="concat(id, ' Semester')"/>
        <xsl:variable name="sSemester" select="id"/>
        <xsl:variable name="nsDate" select=".//Event/DateTime/date"/>
        <xsl:variable name="nsEvents" select="$nsDate/ancestor::Event"/>
        <xsl:variable name="bActive" select="generate-id($nsSemestersAvailable/semester[title=$sSemester]) = generate-id($nodeSemesterCatalog)"/>

        <!-- Begin the tab definition -->
        <tab>
            <tab_id><xsl:value-of select="$sId"/></tab_id>
            <tab_label><xsl:value-of select="$sLabel"/></tab_label>
            <!-- Content consists of the shortcourse notice (if applicable) and a table of events -->
            <tab_content>
                <xsl:if test="shortcourse/path != '/'">
                    <div class="alert alert-error">
                        Note: Short courses do not have the same drop/withdraw dates as full semester courses. For short course drop/withdraw dates visit the <a href="{shortcourse/path}"> Registrar's Short Course page.</a></div>
                </xsl:if>
                <!-- Create the modal windows -->
                <xsl:apply-templates select="$nsEvents" mode="modal"/>

                <!-- Here we spit out the table wrapper by hand rather than pass control via apply-templates of the system-index-block due to an oddity in how Xalan works with variable copies of the source document (xsl:copy-of converted through exsl:node-set). -->
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
            </tab_content>
            <tab_active><xsl:value-of select="$bActive"/></tab_active>
        </tab>
    </xsl:template>
</xsl:stylesheet>
