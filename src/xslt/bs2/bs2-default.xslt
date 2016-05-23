<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
    <xsl:include href='bs2-ablock-content.xslt'/>
    <xsl:include href='bs2-columns.xslt'/>
    <xsl:include href='bs2-description-list.xslt'/>
    <xsl:include href='bs2-email-form.xslt'/>
    <xsl:include href='bs2-faq.xslt'/>
    <xsl:include href='bs2-modal-simple.xslt'/>
    <xsl:include href='bs2-non-credit-course.xslt'/>
    <xsl:include href='bs2-personnel-list.xslt'/>
    <xsl:include href='bs2-personnel.xslt'/>
    <xsl:include href='bs2-tabs.xslt'/>
    <xsl:include href='bs2-thumbnail-with-caption.xslt'/>
    <xsl:include href='bs2-sidebar-address.xslt'/>
    <xsl:include href='../modules/gallery.xslt'/>
    <xsl:variable name="nl"><xsl:text>&#xa;</xsl:text></xsl:variable>

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
       <!-- The indentation below is off on purpose -->
        <xsl:comment>
WARNING: Unhandled node encountered.

Stack trace:

<xsl:call-template name="node-path-dump"/>
<xsl:value-of select="$nl"/>
        </xsl:comment>
    </xsl:template>

    <!-- Recursively dump out the names of the current and node and its ancestors -->
    <xsl:template name="node-path-dump">
        <xsl:param name="curNode" select="."/>
        <xsl:value-of select="concat('- ', name($curNode), $nl)"/>
        <xsl:if test="$curNode/.. and string-length(name($curNode/..))">
            <xsl:call-template name="node-path-dump">
                <xsl:with-param name="curNode" select="$curNode/.."/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
