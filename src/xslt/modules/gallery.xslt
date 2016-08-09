<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-05-19T17:31:49-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-08-08T13:17:36-08:00
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
        <xd:short>Create the necessary elements on a page to bootstrap a gallery module. Currently supports Flickr using the Juicebox module and Bootstrap carousel component with images provided via an index block of system-file assets.</xd:short>
        <xd:detail>
            <p>For Flickr galleries, this module creates a &lt;div&gt; element with configuration attributes so that a BERT module can invoke the Juicebox module and create the gallery.</p>
            <p>Photos kept within the CMS can be used to create a slideshow as well using the Bootstrap carousel component.</p>
            <p>Future expandability may include a local option using photos from a Google Photos album.</p>
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
                    <regex>^(?:flickr|cms)$</regex>
                    <flags></flags>
                    <message>Invalid gallery type specified</message>
                </node>
            </nodedefs>
        </xsl:variable>

        <!-- Call the validate-nodes template which does the heavy lifting and will emit warnings for the browser to pick up -->
        <xsl:call-template name="validate-nodes">
            <xsl:with-param name="nsValidDef" select="exsl:node-set($rtfValidNodes)"/>
        </xsl:call-template>

        <!-- Handle the output differently depending on the type of gallery desired -->
        <xsl:choose>
            <xsl:when test="type = 'flickr'">
                <xsl:call-template name="gallery-flickr"/>
            </xsl:when>
            <xsl:when test="type = 'cms'">
                <xsl:call-template name="gallery-cms"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        Handle CMS gallery via static carousel of images. BS2 and BS3 handle this with same markup.
    </xd:doc>
    <xsl:template name="gallery-cms">
        <!-- Gather up nodeset of image files for display -->
        <xsl:variable name="nsImage" select=".//system-file[is-published='true']"/>

        <!-- Figure out what the ID should be. If specified, use that, otherwise generate -->
        <xsl:variable name="idCarousel">
            <xsl:choose>
                <xsl:when test="id[text() != '']">
                    <xsl:value-of select="string:sanitizeHtmlId(string(id))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="generate-id()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>


        <!-- Is there a class string associated with this grid structure? -->
        <xsl:variable name="rtfClass">
            <xsl:if test="class[text() != '']">
                <node>
                    <xsl:value-of select="normalize-space(class)"/>
                </node>
            </xsl:if>
            <node>carousel</node>
            <node>slide</node>
        </xsl:variable>

        <xsl:variable name="sClass">
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns" select="exsl:node-set($rtfClass)/*"/>
                <xsl:with-param name="glue" select="' '"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:if test="count($nsImage) &gt; 0">
            <div class="{$sClass}" id="{$idCarousel}" data-ride="carousel">
                <!-- Output indicators -->
                <!-- Note: suppressed until production release of Bootstrap 2.3.2 -->
                <!-- <ol class="carousel-indicators">
                    <xsl:apply-templates select="$nsImage" mode="gallery-cms-indicators">
                        <xsl:with-param name="idCarousel" select="$idCarousel"/>
                    </xsl:apply-templates>
                </ol> -->

                <!-- Wrapper for slides -->
                <div class="carousel-inner" role="listbox">
                    <xsl:apply-templates select="$nsImage" mode="gallery-cms-slides"/>
                </div>

                <!-- Output controls -->
                <!-- Note: suppressed until production release of Bootstrap 2.3.2 as well as Gallery module attribute to hide / show buttons -->
                <!-- <a class="left carousel-control" href="{concat('#', $idCarousel)}" role="button" data-slide="prev">
                    &#8249;
                    <span class="sr-only">Previous</span>
                </a>
                <a class="right carousel-control" href="{concat('#', $idCarousel)}" role="button" data-slide="next">
                    &#8250;
                    <span class="sr-only">Next</span>
                </a> -->
            </div>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        Output the little indicators at the bottom of the carousel to show people where we are at in the slideshow.
    </xd:doc>
    <xsl:template match="system-file" mode="gallery-cms-indicators">
        <xsl:param name="idCarousel"/>
        <li>
            <!-- Create link to slide -->
            <xsl:attribute name="data-target"><xsl:value-of select="concat('#', $idCarousel)"/></xsl:attribute>

            <!-- Bootstrap glue: sets position in list (0 based) -->
            <xsl:attribute name="data-slide-to"><xsl:value-of select="position() - 1"/></xsl:attribute>

            <!-- If the first slide, then set as active -->
            <xsl:if test="position() = 1">
                <xsl:attribute name="class"><xsl:value-of select="'active'"/></xsl:attribute>
            </xsl:if>
        </li>
    </xsl:template>

    <xd:doc>
        Output the slide image and caption (if description is present)
    </xd:doc>
    <xsl:template match="system-file" mode="gallery-cms-slides">
        <!-- Set the title (alternate text) to be the title field or display-name field -->
        <xsl:variable name="sTitle">
            <xsl:choose>
                <xsl:when test="title"><xsl:value-of select="title"/></xsl:when>
                <xsl:when test="display-name"><xsl:value-of select="display-name"/></xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!-- If there's a description present, then we'll use the description as the caption -->
        <xsl:variable name="sCaption">
            <xsl:choose>
                <xsl:when test="description"><xsl:value-of select="description"/></xsl:when>
            </xsl:choose>
        </xsl:variable>

        <div>
            <!-- Set the class for the slide - if the first, then set as active -->
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="position() = 1">item active</xsl:when>
                    <xsl:otherwise>item</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!-- Set the image source -->
            <img src="{path}">
                <xsl:if test="normalize-space($sTitle) != ''">
                    <xsl:attribute name="alt"><xsl:value-of select="$sTitle"/></xsl:attribute>
                </xsl:if>
            </img>

            <!-- Set the caption (if description present) -->
            <xsl:if test="normalize-space($sCaption)">
                <div class="carousel-caption">
                    <xsl:value-of select="$sCaption"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>

    <xd:doc>
        Handle Flickr gallery via BERT Javascript module
    </xd:doc>
    <xsl:template name="gallery-flickr">
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
            <!-- Output ID, if present -->
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

            <xsl:apply-templates select="settings-flickr/*" mode="data-attribute"/>
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
