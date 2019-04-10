<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2019-04-10T13:29:10-08:00
@Email:  ctosterhout@alaska.edu
@Last modified by:   ctosterhout
@Last modified time: 2019-04-10T14:00:54-08:00
@License: Released under MIT License. Copyright 2017 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:string="my:string"
                exclude-result-prefixes="string xd">

    <xsl:include href="../include/string.xslt" />
    
    <xd:doc type="stylesheet">
        <xd:short>Create simple sitemap using lists with collapsible accordions</xd:short>
        <xd:detail>
            <p>Takes an index block input and converts it into a set of nested ul>li structures, each encapsulated in an accordion.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2019</xd:copyright>
    </xd:doc>

    <xsl:strip-space elements="*"/>
    <xsl:output
          method='html'
          indent='yes'
          omit-xml-declaration='yes'
          />

    <xd:doc>
        Top level matching template on system-index-block
    </xd:doc>
    
    <xsl:template match="system-index-block">
        <h2>Content</h2>
        
        <ul class="site">
            <!-- We avoid listing the initial index asset -->
            <xsl:apply-templates select="system-page[name != 'index'] | system-folder" mode="list-item"/>
        </ul>
    </xsl:template>
    
    <xd:doc>
        Matching template for a system folder that will output a list item and then recurse down in the folder
    </xd:doc>
    
    <xsl:template match="system-folder" mode="list-item">
        <xsl:variable name="idCollapse" select="string:generateId('collapse-')"/>
        <xsl:variable name="sDescription">
            <xsl:call-template name="get-description"/>
        </xsl:variable>
        
        <li class="folder">
            <a href="{concat('#', $idCollapse)}" data-toggle="collapse" class="sitemap"><xsl:value-of select="display-name"/></a>
            <span class="description">
                <xsl:text> — </xsl:text>
                <xsl:value-of select="$sDescription"/>
            </span>
            
            <div class="collapse" id="{$idCollapse}">
                <xsl:apply-templates select="." mode="folder-contents"/>
            </div>
        </li>
    </xsl:template>
    
    <xd:doc>
        Matching template for a system page that will create a list item that links to the page
    </xd:doc>
    
    <xsl:template match="system-page" mode="list-item">
        <xsl:variable name="sDescription">
            <xsl:call-template name="get-description"/>
        </xsl:variable>
        
        <li class="page">
            <a href="{path}">
                <xsl:call-template name="get-link-text"/>
            </a>
            <span class="description">
                <xsl:text> — </xsl:text>
                <xsl:value-of select="$sDescription"/>
            </span>
        </li>
    </xsl:template>
    
    <xd:doc>
        Matching template for a folder that begins a list and then invokes matching templates on system-page and system-folder elements
    </xd:doc>
    
    <xsl:template match="system-folder" mode="folder-contents">
        <ul>
            <xsl:apply-templates select="system-page | system-folder[.//system-page]" mode="list-item"/>
        </ul>
    </xsl:template>
    
    <xd:doc>
        Named template to generate a description suitable for a list item
    </xd:doc>
    
    <xsl:template name="get-description">
        <xsl:choose>
            <xsl:when test="normalize-space(summary) != ''">
                <xsl:value-of select="summary"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="description"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        Named template to generate a name suitable for link text
    </xd:doc>
    
    <xsl:template name="get-link-text">
        <xsl:choose>
            <xsl:when test="normalize-space(display-name) != ''">
                <xsl:value-of select="display-name"/>
            </xsl:when>
            <xsl:when test="normalize-space(title) != ''">
                <xsl:value-of select="title"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>