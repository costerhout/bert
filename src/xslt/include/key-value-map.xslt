<?xml version="1.0" encoding="UTF-8"?>
<!--
    key-value-map.xslt

    Create key-value map in memory during template processing and then retrieve those values
    later on.

    Elements:
        mapInit - Initialize a named map with a set of values associated with names (key) and set
                    configuration parameters via attributes for map operations. At this time there's
                    only one attribute recognized: 'casesensitive', with a default of 'true'.
        
        The mapInit element must have one or more children with at least two attributes, 
            'name', and 'value'.

    Functions:
        mapValue - Retrieve a value from the named map given the name of the desired value.
                    Returns an empty string upon failure to find either the map or the value.

    Sample usage:

    **** Input XML file ****

    <buildings>
        <building>
            <address>123 Anystreet, Berlin CA</address>
            <owner>Pig 1</owner>
        </building>
        <building>
            <address>456 Yourstreet, Youngstown OH</address>
            <owner>pig 2</owner>
        </building>
        <building>
            <address>789 Little Pig Alley, Wolfsburg ON</address>
            <owner>PiG 3</owner>
        </building>
    </buildings>

    **** XSLT ****

    <?xml version="1.0" encoding="UTF-8"?>
    <xsl:stylesheet
                    version="1.0"
                    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    xmlns:key="my:key-value-map"
                    extension-element-prefixes="key"
                    >
        <xsl:include href='util/key-value-map.xslt'/>
        <xsl:variable name="nl"><xsl:text>&#xa;</xsl:text></xsl:variable>
        <xsl:variable name="sep"><xsl:text>, </xsl:text></xsl:variable>
        <xsl:strip-space elements="*"/>
        <xsl:output 
                    method="html"
                    indent="yes"
                    omit-xml-declaration="yes"
                    />   

        <xsl:template match="/buildings">
            <key:mapInit name='mapOwnerToMaterials' casesensitive='false'>
                <entry name='Pig 1' value='Straw'/>
                <entry name='Pig 2' value='Wood'/>
                <entry name='Pig 3' value='Brick'/>
            </key:mapInit>

            <xsl:apply-templates select="building"/>
        </xsl:template>

        <xsl:template match="building">        
            <xsl:param name='material' select="key:mapValue('mapOwnerToMaterials', string(owner))"/>
            <xsl:text>Building at address: </xsl:text><xsl:value-of select="address"/><xsl:value-of select='$nl'/>
            <xsl:text>Owned by: </xsl:text><xsl:value-of select="owner"/><xsl:value-of select='$nl'/>
            <xsl:if test="$material != ''">
                <xsl:text>Probably made of: </xsl:text><xsl:value-of select="$material"/><xsl:value-of select='$nl'/>
           </xsl:if>
        </xsl:template>
    </xsl:stylesheet>   

    **** Output ****

    Building at address: 123 Anystreet, Berlin CA
    Owned by: Pig 1
    Probably made of: Straw
    Building at address: 456 Yourstreet, Youngstown OH
    Owned by: pig 2
    Probably made of: Wood
    Building at address: 789 Little Pig Alley, Wolfsburg ON
    Owned by: PiG 3
    Probably made of: Brick
-->

<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:my="my:key-value-map"
                xmlns:xalan="http://xml.apache.org/xalan"
                exclude-result-prefixes="my xalan"
                >

    <xalan:component functions="mapValue" elements="mapInit" prefix="my">
        <xalan:script lang="javascript">
            <![CDATA[
            // Hash of hashes.
            var hEntries = {};

            // Create the named key -> value array
            var mapInit = function(ctx, elem) {
                var a_attr, attr;
                var i, o;

                // Which map name should we operate on?
                var s_map = String(elem.getAttribute('name'));

                // Initilize the node as the first child of the mapInit node
                var node = elem.getFirstChild();

                /* 
                Initialize hash of array. Each object contains these members:
                    array: array of objects, each one with a "name: value" pair
                    casesensitive: boolean, whether or not searches should be done in a case sensitive manner
                */

                hEntries[s_map] = {};
                hEntries[s_map].array = [];
                hEntries[s_map].casesensitive = !(String(elem.getAttribute('casesensitive')) === 'false');

                // Each node is of type "entry" with two expected attributes, name and value
                while (node) {
                    // Get NamedNodeList of attributes and initialize object that we'll push
                    a_attr = node.getAttributes();
                    o = {};

                    // Iterate through all the attributes and add them to the temp object
                    for (i = 0; i < a_attr.getLength(); i++) {
                        attr = a_attr.item(i);
                        o[String(attr.getNodeName())] = String(attr.getNodeValue());
                    }

                    // Push temp object onto the map and set up next iteration
                    hEntries[s_map].array.push(o);                    
                    node = node.getNextSibling();
                }

                return null;
            }

            var mapValue = function(s_map, needle) {
                // Check to see if the map exists, and if not, fail gracefully with empty string
                if (typeof hEntries[s_map] === 'undefined') {
                    return '';
                }

                // Iterate on all map entries, creating array of items w/ matching names
                var a = hEntries[s_map].array.filter(function(o) {
                    if (!hEntries[s_map].casesensitive) {
                        // Perform the search in a case insensitive manner by making everything upper case
                        return o['name'].toUpperCase() === needle.toUpperCase();
                    } else {
                        return o['name'] === needle;
                    }
                });

                // Return the first value found or the empty string
                return (a.length > 0) ? a[0]['value'] : '';
            }
            ]]>
        </xalan:script>
    </xalan:component>
</xsl:stylesheet>