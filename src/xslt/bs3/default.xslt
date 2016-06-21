<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-03-15T16:07:59-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-06-01T23:12:17-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:string="my:string"
                exclude-result-prefixes="string xd"
                >

    <xsl:import href="../include/error.xslt"/>
    <xsl:import href="../include/string.xslt"/>
    <xsl:include href="grid.xslt"/>
    <xsl:include href="menu.xslt"/>
    <xsl:include href="tabs.xslt"/>
    <xsl:include href="container.xslt"/>
    <xsl:include href="ablock-content.xslt"/>
    <xsl:include href="../modules/gallery.xslt"/>
    <xsl:include href="../modules/video-container.xslt"/>

    <xd:doc type="stylesheet">
        <xd:short>default.xslt: Root level stylesheet to convert CMS assets into
          HTML based on the Bootstrap 3 framework.</xd:short>
        <xd:detail>
            <p>Top-level stylesheet which includes all the other Bootstrap 3
            stylesheets.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
      <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <xsl:strip-space elements="*"/>
    <xsl:output
                method='html'
                indent='yes'
                omit-xml-declaration='yes'
                />

    <xd:doc>Fall back template for unknown system-data-structures</xd:doc>
    <xsl:template match="system-data-structure" priority="-2">
        <xsl:call-template name="log-warning">
            <xsl:with-param name="message">Unhandled system-data-structure</xsl:with-param>
            <xsl:with-param name="nsToLog" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="system-index-block">
        <xsl:apply-templates select="system-block/system-data-structure"/>
    </xsl:template>
</xsl:stylesheet>
