<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-03-28T15:16:19-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-08-08T10:18:51-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

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

    <xsl:param name="sClassPrefixMenu">menu</xsl:param>

    <!-- Matching templates -->
    <!-- Create menu to match index block of pages / folders -->
    <xsl:template match="system-data-structure[menu]">
        <xsl:apply-templates select="menu" mode="bs3-menu"/>
    </xsl:template>

    <!-- Lower level templates -->
    <xd:doc>
        <xd:short>Low level match template to create menu. Pills,
            stacked pills, and sliding menu are supported.</xd:short>
        <xd:detail>
            <p>A menu will be created for each node in the node-set with the
            following format:</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="menu" mode="bs3-menu">
        <xsl:variable name="sClassMenuTitle">
            <xsl:value-of select="concat($sClassPrefixMenu, '-title')"/>
        </xsl:variable>

        <!-- Do sanity check on variables (regex) -->
        <xsl:variable name="rtfValidDef">
            <nodedefs>
                <node>
                    <path>type</path>
                    <level>error</level>
                    <regex>^(?:simple|pill|pill-stacked|sliding|dropdown)$</regex>
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
                    <path>menuitem-source</path>
                    <level>error</level>
                    <!-- index-block is not yet supported -->
                    <!-- <regex>^(?:index-block|menuitems|sitemap)$</regex> -->
                    <regex>^(?:menuitems|sitemap)$</regex>
                    <flags></flags>
                    <message>Invalid menu source specified</message>
                </node>
            </nodedefs>
        </xsl:variable>
        <xsl:call-template name="validate-nodes">
            <xsl:with-param name="nsValidDef" select="exsl:node-set($rtfValidDef)"/>
        </xsl:call-template>

        <!-- What's the source of our menu? If it's a sitemap than we're going to output the module div and be done -->
        <xsl:choose>
            <xsl:when test="menuitem-source = 'sitemap'">
                <xsl:call-template name="menu-sitemap"/>
            </xsl:when>
            <xsl:when test="menuitem-source = 'menuitems'">
                <!-- Top level menu. Display label as menu title -->
                <h2 class="{$sClassMenuTitle}">
                    <xsl:value-of select="menu/label"/>
                </h2>

                <xsl:call-template name="menu-menuitems"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:short>Helper template to create a menu based on a menu item feed which is externally housed</xd:short>
        <xd:detail>
            <p>Menus may also be built by grabbing a list of menu items from the server and then using the contents of that menu feed to generate the menu items at run-time. This template outputs the module specification so that BERT will pick up on that and create the menu accordingly.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template name="menu-sitemap">
        <!-- Is there an ID associated with this grid structure? -->
        <xsl:variable name="idSanitized">
            <xsl:choose>
                <xsl:when test="id[text() != '']">
                    <xsl:value-of select="string:sanitizeHtmlId(string(id))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="string:generateId('menu-')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="rtfClass">
            <node>menu</node>
            <xsl:choose>
                <xsl:when test="class[text() != '']">
                    <node>
                        <xsl:value-of select="normalize-space(class)"/>
                    </node>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sClass">
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns" select="exsl:node-set($rtfClass)/*"/>
                <xsl:with-param name="glue" select="' '"/>
            </xsl:call-template>
        </xsl:variable>

        <div
            id='{$idSanitized}'
            class='{$sClass}'
            data-module='menu'
            data-url="{concat(sitemap/path, '.xml')}"
            data-type='{type}'
            data-cache-bust='true'
            >
            <!-- If the justified parameter is set then send that along as well -->
            <xsl:if test="justified/value = 'Yes'">
                <xsl:attribute name="data-justified">justified</xsl:attribute>
            </xsl:if>

            <!-- Pass along brand information (label, icon, link) if present -->
            <xsl:if test="normalize-space(brand/label) != ''">
                <xsl:attribute name="data-brand-label"><xsl:value-of select="normalize-space(brand/label)"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="brand/link/path != '/'">
                <xsl:attribute name="data-brand-link"><xsl:value-of select="concat(brand/link/path, '.html')"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="brand/logo/path != '/'">
                <xsl:attribute name="data-brand-logo"><xsl:value-of select="brand/logo/path"/></xsl:attribute>
            </xsl:if>
        </div>
    </xsl:template>

    <xd:doc>
        <xd:short>Helper template to create a menu based on the included menuitems data structure</xd:short>
        <xd:detail>
            <p>This template is called to start walking through menuitem structures, which many be nested, in order to create the menu.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template name="menu-menuitems">
        <!-- Are we a submenu? Certain types of menus don't support submenus. -->
        <xsl:choose>
            <!-- Pill and stacked pill menu types don't support submenus -->
            <xsl:when test="ancestor::menu[last()][type = 'pill' or type = 'pill-stacked']">
                <xsl:call-template name="log-error">
                    <xsl:with-param name="message">Menu type doesn't support submenus</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>

        <!-- Only apply the justified class for certain menu types and not for submenus -->
        <xsl:variable name="sClassJustified">
            <xsl:choose>
                <xsl:when test="not(ancestor::menu) and (type='pill') and (justified/value = 'Yes')">
                    nav-justified
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!-- Generate a clean class string of all the various components by creating an RTF,
        turning that into a node-set, and then concatenating them together with space
        in between -->
        <xsl:variable name="rtfClass">
            <xsl:choose>
                <!-- Simple menus get the class all the way down the stack -->
                <!-- This query checks to see if the top most menu is a simple menu -->
                <xsl:when test="ancestor-or-self::menu[last()]/type = 'simple'">
                    <!-- <node>nav</node> -->
                </xsl:when>

                <xsl:when test="not(ancestor::menu)">
                    <xsl:choose>
                        <xsl:when test="type = 'pill'">
                            <node>nav</node>
                            <node>nav-pills</node>
                        </xsl:when>
                        <xsl:when test="type = 'pill-stacked'">
                            <node>nav</node>
                            <node>nav-tabs</node>
                            <node>nav-stacked</node>
                        </xsl:when>
                        <xsl:otherwise></xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
            <node><xsl:value-of select="normalize-space($sClassJustified)"/></node>
        </xsl:variable>

        <!-- Bring all the components together into one class string -->
        <xsl:variable name="sClass">
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns" select="exsl:node-set($rtfClass)/node"/>
                <xsl:with-param name="glue" select="' '"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Figure out the class for the element which will wrap this menu -->
        <xsl:variable name="sClassMenuWrapper">
            <!-- Determine if we're a submenu - if so then don't apply the nav class -->
            <xsl:choose>
                <xsl:when test="not(ancestor::menu)">
                    <xsl:choose>
                        <xsl:when test="type = 'sliding'">
                            menu-sliding
                        </xsl:when>
                        <xsl:otherwise></xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!-- Generate a clean class string of all the various components by creating an RTF,
        turning that into a node-set, and then concatenating them together with space
        in between -->
        <xsl:variable name="rtfClassWrapper">
            <node><xsl:value-of select="normalize-space($sClassMenuWrapper)"/></node>
            <node><xsl:value-of select="normalize-space(class)"/></node>
        </xsl:variable>

        <!-- Bring all the components together into one class string -->
        <xsl:variable name="sClassWrapper">
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns" select="exsl:node-set($rtfClassWrapper)/node"/>
                <xsl:with-param name="glue" select="' '"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Generate the ID for this menu -->
        <xsl:variable name="sIdWrapper">
            <xsl:choose>
                <xsl:when test="id[text()]">
                    <xsl:value-of select="string:sanitizeHtmlId(string(id))"/>
                </xsl:when>
                <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Create the list of menu items -->
        <xsl:choose>
            <!-- Are we a submenu? If no, wrap this thing in a nav with the appropriate wrapper class -->
            <xsl:when test="not(ancestor::menu)">
                <nav>
                    <!-- Output class attribute if present -->
                    <xsl:if test="$sClassWrapper != ''">
                        <xsl:attribute name="class">
                            <xsl:value-of select="$sClassWrapper"/>
                        </xsl:attribute>
                    </xsl:if>

                    <xsl:if test="$sIdWrapper != ''">
                        <xsl:attribute name="id">
                            <xsl:value-of select="$sIdWrapper"/>
                        </xsl:attribute>
                    </xsl:if>

                    <xsl:call-template name="menu-inner">
                        <xsl:with-param name="sClass" select="$sClass"/>
                    </xsl:call-template>
                </nav>
            </xsl:when>
            <!-- Or else just output another level -->
            <xsl:otherwise>
                <xsl:call-template name="menu-inner">
                    <xsl:with-param name="sClass" select="$sClass"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:short>Helper template to generate menu outer HTML markup</xd:short>
        <xd:detail>
            <p>Generates outer menu HTML markup (&lt;ul&gt; tag) with an optional class. Context node should be the "menu" node. Processes menuitems via apply-templates.</p>
        </xd:detail>
        <xd:param name="sClass" type="string">Optional string to use as in the class attribute</xd:param>
    </xd:doc>
    <xsl:template name="menu-inner">
        <xsl:param name="sClass"/>
        <!-- Generate the ul tag with optional class string -->
        <ul>
            <xsl:if test="$sClass != ''">
                <xsl:attribute name="class">
                    <xsl:value-of select="$sClass"/>
                </xsl:attribute>
            </xsl:if>

            <!-- Go through and list out the menu items -->
            <xsl:apply-templates select="menuitem" mode="bs3-menuitem"/>
        </ul>
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
        <!-- Sanity check on the parameters. -->
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

        <!-- Create the menu item label -->
        <xsl:variable name="sLabel">
            <xsl:choose>
                <!-- If this is a submenu, then get the label from the referenced block's label
                field. -->
                <xsl:when test="type='Submenu'">
                    <xsl:value-of select="normalize-space(.//menu/label)"/>
                    <xsl:value-of select="$nbsp"/>
                    <span>
                        <xsl:attribute name="class">
                            <xsl:value-of select="concat($sClassPrefixMenu, '-caret')"/>
                        </xsl:attribute>
                    </span>
                </xsl:when>
                <!-- Otherwise get the label from the field -->
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(label)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Generate the menu item ID (if this is really a submenu)-->
        <xsl:variable name="sIdSubmenu">
            <xsl:if test="not(ancestor-or-self::menu[last()]/type = 'simple') and type='Submenu'">
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

        <!-- Generate the submenu URL (if this is really a submenu) -->
        <xsl:variable name="sUrlSubmenu">
            <xsl:if test="type='Submenu' and $sIdSubmenu != ''">
                <xsl:value-of select="concat('#', $sIdSubmenu)"/>
            </xsl:if>
        </xsl:variable>

        <!-- Generate the menu item URL -->
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

        <!-- Output the list item -->
        <li role="presentation">
            <xsl:choose>
                <xsl:when test="$sUrl != ''">
                    <a href="{$sUrl}">
                        <!-- Spit out the alt text -->
                        <xsl:if test="alt[text() != '']">
                            <xsl:attribute name="alt">
                                <xsl:value-of select="alt"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:copy-of select="$sLabel"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$sLabel"/>
                </xsl:otherwise>
            </xsl:choose>

            <!-- Recurse into submenus if present -->
            <xsl:apply-templates select="link-submenu[@type='block']/content/system-data-structure/menu" mode="bs3-menu"/>
        </li>
    </xsl:template>
</xsl:stylesheet>
