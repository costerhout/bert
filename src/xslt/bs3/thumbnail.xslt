<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-07-12T14:43:04-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-07-12T15:27:53-08:00
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
    <xd:doc type="stylesheet">
        <xd:short></xd:short>
        <xd:detail>
            <p></p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctoterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <xsl:strip-space elements="*"/>
    <xsl:output
          method='html'
          indent='yes'
          omit-xml-declaration='yes'
          />


    <xd:doc>
        Output a thumbnail. Unlike the BS2 version, this template is simply passed a content and caption, and leaves the logic of how these should be presented up to the caller.
    </xd:doc>
    <xsl:template name="thumbnail">
        <xsl:param name='caption' select="''"/>
        <xsl:param name='content' select="''"/>
        <xsl:param name="class_div" select="''"/>
        <div>
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="normalize-space($class_div) != ''">
                        <xsl:value-of select="concat('thumbnail', ' ', $class_div)"/>
                    </xsl:when>
                    <xsl:otherwise>thumbnail</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>

            <!-- Output the content -->
            <xsl:call-template name="paragraph-wrap">
                <xsl:with-param name="nodeToWrap" select="$content"/>
            </xsl:call-template>

            <!-- Whether or not to display a caption -->
            <xsl:if test="normalize-space($caption) != ''">
                <xsl:call-template name="paragraph-wrap">
                    <xsl:with-param name="nodeToWrap" select="$caption"/>
                </xsl:call-template>
            </xsl:if>
        </div>
    </xsl:template>
</xsl:stylesheet>
