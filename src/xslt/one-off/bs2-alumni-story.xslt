<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2019-02-28T15:59:15-09:00
@Email:  ctosterhout@alaska.edu
@Last modified by:   ctosterhout
@Last modified time: 2019-02-28T17:30:01-09:00
@License: Released under MIT License. Copyright 2017 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:string="my:string"
                exclude-result-prefixes="string xd">

    <xsl:include href="../include/string.xslt" />
    
    <xd:doc type="stylesheet">
        <xd:short>bs2-alumni-story.xslt</xd:short>
        <xd:detail>
            <p>Display a story (or a set of stories) for the Alumni &amp; Development office.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2019</xd:copyright>
    </xd:doc>

    <xsl:strip-space elements="*" />
    <xsl:output method='html'
                indent='yes'
                omit-xml-declaration='yes' />

    
    <xd:doc>
        Match an index block and apply the template which handles the alumni-story only
    </xd:doc>
    
    <xsl:template match="system-index-block">
        <xsl:apply-templates select=".//system-data-structure"/>
    </xsl:template>
    
    <xd:doc>
        Output a story, including a title, an image, a pullquote + citation, followed by the story body.
    </xd:doc>

    <xsl:template match="system-data-structure">
        <h2 class="story-title"><xsl:value-of select="title"/></h2>
        <div class="row-fluid story-topbar">
            <div class="span5"><img alt=""
                     src="{image/path}" /></div>
            <div class="span7 pullquote-container">
                <div class="pullquote">
                    <p class="lead story-pullquote"><span class="story-pullquote-content"><xsl:value-of select="pullquote"/></span></p>
                    <p class="small story-pullquote-citation"><xsl:value-of select="citation"/></p>
                </div>
            </div>
        </div>
        <div class="story-content">
            <xsl:for-each select="body">
                <xsl:call-template name="paragraph-wrap"/>
            </xsl:for-each>
        </div>
    </xsl:template>
</xsl:stylesheet>