<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-11-16T14:52:04-09:00
@Email:  ctosterhout@alaska.edu
@Last modified by:   ctosterhout
@Last modified time: 2020-03-10T13:57:14-08:00
Based on previous work by jtmundy and jhfrench
-->
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    exclude-result-prefixes="exsl">

    <xsl:import href="../include/string.xslt"/>
    <xsl:output indent="yes" method="xml" omit-xml-declaration="yes"/>

    <!-- In bootstrap we have a total of 12 slots to occupy. These variables determine how the menu items are broken up -->
    <xsl:variable name="nButtonsPerRow" select="2"/>
    <xsl:variable name="nSpan" select="12 div $nButtonsPerRow"/>
    
    <xsl:variable name="sBaseUrl" select="'//uas.alaska.edu'"/>

    <xsl:key match="/system-index-block/*[self::system-page or self::system-folder or self::system-symlink]" name="keyGetMenuItems" use="dynamic-metadata[name='Include in Navigation']/value = 'Yes'"/>

    <!-- Top level matching template -->
    <xsl:template match="/system-index-block">
        <!-- The links are organized into sets of folders. These folders become groups of links. -->
        <div class="row-fluid">
            <xsl:apply-templates select="system-folder[.//system-page or .//system-symlink]"/>
        </div>
    </xsl:template>

    <xsl:template match="system-folder">
        <div class="span6">
            <h3><xsl:value-of select="display-name"/></h3>
            <ul class="nav nav-pills nav-stacked">
                <xsl:apply-templates select="system-page[is-published = 'true'][dynamic-metadata[name='Include in Navigation']/value = 'Yes']"/>
            </ul>
        </div>
    </xsl:template>
    
    <xsl:template match="system-page">
        <xsl:variable name="sLabel">
            <xsl:choose>
                <xsl:when test="normalize-space(title) != ''">
                    <xsl:value-of select="title"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="display-name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <li>
            <a href="{concat($sBaseUrl, path, '.html')}"><xsl:value-of select="$sLabel"/></a>
        </li>
    </xsl:template>
</xsl:stylesheet>