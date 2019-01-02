<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2017-09-06T10:28:53-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2018-11-21T14:36:32-09:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:hh="http://www.hannonhill.com/XSL/Functions"
    exclude-result-prefixes="exsl xd hh"
    >
    <xsl:import href="../bs2/bs2-default.xslt"/>
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="html"/>

    <xd:doc>
        Limit the number of events to display
    </xd:doc>
    <xsl:variable name="nEventLimit">6</xsl:variable>

    <xd:doc>
        Match the top level system-data-structure which should contain a tab data definition
    </xd:doc>
    <xsl:template match="/system-data-structure[tab]">
        <xsl:variable name="rtfTabs">
            <!-- Operate differently depending on which tab this is -->
            <xsl:for-each select="tab">
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <!-- Create the tab definition for the first tab (news) -->
                        <xsl:call-template name="generate-tab-news"/>
                    </xsl:when>
                    <xsl:when test="position() = 2">
                        <!-- Create the tab definition for the second tab (calendar / events) -->
                        <xsl:call-template name="generate-tab-calendar"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <!-- Invoke the Bootstrap code to create the tabs -->
        <xsl:for-each select="exsl:node-set($rtfTabs)">
            <xsl:call-template name="tab">
                <xsl:with-param name="sClassTabs" select="'nav-pills'"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        Helper template to generate the tab definition for the news tab
    </xd:doc>
    <xsl:template name="generate-tab-news">
        <xsl:variable name="sId" select="generate-id()" />
        <xsl:variable name="sLabel" select="tab_label" />
        <xsl:variable name="rtfTabContent">
            <!-- Generate an article element for each news item contained within -->
            <div class="newsbox">
                <xsl:apply-templates select=".//system-page/system-data-structure"/>

                <br class="clearfix"/>
                <div>
                    <a href="events/news.html">More News and Events &#187;</a>
                </div>
                <br class="clearfix"/>
            </div>
        </xsl:variable>

        <!-- Output the tab definition -->
        <tab>
            <tab_id><xsl:value-of select="$sId"/></tab_id>
            <tab_label><xsl:value-of select="tab_label"/></tab_label>
            <tab_content><xsl:copy-of select="$rtfTabContent"/></tab_content>
            <tab_active>true</tab_active>
        </tab>
    </xsl:template>

    <xd:doc>
        Helper template to generate the tab definition for the calendar tab
    </xd:doc>
    <xsl:template name="generate-tab-calendar">
        <xsl:variable name="sId" select="generate-id()" />
        <xsl:variable name="sLabel" select="tab_label" />
        <xsl:variable name="rtfTabContent">
            <xsl:copy-of select="tab_content/*"/>
        </xsl:variable>

        <!-- Output the tab definition -->
        <tab>
            <tab_id><xsl:value-of select="$sId"/></tab_id>
            <tab_label><xsl:value-of select="tab_label"/></tab_label>
            <tab_content><xsl:copy-of select="$rtfTabContent"/></tab_content>
            <tab_active>false</tab_active>
        </tab>
    </xsl:template>

    <xd:doc>
        Helper template to create an article item for each news item
    </xd:doc>
    <xsl:template match="system-page/system-data-structure[Title][Description]">
        <xsl:variable name="sAlt" select="normalize-space(image-label)" />
        <xsl:variable name="sTitle" select="Title" />

        <article>
            <xsl:if test="normalize-space(image/path) != '/'">
                <div class="pull-right">
                    <img class="img-rounded" src="{image/path}" alt="{$sAlt}"/>
                </div>
            </xsl:if>
            <h4>
                <xsl:choose>
                    <xsl:when test="normalize-space(Link) != ''">
                        <a href="{normalize-space(Link)}"><xsl:value-of select="$sTitle"/></a>
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="$sTitle"/></xsl:otherwise>
                </xsl:choose>
            </h4>
            <p>
               <xsl:value-of select="Description"/>
            </p>
            <div align="center" style="padding:0 30px;"><hr/></div>
        </article>
    </xsl:template>
</xsl:stylesheet>
