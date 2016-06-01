<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                exclude-result-prefixes="xd"
                >
    <xsl:include href='bs2-default.xslt'/>

    <xsl:strip-space elements="*"/>
    <xsl:output
                method='html'
                indent='yes'
                omit-xml-declaration='yes'
                />


    <xd:doc>
        Wrapper around the default processing in order to encapsulate the output into a BS2 well element.
    </xd:doc>
    <xsl:template match="/">
        <div class="well">
            <xsl:apply-templates select="*"/>
        </div>
    </xsl:template>
</xsl:stylesheet>
