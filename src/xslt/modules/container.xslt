<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-04-27T15:11:02-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-10-26T16:51:42-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:string="my:string"
    xmlns:exsl="http://exslt.org/common"
    exclude-result-prefixes="xd exsl string"
    version="1.0">
    <xsl:import href="../include/string.xslt"/>
    <xsl:import href="../include/error.xslt"/>

    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>

    <xd:doc type="stylesheet">
        <xd:short>container.xslt: Simple stylesheet to output common 'ablock' elements.</xd:short>
        <xd:detail>
            <p>This stylesheet is used to wrap content blocks within a &lt;div&gt; structure with desired HTML id and CSS attributes and to invoke further matching templates on the ablock items contained within.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
      <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>
    <!-- ablock nodes are used for content blocks and index blocks that are appended to the tab -->
    <xd:doc>
        <xd:short>Match template to match on "container" blocks.</xd:short>
        <xd:detail>
            <p>Containers are used to wrap content in a DIV with either an ID, a class string, or both.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-data-structure[container]">
        <xsl:apply-templates select="container" mode="container"/>
    </xsl:template>

    <xsl:template match="container[ablock/@type='block']" mode="container">
        <!-- Do sanity checking on the variables -->
        <xsl:variable name="rtfValidNodes">
            <nodedefs>
                <node>
                    <path>id</path>
                    <level>warning</level>
                    <regex>^(?:[a-zA-Z][\w:.-]*)?$</regex>
                    <flags></flags>
                    <message>Invalid HTML ID specified</message>
                </node>
                <node>
                    <path>class</path>
                    <level>warning</level>
                    <regex>^(?:-?[_a-zA-Z]+[_a-zA-Z0-9-]*\s*)*$</regex>
                    <flags></flags>
                    <message>Invalid CSS class string specified</message>
                </node>
            </nodedefs>
        </xsl:variable>

        <xsl:call-template name="validate-nodes">
            <xsl:with-param name="nsValidDef" select="exsl:node-set($rtfValidNodes)"/>
        </xsl:call-template>

        <!-- Is there an ID associated with this container? -->
        <xsl:variable name="idSanitized">
            <xsl:if test="id[text() != '']">
                <xsl:value-of select="string:sanitizeHtmlId(string(id))"/>
            </xsl:if>
        </xsl:variable>

        <!-- Is there a class string associated with this container? -->
        <xsl:variable name="sClass">
            <xsl:if test="class[text() != '']">
                <xsl:value-of select="normalize-space(class)"/>
            </xsl:if>
        </xsl:variable>

        <xsl:choose>
            <!-- If there's either an ID or a class associated with this container then wrap it -->
            <xsl:when test="$idSanitized != '' or $sClass != ''">
                <div>
                    <xsl:if test="$idSanitized != ''">
                        <xsl:attribute name="id">
                            <xsl:value-of select="$idSanitized"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$sClass != ''">
                        <xsl:attribute name="class">
                            <xsl:value-of select="$sClass"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates select="ablock"/>
                </div>
            </xsl:when>

            <!-- Otherwise just output the referenced content block(s) - no need for a DIV -->
            <xsl:otherwise>
                <xsl:apply-templates select="ablock"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
