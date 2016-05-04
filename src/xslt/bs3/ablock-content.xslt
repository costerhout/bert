<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xd"
    version="1.0">
    <xsl:import href="../include/string.xslt"/>

    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>

    <xd:doc type="stylesheet">
        <xd:short>ablock-content.xslt: Simple stylesheet to output common 'ablock' elements.</xd:short>
        <xd:detail>
            <p>There's minimal processing done within this stylesheet.  Content blocks used within data definitions typically have the name "ablock" - this stylesheet is chained from other stylesheets in order to display those blocks.  This stylesheet is smart enough to figure out if the ablock is a system-index-block, a system-data-structure, or else a block of XHTML content and apply templates accordingly.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
      <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>
    <!-- ablock nodes are used for content blocks and index blocks that are appended to the tab -->
    <xd:doc>
        <xd:short>Match template to match on "ablock" elements.</xd:short>
        <xd:detail>
            <p>The following ablock types are known:</p>
            <ul>
                <li>content/system-data-structure: the referenced block is a data block with a data definition</li>
                <li>content/system-index-block: the referenced block is an index block</li>
                <li>content: the referenced block is simply a block of XHTML content</li>
            </ul>
        </xd:detail>
    </xd:doc>
    <xsl:template match="ablock[@type='block']">
        <xsl:choose>
            <!-- Determine whether or not the block is WYSIWYG content or a structured data block -->
            <xsl:when test="content/system-data-structure">
                <xsl:apply-templates select="content/system-data-structure"/>
            </xsl:when>
            <!-- Find out if this is an index block -->
            <xsl:when test="content/system-index-block">
                <xsl:apply-templates select="content/system-index-block"/>
            </xsl:when>
            <!-- Assume that the ablock is simply a structured data block -->
            <xsl:otherwise>
                <xsl:apply-templates select="content"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:short>Simple template to do nothing upon an ablock which is not set.</xd:short>
        <xd:detail>
            <p>Likely not needed, but if any additional functionality is desired such as logging the existence of empty blocks, then you would override this template in a parent stylesheet.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="ablock" priority="-1">
        <!-- There's nothing to do here yet -->
    </xsl:template>

    <xd:doc>
        Fall back template to dump out the block content in the event that this block does not contain a system-data-structure
    </xd:doc>
    <xsl:template match="content">
        <!-- Just dump out the content -->
        <xsl:copy-of select="./*"/>
    </xsl:template>

    <xd:doc>
        Helper matching template to wrap content in a paragraph if it isn't already encapsulated
    </xd:doc>
    <xsl:template match="content" mode="paragraph-wrap">
        <!-- Just dump out the content, wrapped in a paragraph if needed -->
        <xsl:call-template name="paragraph-wrap">
            <xsl:with-param name="nodeToWrap" select="."/>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
