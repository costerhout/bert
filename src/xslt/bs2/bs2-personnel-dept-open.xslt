<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:exsl="http://exslt.org/common"
                xmlns:string="my:string"
                exclude-result-prefixes="xd exsl string"
                >

    <xsl:import href="bs2-personnel-list.xslt"/>

    <xsl:strip-space elements="*"/>
    <xsl:output method="html" indent='yes' omit-xml-declaration='yes'/>

    <!--
    Whether or not the display should be a flat listing of users or to treat
    folders specially.
    -->
    <xsl:param name="personnel-list-mode">dept-open</xsl:param>
</xsl:stylesheet>
