<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2015-09-16T16:38:04-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-08-10T11:23:00-08:00
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
    <xsl:strip-space elements="*"/>
    <xsl:output method="html" indent='yes' omit-xml-declaration='yes'/>

    <xd:doc type="stylesheet">
        <xd:short>bs2-faq.xslt</xd:short>
        <xd:detail>
            <p>Convert FAQ data definition instance into an accordion list. Depends upon bs2-accordion-group.xslt to perform the output.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <xd:doc>
        <xd:short>Matching template for system-data-structure elements which contain faq-group structures, which allow for groups of different FAQs, each potentially with an introductory paragraph.</xd:short>
        <xd:detail>
            <p>This template dumps out the FAQ introduction, if specified, and then calls the 'faq-group' template which wades through the FAQ question and answers.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-data-structure[faq-group]">
        <xsl:for-each select="faq-group">
            <xsl:call-template name="paragraph-wrap">
                <xsl:with-param name="nodeToWrap" select="group-intro"/>
            </xsl:call-template>
            <xsl:call-template name="faq-group"/>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:short>Matching template for system-data-structure elements which contain faq-wysiwyg structures, which contain one set of FAQs.</xd:short>
        <xd:detail>
            <p>This template calls the 'faq-group' template which wades through the FAQ question and answers.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-data-structure[faq-item-wysiwyg]">
        <xsl:call-template name="faq-group"/>
    </xsl:template>

    <xd:doc>
        <xd:short>faq-group</xd:short>
        <xd:detail>
            <p>A named template which operates upon the current node which should contain faq-item-wysiwyg items.  Repackages the contained faq-item-wysiwyg contents and calls the accordion template to do the actual outputting.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template name="faq-group">
        <xsl:variable name="rtfAccordionGroup">
            <accordion>
                <xsl:apply-templates select="faq-item-wysiwyg"/>
            </accordion>
        </xsl:variable>
        <xsl:variable name="nsAccordionGroup" select="exsl:node-set($rtfAccordionGroup)"/>
        <xsl:call-template name="accordion">
            <xsl:with-param name="nsAccordionGroup" select="$nsAccordionGroup"/>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:short>faq-item-wysiwyg</xd:short>
        <xd:detail>
            <p>Matching template to repackage an individual FAQ item into a "accordion-item" for inclusion in an "accordion" node to be passed to the accordion template.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="faq-item-wysiwyg">
        <accordion-item>
            <title>
                <xsl:value-of select="question"/>
            </title>
            <body>
                <xsl:copy-of select="answer/* | definition/text()"/>
            </body>
        </accordion-item>
    </xsl:template>
</xsl:stylesheet>
