<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:exsl="http://exslt.org/common"
    exclude-result-prefixes="exsl xd"
    >

    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- Total number of span slots available -->
    <xsl:variable name="nSpanTotal">12</xsl:variable>

    <!-- Top level block pattern to match the "tab" data definition -->
    <xsl:template match="system-data-structure[tab]">
        <xsl:if test="count(tab) &gt; 0">
            <div class="tabbable">
                <div class="tab-content">
                    <ul>
                        <xsl:attribute name="class">nav nav-tabs</xsl:attribute>
                        <xsl:apply-templates select="tab" mode="tab-toc"/>
                    </ul>
                    <xsl:apply-templates select="tab" mode="tab-body"/>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- Generate the tab navigation area (the table of contents -->
    <xsl:template match="tab" mode="tab-toc">
        <li>
            <xsl:if test="position() = 1">
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
        <div>
            <xsl:attribute name="id"><xsl:value-of select="tab_id"/></xsl:attribute>
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="position() = 1">tab-pane active</xsl:when>
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
            <!-- Funky logic to support legacy:

            if ( class/value is 'class_span8_span4' is present ) then
                Split up content into a span8 and span4 row
                WYSIWYG content goes in the left
                ablock content goes in the right
            else if ( ablock exists and is an address )
                Split up content into a span8 and span4 row
                Address content goes in the right
                If ( ablock exists that is not an address )
                    ablock content other than address info goes in the left
                else
                    WYSIWYG content goes in the left
                end
            end -->

            <!-- First gather up the content to be displayed in the main area,
            which is either ablock content that is not an address or the WYSIWYG if there
            are no ablocks which are not an address -->
            <xsl:variable name="rtfAddress">
                <xsl:apply-templates select="ablock[@type='block']//system-data-structure[dept-address]">
                    <xsl:with-param name="sTitlePrefix" select="''"/>
                </xsl:apply-templates>
            </xsl:variable>

            <xsl:variable name="rtfAblockNoAddress">
                <xsl:apply-templates select="ablock[@type='block'][not(.//system-data-structure/dept-address)]"/>
            </xsl:variable>

            <xsl:variable name="rtfMainContent">
                <xsl:choose>
                    <xsl:when test="$rtfAblockNoAddress = ''">
                        <xsl:apply-templates select="tab_content"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$rtfAblockNoAddress"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <!-- OK run through the column logic -->
            <xsl:choose>
                <!-- Do we have a department address present or are we instructed to split the view? -->
                <xsl:when test="class/value = 'columns_span8_span4' or $rtfAddress != ''">
                    <div class="row-fluid">
                        <div class="span8">
                            <xsl:copy-of select="$rtfMainContent"/>
                        </div>
                        <div class="span4">
                            <div class="well">
                                <xsl:copy-of select="$rtfAddress"/>
                            </div>
                            <xsl:copy-of select="$rtfAblockNoAddress"/>
                        </div>
                    </div>
                </xsl:when>
                <!-- Otherwise use up the whole view for main content -->
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
        <!-- Sanity check: verify # of defined span slots does not exceed maximum -->
        <xsl:if test="sum($nsSpan) &gt; $nSpanTotal">
            <xsl:comment>WARNING: Total # of row spans exceeds maximum of <xsl:value-of select="$nSpanTotal"/></xsl:comment>
        </xsl:if>
        <xsl:if test="$nSpanDef &lt; 1">
            <xsl:comment>WARNING: No available row span slots</xsl:comment>
            <xsl:comment>sum($nsSpan): <xsl:value-of select="sum($nsSpan)"/></xsl:comment>
            <xsl:comment>count($nsSpan): <xsl:value-of select="count($nsSpan)"/></xsl:comment>
            <xsl:comment>$nSpanDef: <xsl:value-of select="$nSpanDef"/></xsl:comment>
        </xsl:if>

        <div>
            <!-- Assign the span class if possible -->
            <xsl:choose>
                <xsl:when test="tab_content_span[normalize-space(text()) != '' and number(text()) != 0]">
                    <!-- Use the value of the span given -->
                    <xsl:attribute name="class"><xsl:value-of select="concat('span', tab_content_span)"/></xsl:attribute>
                </xsl:when>
                <!-- Use the default span number -->
                <xsl:when test="$nSpanDef &gt; 0">
                    <xsl:attribute name="class"><xsl:value-of select="concat('span', $nSpanDef)"/></xsl:attribute>
                </xsl:when>
            </xsl:choose>

            <!-- Go through the presentation logic -->
            <xsl:apply-templates select="tab_content"/>
            <xsl:apply-templates select="ablock_group/ablock | ablock | block_group"/>
        </div>
    </xsl:template>

    <!-- WYSIWYG Content -->
    <xsl:template match="tab_content">
        <!-- Just dump out the content -->
        <xsl:copy-of select="./*"/>
    </xsl:template>
</xsl:stylesheet>
