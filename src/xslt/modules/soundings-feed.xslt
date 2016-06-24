<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-06-23T12:30:53-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-06-23T12:48:03-08:00
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
    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to create a &lt;div&gt; which will be processed by a Javascript module in order to display a list of Soundings articles.</xd:short>
        <xd:detail>
            <p>In order to display a list of Soundings articles we need to know the location of the Soundings data source, the department we wish to filter on, and the number of articles to include.  Future enhancements may include more terms for filtering.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

   <xd:doc>
       Top level template matches a system-index-block with calling page data, which
       is required for filtering the output properly.
   </xd:doc>
   <xsl:template match="system-data-structure[soundings-feed]">
       <xsl:apply-templates select="soundings-feed"/>
   </xsl:template>

    <xsl:template match="soundings-feed">
        <!-- Generate the base path, filtered through the path filter -->
        <xsl:variable name="sPathBase">
            <xsl:call-template name="pathfilter">
                <xsl:with-param name="path" select="data-src/path"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Take the base path and slap an XML extension on it -->
        <xsl:variable name="sPath">
            <xsl:value-of select="concat($sPathBase, '.xml')"/>
        </xsl:variable>

        <!-- Create a comma separated list of departments that we care about -->
        <xsl:variable name="sDepartments">
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns" select="department/*"/>
                <xsl:with-param name="glue" select="','"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Output the div with required attributes -->
        <div
            class='soundings-feed'
            data-module='soundings-feed'
            data-url='{$sPath}'
            data-count='{count}'
            >
            <!-- If there's a set of specific departments that we want to display, then pass that along too -->
            <xsl:if test="$sDepartments != ''">
                <xsl:attribute name="data-departments">
                    <xsl:value-of select="$sDepartments"/>
                </xsl:attribute>
            </xsl:if>
        </div>
    </xsl:template>
</xsl:stylesheet>
