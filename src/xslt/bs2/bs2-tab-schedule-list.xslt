<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!--
@Author: Colin Osterhout <ctosterhout> based on previous work from John French <jhfrench>
@Date:   2017-06-14T15:47:32-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-11-08T17:12:51-09:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:string="my:string"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:exsl="http://exslt.org/common"
    exclude-result-prefixes="exsl string xd"
    >

    <xsl:import href="bs2-default.xslt"/>
    <xsl:import href="../include/class-variables-term.xslt"/>

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet used to override default behavior for tabs which should include schedule information</xd:short>
        <xd:detail>
            <p>Certain pages want to have schedule information up on certain tabs. This has been accomplished in the past by having custom stylesheets that base their output generation by the id field of the tab.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctoterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2017</xd:copyright>
    </xd:doc>

    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>

    <xd:doc>
        Override default tab generation for tabs whose id begins with the string 'class_'. Generates query and begins parses the resulting schedule information into an accordion structure for rendering.
    </xd:doc>
    <xsl:template match="tab[starts-with(tab_id, 'class_')]" mode="tab-body">
        <div id="{tab_id}">
            <!-- Copied over from the bs2-tabs template. Potential improvement would be roll this into one spot -->
            <xsl:attribute name="class">
                <!-- Check for manual override of tab order based on the tab_active element, if present -->
                <xsl:choose>
                    <xsl:when test="tab_active = 'true'">tab-pane active</xsl:when>
                    <xsl:when test="tab_active = 'false'">tab-pane</xsl:when>
                    <xsl:when test="position() = 1">tab-pane active</xsl:when>
                    <xsl:otherwise>tab-pane</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>

            <!-- Different than typical tab behavior where we suppress tab_content if there is a block present -->
            <xsl:copy-of select="child::tab_content/*"/>
            <xsl:apply-templates select="ablock"/>

            <!-- Bring in outside XML from query -->
            <xsl:apply-templates select="document($urlScheduleClassChooser)/SCHEDULE">
                <xsl:with-param name="subject" select="substring-after(tab_id, '_')"/>
            </xsl:apply-templates>
        </div>
    </xsl:template>

    <xd:doc>
        Match on the root level element of the returned query result and builds an accordion data structure out of it. Creates outer element of class 'schedule-list' and calls the accordion template to generate the BS accordion markup.
    </xd:doc>
    <xsl:template match="SCHEDULE">
        <xsl:param name="subject"/>

        <!-- Build the accordion definition -->
        <xsl:variable name="rtfAccordionGroup">
            <accordion>
                <!-- Populate the accordion group with accordion items -->
                <xsl:apply-templates select="COURSE[SUBJ = $subject]"/>
            </accordion>
        </xsl:variable>
        <div style="margin: 2em 0;">
            <a class="btn pull-right" href="http://www.uas.alaska.edu/schedule/index.html" target="_blank">View Full UAS Schedule</a>
            <h2>
                <xsl:value-of select="concat('Classes: ', $subject, ' ', $nodeSemesterClassChooser/title, '&#160;', $nodeSemesterClassChooser/year)"/>
            </h2>
        </div>
        <div class="schedule-list">
            <!-- Render accordion group here -->
            <xsl:call-template name="accordion">
                <xsl:with-param name="nsAccordionGroup" select="exsl:node-set($rtfAccordionGroup)"/>
            </xsl:call-template>
        </div>
    </xsl:template>

    <xd:doc>
        COURSE elements are direct children of SCHEDULE. Each matched COURSE will generate a new accordion-item, with the title being a composite of the subject, number, title, and credits. The body consists of the course description, prerequisites, grade mode, and their stacked status.
    </xd:doc>
    <xsl:template match="COURSE">
        <accordion-item>
            <title>
                <xsl:value-of select="concat(SUBJ, '&#160;', NUMBER, ': ', TITLE, ' (', CR, ' credits)')"/>
            </title>
            <class>schedule-course</class>
            <body>
                <div class="thumbnail">
                    <p><xsl:value-of select="DESC"/></p>

                    <xsl:if test="string(PREREQUISITES)">
                        <div class="alert alert-error"><xsl:value-of select="PREREQUISITES"/></div>
                    </xsl:if>

                    <xsl:if test="string(GRADEMODE)">
                        <p class="schedule-grademode"><xsl:value-of select="GRADEMODE"/></p>
                    </xsl:if>

                    <xsl:if test="string(STACKED)">
                        <p class="schedule-stacked"><xsl:value-of select="STACKED"/></p>
                    </xsl:if>
                </div>

                <xsl:apply-templates select="SECTION"/>
            </body>
        </accordion-item>
    </xsl:template>

    <xd:doc>
        Each COURSE consists of one or more SECTION elements. These are displayed via a table layout, with one table per SECTION.
    </xd:doc>
    <xsl:template match="SECTION">
        <div class="well">
            <table class="table schedule_group">
                <caption class="sr-only">Schedule information for <xsl:value-of select="concat('CRN: ', CRN, ', Section: ', SECT)"/></caption>
                <thead>
                    <tr>
                        <th scope="col">CRN</th>
                        <th scope="col">SECTION</th>
                        <th scope="col">INSTRUCTOR</th>
                        <th scope="col">MEETS</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><xsl:value-of select="CRN"/></td>
                        <td><xsl:value-of select="SECT"/></td>
                        <td><xsl:value-of select="INST"/></td>
                        <td>
                            <xsl:apply-templates select="MEET"/>
                        </td>
                    </tr>
                </tbody>
            </table>
            <xsl:apply-templates select="PREREQUISITES | NOTE"/>
        </div>
    </xsl:template>

    <xd:doc>
        Display section meeting information if available.
    </xd:doc>
    <xsl:template match="MEET">
        <div class="row-fluid">
            <div class="span3 location">
                <xsl:value-of select="bldg"/>
                <xsl:value-of select="room"/>
            </div>
            <div class="span3 days">
                <xsl:value-of select="days"/>
            </div>
            <div class="span3 times">
                <xsl:value-of select="times"/>
            </div>
            <div class="span3 dates">
                <xsl:value-of select="dates"/>
            </div>
        </div>
    </xsl:template>

    <xd:doc>
        Output PREQUISITES and NOTE nodes in paragraph form. Applied from SECTION template.
    </xd:doc>
    <xsl:template match="PREREQUISITES | NOTE">
        <p><xsl:value-of select="."/></p>
    </xsl:template>
</xsl:stylesheet>
