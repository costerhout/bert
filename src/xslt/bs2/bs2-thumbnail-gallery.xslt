<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-09-09T14:02:23-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-09-09T14:38:14-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:exsl="http://exslt.org/common"
    xmlns:string="my:string"
    exclude-result-prefixes="string xd"
    >

    <xsl:import href="../include/error.xslt"/>
    <xsl:import href="../include/string.xslt"/>
    <xsl:import href="bs2-thumbnail-with-caption.xslt"/>

    <xd:doc type="stylesheet">
        <xd:short>Simple stylesheet to display an index of images in a grid of thumbnails.</xd:short>
        <xd:detail>
            <p>Displays indexed images in a thumbnail grid, using the indexed files' "Display Name" and "Description" metadata fields as the image title and caption, respectively. This component has to be used outside of the bs2-default since it blindly uses any system-index-block content.</p>
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
        Match top level system-index-block and begin building the node-set of thumbnail descriptors
    </xd:doc>
    <xsl:template match="/system-index-block">
        <!-- Craft thumbnail descriptors for further processing by the bs2-thumbnail-with-caption.xslt stylesheet -->
        <xsl:variable name="rtfThumbnails">
            <thumbnails>
                <xsl:if test=".//system-file[is-published = 'true']">
                    <!-- Recurse through folders and find all system files and craft thumbnail descriptors -->
                    <xsl:apply-templates select=".//system-file[is-published = 'true']"/>
                </xsl:if>
            </thumbnails>
        </xsl:variable>

        <!-- ... and turn into a real node-set -->
        <xsl:variable name="nsThumbnails" select="exsl:node-set($rtfThumbnails)"/>

        <!-- Invoke the bs2-thumbnail-with-caption.xslt stylesheet template to arrange the thumbnails into a grid -->
        <xsl:apply-templates select="($nsThumbnails/thumbnails/thumbnail)[position() mod $nThumbnailsPerRow = 1]" mode="row"/>
    </xsl:template>

    <xd:doc>
        For each system file create a simple thumbnail descriptor containing the title, image path, and caption to display.
    </xd:doc>
    <xsl:template match="system-file">
        <!-- Come up with a title - if there's a display-name, use that. Otherwise, use the title field or if that's not available use the system name -->
        <xsl:variable name="sTitle">
            <xsl:choose>
                <xsl:when test="display-name != ''">
                    <xsl:value-of select="display-name"/>
                </xsl:when>
                <xsl:when test="title != ''">
                    <xsl:value-of select="title"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- If a description is set, use that as the caption -->
        <xsl:variable name="sCaption">
            <xsl:choose>
                <xsl:when test="description != ''">
                    <xsl:value-of select="description"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <thumbnail>
            <image>
                <xsl:copy-of select="path"/>
            </image>
            <title>
                <xsl:value-of select="$sTitle"/>
            </title>
            <caption>
                <xsl:value-of select="$sCaption"/>
            </caption>
        </thumbnail>
    </xsl:template>
</xsl:stylesheet>
