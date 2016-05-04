<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:exsl="http://exslt.org/common"
    exclude-result-prefixes="xd"
    >

    <xsl:import href="string.xslt"/>

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

    <xd:doc>
        <xd:short>Utility template to remove '..' from file paths</xd:short>
        <xd:detail>
            <p>Takes a path in the form of 'base/remove/three/dirs/../../../path/to/file' and shortens it up accordingly to base/path/to/file</p>
        </xd:detail>
    </xd:doc>
    <xsl:template name="resolve-path">
        <xsl:param name="path"/>

        <!-- Do we even need to process this path? -->
        <xsl:choose>
            <xsl:when test="contains($path, '/..')">
                <!-- Yes! -->
                <!-- Step one: tokenize the path -->
                <xsl:variable name="rtfPathTokens">
                    <xsl:call-template name="tokenize-string">
                        <xsl:with-param name="sString" select="$path"/>
                        <xsl:with-param name="sDelimiter" select="'/'"/>
                    </xsl:call-template>
                </xsl:variable>

                <xsl:variable name="nsPathTokens" select="exsl:node-set($rtfPathTokens)"/>

                <!-- Step two: walk through the $nsPathTokens and remove the first directory fragment whose next fragment is a '..' -->
                <xsl:variable name="rtfPathTokensResolved">
                    <xsl:variable name="nSliceStart">
                        <xsl:for-each select="$nsPathTokens/*">
                            <xsl:if test="text() = '..' and count(preceding-sibling::*[text() = '..']) = 0">
                                <xsl:value-of select="position()"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>

                    <!-- Determine indexes of the first '..' item and first non-'..' item to use in later comparisons -->
                    <xsl:variable name="idStart" select="generate-id($nsPathTokens/*[$nSliceStart])"/>
                    <xsl:variable name="idEnd" select="generate-id($nsPathTokens/*[position() >= $nSliceStart][text() != '..'][1])"/>

                    <!-- Figure out how many '..' in a row we have -->
                    <xsl:variable name="nSliceLength">
                        <xsl:choose>
                            <!-- If we're at the end, the count is 1 -->
                            <xsl:when test="$nSliceStart = count($nsPathTokens/*)">
                                <xsl:value-of select="'1'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- We're not at the end, if we're at the first non-'..' item after the start then mark our position -->
                                <xsl:for-each select="$nsPathTokens/*">
                                    <xsl:if test="generate-id(.) = $idEnd">
                                        <xsl:value-of select="position() - $nSliceStart"/>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <!-- Output the node if we're not in the slice range -->
                    <xsl:for-each select="$nsPathTokens/*[position() &lt; ($nSliceStart - $nSliceLength) or position() &gt; ($nSliceStart + $nSliceLength - 1)]">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:variable>

                <!-- Convert the RTF to a node-set -->
                <xsl:variable name="nsPathTokensResolved" select="exsl:node-set($rtfPathTokensResolved)"/>

                <!-- Step three - assemble the nodes back into a string -->
                <xsl:variable name="sPathTokensResolved">
                    <xsl:call-template name="nodeset-join">
                        <xsl:with-param name="ns" select="$nsPathTokensResolved/*"/>
                        <xsl:with-param name="glue" select="'/'"/>
                    </xsl:call-template>
                </xsl:variable>

                <!-- Step four - if we have more to resolve, recurse, otherwise spit out value -->
                <xsl:choose>
                    <xsl:when test="contains($sPathTokensResolved, '/../')">
                        <xsl:call-template name="resolve-path">
                            <xsl:with-param name="path" select="$sPathTokensResolved"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$sPathTokensResolved"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- No, we don't need to process. Return as-is -->
                <xsl:value-of select="$path"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
