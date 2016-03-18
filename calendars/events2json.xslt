<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="../bs2-xslt/xml2json.xslt"/>
<!--    <xsl:import href="../bs2-xslt/xml-to-jsonml.xslt"/>-->
    <xsl:output indent="no" omit-xml-declaration="yes" method="text" encoding="UTF-8" media-type="text/x-json"/>
    <xsl:strip-space elements="*"/>
    
    
<!--
    <xsl:template match="/system-index-block">
        <xsl:apply-templates select=".//system-page/system-data-structure[@definition-path='Event']/Event"/>
    </xsl:template>
-->

    <!--    
    <xsl:template match="system-folder | /system-index-block">
        <xsl:call-template name="json_array" select=".//system-page/system-data-structure[@definition-path='Event']/Event"/>
        <xsl:apply-templates select="system-page[system-data-structure[@definition-path='Event']]"/>
        <xsl:apply-templates select="system-folder"/>
    </xsl:template>
    -->
    
    
    
<!--
    <xsl:template match="system-data-structure[@definition-path='Event']">
        
    </xsl:template>
-->
</xsl:stylesheet>