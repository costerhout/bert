<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:string="my:string"
                exclude-result-prefixes="string xd"
                >

    <xsl:import href="../include/error.xslt"/>
    <xsl:import href="../include/string.xslt"/>
    <xsl:include href="grid.xslt"/>
    <xsl:include href="ablock-content.xslt"/>

    <xd:doc type="stylesheet">
      default.xslt: Root level stylesheet to convert CMS assets into
      HTML based on the Bootstrap 3 framework.
      <xd:author>ctsoterhout</xd:author>
      <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <xsl:strip-space elements="*"/>
    <xsl:output
                method='html'
                indent='yes'
                omit-xml-declaration='yes'
                />

    <xsl:template match="system-index-block">
        <xsl:apply-templates select="system-block/system-data-structure"/>
    </xsl:template>

    <xd:doc>Fall back template for unknown system-data-structures</xd:doc>
    <xsl:template match="system-data-structure">
      <xsl:call-template name="log-warning">
         <xsl:with-param name="message">Unhandled system-data-structure</xsl:with-param>
          <xsl:with-param name="nsToLog" select="."/>
      </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
