<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout> based on work initially performed by John French
@Date:   2018-04-02T13:24:30-08:00
@Email:  ctosterhout@alaska.edu
@Last modified by:   ctosterhout
@Last modified time: 2018-04-02T13:51:05-08:00
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xd exsl"
                version="1.0"
                xmlns:exsl="http://exslt.org/common"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc">
    <xsl:import href="../include/pathfilter.xslt" />

    <xsl:output method="html" />

    <xsl:template match="/">
        <xsl:apply-templates select="system-index-block" />
    </xsl:template>

    <xsl:template match="system-index-block">
        <table class="table-striped table-bordered table-autosort:0"
               id="tablePrograms">
            <thead>
                <tr>
                    <th>Area of Study</th>
                    <th class="hidden-phone">Location</th>
                    <th style="display: none">Search fields</th>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates select="descendant-or-self::system-page">
                    <xsl:sort select="display-name" /></xsl:apply-templates>
            </tbody>
            <tfoot>
                <tr>
                    <th>Area of Study</th>
                    <th class="hidden-phone">Location</th>
                    <th style="display: none">Search fields</th>
                </tr>
            </tfoot>
        </table>
    </xsl:template>

    <xsl:template match="system-page">
        <xsl:variable name="sUrl">
            <xsl:call-template name="pathfilter">
                <xsl:with-param name="path"
                                select="path" />
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="sTitle">
            <xsl:choose>
                <xsl:when test="summary">
                    <xsl:value-of select="summary" />
                </xsl:when>
                <xsl:when test="description">
                    <xsl:value-of select="summary" />
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="sMeta"
                      select="keywords" />

        <xsl:variable name="rtfLocations">
            <xsl:for-each select="dynamic-metadata[name= 'Campus']/value">
                <xsl:sort select="." />
                <node>
                    <xsl:choose>
                        <xsl:when test=". = 'Distance'">E-Learning</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="." /></xsl:otherwise>
                    </xsl:choose>
                </node>
            </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="sLocations">
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns"
                                select="exsl:node-set($rtfLocations)/node" />
            </xsl:call-template>
        </xsl:variable>

        <xsl:if test="name != 'index'">
            <tr>
                <td>
                    <a href="{$sUrl}">
                        <xsl:if test="normalize-space($sTitle != '')">
                            <xsl:attribute name="title">
                                <xsl:value-of select="summary" />
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="display-name" />
                    </a>
                </td>

                <td class="hidden-phone">
                    <xsl:value-of select="$sLocations" />
                </td>

                <td style="display: none">
                    <xsl:value-of select="$sMeta" />
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>