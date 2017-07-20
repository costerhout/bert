<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout> based on original John French <jhfrench>
@Date:   2017-05-03T14:52:04-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-06-15T09:30:04-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="xd exsl"
    version="1.0"
    xmlns:exsl="http://exslt.org/common"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    >

    <xsl:variable name="semester">Summer</xsl:variable>
    <xsl:variable name="year">2017</xsl:variable>
    <xsl:variable name="urlSchedule">http://www.uas.alaska.edu/schedule/schedule4.cgi?db=<xsl:value-of select="$semester"/><xsl:text disable-output-escaping="yes">&amp;</xsl:text>format=xml</xsl:variable>

    <xsl:variable name="rtfSemestersAvailable">
        <semester>
            <title>Summer</title>
            <active>true</active>
        </semester>
        <semester>
            <title>Fall</title>
        </semester>
    </xsl:variable>

    <xsl:variable name="nsSemestersAvailable" select="exsl:node-set($rtfSemestersAvailable)"/>
</xsl:stylesheet>
