<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:key="my:key-value-map"
                extension-element-prefixes="key"
                >
    <xsl:import href='../util/key-value-map.xslt'/>
    <xsl:strip-space elements="*"/>
    <xsl:output 
                method='html'
                indent='yes'
                omit-xml-declaration='yes'
                />

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
        <!-- Initialize map of social media type to icon -->
        <key:mapInit name='mapSocToIcon' casesensitive='false'>
            <entry name='instagram' value='//uas.alaska.edu/contacts/images/icons/32/instagram.png'/>
            <entry name='facebook' value='//uas.alaska.edu/contacts/images/icons/32/facebook.png'/>
            <entry name='twitter' value='//uas.alaska.edu/contacts/images/icons/32/twitter.png'/>
            <entry name='youtube' value='//uas.alaska.edu/contacts/images/icons/32/you-tube.png'/>
            <entry name='rss' value='//uas.alaska.edu/contacts/images/icons/32/rss.png'/>
            <entry name='uasonline' value='//uas.alaska.edu/contacts/images/icons/32/uasonline.png'/>
            <entry name='email' value='//uas.alaska.edu/contacts/images/icons/32/email-digest.png'/>
            <entry name='flickr' value='//uas.alaska.edu/contacts/images/icons/32/flickr.png'/>
            <entry name='pinterest' value='//uas.alaska.edu/contacts/images/icons/32/pinterest.png'/>
        </key:mapInit>
        <xsl:variable name="urlIcon" select="key:mapValue('mapSocToIcon', string(soc-type))"/>
        <a class="external-hide-icon" target="_blank">
            <xsl:attribute name="href">
                <xsl:value-of select="soc-url"/>
            </xsl:attribute>
            <img alt="Follow us on social media" src="{$urlIcon}"/>
        </a>
    </xsl:template>
</xsl:stylesheet>