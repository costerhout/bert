<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xd"
    version="1.0">

    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>

    <xd:doc type="stylesheet">
        <xd:short>Utility stylesheet to generate a user-friendly file size string</xd:short>
        <xd:author>Colin Osterhout (ctoterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <xd:doc>
        <xd:short>This template generates an appropriate size string based on the file size.</xd:short>
        <xd:detail>
            <p>Generate a formatted file size string based on the passed in context node. Context node should be a "system-file"
            </p>
        </xd:detail>
        <xd:param name="unit" type="string">File type unit ('TB', 'GB', 'MB', 'KB', 'B'). Defaults to 'KB'.</xd:param>
        <xd:param name="formatNumber" type="string">Input to 'format-number' XPath function to control number output. Defaults to '###.##'.</xd:param>
    </xd:doc>
    <xsl:template name="format-filesize">
       <xsl:param name="unit">KB</xsl:param>
       <xsl:param name="formatNumber">###.##</xsl:param>

        <!-- Determine the denominator based on the unit passed in -->
        <xsl:variable name="denominator">
            <xsl:choose>
                <xsl:when test="$unit='TB'"><xsl:value-of select="1024 * 1024 * 1024 * 1024"/></xsl:when>
                <xsl:when test="$unit='GB'"><xsl:value-of select="1024 * 1024 * 1024"/></xsl:when>
                <xsl:when test="$unit='MB'"><xsl:value-of select="1024 * 1024"/></xsl:when>
                <xsl:when test="$unit='KB'"><xsl:value-of select="1024"/></xsl:when>
                <xsl:when test="$unit='B'"><xsl:value-of select="1"/></xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat(format-number(file-size div $denominator, $formatNumber), ' ', $unit)"/>
    </xsl:template>
</xsl:stylesheet>
