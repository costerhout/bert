<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2018-11-21T13:34:53-09:00
@Email:  ctosterhout@alaska.edu
@Last modified by:   ctosterhout
@Last modified time: 2018-11-21T14:07:12-09:00
@License: Released under MIT License. Copyright 2017 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:string="my:string"
                exclude-result-prefixes="string xd">

    <xsl:import href="../bs2/bs2-default.xslt" />
    <xsl:include href="../include/pathfilter.xslt" />
    
    <xd:doc type="stylesheet">
        <xd:short></xd:short>
        <xd:detail>
            <p>Display MOU/MOA in table form</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2018</xd:copyright>
    </xd:doc>

    <xsl:strip-space elements="*"/>
    <xsl:output
          method='html'
          indent='yes'
          omit-xml-declaration='yes'
          />

    <xd:doc>
        Matching template for a specific pattern of MOU blocks which map information to files.
    </xd:doc>
    
    <xsl:template match="system-index-block[.//system-data-structure[mou]]">
        <table class="table table-bordered table-striped table-autosort:0" summary="List of MOU and MOA documents" style="font-size: 75%">
            <thead>
                <tr>
                    <th scope="col">Partners</th>
                    <th scope="col">Purpose</th>
                    <th scope="col">Inception</th>
                    <th scope="col">Expiration</th>
                    <th scope="col">Effective Fiscal Year</th>
                    <th scope="col">AK Native Specific?</th>
                    <th scope="col">Document</th>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates select=".//mou"/>
            </tbody>
        </table>        
    </xsl:template>
    
    <xsl:template match="mou">
        <xsl:variable name="sUrl">
            <xsl:call-template name="pathfilter">
                <xsl:with-param name="path" select="doc-url/path" />
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="sTitle">
            <xsl:choose>
                <xsl:when test="normalize-space(doc-title) != ''">
                    <xsl:value-of select="normalize-space(doc-title)"/>
                </xsl:when>
                <xsl:when test="normalize-space(doc-url/display-name) != ''">
                    <xsl:value-of select="normalize-space(doc-url/display-name)"/>
                </xsl:when>
                <xsl:when test="normalize-space(doc-url/title) != ''">
                    <xsl:value-of select="normalize-space(doc-url/title)"/>
                </xsl:when>
                <xsl:otherwise>Document link</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="sNativeSpecific">
            <xsl:choose>
                <xsl:when test="aknative-specific/value = 'Yes'">Yes</xsl:when>
                <xsl:otherwise>No</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <tr>
            <td>
                <xsl:value-of select="partners"/>
            </td>
            <td>
                <xsl:value-of select="purpose"/>
            </td>
            <td>
                <xsl:value-of select="inception_date"/>
            </td>
            <td>
                <xsl:value-of select="expiration_date"/>
            </td>
            <td>
                <xsl:value-of select="effective-fy"/>
            </td>
            <td>
                <xsl:value-of select="$sNativeSpecific"/>
            </td>
            <td>
                <a href="{$sUrl}">
                    <xsl:value-of select="$sTitle"/>
                </a>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>