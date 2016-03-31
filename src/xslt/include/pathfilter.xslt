<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

    <xd:doc type="stylesheet">
        <xd:short>Helper stylesheet to alter paths to fit website redirection.</xd:short>
        <xd:detail>
            <p>The paths in the CMS aren't always 1:1 matches with the paths
            on the webserver. This stylesheet contains a template (pathfilter)
            which accounts for those differences.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <xsl:output method="html" indent='yes' omit-xml-declaration='yes'/>

    <xd:doc>
        <xd:short>Utility template to operate on paths intended for use in URLs</xd:short>
        <xd:detail>
            <p>This template takes a path and alters it if necessary to support
            webserver file path oddities.</p>
        </xd:detail>
        <xd:param name="path" type="string">Path to operate on</xd:param>
    </xd:doc>
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