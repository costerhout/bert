<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-03-30T08:32:55-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-06-01T23:12:22-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->


<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:exsl="http://exslt.org/common"
    xmlns:string="my:string"
    exclude-result-prefixes="exsl xd string"
    >

    <xsl:import href="../include/error.xslt"/>
    <xsl:import href="../include/string.xslt"/>
    <xd:doc type="stylesheet">
        <xd:short>Bootstrap 3 menu creation stylesheet</xd:short>
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

    <xsl:strip-space elements="*"/>
    <xsl:output
          method='html'
          indent='yes'
          omit-xml-declaration='yes'
          />

    <!-- Matching templates -->
    <!-- Create menu to match index block of pages / folders -->
    <xsl:template match="system-data-structure[menu]">
        <nav class="menu-advanced">
            <!-- Top level menu. Display label as menu title -->
            <h2 class="menu-title">
                <xsl:value-of select="menu/label"/>
            </h2>
            <xsl:apply-templates select="menu" mode="bs3-menu"/>
        </nav>
    </xsl:template>

    <!-- Lower level templates -->
    <xd:doc>
        <xd:short>Low level match template to create menu. Tabs, pills,
            stacked pills, navbar are all supported.</xd:short>
        <xd:detail>
            <p>A menu will be created for each node in the node-set with the
            following format:</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="menu" mode="bs3-menu">
        <!-- Drill down into collection of menu items -->
        <!-- Handle index blocks - will have to build node-set for each
        page and folder -->
        <!-- Handle XML Sitemap by inserting necessary data into the result tree
        so the downstream Javascript handler can build the menu -->
        <xsl:variable name="rtfValidDef">
            <nodedefs>
                <node>
                    <path>type</path>
                    <level>error</level>
                    <regex>^(?:pill|pill-stacked|tabs)$</regex>
                    <flags></flags>
                    <message>Invalid type specified</message>
                </node>
                <node>
                    <path>id</path>
                    <level>warning</level>
                    <regex>^(?:[a-zA-Z][\w:.-]*)?$</regex>
                    <flags></flags>
                    <message>Invalid HTML ID specified</message>
                </node>
            </nodedefs>
        </xsl:variable>
        <xsl:call-template name="validate-nodes">
            <xsl:with-param name="nsValidDef" select="exsl:node-set($rtfValidDef)"/>
        </xsl:call-template>

        <xsl:variable name="sClassMenu">
            <!-- Determine if we're a submenu - if so then don't apply the nav class -->
            <xsl:choose>
                <xsl:when test="not(ancestor::menu)">
                    <xsl:choose>
                        <xsl:when test="type = 'pill'">
                            nav-pills
                        </xsl:when>
                        <xsl:when test="type = 'pill-stacked'">
                            nav-tabs nav-stacked
                        </xsl:when>
                        <xsl:when test="type = 'tabs'">
                            nav-tabs
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!-- Only apply the justified class for certain menu types and not for submenus -->
        <xsl:variable name="sClassJustified">
            <xsl:choose>
                <xsl:when test="not(ancestor::menu) and (type='pill' or type='tabs') and (justified/value = 'Yes')">
                    nav-justified
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!-- Generate a clean class string of all the various components by creating an RTF,
        turning that into a node-set, and then concatenating them together with space
        in between -->
        <xsl:variable name="rtfClass">
            <node>nav</node>
            <node><xsl:value-of select="normalize-space($sClassMenu)"/></node>
            <node><xsl:value-of select="normalize-space($sClassJustified)"/></node>
            <node><xsl:value-of select="normalize-space(class)"/></node>
        </xsl:variable>

        <xsl:variable name="sClass">
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns" select="exsl:node-set($rtfClass)/node"/>
                <xsl:with-param name="glue" select="' '"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Create the list of menu items -->
        <div class="panel-group">
            <xsl:attribute name="id">
                <xsl:choose>
                    <xsl:when test="id[text()]">
                        <xsl:value-of select="string:sanitizeHtmlId(string(id))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="generate-id()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="menuitem" mode="bs3-menuitem"/>
        </div>
    </xsl:template>

    <xd:doc>
        <xd:short>Match template to create individual menu items</xd:short>
        <xd:detail>
            <p>A menu item will be created for each node in the input node-set with
            the following format:</p>
        </xd:detail>
        <xd:param name="menuitem" type="node-set">Set of menu item definitions</xd:param>
    </xd:doc>
    <xsl:template match="menuitem" mode="bs3-menuitem">
        <!-- Sanity check on the parameters.
        If this is a submenu item then make sure referenced block is really a
        menu block -->
        <!-- If this is an external link, then get the label from the field -->
        <!-- If this is an internal link, then get the label from the display name
        field of the referenced asset -->
        <!-- If this is a submenu, then get the label from the referenced block's label
        field. -->
        <xsl:variable name="rtfValidDef">
            <nodedefs>
                <node>
                    <path>type</path>
                    <level>error</level>
                    <regex>^(?:Internal|External|Submenu)$</regex>
                    <flags></flags>
                    <message>Invalid type specified</message>
                </node>
                <node>
                    <path>id</path>
                    <level>warning</level>
                    <regex>^(?:[a-zA-Z][\w:.-]*)?$</regex>
                    <flags></flags>
                    <message>Invalid HTML ID specified</message>
                </node>
                <node>
                    <path>link-external</path>
                    <regex>^(?:http[s]?:\/\/.*)?$</regex>
                    <flags>i</flags>
                    <level>error</level>
                    <message>Invalid external link specified</message>
                </node>
            </nodedefs>
        </xsl:variable>
        <xsl:call-template name="validate-nodes">
            <xsl:with-param name="nsValidDef" select="exsl:node-set($rtfValidDef)"/>
        </xsl:call-template>

        <xsl:variable name="sLabel">
            <xsl:choose>
                <xsl:when test="type='Submenu'">
                    <xsl:value-of select="normalize-space(.//menu/label)"/><xsl:value-of select="$nbsp"/><span class="caret"></span>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(label)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sIdSubmenu">
            <xsl:if test="type='Submenu'">
                <xsl:choose>
                    <xsl:when test=".//menu/id[text()]">
                        <xsl:value-of select="normalize-space(.//menu/id)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="generate-id(.//menu)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="sUrlSubmenu">
            <xsl:if test="type='Submenu'">
                <xsl:value-of select="concat('#', $sIdSubmenu)"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="sUrl">
            <xsl:choose>
                <xsl:when test="type = 'External'">
                    <!-- TODO - add check for valid link -->
                    <xsl:value-of select="link-external"/>
                </xsl:when>
                <xsl:when test="type = 'Internal'">
                    <xsl:value-of select="link-page/path"/>
                </xsl:when>
                <xsl:when test="type = 'Submenu'">
                    <xsl:value-of select="$sUrlSubmenu"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <div class="panel panel-default">
            <div class="panel-heading">
                <div class="panel-title">
                    <a alt="{alt}" href="{$sUrl}">
                        <xsl:if test="type = 'Submenu'">
                            <xsl:attribute name="data-parent">
                                <xsl:choose>
                                    <xsl:when test="parent::menu/id[text()]">
                                        <xsl:value-of select="concat('#', string:sanitizeHtmlId(string(parent::menu/id)))"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat('#', generate-id(parent::menu))"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="data-toggle">collapse</xsl:attribute>
                        </xsl:if>
                        <xsl:copy-of select="$sLabel"/>
                    </a>
                </div>
            </div>
            <xsl:choose>
                <xsl:when test="type='Submenu'">
                    <div class="panel-collapse collapse" id="{$sIdSubmenu}">
                        <div class="panel-body">
                            <xsl:apply-templates select="link-submenu[@type='block']/content/system-data-structure/menu" mode="bs3-menu"/>
                        </div>
                    </div>
                </xsl:when>
            </xsl:choose>
        </div>
    </xsl:template>
</xsl:stylesheet>
