<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2015-11-05T15:44:27-09:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-06-01T23:10:52-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->


<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
    <xsl:strip-space elements="*"/>
    <xsl:output
                method='html'
                indent='yes'
                omit-xml-declaration='yes'
                />

    <!--
    Popover Bootstrap 2x template
    http://getbootstrap.com/2.3.2/javascript.html#popovers

    Dependencies: Unless you override the 'icon' parameter, FontAwesome is required
    Parameters:
        placement: left (default), right, top, bottom
        trigger: hover (default), click, manual, focus
        icon: (any valid HTML), default is a blue I in a circle, courtesy of FontAwesome:
            <span class='fa-stack' style='color: #365c9d'>
                <i class="fa fa-stack-2x fa-circle-thin"></i>
                <i class="fa fa-stack-1x fa-info"></i>
            </span>
        href: URL
        description: string
        title: string
        id: valid HTML entity ID - useful for manually triggering popovers
        class: space separated set of CSS classes

    -->
    <xsl:template name="popover">
        <!-- Parameter definintion (with defaults) -->
        <xsl:param name="placement">left</xsl:param>
        <xsl:param name="trigger">hover</xsl:param>
        <xsl:param name="icon">
            <span class='fa-stack' style='color: #365c9d'>
                <i class="fa fa-stack-2x fa-circle-thin">&#160;</i>
                <i class="fa fa-stack-1x fa-info">&#160;</i>
            </span>
        </xsl:param>

        <!-- Parameter definition (somewhat required for proper function) -->
        <xsl:param name="href"/>
        <xsl:param name="description"/>
        <xsl:param name="title"/>

        <!-- Very optional parameters -->
        <xsl:param name="id"/>
        <xsl:param name="class"/>

        <!-- Generate the anchor reference -->
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="normalize-space($href)"/>
            </xsl:attribute>
            <xsl:attribute name="data-content">
                <xsl:value-of select="normalize-space($description)"/>
            </xsl:attribute>
            <xsl:attribute name="data-original-title">
                <xsl:value-of select="normalize-space($title)"/>
            </xsl:attribute>
            <xsl:attribute name="data-trigger">
                <xsl:value-of select='$trigger'/>
            </xsl:attribute>
            <xsl:attribute name="data-placement">
                <xsl:value-of select="$placement"/>
            </xsl:attribute>
            <xsl:attribute name="rel">popover</xsl:attribute>
            <xsl:attribute name="type">button</xsl:attribute>
            <xsl:if test="normalize-space($id) != ''">
                <xsl:attribute name='id'>
                    <xsl:value-of select="normalize-space($id)"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="normalize-space($class) != ''">
                <xsl:attribute name='class'>
                    <xsl:value-of select="normalize-space($class)"/>
                </xsl:attribute>
            </xsl:if>

            <!-- Contents of the icon (any valid HTML) -->
            <xsl:copy-of select="$icon"/>
        </a>
    </xsl:template>
</xsl:stylesheet>
