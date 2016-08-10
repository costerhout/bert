<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2015-09-16T16:38:04-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-08-10T13:01:06-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes="xd exsl"
                >
    <xsl:import href="bs2-accordion-group.xslt"/>
    <xsl:import href="../include/error.xslt"/>

    <xsl:strip-space elements="*"/>
    <xsl:output method="html" indent='yes' omit-xml-declaration='yes'/>

    <xd:doc type="stylesheet">
        <xd:short>bs2-description-list.xslt</xd:short>
        <xd:detail>
            <p>Convert a description list data definition instance into a DL>DT+DD combination or an accordion set, depending on the layout parameter.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <xd:doc>
        <xd:short>Matching template for a system-data-structure that has the description list signature.</xd:short>
        <xd:detail>
            <p>Figures out how to process the description list based on the 'layout' parameter and invokes the proper template.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-data-structure[layout][dl-group]">
        <!-- Determine the type of layout desired -->
       <xsl:choose>
           <!-- Use a description list -->
            <xsl:when test="(layout = 'Horizontal') or (layout = 'Vertical')">
               <xsl:apply-templates select="." mode="dl"/>
           </xsl:when>
           <!-- Use an accordion list -->
           <xsl:when test="layout = 'Accordion'">
               <xsl:apply-templates select="." mode="accordion"/>
           </xsl:when>
           <xsl:otherwise>
               <!-- Punt -->
               <xsl:call-template name="log-error">
                   <xsl:with-param name="message">Invalid layout: <xsl:value-of select='layout'/></xsl:with-param>
               </xsl:call-template>
           </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        Matching template to begin the output of the DL element (which itself should contain pairs of DT and DD elements).
    </xd:doc>
    <xsl:template match="system-data-structure[layout][dl-group]" mode="dl">
        <dl>
            <xsl:if test="layout = 'Horizontal'">
                <xsl:attribute name="class">dl-horizontal</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="dl-group" mode="dl"/>
        </dl>
    </xsl:template>

    <xd:doc>
        Matching template to put together an accordion node for further processing by the accordion template.
    </xd:doc>
    <xsl:template match="system-data-structure[layout][dl-group]" mode="accordion">
        <xsl:variable name="rtfAccordionGroup">
            <accordion>
                <xsl:apply-templates select="dl-group" mode="accordion"/>
            </accordion>
        </xsl:variable>
        <xsl:variable name="nsAccordionGroup" select="exsl:node-set($rtfAccordionGroup)"/>
        <xsl:call-template name="accordion">
            <xsl:with-param name="nsAccordionGroup" select="$nsAccordionGroup"/>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        For each dl-group, creates a dt+dd pair
    </xd:doc>
    <xsl:template match="dl-group" mode="dl">
        <dt><xsl:value-of select="term"/></dt>
        <dd>
            <!-- Dump out the HTML expression as well as anything unencapsulated -->
            <xsl:copy-of select="definition/* | definition/text()"/>

            <!-- Nested blocks are OK - perform apply-templates accordingly -->
            <xsl:if test="ablock[@type='block']">
                <xsl:apply-templates select="ablock"/>
            </xsl:if>
        </dd>
    </xsl:template>

    <xd:doc>
        For each dl-group create an accordion-item with title and body.
    </xd:doc>
    <xsl:template match="dl-group" mode="accordion">
        <accordion-item>
            <title>
                <xsl:value-of select="term"/>
            </title>
            <body>
                <xsl:call-template name="paragraph-wrap">
                    <xsl:with-param name="nodeToWrap" select="definition"/>
                </xsl:call-template>

                <!-- Nested blocks are OK - perform apply-templates accordingly -->
                <xsl:if test="ablock[@type='block']">
                    <xsl:apply-templates select="ablock"/>
                </xsl:if>
            </body>
        </accordion-item>
    </xsl:template>
</xsl:stylesheet>
