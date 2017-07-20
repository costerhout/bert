<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-03-28T15:16:19-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-04-18T10:28:13-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xd"
    >

    <xsl:import href="../include/pathfilter.xslt"/>

    <xd:doc type="stylesheet">
        <xd:short>Dump index information out in simple sitemap format</xd:short>
        <xd:detail>
            <p>This stylesheet is designed to dump information out for a BERT runtime module to pick up and render a menu with.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
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
        Matching a lone system-index-block - just build a simple menu with no brand information or form.
    </xd:doc>
    <xsl:template match="system-index-block">
        <menu>
            <xsl:call-template name="menu-recurse"/>
        </menu>
    </xsl:template>

    <xd:doc>
        Helper template to recurse down into children of the current system-folder.
        Applies templates on system-pages, system-folders, and system-symlinks if they are published and included in navigation. Folders are only recursed into if they have children.
    </xd:doc>
    <xsl:template name="menu-recurse">
        <xsl:apply-templates select="
                system-page
                    [is-published='true']
                    [dynamic-metadata[name='Include in Navigation']/value='Yes']
                | system-folder
                    [*
                        [self::system-page or self::system-folder]
                        [is-published='true']
                        [dynamic-metadata[name='Include in Navigation']/value='Yes']
                    or system-symlink
                        [dynamic-metadata[name='Include in Navigation']/value='Yes']
                    ]
                    [dynamic-metadata[name='Include in Navigation']/value='Yes']
                | system-symlink[dynamic-metadata[name='Include in Navigation']/value='Yes']
                "
        />
    </xsl:template>

    <xsl:template name="create-label">
        <xsl:choose>
            <xsl:when test="normalize-space(display-name) != ''">
                <xsl:value-of select="display-name"/>
            </xsl:when>
            <xsl:when test="normalize-space(title) != ''">
                <xsl:value-of select="title"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        Match a folder. Output structure:
        &lt;menuitem&gt;
            &lt;label&gt;&lt;/label&gt;
            &lt;menuitem&gt;...&lt;/menuitem&gt;
            &lt;menuitem&gt;...&lt;/menuitem&gt;
            &lt;menuitem&gt;...&lt;/menuitem&gt;
            &lt;menugroup&gt;...&lt;/menugroup&gt;
        &lt;/menugroup&gt;
    </xd:doc>
    <xsl:template match="system-folder">
        <xsl:variable name="sLabel">
            <xsl:call-template name="create-label"/>
        </xsl:variable>
        <menuitem>
            <label>
                <xsl:value-of select="$sLabel"/>
            </label>
            <xsl:call-template name="menu-recurse"/>
        </menuitem>
    </xsl:template>

    <xd:doc>
        Match a single system page. Output structure:
        &lt;menuitem&gt;
            &lt;label&gt;&lt;/label&gt;
            &lt;url&gt;&lt;/url&gt;
        &lt;/menuitem&gt;
    </xd:doc>
    <xsl:template match="system-page">
        <xsl:variable name="sPath">
            <xsl:value-of select="concat(path, '.html')"/>
        </xsl:variable>
        <xsl:variable name="sLabel">
            <xsl:call-template name="create-label"/>
        </xsl:variable>
        <menuitem>
            <label><xsl:value-of select="$sLabel"/></label>
            <url><xsl:value-of select="$sPath"/></url>
        </menuitem>
    </xsl:template>

    <xd:doc>
        Match a single system symlink. Output structure:
        &lt;menuitem&gt;
            &lt;label&gt;&lt;/label&gt;
            &lt;url&gt;&lt;/url&gt;
        &lt;/menuitem&gt;
    </xd:doc>
    <xsl:template match="system-symlink">
        <xsl:variable name="sPath">
            <xsl:value-of select="link"/>
        </xsl:variable>
        <xsl:variable name="sLabel">
            <xsl:call-template name="create-label"/>
        </xsl:variable>
        <menuitem>
            <label><xsl:value-of select="$sLabel"/></label>
            <url><xsl:value-of select="$sPath"/></url>
        </menuitem>
    </xsl:template>

    <!-- Lower level templates -->
    </xsl:stylesheet>
