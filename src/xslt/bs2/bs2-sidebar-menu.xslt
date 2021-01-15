<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout> derived from previous work by John French <jhfrench>
@Date:   2021-01-15T08:55:36-09:00
@Email:  ctosterhout@alaska.edu
@Project: bert
@Last modified by:   ctosterhout
@Last modified time: 2021-01-15T09:44:21-09:00
@License: Released under MIT License. Copyright 2020 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xd"
    version="1.0">
    
    <xsl:output indent="yes"
                method="html"
                omit-xml-declaration="yes" />
    
    <xd:doc>
        Top level matching template
    </xd:doc>
    
    <xsl:template match="system-index-block">
        <xsl:call-template name="build-desktop-menu"/>
        <xsl:call-template name="build-mobile-menu"/>
    </xsl:template>
    
    <xd:doc>
        Named template to build out the desktop version of the menu and write out the script which operates upon it.
    </xd:doc>
    
    <xsl:template name="build-desktop-menu">
        <xsl:variable name="idMenu" select="concat(generate-id(), '-menu-desktop')"/>
        
        <div class="hidden-phone">
            <div class="p7TMM10"
                 id="{$idMenu}">
                <ul class="p7TMM">
                    <xsl:apply-templates select="system-page | system-folder | system-symlink">
                        <xsl:with-param name="bIncludeIndexPage" select="'false'"/>
                        <xsl:with-param name="bUseEmptyIndexLink" select="'false'"/>
                    </xsl:apply-templates>
                </ul>
                <script type="text/javascript">
                    P7_TMMop('<xsl:value-of select="$idMenu"/>', 1, 0, 0, 3, 1, 1, 1, 0, -1);
                </script>
            </div>
        </div>
    </xsl:template>
    
    <xd:doc>
        Named template to build out the mobile version of the menu and write out the script which operates upon it.
    </xd:doc>
    
    <xsl:template name="build-mobile-menu">
        <xsl:variable name="idMenu" select="concat(generate-id(), '-menu-mobile')"/>
        
        <div class="visible-phone">
            <div class="p7TMM10"
                 id="{$idMenu}">
                <ul class="p7TMM">
                    <xsl:apply-templates select="system-page | system-folder | system-symlink">
                        <xsl:with-param name="bIncludeIndexPage" select="'true'"/>
                        <xsl:with-param name="bUseEmptyIndexLink" select="'true'"/>
                    </xsl:apply-templates>
                </ul>
                <script type="text/javascript">
                    P7_TMMop('<xsl:value-of select="$idMenu"/>', 0, 0, 0, 3, 1, 0, 0, 1, -1);
                </script>
            </div>
        </div>
    </xsl:template>

    <xd:doc>
        Match on a system-page which:
            * is marked as to be included in navigation
        
        Furthermore conditions are applied within the template.
    </xd:doc>
    
    <xsl:template match="
        system-page
            [dynamic-metadata[name='Include in Navigation']/value = 'Yes']
        ">
        <xsl:param name="bIncludeIndexPage" />
        <xsl:param name="bUseEmptyIndexLink" />
        <xsl:choose>
            <!--
            Output a link whenever:
                we're explicitly instructed to, or
                the name of the page is not "index", or
                it's a reference, or
                we're at the root of the index
            -->
            <xsl:when test="
                ($bIncludeIndexPage = 'true') or
                (name != 'index') or
                (@reference = 'true') or
                not(parent::system-folder)">
                <li>
                    <a href="{path}"><xsl:value-of select="display-name"/></a>
                </li>
            </xsl:when>
            <xsl:otherwise />
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        Match on a system-symlink which is marked as to be included in navigation
    </xd:doc>
    
    <xsl:template match="system-symlink[dynamic-metadata[name='Include in Navigation']/value = 'Yes']">
        <li>
            <a href="{link}" target="_blank" rel="noopener noreferrer"><xsl:value-of select="display-name"/></a>
        </li>
    </xsl:template>
    
    <xd:doc>
        Match on a system-folder which:
            * is marked as to be included in navigation, and
            * has a system-page named 'index' which is not a reference    
    </xd:doc>
    
    <xsl:template match="
        system-folder
            [dynamic-metadata[name='Include in Navigation']/value = 'Yes']
            [system-page[(name = 'index') and not(@reference = 'true')]]
        ">        
        <xsl:param name="bIncludeIndexPage" />
        <xsl:param name="bUseEmptyIndexLink" />
        
        <xsl:variable name="nCountChildren" select="count(
            system-page
                [dynamic-metadata[name='Include in Navigation']/value = 'Yes']
                [name != 'index'] |
            system-page
                [dynamic-metadata[name='Include in Navigation']/value = 'Yes']
                [@reference = 'true']                        
            )"/>
        
        <xsl:variable name="rtfMenuitem">
            <xsl:choose>
                <!-- This menu item links to the index page (non-reference)-->
                <xsl:when test="($bUseEmptyIndexLink = 'true') and ($nCountChildren &gt; 0)">
                    <a href="#" class="subFolder"><xsl:value-of select="display-name"/></a>
                </xsl:when>

                <xsl:otherwise>
                    <a href="{(system-page[name='index' and not(@reference = 'true')])/path}" class="subFolder"><xsl:value-of select="display-name"/></a>
                </xsl:otherwise>
            </xsl:choose>            
        </xsl:variable>
        
        <li>
            <xsl:choose>
                <!-- Are we operating on a folder with non-index children? -->
                <xsl:when test="$nCountChildren &gt; 0">
                    <xsl:copy-of select="$rtfMenuitem"/>                    
                    
                    <div>
                        <ul>
                            <xsl:apply-templates select="system-page | system-folder | system-symlink">
                                <xsl:with-param name="bIncludeIndexPage" select="$bIncludeIndexPage"/>
                                <xsl:with-param name="bUseEmptyIndexLink" select="$bUseEmptyIndexLink"/>
                            </xsl:apply-templates>
                        </ul>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$rtfMenuitem"/>
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>
    
    <xd:doc>
        Override default template in order to skip over system-page and system-folder assets which should not be output (e.g. not navigable, or not published, or doesn't have a index asset)        
    </xd:doc>
    
    <xsl:template match="system-page | system-folder | system-symlink">
        <!-- this spot intentionally left blank -->
    </xsl:template>
</xsl:stylesheet>