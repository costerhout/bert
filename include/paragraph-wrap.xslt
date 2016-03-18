<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

    <xsl:strip-space elements="*"/>
    <xsl:output 
                method='html'
                indent='yes'
                omit-xml-declaration='yes'
                />

    <!-- 
    paragraph-wrap
       Accepts input text() or node structure.  If the input is a text() node, then wrap
       within a <p>...</p> tag set with optional class.

    Inputs:
       nodeToWrap (node) - either text() or node to wrap within a set of <p> ... </p> tags
       classWrap (string) - class to apply to the <p> tag

    Output:
        Outputs the nodeToWrap within a <p> if needed.
    -->

    <xsl:template name="paragraph-wrap">
        <xsl:param name="nodeToWrap"/>
        <xsl:param name="classWrap"/>
        <xsl:choose>
            <xsl:when test="$nodeToWrap[text()]">
                <p>
                    <xsl:if test="$classWrap != ''">
                        <xsl:attribute name="class"><xsl:value-of select="$classWrap"/></xsl:attribute>
                    </xsl:if>
                    <xsl:copy-of select="normalize-space(string($nodeToWrap))"/>
                </p>
            </xsl:when>
            <xsl:when test="$nodeToWrap[node()]">
                <xsl:choose>
                    <xsl:when test="$classWrap != ''">
                        <div class="{$classWrap}">
                            <xsl:copy-of select="$nodeToWrap/*"/>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$nodeToWrap/*"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>