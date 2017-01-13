<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-11-16T14:52:04-09:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-01-06T11:53:48-09:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    version="1.0"
    exclude-result-prefixes="xd"
    >
    <xd:doc>
        <xd:short>Stylesheet used to generate a combined breadcrumb trail and heading for the current page.</xd:short>
        <xd:detail>
            <p>This is useful for the top of the page navigation. The index block must be set to index page assets and to have "Start at the current page with folder hierarchy, and also include siblings" set. System metadata and user metadata must be included as well.</p>
        </xd:detail>
    </xd:doc>

    <xsl:output indent="yes" method="html"/>
    <xsl:variable name="bread-crumb-separator">&#187;</xsl:variable>

    <xd:doc>
        <xd:short>Top level matching template for the system-index-block output.</xd:short>
        <xd:detail>
            <p>Begin the output of the unordered list (ul) element. Walk through system-folders and output a breadcrumb entry for each and then finally output the entry for the current page node.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="/system-index-block">
        <xsl:variable name="nodePageCurrent" select=".//system-page[@current='true']"/>
        <xsl:variable name="nsAncestors" select="$nodePageCurrent/ancestor::system-folder[(generate-id(system-page[name='index']) != generate-id($nodePageCurrent))]"/>
        <!-- Create the UL, start recursing through the folder hierarchy, then output the page name / display name at the end -->
        <ul class="breadcrumb">
            <!-- Output all the ancestor folders with the exception of the current folder if the current page is the index page -->
            <xsl:apply-templates select="$nsAncestors">
                <xsl:with-param name="nodePageCurrent" select="$nodePageCurrent"/>
            </xsl:apply-templates>

            <!-- Finally output the current page -->
            <xsl:apply-templates select="$nodePageCurrent"/>
        </ul>
    </xsl:template>

    <xd:doc>
        <xd:short>Matching template for a system-page</xd:short>
        <xd:detail>
            <p>This template is designed to output a list item with an H1 element containing the display name (or title) for a system page entry. By design, this template will only be applied for the current page.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-page">
        <xsl:variable name="sTitle">
            <xsl:call-template name="generate-breadcrumb-title"/>
        </xsl:variable>

        <li class="active">
            <h1 class="small lead"><xsl:value-of select="$sTitle"/></h1>
        </li>
    </xsl:template>

    <xd:doc>
        <xd:short>Matching template for a system-folder</xd:short>
        <xd:detail>
            <p>This template is designed to output a list item with a link to the folder's index page, if published and set to appear in the navigation. The display name (or title) is used for the element content.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-folder">
        <xsl:param name="nodePageCurrent" />
        <xsl:variable name="nodePageIndex" select="child::system-page[name='index']"/>

        <xsl:variable name="sTitle">
            <xsl:call-template name="generate-breadcrumb-title"/>
        </xsl:variable>

        <!-- Determine if there's an index file in this directory -->
        <xsl:variable name="rtfItem">
            <xsl:choose>
                <xsl:when test="$nodePageIndex">
                    <a href="{$nodePageIndex/path}"><xsl:value-of select="$sTitle"/></a>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="$sTitle"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Output a list item -->
        <li>
            <xsl:copy-of select="$rtfItem"/>
        </li>
        <span class="divider"><xsl:value-of select="$bread-crumb-separator"/></span>
    </xsl:template>

    <xd:doc>
        Do nothing for folders who are not included in navigation
    </xd:doc>
    <xsl:template match="system-folder[dynamic-metadata[name='Include in Navigation']/value = 'No']"></xsl:template>

    <xd:doc>
        <xd:short>Named template to generate a name based on the current node's metadata.</xd:short>
        <xd:detail>
            <p>If the display-name is defined, use that. Otherwise, use the asset's title.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template name="generate-breadcrumb-title">
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
    </xsl:template>
</xsl:stylesheet>
