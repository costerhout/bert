<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- 
    Generate a Bootstrap 2 Thumbnail with an image up on top, a title (h3) below, 
    and then the caption below in a <p>
    
    Required Parameters:
        img_src: (string, URL) - Required
    
    Optionsl Parameters:
        title: (string) - Defaults to ''
        caption: (string) - Defaults to ''
        alt: (string) - Defaults to $title
        href: (string, URL) - If set, the link that the image should be pointed to
        elem_title: (string, HTML element) - Defaults to 'h3'
        elem_caption: (string, HTML element) - Defaults to 'p'
        class_div: (string list, space separated) - applies to the containing div as a whole
        class_caption: (string list, space separated) - applies to the caption
        class_img: (string list, space separated) - applies to the img
        
    -->
    <xsl:template name="thumbnail-with-caption">
        <xsl:param name='img_src'/>
        <xsl:param name='title' select="''"/>
        <xsl:param name='alt' select='$title'/>
        <xsl:param name="class_img" select="''"/>
        <xsl:param name='href' select="''"/>
        <xsl:param name='caption' select="''"/>
        <xsl:param name='elem_title'>h3</xsl:param>
        <xsl:param name='elem_caption'>p</xsl:param>
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
                <!-- Use the element type specified --> 
                <xsl:element name='{$elem_caption}'>                    
                    <xsl:if test="normalize-space($class_caption) != ''">
                        <xsl:attribute name="class">
                            <xsl:value-of select="$class_caption"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="$caption"/>
                </xsl:element>
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