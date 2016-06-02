<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-01-04T15:47:45-09:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-06-01T23:07:47-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>

    <!--
    Top level block pattern to match the "columns" data definition.
    The purpose of this template is to pull out the tab_content_group
    fragment and potentially wrap it into a div with the assigned class.

    The actual template which dumps out the tab_content_group is defined
    within the bs2-tabs stylesheet.
    -->
    <xsl:template match="system-data-structure[class][tab_content_group]">
        <xsl:choose>
            <xsl:when test="class/value">
                <div>
                    <xsl:attribute name="class">
                        <xsl:for-each select="class/value">
                            <xsl:value-of select="normalize-space(.)"/>
                            <xsl:if test="position() != last()">
                                <xsl:text>&#x20;</xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:attribute>
                    <xsl:apply-templates select="tab_content_group"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="tab_content_group"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
