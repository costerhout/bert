<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-03-31T11:42:24-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-03-21T15:39:31-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:string="my:string"
    exclude-result-prefixes="xd string"
    >

    <xsl:import href="../include/string.xslt"/>

    <xd:doc type="stylesheet">
        <xd:short>Dump system-data-structure in XML-encapsulated block within a script tag.</xd:short>
        <xd:detail>
            Takes an input system-data-structure and dumps the contents within a script tag.
        </xd:detail>
        <xd:author>Colin Osterhout (ctoterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2017</xd:copyright>
    </xd:doc>

    <xsl:strip-space elements="*"/>
    <xsl:output
          method='xml'
          indent='yes'
          omit-xml-declaration='no'
          />

    <xd:doc>
        Identity transform to cover vast majority of elements in data.
    </xd:doc>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:short>Template which matches map data definition and filters elements
            to remove unnecessary information.</xd:short>
        <xd:detail>
            <p>The CMS outputs much unnecessary data for linked-to assets.
            This template filters the image and icon elements in particular to
            just output the path (if present).</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-data-structure">
        <xsl:variable name="idScript">
            <xsl:choose>
                <xsl:when test="normalize-space(id) != ''"><xsl:value-of select="id"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="string:generateId('object-')"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <script id="{$idScript}" type="application/xml">
            <object>
                <xsl:apply-templates select="*"/>
            </object>
        </script>
    </xsl:template>
</xsl:stylesheet>
