<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-06-16T18:32:44-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-07-12T15:28:15-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:exsl="http://exslt.org/common"
    exclude-result-prefixes="xd exsl"
    >

    <xsl:import href="thumbnail.xslt"/>

    <xd:doc type="stylesheet">
        <xd:short>Generate a wrapper video container &lt;div&gt; element to allow for responsive &lt;iframe&gt; video embeds.</xd:short>
        <xd:detail>
            <p>&lt;iframe&gt; elements are not responsive by design. This gets around that limitation by wrapping a simple &lt;iframe&gt; with a &lt;div&gt; that will be appropriately styled via CSS.  </p>
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
        Simple matching template to match nested video-container systems-data-structures. Invokes the matching template video-container to do the actual work.
    </xd:doc>
    <xsl:template match="system-data-structure[video-container]">
        <xsl:apply-templates select="video-container"/>
    </xsl:template>

    <xd:doc>
        <xd:short>Template to encode the video-container information within an &lt;iframe&gt; wrapped by a &lt;div&gt; with a class string.</xd:short>
        <xd:detail>
            <p>All we're doing is to create a simple div>iframe HTML structure. The CSS does the _real_ work here.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="video-container">
        <xsl:variable name="sClass">
            <xsl:value-of select="concat('video-container-', aspect-ratio)"/>
        </xsl:variable>

        <xsl:variable name="rtfContent">
            <div class='{$sClass}'>
                <iframe src="{link-video}" frameborder="0"></iframe>
            </div>
        </xsl:variable>

        <xsl:variable name="rtfCaption">
            <h3><xsl:value-of select="thumbnail-options/title"/></h3>
            <xsl:call-template name="paragraph-wrap">
                <xsl:with-param name="nodeToWrap" select="thumbnail-options/caption"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="thumbnail/value = 'Yes'">
                <xsl:call-template name="thumbnail">
                    <xsl:with-param name="content" select="exsl:node-set($rtfContent)"/>
                    <xsl:with-param name="caption" select="exsl:node-set($rtfCaption)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="exsl:node-set($rtfContent)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
