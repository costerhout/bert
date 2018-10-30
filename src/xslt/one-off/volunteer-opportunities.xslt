<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2015-08-25T13:40:49-08:00
@Email:  ctosterhout@alaska.edu
@Project: Oneoff
@Last modified by:   ctosterhout
@Last modified time: 2018-10-30T13:28:18-08:00
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="string xd" version="1.0" xmlns:exsl="http://exslt.org/common" xmlns:string="my:string" xmlns:xd="http://www.pnp-software.com/XSLTdoc">

    <xsl:import href="../include/string.xslt"/>
    <xsl:import href="../bs2/bs2-default.xslt"/>
    <xd:doc type="stylesheet">
        <xd:short>Convert system-index-block of "internship" content blocks to a table of Volunteer opportunities.  Each item opens up a modal window.</xd:short>
        <xd:detail>
            <p></p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctoterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>

    <xd:doc>
        Top level matching template.
    </xd:doc>
    <xsl:template match="/system-index-block">
        <xsl:choose>
            <!-- Check for volunteer opportunities to list -->
            <xsl:when test="count(.//system-data-structure[@definition-path='internship']/opening) &gt; 0">
                <!-- We have openings! Build table -->
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Organization</th>
                            <th>Opportunity</th>
                            <th>Closing Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Generate a separate row for each opening in the table -->
                        <xsl:apply-templates mode="table" select=".//system-data-structure[@definition-path='internship']/opening"/>
                    </tbody>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <div class="well">
                    No opportunities currently listed. Please check back soon.
                </div>
            </xsl:otherwise>
        </xsl:choose>

        <!-- Generate the modal windows for each opening -->
        <xsl:apply-templates mode="modal" select=".//system-data-structure[@definition-path='internship']/opening"/>
    </xsl:template>

    <xd:doc>
        Generate the table rows, one per opening
    </xd:doc>
    <xsl:template match="opening" mode="table">
        <!-- Generate the different row/cell data -->
        <xsl:variable name="sAlt" select="concat('Open up an information box to see more about the position: ', job-title)"/>
        <tr>
            <td><xsl:value-of select="company"/></td>
            <td>
                <a alt="{$sAlt}" data-toggle="modal" href="#{generate-id()}">
                    <xsl:value-of select="job-title"/>
                </a>
            </td>
            <td><xsl:value-of select="closing-date"/></td>
        </tr>
    </xsl:template>

    <xd:doc>
        Generate the modal windows, one per opening
    </xd:doc>
    <xsl:template match="opening" mode="modal">
        <!-- Generate the content for the modal -->
        <xsl:variable name="rtfContent">
            <h4>Opportunity Description</h4>
            <xsl:call-template name="paragraph-wrap">
                <xsl:with-param name="nodeToWrap" select="summary"/>
            </xsl:call-template>
            <xsl:if test="requirements != ''">
                <h4>Requirements</h4>
                <p>
                    <xsl:value-of select="requirements"/>
                </p>
            </xsl:if>
            <h4>Contact Information</h4>
            <ul class="unstyled">
                <xsl:if test="contact-person != ''">
                    <li>Name: <xsl:value-of select="contact-person"/></li>
                </xsl:if>
                <li><xsl:value-of select="contact-phone"/></li>
            </ul>
        </xsl:variable>
        <!-- Generate the different cell data -->
        <xsl:call-template name="modal">
            <xsl:with-param name="id" select="generate-id()"/>
            <xsl:with-param name="title" select="concat(company, ': ', job-title)"/>
            <xsl:with-param name="content" select="exsl:node-set($rtfContent)"/>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>