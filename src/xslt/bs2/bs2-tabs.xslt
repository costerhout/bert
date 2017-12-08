<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2015-09-13T22:01:53-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-12-08T09:32:47-09:00

Derived from previous work done by John French at the University of Alaska Southeast.
-->

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:exsl="http://exslt.org/common"
    exclude-result-prefixes="exsl xd"
    >

    <xsl:import href="../include/string.xslt"/>
    <xsl:import href="../include/error.xslt"/>
    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- Total number of span slots available -->
    <xsl:variable name="nSpanTotal">12</xsl:variable>

    <!-- Top level block pattern to match the "tab" data definition -->
    <xsl:template match="system-data-structure[tab]">
        <xsl:call-template name="tab"/>
    </xsl:template>

    <xsl:template name="tab">
        <xsl:param name="sClassTabs" select="'nav-tabs'"/>
        <xsl:if test="count(tab) &gt; 0">
            <div class="tabbable">
                <div class="tab-content">
                    <ul>
                        <xsl:attribute name="class">
                            <xsl:value-of select="concat('nav ', $sClassTabs)"/>
                        </xsl:attribute>
                        <xsl:apply-templates select="tab" mode="tab-toc"/>
                    </ul>
                    <xsl:apply-templates select="tab" mode="tab-body"/>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- Generate the tab navigation area (the table of contents -->
    <xsl:template match="tab" mode="tab-toc">
        <xsl:variable name="bActive">
            <xsl:choose>
                <xsl:when test="tab_active = 'true'">true</xsl:when>
                <xsl:when test="position() = 1 and count(following-sibling::tab[tab_active = 'true']) = 0">true</xsl:when>
                <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <li>
            <xsl:if test="$bActive = 'true'">
                <xsl:attribute name="class">active</xsl:attribute>
            </xsl:if>
            <a>
                <xsl:attribute name="href">#<xsl:value-of select="tab_id"/></xsl:attribute>
                <xsl:attribute name="data-toggle">tab</xsl:attribute>
                <xsl:value-of select="tab_label"/>
            </a>
        </li>
    </xsl:template>

    <!-- For each tab, generate the div with the content inside -->
    <xsl:template match="tab" mode="tab-body">
        <xsl:variable name="bActive">
            <xsl:choose>
                <xsl:when test="tab_active = 'true'">true</xsl:when>
                <xsl:when test="position() = 1 and count(following-sibling::tab[tab_active = 'true']) = 0">true</xsl:when>
                <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div>
            <xsl:attribute name="id"><xsl:value-of select="tab_id"/></xsl:attribute>
            <xsl:attribute name="class">
                <!-- Check for manual override of tab order based on the tab_active element, if present -->
                <xsl:choose>
                    <xsl:when test="$bActive = 'true'">tab-pane active</xsl:when>
                    <xsl:otherwise>tab-pane</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>

            <!--
            A little strange logical setup in order to support:
                - tabs_with_column_blocks
                - tabs_with_column_blocks with id
                - tabs_with columns

            If "tab_content_group" exists, create a Bootstrap fluid row for it and then
            go through the display logic for the tab_content_group members.

            Then, if there's a separate ablock, display that, if there's no ablock,
            display the WYSIWYG content.

            Note that the tab_content_group may also contain an ablock.
            -->
            <xsl:if test="tab_content_group">
                <div class="row-fluid">
                    <xsl:apply-templates select="tab_content_group"/>
                </div>
            </xsl:if>

            <!-- First gather up the content blocks for the address (and then personnel entries)) -->
            <xsl:variable name="rtfAddress">
                <xsl:apply-templates select="ablock[@type='block']//system-data-structure[dept-address] | page[@type='page']//system-data-structure[dept-address]">
                    <xsl:with-param name="sTitlePrefix" select="''"/>
                </xsl:apply-templates>
                <xsl:apply-templates select="page[@type='page']//system-data-structure[Personnel]" mode="personnel-condensed"/>
            </xsl:variable>

            <!-- rtfAblockNoAddress gathers up the contnet from all the content blocks that aren't addresses plus any page content -->
            <xsl:variable name="rtfAblockNoAddress">
                <xsl:apply-templates select="ablock[@type='block'][not(.//system-data-structure/dept-address)]"/>
                
                <!-- Here we copy over page content that's not been assigned a data definition -->
                <xsl:if test="page/content[not(system-data-structure)]">
                    <xsl:copy-of select="page/content/node()"/>
                </xsl:if>
            </xsl:variable>

            <!-- Figure out what the main content is -->
            <xsl:variable name="rtfMainContent">
                <xsl:choose>
                    <!-- If we have a container as our ablock we assume that all content layout decisions are arranged by the container and its children -->
                    <xsl:when test="ablock[@type='block']/content/system-data-structure[container]">
                        <xsl:apply-templates select="ablock"/>
                    </xsl:when>

                    <!-- If there's no tab_content element, than the rtfAblockNoAddress becomes the main content no matter what -->
                    <xsl:when test="not(tab_content)">
                        <xsl:copy-of select="$rtfAblockNoAddress"/>
                    </xsl:when>

                    <!-- We have a tab_content element if we made it this far, so we're not using the "blocks only" definition. -->

                    <!-- If split is explicitly defined, then set the main content to be tab_content -->
                    <xsl:when test="class/value = 'columns_span8_span4' and exsl:node-set($rtfAblockNoAddress)/*">
                        <xsl:apply-templates select="tab_content"/>
                    </xsl:when>

                    <!-- If there's no non-address content present in blocks then the main content becomes the tab_content -->
                    <xsl:when test="not(exsl:node-set($rtfAblockNoAddress)/*)">
                        <xsl:apply-templates select="tab_content"/>
                    </xsl:when>

                    <!-- If there's non-address content present that takes precedence -->
                    <xsl:when test="exsl:node-set($rtfAblockNoAddress)/*">
                        <xsl:copy-of select="$rtfAblockNoAddress"/>
                    </xsl:when>

                    <!-- All we got left is the tab_content, man. -->
                    <xsl:otherwise>
                        <xsl:apply-templates select="tab_content"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <!-- Figure out what the side content is going to be -->
            <xsl:variable name="rtfSideContent">
                <xsl:choose>
                    <!--In this case, do nothing as we assume the layout is handled by the container and its children -->
                    <xsl:when test="ablock[@type='block']/content/system-data-structure[container]"></xsl:when>

                    <!-- If there's no tab_content element, then the only sidebar content will be the address (if present) -->
                    <xsl:when test="not(tab_content) and exsl:node-set($rtfAddress)/*">
                        <xsl:copy-of select="$rtfAddress"/>
                    </xsl:when>

                    <!-- We have a tab_content element if we made it this far. -->

                    <!-- If there's an explicit split, the sidebar content becomes the address and all other content blocks -->
                    <xsl:when test="class/value = 'columns_span8_span4' and exsl:node-set($rtfAblockNoAddress)/*">
                        <xsl:copy-of select="$rtfAddress"/>
                        <xsl:copy-of select="$rtfAblockNoAddress"/>
                    </xsl:when>

                    <!-- If there's an address defined, the sidebar content becomes that address -->
                    <xsl:when test="exsl:node-set($rtfAddress)/*">
                        <xsl:copy-of select="$rtfAddress"/>
                    </xsl:when>

                    <!-- No sidebar eligible information present, return empty. -->
                    <xsl:otherwise></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <!-- OK run through the column logic -->
            <xsl:choose>
                <!-- Do we have a department address present or are we instructed to split the view? -->
                <xsl:when test="exsl:node-set($rtfSideContent)/*">
                    <div class="row-fluid">
                        <div class="span8">
                            <xsl:copy-of select="$rtfMainContent"/>
                        </div>
                        <div class="span4">
                            <div class="well">
                                <xsl:copy-of select="$rtfSideContent"/>
                            </div>
                        </div>
                    </div>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:copy-of select="$rtfMainContent"/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <!--
    Depending on the data definition, the tab_content_group may contain:
        span
        tab_content
        ablock
        block_id
        ablock_group

    Supported data definitions include:
        tabs_with_column_blocks
        tabs_with_column_blocks with id
        tabs_with columns

    -->
    <xsl:template match="tab_content_group">
        <!-- Get the nodeset of defined numerical spans -->
        <xsl:variable name="nsSpan" select="../tab_content_group/tab_content_span[normalize-space(text()) != '' and number(text()) != 0]"/>
        <!-- Determine the default span number = (span total - sumSpan) / (number of tab content groups without defined span), rounded down -->
        <!-- This could give an Infinite result -->
        <xsl:variable name="nSpanDef"><xsl:value-of select="floor( ($nSpanTotal - sum($nsSpan) ) div (count(../tab_content_group/tab_content_span) - count($nsSpan)) )"/></xsl:variable>

        <!-- Build the class string based on the span values + additional class, if specified -->
        <xsl:variable name="rtfClass">
            <xsl:choose>
                <xsl:when test="tab_content_span[normalize-space(text()) != '' and number(text()) != 0]">
                    <node>
                        <xsl:value-of select="concat('span', tab_content_span)"/>
                    </node>
                </xsl:when>
                <xsl:when test="$nSpanDef &gt; 0">
                    <node>
                        <xsl:value-of select="concat('span', $nSpanDef)"/>
                    </node>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="class[text() != '']">
                <node>
                    <xsl:value-of select="normalize-space(class)"/>
                </node>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="sClass">
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns" select="exsl:node-set($rtfClass)/*"/>
                <xsl:with-param name="glue" select="' '"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Sanity check: verify # of defined span slots does not exceed maximum -->
        <xsl:if test="sum($nsSpan) &gt; $nSpanTotal">
            <xsl:call-template name="log-error">
                <xsl:with-param name="message">WARNING: Total # of row spans exceeds maximum of <xsl:value-of select="$nSpanTotal"/></xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$nSpanDef &lt; 1">
            <xsl:call-template name="log-error">
                <xsl:with-param name="message">WARNING: No available row span slots</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <div class="{$sClass}">
            <!-- Go through the presentation logic -->
            <xsl:apply-templates select="tab_content"/>
            <xsl:apply-templates select="ablock_group/ablock | ablock | block_group"/>
        </div>
    </xsl:template>

    <!-- WYSIWYG Content -->
    <xsl:template match="tab_content">
        <!-- Just dump out the content -->
        <xsl:if test="normalize-space(.) != '...'">
            <xsl:copy-of select="./node()"/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
