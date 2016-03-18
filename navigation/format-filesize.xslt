<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>
    <!--
Context node is a "system-file".  Parameter "file-size" is in bytes.  This template generates
an appropriate size string based on the file size.

Parameters:
unit (string) - Either TB, GB, MB, KB (default), or B
formatNumber (string) - Default: '###.##' - passed to the format-number() XPath function
-->
    <xsl:template name="format-filesize">
        <xsl:param name="unit">KB</xsl:param>
        <xsl:param name="formatNumber">###.##</xsl:param>
        <!-- Determine the denominator based on the unit passed in -->
        <xsl:variable name="denominator">
            <xsl:choose>
                <xsl:when test="$unit='TB'">
                    <xsl:value-of select="1024 * 1024 * 1024 * 1024"/>
                </xsl:when>
                <xsl:when test="$unit='GB'">
                    <xsl:value-of select="1024 * 1024 * 1024"/>
                </xsl:when>
                <xsl:when test="$unit='MB'">
                    <xsl:value-of select="1024 * 1024"/>
                </xsl:when>
                <xsl:when test="$unit='KB'">
                    <xsl:value-of select="1024"/>
                </xsl:when>
                <xsl:when test="$unit='B'">
                    <xsl:value-of select="1"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat(format-number(file-size div $denominator, $formatNumber), ' ', $unit)"/>
    </xsl:template>
</xsl:stylesheet>