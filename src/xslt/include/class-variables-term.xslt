<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout> based on original John French <jhfrench>
@Date:   2017-05-03T14:52:04-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2018-02-12T14:15:26-09:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="xd exsl"
    version="1.0"
    xmlns:exsl="http://exslt.org/common"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    >

    <xsl:variable name="rtfSemestersAvailable">
        <semester>
            <title>Fall</title>
            <year>2017</year>
            <hidden>true</hidden>
            <term>201703</term>
        </semester>
        <semester>
            <title>Spring</title>
            <year>2018</year>
            <hidden>false</hidden>
            <term>201801</term>
        </semester>
        <semester>
            <title>Summer</title>
            <year>2018</year>
            <hidden>false</hidden>
            <term>201802</term>
        </semester>
    </xsl:variable>

    <xsl:variable name="nsSemestersAvailable" select="exsl:node-set($rtfSemestersAvailable)"/>
    <xsl:variable name="nodeSemesterCatalog" select="$nsSemestersAvailable/semester[title='Spring' and year='2018']"/>
    <xsl:variable name="nodeSemesterClassChooser" select="$nsSemestersAvailable/semester[title='Spring' and year='2018']"/>
    <xsl:variable name="urlScheduleClassChooser">http://www.uas.alaska.edu/schedule/schedule4.cgi?db=<xsl:value-of select="$nodeSemesterClassChooser/title"/><xsl:text disable-output-escaping="yes">&amp;</xsl:text>format=xml</xsl:variable>
</xsl:stylesheet>
