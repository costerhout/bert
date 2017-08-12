<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2017-08-11T09:20:23-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-08-11T15:47:07-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:hh="http://www.hannonhill.com/XSL/Functions"
    xmlns:string="my:string"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xd exsl hh string hh"
    >
    <xsl:import href="../include/format-date.xslt"/>
    <xsl:import href="../include/string.xslt"/>
    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to generate buttons corresponding to the next set of months</xd:short>
        <xd:detail>
            <p>On the Activities calendar main page are a series of buttons which link to pages with the activities specific to those months. This stylesheet generates those buttons.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctoterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2017</xd:copyright>
    </xd:doc>

    <xsl:strip-space elements="*"/>
    <xsl:output
          method='html'
          indent='yes'
          omit-xml-declaration='yes'
          />

    <xd:doc>
        Match an index block
    </xd:doc>
    <xsl:template match="/system-index-block">
        <!-- Get current month as two digit date code -->
        <xsl:variable name="nMonthCurrent" select="hh:dateFormat('mm')"/>
        <xsl:variable name="nYearCurrent" select="hh:dateFormat('yyyy')"/>

        <!-- Rearrange the nodes according so that the current month is first -->
        <!-- Start the nav section -->
        <!-- Create one button per node -->
        <ul class="nav nav-pills">
            <!-- Start with the current month -->
            <xsl:apply-templates select="system-page[name != 'index'][name = $nMonthCurrent]">
                <xsl:with-param name="nYear" select="$nYearCurrent"/>
            </xsl:apply-templates>

            <!-- Add in all the months after this -->
            <xsl:apply-templates select="system-page[name != 'index'][number(name) &gt; $nMonthCurrent]">
                <xsl:with-param name="nYear" select="$nYearCurrent"/>
            </xsl:apply-templates>

            <!-- Add in all the months before this (will be next year) -->
            <xsl:apply-templates select="system-page[name != 'index'][number(name) &lt; $nMonthCurrent]">
                <xsl:with-param name="nYear" select="number($nYearCurrent) + 1"/>
            </xsl:apply-templates>
        </ul>
    </xsl:template>

    <xd:doc>
        Output a system page as a nav pill button
    </xd:doc>
    <xsl:template match="system-page">
        <xsl:param name="nYear"/>

        <!-- Set the button to be active if we're referring to the current page -->
        <xsl:variable name="bActive">
            <xsl:choose>
                <xsl:when test="/system-index-block/calling-page/system-page/name = name">true</xsl:when>
                <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Title sample format: "Aug 2018" -->
        <xsl:variable name="sTitle" select="
            concat(
                hh:calendarFormat(
                    concat(string(name), '-', '01', '-', $nYear),
                    'mmm'
                ),
                ' ',
                $nYear
            )"
        />
        <li>
            <!-- Mark the button representing the current month as active -->
            <xsl:if test="$bActive = 'true'">
                <xsl:attribute name="class">active</xsl:attribute>
            </xsl:if>

            <!-- Output link to the page -->
            <a href="{path}"><xsl:value-of select="$sTitle"/></a>
        </li>
    </xsl:template>
</xsl:stylesheet>
