<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-06-14T11:16:53-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-08-15T14:03:39-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:string="my:string"
    xmlns:exsl="http://exslt.org/common"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="string exsl xd"
    >
    <xsl:import href='../include/string.xslt'/>
    <xsl:import href='../include/error.xslt'/>
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="xml" omit-xml-declaration="no"/>

    <xd:doc type="stylesheet">
        <xd:short>Take a decision tree map and output to a module div and corresponding data island on a web page.</xd:short>
        <xd:detail>
            <p>A decision tree is a set of steps that a user can follow - think of "Choose Your Own Adventure". This template
            creates two sets of elements on a web page:
        </p>
        <ol>
            <li>Module definition: a &lt;div&gt; that signals to BERT that a decision tree is present.</li>
            <li>Data island: the data for that particular instance of the decision tree.</li>
        </ol>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <xd:doc>
        <xd:short>Template which matches the decisiontree instance and begins processing.</xd:short>
        <xd:detail>
            <p>Two templates are called based on this instance to create the module definition and data island.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-data-structure[decisiontree]">
        <!-- Check for sane parameters:
            - valid class string
            - valid id
            - animation duration
        -->
        <xsl:variable name="rtfValidNodes">
            <nodedefs>
                <node>
                    <path>id</path>
                    <level>warning</level>
                    <regex>^(?:[a-zA-Z][\w:.-]*)?$</regex>
                    <flags></flags>
                    <message>Invalid HTML ID specified</message>
                </node>
                <node>
                    <path>class</path>
                    <level>warning</level>
                    <regex>^(?:-?[_a-zA-Z]+[_a-zA-Z0-9-]*\s*)*$</regex>
                    <flags></flags>
                    <message>Invalid CSS class string specified</message>
                </node>
                <node>
                    <path>animation-duration</path>
                    <level>warning</level>
                    <regex>^(?:[0-9]*)$</regex>
                    <flags></flags>
                    <message>Invalid duration specified</message>
                </node>
            </nodedefs>
        </xsl:variable>

        <xsl:call-template name="validate-nodes">
            <xsl:with-param name="nsValidDef" select="exsl:node-set($rtfValidNodes)"/>
            <xsl:with-param name="nodeParentNode" select="decisiontree"/>
        </xsl:call-template>

        <!-- Get unique string identifier -->
        <xsl:variable name="sIdIsland" select="string:generateId('decisiontree-')"/>

        <!-- Create data island -->
        <xsl:apply-templates select="decisiontree" mode="data-island">
            <xsl:with-param name="sId" select="$sIdIsland"/>
        </xsl:apply-templates>

        <!-- Create module definition -->
        <xsl:apply-templates select="decisiontree" mode="module">
            <xsl:with-param name="sIdIsland" select="$sIdIsland"/>
        </xsl:apply-templates>
    </xsl:template>

    <xd:doc>
        <xd:short>Create data island to contain the decision tree information.</xd:short>
        <xd:detail>
            <p>Creates &lt;script&gt; tag with type 'text/xml' in order to encapsulate data on the page.</p>
        </xd:detail>
        <xd:param name="sId" type="string">HTML ID to assign to this element</xd:param>
    </xd:doc>
    <xsl:template match="decisiontree" mode='data-island'>
        <xsl:param name="sId"/>
        <!-- Output all data into script tag using identity transform -->
        <script type="text/xml" id="{$sId}">
            <xsl:apply-templates select="." mode="decisiontree"/>
        </script>
    </xsl:template>

    <xd:doc>
        <xd:short>Create module definition to inform BERT that we would like a decisiontree</xd:short>
        <xd:detail>
            Creates &lt;div&gt; tag with attributes required to pass on to BERT's decisiontree module
        </xd:detail>
        <xd:param name="sIdIsland" type="string">HTML ID of data island to link to from this element</xd:param>
    </xd:doc>
    <xsl:template match="decisiontree" mode='module'>
        <xsl:param name="sIdIsland"/>
        <!-- Build the HTML ID of this element, if specified -->
        <xsl:variable name="idSanitized">
            <xsl:if test="normalize-space(id) != ''">
                <xsl:value-of select="string:sanitizeHtmlId(string(id))"/>
            </xsl:if>
        </xsl:variable>

        <!-- Build the class string based on the row-style-preselect and row-settings/class (if enable-row-settings is set) -->
        <xsl:variable name="rtfClass">
            <node>decisiontree</node>
            <xsl:if test="normalize-space(class) != ''">
                <node><xsl:value-of select="normalize-space(class)"/></node>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="sClass">
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns" select="exsl:node-set($rtfClass)/*"/>
                <xsl:with-param name="glue" select="' '"/>
            </xsl:call-template>
        </xsl:variable>

        <div data-module='decisiontree' data-defaults="{concat('#', $sIdIsland)}" class="{$sClass}">
            <!-- Output HTML id, if specified -->
            <xsl:if test="$idSanitized != ''">
                <xsl:attribute name="id"><xsl:value-of select="$idSanitized"/></xsl:attribute>
            </xsl:if>

            <!-- If duration is specified, output it -->
            <xsl:if test="number(animation-duration) = number(animation-duration)">
                <xsl:attribute name="data-animation-duration"><xsl:value-of select="animation-duration"/></xsl:attribute>
            </xsl:if>
        </div>
    </xsl:template>

    <xd:doc>
        <xd:short>Identity template to properly copy out elements, even those that contain children. Will be invoked via the xsl:copy-of elements in the story template.</xd:short>
    </xd:doc>

    <xsl:template match="@*|node()" mode="decisiontree">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="decisiontree"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        This will match more specifically than the identity template. Here we escape the description in CDATA section.
    </xd:doc>
    <xsl:template match="description" mode="decisiontree">
        <description>
            <xsl:call-template name="cdata-wrap"/>
        </description>
    </xsl:template>

    <xd:doc>
        Don't output anything for these elements - they're consumed as part of the module definition
    </xd:doc>
    <xsl:template match="id[parent::decisiontree] | class | animation-duration" mode="decisiontree">
    </xsl:template>
</xsl:stylesheet>
