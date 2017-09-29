<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2017-09-27T13:12:48-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-09-28T16:27:30-08:00
@License: Released under MIT License. Copyright 2017 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:exsl="http://exslt.org/common"
    xmlns:string="my:string"
    exclude-result-prefixes="exsl xd string"
    version="1.0">
    <xsl:import href="../include/string.xslt"/>
    <xsl:import href="../include/error.xslt"/>

    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>

    <xd:doc type="stylesheet">
        <xd:short>Bootstrap 3 dropdown creation stylesheet</xd:short>
        <xd:detail>
            <p>This stylesheet is composed of two sets of templates: the
                first is the templates that match the data definitions within
                the bs3 folder of the CMS, and the second set are named templates
                which are called by the matching templates (and can be called
                by any stylesheet which includes this one).</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2017</xd:copyright>
    </xd:doc>

    <!-- Wrap the entire structure in a div.dropdown element -->
    <xd:doc>
        <xd:short>dropdown</xd:short>
        <xd:detail>
            <p>Named template to create a Bootstrap 3 dropdown widget based on the passed in set of dropdown descriptors.</p>
            <p>The dropdown descriptor node-set should be a set of one or more of these structures:</p>
            &lt;dropdown&gt;
                &lt;class&gt;
                    Optional class string to apply to this dropdown section
                &lt;/class&gt;
                &lt;title&gt;
                    This is the title of the dropdown section.
                &lt;/title&gt;
                &lt;body&gt;
                    &lt;p&gt;This may contain any valid HTML and will be used as the body of the dropdown&lt;/p&gt;
                &lt;/body&gt;
                &lt;open&gt;false&lt;/open&gt;
            &lt;/dropdown&gt;
        </xd:detail>
        <xd:param name="." type="node-set">Set of dropdown-item nodes to display</xd:param>
    </xd:doc>
    <xsl:template name="dropdown">
        <!-- Generate a unique ID for use in the dropdown top-level div -->
        <xsl:variable name="idPanelGroup" select="string:generateId('panelgroup-')"/>

        <xsl:if test="count(dropdown) &gt; 0">
            <div class="panel-group" id="{$idPanelGroup}" role="tablist" aria-multiselectable="true">
                <xsl:apply-templates select="dropdown" mode="bs3">
                    <xsl:with-param name="idPanelGroup" select="$idPanelGroup"/>
                </xsl:apply-templates>
            </div>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        Create the dropdown which consists of the header (with link) and the body.
        <xd:param name="idPanelGroup" type="string">Panel group HTML id to allow for automatic closing of panels when another panel is opened.</xd:param>
    </xd:doc>
    <xsl:template match="dropdown" mode="bs3">
        <xsl:param name="idPanelGroup"/>

        <xsl:variable name="idPanelHeading">
            <xsl:value-of select="string:generateId('panelheading-')"/>
        </xsl:variable>

        <xsl:variable name="idPanelBody">
            <xsl:choose>
                <xsl:when test="id">
                    <xsl:value-of select="id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="string:generateId('panelbody-')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Build the class string based on the open / close value -->
        <xsl:variable name="rtfClassBody">
            <node>panel-collapse</node>
            <node>collapse</node>
            <xsl:choose>
                <xsl:when test="open='true'">
                    <node>in</node>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="sClassBody">
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns" select="exsl:node-set($rtfClassBody)/*"/>
                <xsl:with-param name="glue" select="' '"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Each div.dropdown-group consists of a div.dropdown-heading followed
            by a div.dropdown-inner -->
        <div class="panel panel-default">
            <!-- Create the heading -->
            <div class="panel-heading" id="{$idPanelHeading}">
                <h2 class="panel-title">
                    <a role="button" data-toggle="collapse" data-parent="{concat('#', $idPanelGroup)}" href="{concat('#', $idPanelBody)}">
                        <xsl:value-of select="title"/>
                    </a>
                </h2>
            </div>

            <!-- Now create the body of the dropdown -->
            <div class="{$sClassBody}" id="{$idPanelBody}" role="tabpanel" aria-labeledby="{$idPanelHeading}">
                <div class="panel-body">
                    <xsl:call-template name="paragraph-wrap">
                        <xsl:with-param name="nodeToWrap" select="body"/>
                    </xsl:call-template>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>
