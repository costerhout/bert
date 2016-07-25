<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-07-25T15:11:23-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-07-25T15:33:46-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:string="my:string"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="string xd"
    >
    <xsl:import href='../include/string.xslt'/>
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to create a &lt;div&gt; which will be processed by a Javascript module in order to invoke the Zopim chat.</xd:short>
        <xd:detail>
            <p>The Zopim client is very configurable through their API, some of which are exposed to CMS users. This stylesheet translates configuration data held in the CMS to values that will be picked up by the Javascript module.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

   <xd:doc>
       Top level template matches a system-index-block with calling page data, which
       is required for filtering the output properly.
   </xd:doc>
   <xsl:template match="system-data-structure[zopim]">
       <xsl:apply-templates select="zopim"/>
   </xsl:template>

    <xsl:template match="zopim">
        <!-- Create a comma separated list of departments that we care about -->
        <xsl:variable name="sDepartments">
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns" select="departments/*"/>
                <xsl:with-param name="glue" select="','"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Output the div with required attributes -->
        <div
            class='zopim'
            data-module='zopim'
            >
            <!-- If there's a set of specific departments that we want to display, then pass that along too -->
            <xsl:if test="$sDepartments != ''">
                <xsl:attribute name="data-departments">
                    <xsl:value-of select="$sDepartments"/>
                </xsl:attribute>
            </xsl:if>

            <!-- Encode normal attributes value -->
            <xsl:apply-templates select="default-department | position | timeout-popup" mode='data-attribute'/>
        </div>
    </xsl:template>
</xsl:stylesheet>
