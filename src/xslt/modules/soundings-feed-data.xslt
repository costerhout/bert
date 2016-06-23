<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-06-14T11:16:53-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-06-23T12:03:43-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:string="my:string"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="string xd"
    >
    <xsl:import href='../include/string.xslt'/>
    <xsl:import href="../include/pathfilter.xslt"/>
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="xml" omit-xml-declaration="no"/>

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to take an index of Soundings articles and output them in a flat list of story elements with necessary fields only.</xd:short>
        <xd:detail>
            <p>In order to display a list of Soundings articles we need to take the output of an index block and repackage it into a set of articles. Unnecessary information is filtered out. Necessary dynamic-metadata fields, such as category and department, are flattened into the story data structure.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

   <xd:doc>
       Top level template matches a system-index-block and then begins the generation of the slimmed-down output file.
   </xd:doc>
   <xsl:template match="/system-index-block">
       <stories>
           <!-- Only process stories which are published -->
           <xsl:apply-templates select=".//system-page[is-published='true']//story"/>
       </stories>
   </xsl:template>

    <xd:doc>
        <xd:short>Template which matches the 'story' element and generates a filtered / partially flattened version of that element.</xd:short>
        <xd:detail>
            <p>The story data definition has most of what a Javascript module would need with the exception of the path, ID, and categories. This template combines those things in a nice-to-digest fashion.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="story">
        <!-- Grab the parent page for ease of use later -->
        <xsl:variable name="nodePage" select="ancestor::system-page[1]"/>

        <!-- Generate the path base, filtered just in case -->
        <xsl:variable name="sPathBase">
            <xsl:call-template name="pathfilter">
                <xsl:with-param name="path" select="$nodePage/path"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Stick on the '.html' on the end -->
        <xsl:variable name="sPath">
            <xsl:value-of select="concat($sPathBase, '.html')"/>
        </xsl:variable>

        <!-- Generate the image path, filtered just in case -->
        <xsl:variable name="sImagePath">
            <xsl:if test="image-thumb[@type='file']">
                <xsl:call-template name="pathfilter">
                    <xsl:with-param name="path" select="image-thumb/path"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:variable>

        <story id='{$nodePage/attribute::id}'>
            <!-- Output the path, filtered just in case -->
            <path><xsl:value-of select="$sPath"/></path>

            <!-- Output categories from parent page asset -->
            <xsl:apply-templates select="$nodePage/dynamic-metadata[name='Category' or name='department']"/>

            <!-- Output fields we care about -->
            <xsl:apply-templates select="title | date | writer | writer-email | lead | description | content"/>
            <xsl:if test="image-thumb[@type='file']">
                <featured-image>
                    <path><xsl:value-of select="$sImagePath"/></path>
                    <xsl:copy-of select="caption"/>
                </featured-image>
            </xsl:if>
        </story>
    </xsl:template>

    <xd:doc>
        Output the content of the article wrapped within a CDATA section to avoid intermediary XML parsing.
    </xd:doc>
    <xsl:template match="content">
        <content>
            <xsl:call-template name="cdata-wrap"/>
        </content>
    </xsl:template>

    <xd:doc>
        Output category and deparatment metadata.
    </xd:doc>
    <xsl:template match="dynamic-metadata[name='Category' or name='department']">
        <!-- Generate the element name based on the metadata name field, but make it lower case -->
        <xsl:variable name="sEl" select="string:lowerCase(string(name))"/>

        <!-- Output all the values for this metadata using that element name -->
        <xsl:for-each select="value">
            <xsl:element name='{$sEl}'><xsl:value-of select="."/></xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        Identity template to properly copy out elements, even those that contain children. Will be invoked via the xsl:copy-of elements in the story template.
    </xd:doc>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        This will match more specifically than the identity template. Here we strip leading and trailing spaces off the fields.
    </xd:doc>
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
</xsl:stylesheet>
