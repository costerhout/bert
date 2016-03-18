<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>

    <!-- ablock nodes are used for content blocks and index blocks that are appended to the tab -->
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

    <xsl:template match="ablock">
        <!-- There's nothing to do here yet -->
    </xsl:template>

    <!-- Fall back template to dump out the block content in the event that this block does
        not contain a system-data-structure -->
    <xsl:template match="content">
        <!-- Just dump out the content -->
        <xsl:copy-of select="./*"/>
    </xsl:template>
</xsl:stylesheet>
