<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:str="http://exslt.org/strings"
    exclude-result-prefixes="str"
    >

    <xd:doc type="stylesheet">
        <xd:short>Prepare XSLT for use in the Cascade Server CMS</xd:short>
        <xd:detail>
            <p>This stylesheet goes through and updates import and include
            paths to be correct for use in the UAS CMS system. It's intended
            to be used within the Grunt workflow and libxslt (xsltproc) and
            therefore should not be dependent on Xalan components. Portions
            of EXSLT may be supported, use with caution.</p>
            <p>The following parameters are required to be passed in via
                the --stringparam parameter:
                - sPathBase: CMS base path
                - filepath: Path of the source file relative to the project
                - sPathStrip: portion of file path to strip
            </p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctoterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <xsl:strip-space elements="*"/>
    <xsl:output
        method='xml'
        indent='yes'
        omit-xml-declaration='no'
        />

    <xd:doc>
        Prepend the parent path to the existing 'href' attribute and output altered
        element.  Relative path segments with '..' are resolved as the CMS can't
        handle these for some reason.
    </xd:doc>
    <xsl:template match="xsl:import | xsl:include">
        <!--
        Get filename using EXSLT tokenize function to find the last
        occurrance of the '/' character.
        Credit: modified from Thomas Lule's answer in:
            http://stackoverflow.com/questions/17468891/substring-after-last-character-in-xslt
        -->
        <xsl:variable name="sFile">
            <xsl:if test="substring($filepath, string-length($filepath)) != '/'">
                <xsl:value-of select="str:tokenize($filepath, '/')[last()]" />
            </xsl:if>
        </xsl:variable>

        <!-- Get full relative path of file -->
        <xsl:variable name="sPathSubPreStrip" select="substring-before($filepath, $sFile)"/>

        <!-- Strip off the portion we don't want -->
        <xsl:variable name="sPathSub" select="substring-after($sPathSubPreStrip, $sPathStrip)"/>

        <!-- Get the full HREF path which may include '..' -->
        <xsl:variable name="sPathHref" select="concat($sPathBase, $sPathSub, @href)"/>

        <!-- Find instances of '../' and remove that string and the preceding as the CMS can't
        handle it. -->
        <xsl:variable name="nsPathTokenized" select="str:tokenize($sPathHref, '/')"/>
        <xsl:variable name="sPathResolved">
            <!-- Make this an absolute path by leading it off with the '/' -->
            <xsl:value-of select="'/'"/>

            <!-- Join together the parts of the path where the next segment is not a '..' -->
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns" select="$nsPathTokenized[text() != '..' and (position() = last() or following-sibling::token[1] != '..')]"/>
                <xsl:with-param name="glue" select="'/'"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="sName" select="name()"/>
        <xsl:element name="{$sName}">
            <xsl:attribute name="href">
                <xsl:value-of select="$sPathResolved"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xd:doc>
        Grabbed from include/string.xslt so as to not require dependency on
        the Xalan processor
    </xd:doc>
    <xsl:template name='nodeset-join'>
        <xsl:param name="ns" select="."/>
        <xsl:param name='glue'>, </xsl:param>
        <xsl:for-each select="$ns">
            <xsl:value-of select="."/>
            <xsl:if test='position() != last()'><xsl:value-of select="$glue"/></xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        Output all other elements as-is (identity transform)
    </xd:doc>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
