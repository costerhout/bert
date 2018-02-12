<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout> and John French <jhfrench>
@Date:   2016-11-16T14:52:04-09:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2018-01-03T16:46:37-09:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
--><xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="exsl string xd"
    version="1.0"
    xmlns:exsl="http://exslt.org/common"
    xmlns:string="my:string"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc">
    <xsl:import href="../include/class-variables-term.xslt"/>
    <xsl:import href='../include/string.xslt'/>
    <xsl:import href="../bs2/bs2-tabs.xslt"/>

    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="html"/>

    <xd:doc>
        Top level match on the system-data-structure
    </xd:doc>
    <xsl:template match="system-data-structure">
        <xsl:variable name="nodeSubject" select="Subject"/>

        <!-- Build the tabs variable for later call to the BERT tab generator -->
        <xsl:variable name="rtfTabs">
            <xsl:for-each select="$nsSemestersAvailable">
                <xsl:apply-templates select="semester[hidden='false']">
                    <xsl:with-param name="nodeSubject" select="$nodeSubject"/>
                </xsl:apply-templates>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="exsl:node-set($rtfTabs)">
            <xsl:call-template name="tab"/>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        Create the tab definition for this particular semester
    </xd:doc>
    <xsl:template match="semester">
        <xsl:param name="nodeSubject"/>
        <xsl:variable name="sId" select="generate-id()"/>
        <xsl:variable name="sLabel" select="concat(year, ' ', title, ' Semester')"/>
        <xsl:variable name="sTitle" select="concat(year, ' ', title, ' Classes')"/>

        <tab>
            <!-- Generate a random tab ID -->
            <tab_id><xsl:value-of select="$sId"/></tab_id>
            <tab_label><xsl:value-of select="$sLabel"/></tab_label>
            <tab_content>
                <a class="btn pull-right" href="http://www.uas.alaska.edu/schedule/index.html" target="_blank">View Full UAS Schedule</a>
                <h2><xsl:value-of select="$sTitle"/></h2>
                <xsl:apply-templates select="$nodeSubject">
                    <xsl:with-param name="term" select="string:lowerCase(string(title))"/>
                </xsl:apply-templates>
            </tab_content>
            <tab_active>
                <xsl:choose>
                    <xsl:when test="generate-id($nodeSemesterClassChooser) = generate-id()">true</xsl:when>
                    <xsl:otherwise>false</xsl:otherwise>
                </xsl:choose>
            </tab_active>
        </tab>
    </xsl:template>

    <xd:doc>
        For each subject generate an SSI include statement which will bring in the table of courses from the schedule database.
    </xd:doc>
    <xsl:template match="Subject">
        <xsl:param name="term"/>

        <xsl:variable name="sCampus">
            <xsl:choose>
                <xsl:when test="campus/value">
                    <xsl:apply-templates select="campus/value"/>
                </xsl:when>
                <!-- If no campuses defined, then we'll use all campuses -->
                <xsl:otherwise>%27J%27%2C+%27K%27%2C+%27T%27</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sInclude">
            <xsl:text disable-output-escaping="yes">#include virtual="/schedule/schedule-bs.cgi?db=</xsl:text><xsl:value-of select="$term"/><xsl:text disable-output-escaping="yes">&amp;campus=</xsl:text><xsl:value-of select="$sCampus"/><xsl:text disable-output-escaping="yes">&amp;subject=</xsl:text><xsl:value-of select="code"/>"
        </xsl:variable>
        <xsl:text disable-output-escaping="yes">&lt;</xsl:text>!--<xsl:value-of select="$sInclude"/>--<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
        <div class="clearfix">&#160;</div>
    </xsl:template>

    <xd:doc>
        Put together the portion of the database SSI query string based on the location code.
    </xd:doc>
    <xsl:template match="value">
        <!-- How many selected campuses are there anyhow? -->
        <xsl:variable name="nCampus" select="count(preceding-sibling::value) + count(following-sibling::value) + 1"/>
        <xsl:variable name="sCampusCode">
            <xsl:choose>
                <xsl:when test=". = 'Juneau'">J</xsl:when>
                <xsl:when test=". = 'Ketchikan'">K</xsl:when>
                <xsl:when test=". = 'Sitka'">T</xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!-- If there's more than one campus and we're not at the end, then put in a delimiter -->
        <xsl:variable name="sDelim">
            <xsl:choose>
                <xsl:when test="$nCampus &gt; 1 and position() &lt; $nCampus">
                    <xsl:text disable-output-escaping="yes">%2C+</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!-- Assemble this portion of the query string -->
        <xsl:value-of select="concat('%27', $sCampusCode, '%27', $sDelim)"/>
    </xsl:template>
</xsl:stylesheet>
