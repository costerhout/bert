<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:import href="../include/filetype.xslt"/>
    <xsl:import href="bs2-thumbnail-with-caption.xslt"/>
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

    <!--
    block_group is used in the 'columns' data definition

    A block_group can contain any of the following:
        * ablock
        * address-block
        * index-block
        * file
        * page

    We handle "ablock", "file", and "page" contents within this stylesheet. The other members
    of the block_group go unhandled at this time.
    -->
    <xsl:template match="block_group">
        <!-- Perform default handling of the ablock member -->
        <xsl:apply-templates select="ablock"/>

        <!--
        For the file and page items, apply-templates with a mode specified.
        This is because it is very possible that there's another template somewhere
        that is set to match on "file" or "page" with very different purpose.
        -->
        <xsl:apply-templates select="file | page" mode="block_group"/>

        <!--
        For now just call the handlers (if present) for non-empty index-block and
        address-block members.  We don't define these within this stylesheet at this time,
        so if you want to use these items you have to define these in the top-level
        stylesheet, like so:

        <xsl:template match="index-block" mode="block_group">
        </xsl:template>

        If these members are used but no handlers are found a warning comment should be
        displayed.
        -->
        <xsl:apply-templates select="index-block[path != '/'] | address-block[path != '/']" mode="block_group"/>
    </xsl:template>

    <!--
   Handle the "file" subitem of the "block_group".

   The default handler checkes to see if the file is an image and then if so,
   creates a thumbnail for it.

   Override in calling template via:
   <xsl:template match="file" mode="block_group">
   </xsl:template>
   -->
    <xsl:template match="file" mode="block_group" priority="-1">
        <!-- Only do anything if there's a path associated with this file -->
        <xsl:if test="path">
            <!-- Determine the file type -->
            <xsl:variable name="filetype">
                <xsl:call-template name="getfiletype">
                    <xsl:with-param name="path" select="path"/>
                </xsl:call-template>
            </xsl:variable>
            <!-- If the file is an image then display a simple thumbnail -->
            <xsl:if test="$filetype = 'image'">
                <xsl:call-template name="thumbnail-with-caption">
                    <!-- Here we need to check for the the file being an image first -->
                    <xsl:with-param name="img_src" select="path"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <!--
   Handle the "page" subitem of the "block_group". If there's a system-data-structure
   contained directly within (a page with a Data Definition attached),
   then apply the default handler for that.  Otherwise, then dump out the page contents.

   Override in calling template via:
   <xsl:template match="page" mode="block_group">
   </xsl:template>
   -->
    <xsl:template match="page" mode="block_group" priority="-1">
        <!-- Only do anything if there's a path associated with this file -->
        <xsl:choose>
            <xsl:when test="content/system-data-structure">
                <xsl:apply-templates select="content/system-data-structure"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="content/*"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
