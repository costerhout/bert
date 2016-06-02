<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-02-25T15:17:09-09:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-06-01T23:11:18-08:00

Derived from previous work done by John French at the University of Alaska Southeast.
-->

<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:string="my:string"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes="string exsl"
                >
    <xsl:import href='../include/string.xslt'/>
    <xsl:strip-space elements="*"/>
    <xsl:output
                method='html'
                indent='yes'
                omit-xml-declaration='yes'
                />


    <xsl:variable name="rtfSocToIcon">
        <nodes>
            <node>
                <type>instagram</type>
                <icon>//uas.alaska.edu/contacts/images/icons/32/instagram.png</icon>
            </node>
            <node>
                <type>facebook</type>
                <icon>//uas.alaska.edu/contacts/images/icons/32/facebook.png</icon>
            </node>
            <node>
                <type>twitter</type>
                <icon>//uas.alaska.edu/contacts/images/icons/32/twitter.png</icon>
            </node>
            <node>
                <type>youtube</type>
                <icon>//uas.alaska.edu/contacts/images/icons/32/you-tube.png</icon>
            </node>
            <node>
                <type>rss</type>
                <icon>//uas.alaska.edu/contacts/images/icons/32/rss.png</icon>
            </node>
            <node>
                <type>uasonline</type>
                <icon>//uas.alaska.edu/contacts/images/icons/32/uasonline.png</icon>
            </node>
            <node>
                <type>email</type>
                <icon>//uas.alaska.edu/contacts/images/icons/32/email-digest.png</icon>
            </node>
            <node>
                <type>flickr</type>
                <icon>//uas.alaska.edu/contacts/images/icons/32/flickr.png</icon>
            </node>
            <node>
                <type>pinterest</type>
                <icon>//uas.alaska.edu/contacts/images/icons/32/pinterest.png</icon>
            </node>
        </nodes>
    </xsl:variable>

    <xsl:variable name="nsSocToIcon" select="exsl:node-set($rtfSocToIcon)"/>
    <xsl:key name="keySocToIcon" match="node" use="type"/>

    <!--
    Top-level template which will match a system-data-structure containing an address block
    with social media information
    -->
    <xsl:template match="/system-data-structure[.//system-data-structure[dept-address/soc]]">
        <div class="sidebar-social left-sidebar-social-icons">
            <xsl:apply-templates select=".//system-data-structure/dept-address/soc" mode="sidebar-social"/>
        </div>
    </xsl:template>

    <!-- Template for dumping out social media icons based on the type of social media -->
    <xsl:template match="soc" mode="sidebar-social" priority="-1">
        <!-- Save away soc-type for use within for-each -->
        <xsl:variable name="sSocType" select="soc-type"/>
        <xsl:variable name="urlIcon">
            <xsl:for-each select="$nsSocToIcon">
                <xsl:value-of select="key('keySocToIcon', string:lowerCase(string($sSocType)))/icon"/>
            </xsl:for-each>
        </xsl:variable>
        <a class="external-hide-icon" target="_blank">
            <xsl:attribute name="href">
                <xsl:value-of select="soc-url"/>
            </xsl:attribute>
            <img alt="Follow us on social media" src="{$urlIcon}"/>
        </a>
    </xsl:template>
</xsl:stylesheet>
