<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xd"
    >

    <xd:doc type="stylesheet">
        <xd:short>Filter map XML data for easier processing
        can be processed by JavaScript to display a map.</xd:short>
        <xd:detail>
            <p>Inputs XML from a structured data definition from the CMS and
            writes a &lt;div&gt; element with the necessary attributes and classes
            in order to be processed after page load time via a JavaScript
            component.</p>
            <p>The finished HTML should look like:
                <pre>
                    &lt;div
                        data-map-src=&quot;some/path/to/map-data.xml&quot;
                        data-map-show=&quot;map-marker-id&quot;
                        data-map-type=&quot;hybrid&quot;
                        class=&quot;uas-widget-map&quot;&gt;
                        Loading map data...
                    &lt;/div&gt;
                </pre>
            </p>
            <p>The JavaScript component should hook on the "uas-widget-map" class
            in order to generate a list of elements to process.</p>
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
        Identity transform to cover vast majority of elements in data.
    </xd:doc>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:short>Template which matches map data definition and filters elements
            to remove unnecessary information.</xd:short>
        <xd:detail>
            <p>The CMS outputs much unnecessary data for linked-to assets.
            This template filters the image and icon elements in particular to
            just output the path (if present).</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="point/image | point/icon">
        <xsl:variable name="sUrl">
            <xsl:if test="@type='file'">
                <xsl:value-of select="path"/>
            </xsl:if>
        </xsl:variable>
        <xsl:element name="{name()}"><xsl:value-of select="$sUrl"/></xsl:element>
    </xsl:template>
</xsl:stylesheet>
