<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2017-05-04T14:36:13-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-05-04T14:36:46-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="string xd" version="1.0" xmlns:string="my:string" xmlns:xd="http://www.pnp-software.com/XSLTdoc">
    <xsl:import href="../bs2/bs2-default.xslt"/>
    <xd:doc type="stylesheet">
        <xd:short>Stylesheet used to generate thumbnail grid of videos originally for the UAS Ketchikan Drumbeats project</xd:short>
        <xd:detail>
            <p>The default behavior of the video-container stylesheet is to output a single video embed, potentially wrapped in a thumbnail. This stylesheet overrides that in order to display a set of videos in a grid format.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctoterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>

    <xd:doc>
        How many thumbnails we should have for each row.
    </xd:doc>
    <xsl:param name="nThumbnailsPerRow" select="2"/>

    <xd:doc>
        Match the top level system-index-block, invoking a local video-container matching template for every video that will make up the first of a grid row.
    </xd:doc>
    <xsl:template match="system-index-block[descendant::system-data-structure[video-container]]">
        <xsl:apply-templates mode="row" select="(.//video-container)[position() mod $nThumbnailsPerRow = 1]"/>
    </xsl:template>

    <xd:doc>
        The video-containers are broken up into rows. This template is invoked for the first video of each row.
    </xd:doc>
    <xsl:template match="video-container" mode="row">
        <div class="row-fluid">
            <xsl:apply-templates mode="row-item" select=". | following::video-container[position() &lt; $nThumbnailsPerRow]"/>
        </div>
    </xsl:template>

    <xd:doc>
        This template is appiled for every video-container to set the column information. This template then applies the default video-container template.
    </xd:doc>
    <xsl:template match="video-container" mode="row-item">
        <!-- Figure out what spanN class to use -->
        <xsl:variable name="nSpan" select="12 div $nThumbnailsPerRow"/>
        <xsl:variable name="sClass" select="concat('span', $nSpan)"/>

        <div class="{$sClass}">
            <!-- Actually output the video-container as per normal -->
            <xsl:apply-templates select="."/>
        </div>
    </xsl:template>
</xsl:stylesheet>
