<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:import href="../include/paragraph-wrap.xslt"/>

    <!-- Top level block pattern to match the "tab" data definition -->
    <xsl:template match="system-data-structure[tab]">
        <xsl:if test="count(tab) &gt; 0">
            <div class="tabbable">
                <div class="tab-content">
                    <ul>
                        <xsl:attribute name="class">nav nav-tabs</xsl:attribute>
                        <xsl:apply-templates select="tab" mode="tab-toc"/>
                    </ul>
                    <xsl:apply-templates select="tab" mode="tab-body"/>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- Generate the tab navigation area (the table of contents -->
    <xsl:template match="tab" mode="tab-toc">
        <li>
            <xsl:if test="position() = 1">
                <xsl:attribute name="class">active</xsl:attribute>
            </xsl:if>
            <a>
                <xsl:attribute name="href">#<xsl:value-of select="id"/></xsl:attribute>
                <xsl:attribute name="data-toggle">tab</xsl:attribute>
                <xsl:value-of select="label"/>
            </a>
        </li>
    </xsl:template>

    <!-- For each tab, generate the div with the content inside -->
    <xsl:template match="tab" mode="tab-body">
        <div>
            <xsl:attribute name="id"><xsl:value-of select="id"/></xsl:attribute>
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="position() = 1">tab-pane active</xsl:when>
                    <xsl:otherwise>tab-pane</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>

            <!-- If there's anything defined in the WYSIWYG then spit it out -->
            <xsl:apply-templates select="content[node() | text()]"/>

            <xsl:choose>
                <!-- Figure out what to do with the other content associated with this tab -->
                <xsl:when test="ablock[@type='block']">
                    <!-- It's a referenced block - call any templates that match -->
                    <xsl:apply-templates select="ablock"/>
                </xsl:when>
            </xsl:choose>
        </div>
    </xsl:template>

    <!-- WYSIWYG Content -->
    <xsl:template match="content">
        <!-- Just dump out the content, wrapped in a paragraph if needed -->
        <xsl:call-template name="paragraph-wrap">
            <xsl:with-param name="nodeToWrap" select="."/>
        </xsl:call-template>
        <xsl:copy-of select="./*"/>
    </xsl:template>
</xsl:stylesheet>
