<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:string="my:string"
    exclude-result-prefixes="string xd"
    >

    <xsl:import href="../include/error.xslt"/>
    <xsl:import href="../include/string.xslt"/>
    <xd:doc type="stylesheet">
        <xd:short>Transform map widget data definition to a div on the page which
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
          method='html'
          indent='yes'
          omit-xml-declaration='yes'
          />

    <xd:doc>
        Top level stylesheet to match root element.
    </xd:doc>
    <xsl:template match="/">
        <xsl:apply-templates select="system-data-structure"/>
    </xsl:template>

    <xd:doc>
        <xd:short>Template which matches map widget definitions and generates
        &lt;div&gt; elements with the necessary attributes for post processing.</xd:short>
        <xd:detail>
            <p>Creates a &lt;div&gt; element with the following attributes:</p>
            <ul>
                <li>data-map-src: Source of map data (XML). Must reside on same server</li>
                <li>data-map-type: Type of map (satellite, hybrid, roadmap, terrain) to display</li>
                <li>data-map-show: Which map point should be shown on load. If not defined in the
                attribute, then the processing code should check for a point in the XML data
                which has a 'default' element containing a 'value' of 'Yes'</li>
            </ul>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-data-structure[data-src and type]">
        <div class="uas-widget-map">
            <xsl:attribute name="data-map-src">
                <xsl:value-of select="concat(data-src/path, '.xml')"/>
            </xsl:attribute>
            <xsl:attribute name="data-map-type">
                <xsl:value-of select="string:lowerCase(string(type))"/>
            </xsl:attribute>
            <xsl:if test="id[text()]">
                <xsl:attribute name="data-map-show">
                    <xsl:value-of select="normalize-space(id)"/>
                </xsl:attribute>
            </xsl:if>
            Loading map data...
        </div>
    </xsl:template>
</xsl:stylesheet>
