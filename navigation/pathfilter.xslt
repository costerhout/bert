<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
    <xsl:output method="html" indent='yes' omit-xml-declaration='yes'/>
    <xsl:template name="pathfilter">
        <xsl:param name="path"/>
        <xsl:choose>
            <xsl:when test="starts-with($path,'/Marketing')">
                <xsl:value-of select="substring-after($path,'/Marketing')"/>
                <xsl:comment><xsl:value-of select="substring-after($path,'/Marketing')"/></xsl:comment>
            </xsl:when>
            <xsl:when test="starts-with($path,'/Support')">
                <xsl:value-of select="substring-after($path,'/Support')"/>
            </xsl:when>
            <xsl:when test="starts-with($path,'/Other')">
                <xsl:value-of select="substring-after($path,'/Other')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$path"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>