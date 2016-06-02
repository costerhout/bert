<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-05-19T17:31:49-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-06-01T23:13:55-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:string="my:string"
    exclude-result-prefixes="string xd exsl"
    >

    <xsl:import href="../include/error.xslt"/>
    <xsl:import href="../include/string.xslt"/>
    <xd:doc type="stylesheet">
        <xd:short>Create the necessary elements on a page to bootstrap a gallery module. Currently supports Flickr using the Juicebox module.</xd:short>
        <xd:detail>
            <p>This module creates a &lt;div&gt; element with configuration attributes so that a BERT module can invoke the Juicebox module and create the gallery.  Future expandability may include a local option using photos indexed within the CMS as well as from a Google Photos album.</p>
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

    <xsl:template match="system-data-structure[module-gallery]">
        <xsl:apply-templates select="module-gallery"/>
    </xsl:template>

    <xd:doc>
        <xd:short>Parse gallery information and output &lt;div&gt; element with configuration settings.</xd:short>
        <xd:detail>
            <p>Checks for valid settings, and then outputs those settings into a &lt;div&gt; element which the BERT theme will consume.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="module-gallery">
        <!-- Do sanity checking on the variables -->
        <xsl:variable name="rtfValidNodes">
            <nodedefs>
                <node>
                    <path>id</path>
                    <level>warning</level>
                    <regex>^(?:[a-zA-Z][\w:.-]*)?$</regex>
                    <flags></flags>
                    <message>Invalid HTML ID specified</message>
                </node>
                <node>
                    <path>class</path>
                    <level>warning</level>
                    <regex>^(?:-?[_a-zA-Z]+[_a-zA-Z0-9-]*\s*)*$</regex>
                    <flags></flags>
                    <message>Invalid CSS class string specified</message>
                </node>
                <node>
                    <path>type</path>
                    <level>warning</level>
                    <regex>^(?:flickr)$</regex>
                    <flags></flags>
                    <message>Invalid gallery type specified</message>
                </node>
            </nodedefs>
        </xsl:variable>

        <!-- Call the validate-nodes template which does the heavy lifting and will emit warnings for the browser to pick up -->
        <xsl:call-template name="validate-nodes">
            <xsl:with-param name="nsValidDef" select="exsl:node-set($rtfValidNodes)"/>
        </xsl:call-template>

        <!-- Is there an ID associated with this grid structure? -->
        <xsl:variable name="idSanitized">
            <xsl:if test="id[text() != '']">
                <xsl:value-of select="string:sanitizeHtmlId(string(id))"/>
            </xsl:if>
        </xsl:variable>

        <!-- Is there a class string associated with this grid structure? -->
        <xsl:variable name="rtfClass">
            <xsl:if test="class[text() != '']">
                <node>
                    <xsl:value-of select="normalize-space(class)"/>
                </node>
            </xsl:if>
            <node>gallery</node>
        </xsl:variable>
        <xsl:variable name="sClass">
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns" select="exsl:node-set($rtfClass)/*"/>
                <xsl:with-param name="glue" select="' '"/>
            </xsl:call-template>
        </xsl:variable>

        <div class="{$sClass}" data-module='gallery' data-type='{type}'>
            <!-- Output ID and class information -->
            <xsl:attribute name="id">
                <xsl:choose>
                    <xsl:when test="$idSanitized != ''">
                        <xsl:value-of select="$idSanitized"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="generate-id()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>

            <!-- Output data attributes for display -->
            <xsl:if test="normalize-space(link) != ''">
                <xsl:attribute name="data-sharelink">
                    <xsl:value-of select="normalize-space(link)"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:choose>
                <xsl:when test="type = 'flickr'">
                    <xsl:apply-templates select="settings-flickr/*" mode="data-attribute"/>
                </xsl:when>
            </xsl:choose>
        </div>
    </xsl:template>

    <xd:doc>
        Output div attributes particular to flickr
    </xd:doc>
    <xsl:template match="node()" mode="data-attribute">
        <xsl:variable name="sAttributeName">
            <xsl:value-of select="concat('data-', name())"/>
        </xsl:variable>
        <xsl:attribute name="{$sAttributeName}">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
</xsl:stylesheet>
