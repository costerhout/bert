<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-03-15T16:21:48-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-06-01T23:12:25-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->


<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:exsl="http://exslt.org/common"
    xmlns:string="my:string"
    exclude-result-prefixes="exsl xd string"
    version="1.0">
    <xsl:import href="../include/string.xslt"/>
    <xsl:import href="ablock-content.xslt"/>

    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>

    <xd:doc type="stylesheet">
        <xd:short>Bootstrap 3 tab creation stylesheet</xd:short>
        <xd:detail>
            <p>This stylesheet is composed of two sets of templates: the
                first is the templates that match the data definitions within
                the bs3 folder of the CMS, and the second set are named templates
                which are called by the matching templates (and can be called
                by any stylesheet which includes this one).</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <!-- Top level block pattern to match the "tab" data definition -->
    <xd:doc>
        <xd:short>Top level block pattern to match the "tab" data definition</xd:short>
        <xd:detail>
            <p>This template matches tab data definitions and calls lower level
                templates to generate Bootstrap 3 tabs</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-data-structure[tab]">
        <xsl:if test="count(tab) &gt; 0">
            <!--
            Generate tab set structure to match the bs3-tabset specification:
            <tabset>
                <tab>
                    <id></id>
                    <label></label>
                    <content></content>
                </tab>
            </tabset>
            -->
            <xsl:variable name="rtfTabSet">
                <tabset>
                    <xsl:for-each select="tab">
                        <tab>
                            <id>
                                <xsl:choose>
                                    <xsl:when test="id[text()]">
                                        <xsl:value-of select="string:sanitizeHtmlId(string(id))"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="generate-id()"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </id>
                            <label><xsl:value-of select="label"/></label>
                            <content>
                                <xsl:apply-templates select="content" mode="paragraph-wrap"/>
                                <xsl:apply-templates select="ablock"/>
                            </content>
                        </tab>
                    </xsl:for-each>
                </tabset>
            </xsl:variable>

            <!-- Create Bootstrap 3 tab set -->
            <xsl:call-template name="bs3-tabset">
                <xsl:with-param name="nsTabSet" select="exsl:node-set($rtfTabSet)"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:short>Generate set of Bootstrap 3 tabs based on input tab defintions
            in node-set form</xd:short>
        <xd:detail>
            <p>A tab will be generated for each node in the input node-set with the
                following format:</p>
            &lt;tabset&gt;<br/>
                &lt;tab&gt;<br/>
                    &lt;id&gt;SomeID&lt;/id&gt;<br/>
                    &lt;label&gt;Some tab&lt;/label&gt;<br/>
                    &lt;content&gt;Blah blah blah&lt;/content&gt;<br/>
                &lt;/tab&gt;<br/>
            &lt;/tabset&gt;
        </xd:detail>
        <xd:param name="nsTabSet" type="node-set">Set of tab definitions</xd:param>
    </xd:doc>
    <xsl:template name="bs3-tabset">
        <xsl:param name="nsTabSet"/>

        <!-- Set context to the $nsTabSet tabset -->
        <xsl:for-each select="$nsTabSet/tabset">
            <div class="tabbable">
                <div class="tab-content">
                    <!-- Generate table of contents -->
                    <ul>
                        <xsl:attribute name="class">nav nav-tabs</xsl:attribute>
                        <xsl:apply-templates select="tab" mode="bs3-tab-toc"/>
                    </ul>

                    <!-- Generate tab body sections -->
                    <xsl:apply-templates select="tab" mode="bs3-tab-body"/>
                </div>
            </div>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:short>Generate the tab navigation area (the table of contents)</xd:short>
        <xd:detail>
            <p>This match template will generate a table of contents list item
            based on the matching tab structure.  See notes on bs3-tabset for more details.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="tab" mode="bs3-tab-toc">
        <!-- Each tab gets a <li> element with a link that Bootstrap picks up on -->
        <li>
            <xsl:if test="position() = 1">
                <xsl:attribute name="class">active</xsl:attribute>
            </xsl:if>
            <a>
                <xsl:attribute name="href">#<xsl:value-of select="id"/></xsl:attribute>
                <xsl:attribute name="data-toggle">tab</xsl:attribute>
                <xsl:value-of select="label"/>
            </a>
        </li>
    </xsl:template>

    <xd:doc>
        <xd:short>For each tab, generate the div with the content inside</xd:short>
        <xd:detail><p>This match template will generate the tab body based on the
            matching tab structure.  See notes on bs3-tabset for more details.</p></xd:detail>
    </xd:doc>
    <xsl:template match="tab" mode="bs3-tab-body">
        <div>
            <xsl:attribute name="id"><xsl:value-of select="id"/></xsl:attribute>

            <!-- Set the class of the tab. If sub-classed as 'active', then this
            tab will be shown first (currently this will be set only on the
            first tab in the set) -->
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="position() = 1">tab-pane active</xsl:when>
                    <xsl:otherwise>tab-pane</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>

            <!-- Dump out the contents of the tab -->
            <xsl:copy-of select="content/*"/>
        </div>
    </xsl:template>
</xsl:stylesheet>
