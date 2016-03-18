<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:string="my:string"
                exclude-result-prefixes="string"
                >

    <xsl:import href="../include/error.xslt"/>
    <xsl:import href="../include/string.xslt"/>
    <xsl:include href="grid.xslt"/>
    <xsl:include href="ablock-content.xslt"/>

    <xsl:strip-space elements="*"/>
    <xsl:output
                method='html'
                indent='yes'
                omit-xml-declaration='yes'
                />

    <xsl:template match="system-index-block">
        <xsl:apply-templates select="system-block/system-data-structure"/>
    </xsl:template>

    <!-- Fall back template for unknown system-data-structures -->
    <xsl:template match="system-data-structure">
      <xsl:call-template name="log-warning">
         <xsl:with-param name="message">Unhandled system-data-structure</xsl:with-param>
          <xsl:with-param name="nsToLog" select="."/>
      </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
