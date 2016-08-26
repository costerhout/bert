<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2015-09-14T14:22:33-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-08-19T14:03:46-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
                version="1.0"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xd"
                >
    <xsl:import href="../include/string.xslt"/>
    
    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>

    <xd:doc type="stylesheet">
        <xd:short>Generate a Bootstrap 2 Thumbnail (or set of thumbnails) with an image up on top, a title below,
        and then the caption below that.</xd:short>
        <xd:detail>
            <p>Both individual and lists of thumbnails are supported.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <xd:doc>
        How many thumbnails we should have for each row.
    </xd:doc>
    <xsl:param name="nThumbnailsPerRow" select="3"/>

    <xd:doc>
        <xd:short>Match a list of thumbnail objects.</xd:short>
        <xd:detail>
            <p>This template is used to match a list of thumbnail objects contained within a system-index-block output.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-index-block[descendant::system-data-structure[thumbnail]]">
        <!-- Invoke the "row" thumbnail template for each of the first row members -->
        <xsl:apply-templates select="(.//thumbnail)[position() mod $nThumbnailsPerRow = 1]" mode="row"/>
    </xsl:template>

    <xd:doc>
        <xd:short>Match a single thumbnail data definition instance</xd:short>
        <xd:detail>
            <p>While the previous template matched system-index-block grouped thumbnails, this template matches single thumbnails wrapped in a system-data-structure</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-data-structure[thumbnail]">
        <xsl:apply-templates select="thumbnail"/>
    </xsl:template>

    <xd:doc>
        Matching template to process groups of thumbnails as a row
    </xd:doc>
    <xsl:template match="thumbnail" mode="row">
        <!-- Create the outer UL element and then invoke the inner template with this node as well as the following thumbnails that should be displayed within this row (as determined by their position within the document order) -->
        <ul class="thumbnails">
            <xsl:apply-templates select=". | following::thumbnail[position() &lt; $nThumbnailsPerRow]" mode="row-item"/>
        </ul>
    </xsl:template>

    <xd:doc>
        Matching template for individual thumbnail items as part of a row
    </xd:doc>
    <xsl:template match="thumbnail" mode="row-item">
        <!-- Figure out what spanN class to use -->
        <xsl:variable name="nSpan" select="12 div $nThumbnailsPerRow"/>
        <xsl:variable name="sClass" select="concat('span', $nSpan)"/>

        <!-- Generate list item -->
        <li class="{$sClass}">
            <xsl:apply-templates select="."/>
        </li>
    </xsl:template>

    <xd:doc>
        Matching template for .just. a thumbnail. Invokes the named template 'thumbnail-with-caption' with all the necessary parameters to create the BS2 thumbnail component.
    </xd:doc>
    <xsl:template match="thumbnail">
        <xsl:call-template name="thumbnail-with-caption">
            <xsl:with-param name="img_src" select="image/path"/>
            <xsl:with-param name="title" select="title"/>
            <xsl:with-param name="caption" select="caption"/>
            <xsl:with-param name="elem_title" select="'h3'"/>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:short>Generate a Bootstrap 2 Thumbnail with an image up on top, a title below,
        and then the caption at the bottom.</xd:short>
        <xd:detail>
            <p>Creates a Bootstrap thumbnail &lt;div&gt; element with an image, a title, and a caption along with some optional characteristics such as making the image a link. Only the 'img_src' parameter is required.
            </p>
        </xd:detail>
        <xd:param name="img_src" type="string">URL of the image to display</xd:param>
        <xd:param name="title" type="string">(optional) Title to display below image</xd:param>
        <xd:param name="alt" type="string">(optional, defaults to title parameter) Alternate text to use for image ('alt' attribute)</xd:param>
        <xd:param name="href" type="string">(optional) If set, makes the image a link using this URL as the target </xd:param>
        <xd:param name="elem_title" type="string">(optional, defaults to 'h3') Type of HTML element to use for the title</xd:param>
        <xd:param name="class_div" type="string">(optional) Class to append to wrapping &lt;div&gt; element.</xd:param>
        <xd:param name="class_caption" type="string">(optional) Class to apply to the caption element</xd:param>
        <xd:param name="class_img" type="string">(optional) Class to apply to the &lt;img&gt; element</xd:param>
    </xd:doc>
    <xsl:template name="thumbnail-with-caption">
        <xsl:param name='img_src'/>
        <xsl:param name='title' select="''"/>
        <xsl:param name='alt' select='$title'/>
        <xsl:param name="class_img" select="''"/>
        <xsl:param name='href' select="''"/>
        <xsl:param name='caption' select="''"/>
        <xsl:param name='elem_title'>h3</xsl:param>
        <xsl:param name="class_div" select="''"/>
        <xsl:param name="class_title" select="''"/>
        <xsl:param name="class_caption" select="''"/>
        <div>
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="normalize-space($class_div) != ''">
                        <xsl:value-of select="concat('thumbnail', ' ', $class_div)"/>
                    </xsl:when>
                    <xsl:otherwise>thumbnail</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>

            <!-- Figure out what to do with the img - is it a link? -->
            <xsl:choose>
                <!-- If there's a link specified, then encapsulate the thumbnail with the link tag -->
                <xsl:when test="$href">
                    <a>
                        <xsl:attribute name="href"><xsl:value-of select="$href"/></xsl:attribute>
                        <xsl:call-template name="thumbnail-with-caption-inner">
                            <xsl:with-param name="img_src" select="$img_src"/>
                            <xsl:with-param name="alt" select="$alt"/>
                            <xsl:with-param name="class_img" select="$class_img"/>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <!-- Just display the image -->
                <xsl:otherwise>
                    <xsl:call-template name="thumbnail-with-caption-inner">
                        <xsl:with-param name="img_src" select="$img_src"/>
                        <xsl:with-param name="alt" select="$alt"/>
                        <xsl:with-param name="class_img" select="$class_img"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>

            <!-- Whether or not to display the title -->
            <xsl:if test="normalize-space($title) != ''">
               <!-- Use the element type specified -->
                <xsl:element name='{$elem_title}'>
                   <!-- Apply classes, if specified -->
                    <xsl:if test="normalize-space($class_title) != ''">
                        <xsl:attribute name="class">
                            <xsl:value-of select="$class_title"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="$title"/>
                </xsl:element>
            </xsl:if>

            <!-- Whether or not to display a caption -->
            <xsl:if test="normalize-space($caption) != ''">
                <xsl:call-template name="paragraph-wrap">
                    <xsl:with-param name="nodeToWrap" select="$caption"/>
                    <xsl:with-param name="classWrap" select="$class_caption"/>
                </xsl:call-template>
            </xsl:if>
        </div>
    </xsl:template>

    <!-- This template actually does the work to display the image with alt tag and class -->
    <xsl:template name="thumbnail-with-caption-inner">
        <xsl:param name='img_src'/>
        <xsl:param name='alt' select="''"/>
        <xsl:param name="class_img" select="''"/>

        <img>
            <xsl:attribute name='src'><xsl:value-of select="$img_src"/></xsl:attribute>
            <xsl:attribute name='alt'><xsl:value-of select="$alt"/></xsl:attribute>
            <xsl:if test="normalize-space($class_img) != ''">
                <xsl:attribute name="class">
                    <xsl:value-of select="$class_img"/>
                </xsl:attribute>
            </xsl:if>
        </img>
    </xsl:template>
</xsl:stylesheet>
