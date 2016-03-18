<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:string="my:string"
                version="1.0"
                exclude-result-prefixes="string"
                >
    <xsl:import href="../include/paragraph-wrap.xslt"/>

    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- Total number of column slots available -->
    <xsl:variable name="nColumnTotal">12</xsl:variable>

    <!-- Top level block pattern to match the "tab" data definition -->
    <xsl:template match="system-data-structure[row]">
        <xsl:apply-templates select="row"/>
    </xsl:template>

    <!-- Create key for easier calculation of column spans -->
    <xsl:key name="keyColSpan" match="responsive-settings/*[not(hide/value)]/columns" use="name(..)"/>
    <xsl:key name="keyColOffset" match="responsive-settings/*[not(hide/value)]/offset" use="name(..)"/>
    <!--
    Considerations:

    - If advanced setting isn't defined, then don't print out inline style
    - Verify HTML ID string is valid or fail
    - Verify HTML CSS class string is valid or fail
    - Verify background color is valid RGB string or fail
    - Verify the background size is valid
    - Determine the auto column span #
    -->

    <!--
    Template match: row

    Apply template to display each child column
    -->
    <xsl:template match="row">
        <xsl:variable name="nsTest" select="(key('keyColSpan', 'xs'))[. != 'auto']"/>

        <!-- Get the total set of columns at this level which are marked to be not hidden -->
        <xsl:variable name="nsCol" select="key('keyColSpan', 'lg')"/>
        <xsl:variable name="nsOffset" select="key('keyColOffset', 'sm')"/>

        <!-- Figure out the derived columns value for the entire node set at this level (lg, md, sm, xs) -->
        <!--TODO
            Roll this into the columns template
            Should the value of "enable-responsive-settings" be taken into account?
         -->

        <!--
        nsColDerived is comprised of the following:
            All columns (spans) at the given viewport size whose value is not 'inherit'
            The columns node of the nearest preceding sibling whose columns value is not marked as 'inherit'
        -->
        <xsl:variable name="nsColDerived" select="$nsCol[. != 'inherit'] | ($nsCol[. = 'inherit']/../preceding-sibling::*[columns != 'inherit'][1]/columns)"/>

        <xsl:for-each select="$nsCol">
            <xsl:comment>nsCol: <xsl:value-of select="."/></xsl:comment><xsl:value-of select="$nl"/>
        </xsl:for-each>

        <xsl:for-each select="$nsColDerived">
            <xsl:comment>nsColDerived: <xsl:value-of select="."/></xsl:comment><xsl:value-of select="$nl"/>
        </xsl:for-each>

        <!--
        <xsl:for-each select="$nsTest">
            <xsl:comment>NODE COL: <xsl:value-of select="."/></xsl:comment>
        </xsl:for-each>
        -->


        <!-- Validate row settings -->
        <xsl:variable name="sError">
            <xsl:for-each select="row-settings">
                <xsl:call-template name="grid-validate-background-settings"/>
            </xsl:for-each>
        </xsl:variable>

        <!-- Figure out the attributes of the row (if applicable) -->
        <xsl:variable name="idSanitized">
            <xsl:if test="enable-row-settings[value='Yes']">
                <xsl:value-of select="string:sanitizeHtmlId(string(row-settings/id))"/>
            </xsl:if>
        </xsl:variable>

        <!-- Check HTML id -->
        <xsl:if test="enable-row-settings[value='Yes'] and row-settings/id != $idSanitized">
            <xsl:call-template name="log-warning">
                <xsl:with-param name="message"><xsl:value-of select="concat('Invalid HTML id: &quot;', id, '&quot;')"/></xsl:with-param>
                <xsl:with-param name="nsToDump" select="row-settings/id"/>
            </xsl:call-template>
        </xsl:if>

        <xsl:variable name="sStyle">
            <xsl:if test="enable-row-settings[value='Yes']">
                <xsl:for-each select="row-settings">
                    <xsl:call-template name="grid-build-style-string"/>
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$sError = ''">
                <!-- Generate row div with attributes -->
                <div class="row">
                    <!-- Generate advanced settings if XML calls for it -->
                    <xsl:if test="enable-row-settings[value='Yes']">
                        <xsl:attribute name="style"><xsl:value-of select="$sStyle"/></xsl:attribute>
                        <xsl:attribute name="id"><xsl:value-of select="$idSanitized"/></xsl:attribute>
                    </xsl:if>

                    <!-- Display the columns associated with this row -->
                    <xsl:apply-templates select="column"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$sError"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
    Column span variables:
    Gets nodeset of defined numerical column spans
    Determines default column span

    <xsl:variable name="nsColumnSpan" select="../tab_content_group/tab_content_span[normalize-space(text()) != '' and number(text()) != 0]"/>
    <xsl:variable name="nColumnDef"><xsl:value-of select="floor( ($nSpanTotal - sum($nsColumnSpan) ) div (count(../tab_content_group/tab_content_span) - count($nsColumnSpan)) )"/></xsl:variable>
    <xsl:if test="sum($nsColumnSpan) &gt; $nSpanTotal">
        <xsl:comment>WARNING: Total # of row spans exceeds maximum of <xsl:value-of select="$nSpanTotal"/></xsl:comment>
    </xsl:if>
    <xsl:if test="$nColumnDef &lt; 1">
        <xsl:comment>WARNING: No available row span slots</xsl:comment>
        <xsl:comment>sum($nsColumnSpan): <xsl:value-of select="sum($nsColumnSpan)"/></xsl:comment>
        <xsl:comment>count($nsColumnSpan): <xsl:value-of select="count($nsColumnSpan)"/></xsl:comment>
        <xsl:comment>$nColumnDef: <xsl:value-of select="$nColumnDef"/></xsl:comment>
    </xsl:if>
    -->
    <xsl:template match="column">
        <!-- Validate row settings -->
        <xsl:variable name="sError">
            <xsl:for-each select="column-settings">
                <xsl:call-template name="grid-validate-background-settings"/>
            </xsl:for-each>
        </xsl:variable>

        <!-- Figure out the attributes of the row (if applicable) -->
        <xsl:variable name="idSanitized">
            <xsl:if test="enable-column-settings[value='Yes']">
                <xsl:value-of select="string:sanitizeHtmlId(string(column-settings/id))"/>
            </xsl:if>
        </xsl:variable>

        <!-- Check HTML id -->
        <xsl:if test="enable-column-settings[value='Yes'] and column-settings/id != $idSanitized">
            <xsl:call-template name="log-warning">
                <xsl:with-param name="message"><xsl:value-of select="concat('Invalid HTML id: &quot;', id, '&quot;')"/></xsl:with-param>
                <xsl:with-param name="nsToDump" select="column-settings/id"/>
            </xsl:call-template>
        </xsl:if>

        <!-- Figure out what the style string should be (if enable-column-settings is set) -->
        <xsl:variable name="sStyle">
            <xsl:if test="enable-column-settings[value='Yes']">
                <xsl:for-each select="column-settings">
                    <xsl:call-template name="grid-build-style-string"/>
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>

        <!-- Determine how many span columns this column should span -->
        <xsl:variable name="sClassCol">
            <xsl:apply-templates select="responsive-settings/*"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$sError = ''">
                <!-- Generate row div with attributes -->
                <div class="{$sClassCol}">
                    <!-- Generate advanced settings if XML calls for it -->
                    <xsl:if test="enable-column-settings[value='Yes']">
                        <xsl:attribute name="style"><xsl:value-of select="$sStyle"/></xsl:attribute>
                        <xsl:attribute name="id"><xsl:value-of select="$idSanitized"/></xsl:attribute>
                    </xsl:if>

                    <!-- Display the content associated with this column -->
                    <xsl:apply-templates select="content"/>

                    <!-- Run down the display chain for any blocks -->
                    <xsl:apply-templates select="ablock"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$sError"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="responsive-settings/*">
        <xsl:variable name="sSuffix">
            <xsl:if test="position() != last()">
                <xsl:text> </xsl:text>
            </xsl:if>
        </xsl:variable>

        <!-- Get the total set of columns at this level which are marked to be not hidden -->
        <xsl:variable name="nsCol" select="key('keyColSpan', name())"/>
        <xsl:variable name="nsOffset" select="key('keyColOffset', name())"/>

        <!-- Figure out the derived columns value for the entire node set at this level (lg, md, sm, xs)-->
        <xsl:variable name="nsColDerived">
            <xsl:value-of select="$nsCol[. != 'inherit'] | $nsCol[. = 'inherit']/preceding::columns[. != 'inherit']"/>
        </xsl:variable>

        <!-- Figure out if there's a set value (or derived from a preceding definition via 'inherit', or if it's just all auto -->
        <!-- <xsl:variable name="nColDerived">
            <xsl:when test="columns = 'inherit'">
                <xsl:value-of select="preceding::columns[. != 'inherit']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="columns"/>
            </xsl:otherwise>
        </xsl:variable> -->


        <!--
        The calculation works like this:
            Sum up the defined column and offset values for all columns of this type
                For each column, if marked as 'inherit', then walk back in document order until a value is found

            Subtract this value from the maximum ($nColumnTotal)
            Divide the remaining value by the number of 'auto' columns and round down.
         -->

        <!--
        If we're set to inherit the column span but there's no previous
        defined column span, or the column span is set to 'auto'

        some sample snippets
        <xsl:when test="$nColDerived = 'auto'">
        <xsl:value-of select="sum($nsCol[. != 'auto' and . != 'inherit'] | $nsCol[. = 'inherit']::preceding-sibling[not(hide/value) and columns != 'inherit'])"/>

        ( sum(
        (key('keyColSpan', name()) | key('keyColOffset', name()))[. != 'auto' and . != 'inherit']
        ) )
            div count(parent::*[columns = 'auto'])


        columns = 'auto' or
        ( columns = 'inherit' and generate-id(preceding-sibling::*[columns = 'inherit' or columns = 'auto']) = generate-id(preceding-sibling::*))

        <xsl:variable name="nColSpan">
            <xsl:choose>
                </xsl:when>
                <xsl:when test="columns = 'inherit'">
                    <xsl:value-of select="preceding-sibling::column[not(text() = 'auto')]"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="columns"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
    -->
        <xsl:variable name="nColSpan">7</xsl:variable>

        <xsl:variable name="nColOffset">
            <xsl:choose>
                <xsl:when test="offset = 'inherit'">
                    <xsl:value-of select="preceding-sibling::offset[not(text() = 'inherit')]"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="offset"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>


        <xsl:variable name="sClassSpan" select="concat('col-', name(), '-', $nColSpan)"/>

        <xsl:variable name="sClassOffset">
            <xsl:if test="$nColOffset != 0">
                <xsl:value-of select="concat('col-', name(), '-offset-', $nColOffset)"/>
            </xsl:if>

        </xsl:variable>

        <xsl:value-of select="concat($sClassSpan, ' ', $sClassOffset, $sSuffix)"/>
    </xsl:template>

    <!--
    Template: grid-build-style-string
        Generates a valid CSS string based on row-settings or column-settings parameters.
        Any errors are displayed via the log-warning template.

    Parameters:
        Uses current context, assumed to be row- or column- settings
    -->
    <xsl:template name="grid-build-style-string" priority="-1">
        <xsl:for-each select="background-image | background-color | background-position | background-repeat | background-size">
            <xsl:choose>
                <xsl:when test="name() = 'background-image'">
                    <xsl:value-of select="concat('background-image: url(', path, '); ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat(name(), ': ', text(), '; ')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="grid-validate-background-settings" priority="-1">
        <xsl:variable name="reBackgroundColor">^$|^#[a-f0-9]{6}$|^#[a-f0-9]{3}$|^rgb\((?:(?:\s*\d+\s*,){2}\s*\d+|(?:\s*\d+(?:\.\d+)?%\s*,){2}\s*\d+(?:\.\d+)?%)\s*\)$|^rgba\((?:(?:\s*\d+\s*,){3}|(?:\s*\d+(?:\.\d+)?%\s*,){3})\s*\d+(?:\.\d+)?\s*\)$</xsl:variable>
        <xsl:variable name="reBackgroundPosition">^(?:left|right|center)\s+(top|center|bottom)|\d+(?:px|%|rem|ch|vh|vw|em|pt|ex|cm|mm|in|pc)\s+\d+(?:px|%|rem|ch|vh|vw|em|pt|ex|cm|mm|in|pc)$</xsl:variable>
        <xsl:variable name="reBackgroundRepeat">^(?:repeat|repeat-x|repeat-y|no-repeat|initial|inherit)$</xsl:variable>
        <xsl:variable name="reBackgroundSize">^(?:cover|contain|auto)$</xsl:variable>

        <!-- Check background properties -->
        <xsl:for-each select="background-color | background-position | background-repeat | background-size">
            <xsl:variable name="result">
                <xsl:choose>
                    <xsl:when test="name() = 'background-color'">
                        <xsl:value-of select="string:regexTest(normalize-space(.), $reBackgroundColor, 'i')"/>
                    </xsl:when>
                    <xsl:when test="name() = 'background-position'">
                        <xsl:value-of select="string:regexTest(normalize-space(.), $reBackgroundPosition, 'i')"/>
                    </xsl:when>
                    <xsl:when test="name() = 'background-repeat'">
                        <xsl:value-of select="string:regexTest(normalize-space(.), $reBackgroundRepeat, 'i')"/>
                    </xsl:when>
                    <xsl:when test="name() = 'background-size'">
                        <xsl:value-of select="string:regexTest(normalize-space(.), $reBackgroundSize, 'i')"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>

            <xsl:if test="$result = 'false'">
                <xsl:call-template name="log-warning">
                    <xsl:with-param name="message"><xsl:value-of select="concat('Invalid parameter specified for &quot;', name(), '&quot;: &quot;', ., '&quot;')"/></xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- Generate the tab navigation area (the table of contents -->
    <xsl:template match="content">
        <!-- Just dump out the content, wrapped in a paragraph if needed -->
        <xsl:call-template name="paragraph-wrap">
            <xsl:with-param name="nodeToWrap" select="."/>
        </xsl:call-template>
        <xsl:copy-of select="./*"/>
    </xsl:template>
</xsl:stylesheet>
