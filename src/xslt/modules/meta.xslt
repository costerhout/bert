<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:exsl="http://exslt.org/common"
    exclude-result-prefixes="xd exsl"
    >

    <xsl:import href="../include/string.xslt"/>
    <xsl:import href="../include/pathfilter.xslt"/>

    <xd:doc type="stylesheet">
        <xd:short>Creates meta properties for the head of the webpage.</xd:short>
        <xd:detail>
            <p>Based upon initial work done by John French.</p>
            <p>Takes care of the following things:</p>
            <ul>
                <li>Open graph protocol settings: og:title, og:URL, og:description, og:site_name, og:image</li>
                <li>PageID</li>
            </ul>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <xsl:output indent="yes" method="html" omit-xml-declaration='yes'/>

    <!-- Set base URL parameter -->
    <xsl:param name="sUrlBase">http://www.uas.alaska.edu</xsl:param>
    <xsl:param name="sFbAppId">1524156954552807</xsl:param>

    <xsl:template match="/system-index-block/calling-page/system-page[@current='true']">
        <!-- Set up variables for later output: Page ID, title of page, path of page -->
        <xsl:variable name="sCurrentPageId">
            <xsl:value-of select="@id"/>
        </xsl:variable>

        <!-- Special case: run the path through the path filter -->
        <xsl:variable name="sPathFragment">
            <xsl:call-template name="pathfilter">
                <xsl:with-param name="path" select="path"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Break down the path into its constituent parts -->
        <xsl:variable name="rtfPathTokens">
            <xsl:call-template name="tokenize-string">
                <xsl:with-param name="sString" select="path"/>
                <xsl:with-param name="sDelimiter" select="'/'"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Create the path string out of all the parts except for the last one -->
        <xsl:variable name="sPathBase">
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns" select="(exsl:node-set($rtfPathTokens)/*)[position() != last()]"/>
                <xsl:with-param name="glue" select="'/'"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="sPath">
            <xsl:value-of select="concat(normalize-space($sUrlBase), $sPathFragment, '.html')"/>
        </xsl:variable>

        <xsl:variable name="sThumbnail">
            <xsl:choose>
                <!-- Test first for an explicitly set Thumbnail value -->
                <xsl:when test="dynamic-metadata[name = 'Thumbnail'][value]">
                    <xsl:value-of select="normalize-space(dynamic-metadata[name = 'Thumbnail']/value)"/>
                </xsl:when>
                <!-- Test next for the first image found in the page body -->
                <xsl:when test="page-xhtml//img">
                    <xsl:choose>
                        <!-- Check to see if this is an external image - if so, then pass it along unaltered -->
                        <xsl:when test="starts-with(page-xhtml//img[1]/@src, 'http://') or starts-with(page-xhtml//img[1]/@src, 'https://') or starts-with(page-xhtml//img[1]/@src, '//')">
                            <xsl:value-of select="page-xhtml//img[1]/@src"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message><xsl:value-of select="concat($sPathBase, '/', page-xhtml//img[1]/@src)"/></xsl:message>
                            <!-- Resolve the path to an absolute path -->
                            <xsl:variable name="sPathThumbnail">
                                <xsl:call-template name="resolve-path">
                                    <xsl:with-param name="path" select="concat($sPathBase, '/', page-xhtml//img[1]/@src)"/>
                                </xsl:call-template>
                            </xsl:variable>

                            <!-- Prepend the '/' and then filter that path -->
                            <xsl:variable name="sPathThumbnailFiltered">
                                <xsl:call-template name="pathfilter">
                                    <xsl:with-param name="path" select="concat('/', $sPathThumbnail)"/>
                                </xsl:call-template>
                            </xsl:variable>

                            <!-- Pass along the absolute path of the image -->
                            <xsl:value-of select="concat($sUrlBase, $sPathThumbnailFiltered)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="system-data-structure">
                    <xsl:apply-templates select="system-data-structure" mode="meta-thumbnail"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!-- Output page ID -->
        <meta>
            <xsl:attribute name="content"><xsl:value-of select="$sCurrentPageId"/></xsl:attribute>
            <xsl:attribute name="name">PageID</xsl:attribute>
        </meta>

        <!-- Output Open Graph meta tags -->
        <meta property="og:title"><xsl:attribute name="content"><xsl:value-of select="normalize-space(display-name)"/></xsl:attribute></meta>
        <meta property="og:type" content="website"/>
        <meta property="og:url"><xsl:attribute name="content"><xsl:value-of select="normalize-space($sPath)"/></xsl:attribute></meta>
        <meta property="og:description"><xsl:attribute name="content"><xsl:value-of select="normalize-space(description)"/></xsl:attribute></meta>
        <meta property="og:site_name" content="University of Alaska Southeast"/>
        <meta property="fb:app_id" content="{$sFbAppId}"/>

        <!-- Only output og:image tag if we have resolved a thumbnail path -->
        <xsl:if test="$sThumbnail != ''">
            <meta property="og:image">
                <xsl:attribute name="content"><xsl:value-of select="normalize-space($sThumbnail)"/></xsl:attribute>
            </meta>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
