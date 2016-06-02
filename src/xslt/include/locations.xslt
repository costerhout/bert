<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-04-01T09:03:51-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-06-01T23:13:13-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:exsl="http://exslt.org/common"
    exclude-result-prefixes="xd"
    >

    <xd:doc type="stylesheet">
        <xd:short>Defines location node-set to map CMS address information
        to shortcodes used by Google maps.</xd:short>
        <xd:detail>
            <p>The 'Personnel' and 'Address' data definitions in the CMS
            use long strings to denote location information. This stylesheet
            defines a node-set and key pair to map the long building string
            to a short code for use in our Google map implementation.</p>
            <p>Each location XML representation:</p>
            <pre>
                &lt;location&gt;
                    &lt;key&gt;Some long location code used by the CMS&lt;/key&gt;
                    &lt;shortcode&gt;smallstring&lt;/shortcode&gt;
                &lt;/location&gt;
            </pre>
            <p>Useful things exported by this stylesheet:</p>
            <ul>
                <li>node-set: nsLocations</li>
                <li>key: keyLocationToShortCode</li>
                <li>string: sUrlBase</li>
                <li>string: sUrlLocationData</li>
            </ul>
        </xd:detail>
        <xd:author>Colin Osterhout (ctoterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <xsl:strip-space elements="*"/>
    <xsl:output
          method='html'
          indent='yes'
          omit-xml-declaration='yes'
          />
    <xd:doc>
        Set this to be the base URL of the UAS website for image URL
        resolution.  If set, remember to enable proper header on the server to account for CORS
    </xd:doc>
    <xsl:param name="sUrlBase"></xsl:param>

    <xd:doc>
        Set this to be the default map data XML file location.
    </xd:doc>
    <xsl:param name="sUrlLocationData" select="concat($sUrlBase, '/dir/maps/building-locator/buildings.xml')"/>

    <xsl:variable name="rtfLocations">
      <locations>
          <location>
              <key>Juneau Campus: Anderson Bldg</key>
              <shortcode>anderson</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Banfield Hall</key>
              <shortcode>housing</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Bookstore/Administrative Services</key>
              <shortcode>business-services</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Egan Library</key>
              <shortcode>egan</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Egan Lecture Hall (112)</key>
              <shortcode>egan-wing</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Egan Classroom Wing</key>
              <shortcode>egan-wing</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Facilities Services</key>
              <shortcode>facilities</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Fireweed Room</key>
              <shortcode>mourant</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Glacier View Room (221)</key>
              <shortcode>egan-wing</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Hendrickson Annex</key>
              <shortcode>hendrickson-annex</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Hendrickson Bldg</key>
              <shortcode>hendrickson</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Mourant Bldg</key>
              <shortcode>mourant</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Mourant Courtyard</key>
              <shortcode>mourant</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Novatney Bldg</key>
              <shortcode>novatney</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Noyes Pavilion</key>
              <shortcode>noyes</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Recreation Center</key>
              <shortcode>rec</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Student Housing</key>
              <shortcode>housing</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Soboleff Annex</key>
              <shortcode>soboleff-annex</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Soboleff Bldg</key>
              <shortcode>soboleff</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Spikes Cafe</key>
              <shortcode>egan-wing</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Technical Education Center</key>
              <shortcode>juneau-tec</shortcode>
          </location>
          <location>
              <key>Juneau Campus: Whitehead Bldg</key>
              <shortcode>whitehead</shortcode>
          </location>
          <location>
              <key>Sitka Campus</key>
              <shortcode>sitka-campus</shortcode>
          </location>
          <location>
              <key>Ketchikan Campus: Ziegler Bldg</key>
              <shortcode>ziegler</shortcode>
          </location>
          <location>
              <key>Ketchikan Campus: Paul Bldg</key>
              <shortcode>paul</shortcode>
          </location>
          <location>
              <key>Ketchikan Campus: Ketchikan Regional Maritime and Career Center</key>
              <shortcode>robertson</shortcode>
          </location>
      </locations>
    </xsl:variable>
    <xsl:variable name="nsLocations" select="exsl:node-set($rtfLocations)"/>
    <xsl:key name="keyLocationToShortCode" match="location" use="key"/>
</xsl:stylesheet>
