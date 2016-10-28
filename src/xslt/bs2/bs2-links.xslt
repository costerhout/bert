<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-06-08T15:41:48-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-10-25T18:12:55-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:string="my:string"
    exclude-result-prefixes="string xd"
    >

    <xsl:import href="../include/error.xslt"/>
    <xsl:import href="../include/string.xslt"/>
    <xd:doc type="stylesheet">
        <xd:short></xd:short>
        <xd:detail>
            <p></p>
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

    <xsl:template match='system-data-structure[link-group/link]'>
        <!-- If there's a linkheader defined, then spit it out -->
        <xsl:if test="linkheader != '' or linkheader/*">
            <!-- There is!  Display it wrapped as a paragraph if necessary -->
            <xsl:call-template name="paragraph-wrap">
                <xsl:with-param name="nodeToWrap" select='linkheader'/>
            </xsl:call-template>
        </xsl:if>
        <!-- Process each group of links -->
        <xsl:apply-templates select="link-group" mode="links"/>
    </xsl:template>

    <xd:doc>
        <xd:short>Matching template to process "link-group" data blocks</xd:short>
        <xd:detail>
            <p>Each link group block title is displayed as a &lt;h2&gt; tag followed by a description list. The matching template "link" handles the individual link items.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="link-group[link]" mode="links">
        <xsl:if test="link/*">
            <!-- Output the group title -->
            <h2><xsl:value-of select="group-title"/></h2>

            <!-- Wrap the links in a definition list -->
            <dl>
                <xsl:apply-templates select="link" mode="links"/>
            </dl>
        </xsl:if>

    </xsl:template>

    <xd:doc>
        <xd:short>Matching template to process each individual link.</xd:short>
        <xd:detail>
            <p>Each link is presented as a description list item, consisting of the title and the explanation of the link.  The title is presented as the link.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="link" mode="links">
        <dt>
            <a href="{url}">
                <xsl:value-of select="normalize-space(title)"/>
            </a>
        </dt>
        <dd><xsl:value-of select="note"/></dd>
    </xsl:template>
</xsl:stylesheet>
