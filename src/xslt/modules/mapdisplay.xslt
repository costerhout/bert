<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:string="my:string"
    exclude-result-prefixes="xd string"
    >

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
                        class=&quot;mapdisplay&quot;&gt;
                        Loading map data...
                    &lt;/div&gt;
                </pre>
            </p>
            <p>The JavaScript component should hook on the "mapdisplay" class
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
        <xd:short>Template which matches map module definitions and calls the
        map named template to generate &lt;div&gt; elements with the necessary
        attributes for post processing.</xd:short>
        <xd:detail>
            See the 'mapdisplay' template for more detailed information.
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-data-structure[data-src and type and id]">
        <xsl:call-template name="mapdisplay">
            <xsl:with-param name="urlSrc" select="concat(data-src/path, '.xml')"/>
            <xsl:with-param name="sType" select="string:lowerCase(string(type))"/>
            <xsl:with-param name="idShow" select="normalize-space(id)"/>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:short>Named template which generates &lt;div&gt; elements with the
            necessary attributes for post processing.</xd:short>
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
        <xd:param name="urlSrc" type="string (url)">Full URL to source of map data in XML format</xd:param>
        <xd:param name="sType" type="string">Type of map to generate:
            hybrid (default), satellite, roadmap, terrain</xd:param>
        <xd:param name="idShow" type="string">ID of map element to show by default,
            overriding any configuration in the map data XML file</xd:param>
    </xd:doc>
    <xsl:template name="mapdisplay">
        <xsl:param name="urlSrc"/>
        <xsl:param name="sType" select="hybrid"/>
        <xsl:param name="idShow"/>
        <div class="mapdisplay" data-module="mapdisplay">
            <xsl:attribute name="data-url">
                <xsl:value-of select="$urlSrc"/>
            </xsl:attribute>
            <xsl:attribute name="data-type">
                <xsl:value-of select="$sType"/>
            </xsl:attribute>
            <xsl:if test="$idShow != ''">
                <xsl:attribute name="data-id-show">
                    <xsl:value-of select="$idShow"/>
                </xsl:attribute>
            </xsl:if>
            Loading map data...
        </div>
    </xsl:template>
</xsl:stylesheet>
