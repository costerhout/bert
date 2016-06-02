<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-03-15T16:21:48-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-06-01T23:12:19-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->


<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:string="my:string"
                xmlns:exsl="http://exslt.org/common"
                version="1.0"
                exclude-result-prefixes="string xd exsl"
                >
    <xsl:import href="../include/string.xslt"/>
    <xsl:import href="../include/error.xslt"/>
    <xsl:import href="ablock-content.xslt"/>

    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>

    <xd:doc type="stylesheet">
        <xd:short>Bootstrap 3 stylesheet to control grid output</xd:short>
        <xd:detail>
            <p>Produce a set of Bootstrap row and column &lt;div&gt; elements,
            the heart of the Bootstrap 3 grid system.  Two types of templates
            are defined within: matching templates which match on the CMS data
            definition bs3/grid and the named templates which are called by the
            matching templates and are able to be called by including stylesheets.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <!-- Total number of column slots available -->
    <xsl:param name="nColumnTotal">12</xsl:param>
    <xsl:param name="sViewportDefault">sm</xsl:param>
    <xsl:param name="sClassPrefixGrid">grid</xsl:param>

    <!-- Top level block pattern to match the "tab" data definition -->
    <xsl:template match="system-data-structure[row/column]">
        <!-- Do sanity checking on the variables -->
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
            </nodedefs>
        </xsl:variable>

        <xsl:call-template name="validate-nodes">
            <xsl:with-param name="nsValidDef" select="exsl:node-set($rtfValidNodes)"/>
        </xsl:call-template>

        <!-- Is there an ID associated with this grid structure? -->
        <xsl:variable name="idSanitized">
            <xsl:if test="id[text() != '']">
                <xsl:value-of select="string:sanitizeHtmlId(string(id))"/>
            </xsl:if>
        </xsl:variable>

        <!-- Is there a class string associated with this grid structure? -->
        <xsl:variable name="sClass">
            <xsl:if test="class[text() != '']">
                <xsl:value-of select="normalize-space(class)"/>
            </xsl:if>
        </xsl:variable>

        <xsl:choose>
            <!-- If there's either an ID or a class associated with this grid then wrap it -->
            <xsl:when test="$idSanitized != '' or $sClass != ''">
                <div>
                    <xsl:if test="$idSanitized != ''">
                        <xsl:attribute name="id">
                            <xsl:value-of select="$idSanitized"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$sClass != ''">
                        <xsl:attribute name="class">
                            <xsl:value-of select="$sClass"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates select="row"/>
                </div>
            </xsl:when>
            <!-- Otherwise just output the row -->
            <xsl:otherwise>
                <xsl:apply-templates select="row"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:short>Display each row of columns along with background style information.</xd:short>
        <xd:detail>
            <p>After determining the RTF for the child column content, the style and class
            information is passed on to the Bootstrap layer row generator.</p>
            <p>Considerations:</p>
            <ul>
                <li>If advanced setting isn't defined, then don't print out inline style</li>
                <li>Verify HTML ID string is valid or fail</li>
                <li>Verify HTML CSS class string is valid or fail</li>
                <li>Verify background color is valid RGB string or fail</li>
                <li>Verify the background size is valid</li>
                <li>Determine the auto column span #</li>
            </ul>
        </xd:detail>
    </xd:doc>
    <xsl:template match="row">
        <!-- Define the valid node specifications -->
        <!-- The paths are defined such that they're only checked if the 'enable-column-settings' is checked -->
        <xsl:variable name="rtfValidNodes">
            <nodedefs>
                <node>
                    <path>row-settings[preceding-sibling::enable-row-settings/value='Yes']/background-color</path>
                    <regex>^$|^#[a-f0-9]{6}$|^#[a-f0-9]{3}$|^rgb\((?:(?:\s*\d+\s*,){2}\s*\d+|(?:\s*\d+(?:\.\d+)?%\s*,){2}\s*\d+(?:\.\d+)?%)\s*\)$|^rgba\((?:(?:\s*\d+\s*,){3}|(?:\s*\d+(?:\.\d+)?%\s*,){3})\s*\d+(?:\.\d+)?\s*\)$</regex>
                    <flags>i</flags>
                    <level>warning</level>
                    <message>Invalid background-color specified</message>
                </node>
                <node>
                    <path>row-settings[preceding-sibling::enable-row-settings/value='Yes']/background-position</path>
                    <regex>^(?:left|right|center)\s+(top|center|bottom)|\d+(?:px|%|rem|ch|vh|vw|em|pt|ex|cm|mm|in|pc)\s+\d+(?:px|%|rem|ch|vh|vw|em|pt|ex|cm|mm|in|pc)$</regex>
                    <flags>i</flags>
                    <level>warning</level>
                    <message>Invalid background-position specified</message>
                </node>
                <node>
                    <path>row-settings[preceding-sibling::enable-row-settings/value='Yes']/background-repeat</path>
                    <regex>^(?:repeat|repeat-x|repeat-y|no-repeat|initial|inherit)$</regex>
                    <flags>i</flags>
                    <level>warning</level>
                    <message>Invalid background-repeat specified</message>
                </node>
                <node>
                    <path>row-settings[preceding-sibling::enable-row-settings/value='Yes']/background-size</path>
                    <regex>^(?:cover|contain|auto)$</regex>
                    <flags>i</flags>
                    <level>warning</level>
                    <message>Invalid background-size specified</message>
                </node>
                <node>
                    <path>row-settings[preceding-sibling::enable-row-settings/value='Yes']/background-image[@type='file']/path</path>
                    <regex>(?:jpg|gif|png|jpeg)$</regex>
                    <flags>i</flags>
                    <level>warning</level>
                    <message>Invalid background-image format specified</message>
                </node>
                <node>
                    <path>class[preceding-sibling::enable-row-settings/value='Yes']</path>
                    <level>warning</level>
                    <regex>^(?:-?[_a-zA-Z]+[_a-zA-Z0-9-]*\s*)*$</regex>
                    <flags></flags>
                    <message>Invalid CSS class string specified</message>
                </node>
                <node>
                    <path>id[preceding-sibling::enable-row-settings/value='Yes']</path>
                    <level>warning</level>
                    <regex>^(?:[a-zA-Z][\w:.-]*)?$</regex>
                    <flags></flags>
                    <message>Invalid HTML ID specified</message>
                </node>
            </nodedefs>
        </xsl:variable>

        <!-- Call the validate-nodes template which does the heavy lifting -->
        <xsl:variable name="sError">
            <xsl:call-template name="validate-nodes">
                <xsl:with-param name="nsValidDef" select="exsl:node-set($rtfValidNodes)"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Figure out the attributes of the row (if applicable) -->
        <xsl:variable name="idSanitized">
            <xsl:if test="enable-row-settings[value='Yes']">
                <xsl:value-of select="string:sanitizeHtmlId(string(row-settings/id))"/>
            </xsl:if>
        </xsl:variable>

        <!-- Build the class string based on the row-style-preselect and row-settings/class (if enable-row-settings is set) -->
        <xsl:variable name="rtfClass">
            <xsl:if test="row-style-preselect != 'default'">
                <node>
                    <xsl:value-of select="concat($sClassPrefixGrid, '-', row-style-preselect)"/>
                </node>
            </xsl:if>
            <xsl:if test="enable-row-settings[value='Yes'] and normalize-space(row-settings/class) != ''">
                <node><xsl:value-of select="normalize-space(row-settings/class)"/></node>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="sClass">
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns" select="exsl:node-set($rtfClass)/*"/>
                <xsl:with-param name="glue" select="' '"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Build the style string, but only if row settings are enabled -->
        <xsl:variable name="sStyle">
            <xsl:if test="enable-row-settings[value='Yes']">
                <xsl:for-each select="row-settings">
                    <xsl:call-template name="grid-build-style-string"/>
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>

        <!-- If there's an error, spit it out. Otherwise build the columns RTF and pass that into the bs3-row creation template -->
        <xsl:choose>
            <xsl:when test="$sError = ''">
                <!-- Generate column information -->
                <xsl:variable name="rtfColumns">
                    <xsl:apply-templates select="column"/>
                </xsl:variable>

                <xsl:call-template name="bs3-row">
                    <xsl:with-param name="rtfColumns"><xsl:copy-of select="$rtfColumns"/></xsl:with-param>
                    <xsl:with-param name="sStyle" select="$sStyle"/>
                    <xsl:with-param name="sClass" select="$sClass"/>
                    <xsl:with-param name="id" select="$idSanitized"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$sError"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:short>Maps column information to Bootstrap 3 div elements</xd:short>
        <xd:detail>
            <p>Each column consists of a combination of WYSIWYG content, linked content blocks, background
            style information (image, color, etc.), additional styles, and column span information:
            either a defined number of columns or 'inherit' (take column information from the size below), or
            'auto', meaning to divide the remaining unallocated space evenly.</p>
            <p>After determining the RTF for the content block and WYSIWYG content, the style and class
            information is passed on to the Bootstrap layer column generator.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="column">
        <!-- Define the valid node specifications -->
        <!-- The paths are defined such that they're only checked if the 'enable-column-settings' is checked -->
        <xsl:variable name="rtfValidNodes">
            <nodedefs>
                <node>
                    <path>column-settings[preceding-sibling::enable-column-settings/value='Yes']/background-color</path>
                    <regex>^$|^#[a-f0-9]{6}$|^#[a-f0-9]{3}$|^rgb\((?:(?:\s*\d+\s*,){2}\s*\d+|(?:\s*\d+(?:\.\d+)?%\s*,){2}\s*\d+(?:\.\d+)?%)\s*\)$|^rgba\((?:(?:\s*\d+\s*,){3}|(?:\s*\d+(?:\.\d+)?%\s*,){3})\s*\d+(?:\.\d+)?\s*\)$</regex>
                    <flags>i</flags>
                    <level>warning</level>
                    <message>Invalid background-color specified</message>
                </node>
                <node>
                    <path>column-settings[preceding-sibling::enable-column-settings/value='Yes']/background-position</path>
                    <regex>^(?:left|right|center)\s+(top|center|bottom)|\d+(?:px|%|rem|ch|vh|vw|em|pt|ex|cm|mm|in|pc)\s+\d+(?:px|%|rem|ch|vh|vw|em|pt|ex|cm|mm|in|pc)$</regex>
                    <flags>i</flags>
                    <level>warning</level>
                    <message>Invalid background-position specified</message>
                </node>
                <node>
                    <path>column-settings[preceding-sibling::enable-column-settings/value='Yes']/background-repeat</path>
                    <regex>^(?:repeat|repeat-x|repeat-y|no-repeat|initial|inherit)$</regex>
                    <flags>i</flags>
                    <level>warning</level>
                    <message>Invalid background-repeat specified</message>
                </node>
                <node>
                    <path>column-settings[preceding-sibling::enable-column-settings/value='Yes']/background-size</path>
                    <regex>^(?:cover|contain|auto)$</regex>
                    <flags>i</flags>
                    <level>warning</level>
                    <message>Invalid background-size specified</message>
                </node>
                <node>
                    <path>column-settings[preceding-sibling::enable-column-settings/value='Yes']/background-image[@type='file']/path</path>
                    <regex>(?:jpg|gif|png|jpeg)$</regex>
                    <flags>i</flags>
                    <level>warning</level>
                    <message>Invalid background-image format specified</message>
                </node>
                <node>
                    <path>column-settings[preceding-sibling::enable-column-settings/value='Yes']/class</path>
                    <level>warning</level>
                    <regex>^(?:-?[_a-zA-Z]+[_a-zA-Z0-9-]*\s*)*$</regex>
                    <flags></flags>
                    <message>Invalid CSS class string specified</message>
                </node>
                <node>
                    <path>column-settings[preceding-sibling::enable-column-settings/value='Yes']/id</path>
                    <level>warning</level>
                    <regex>^(?:[a-zA-Z][\w:.-]*)?$</regex>
                    <flags></flags>
                    <message>Invalid HTML ID specified</message>
                </node>
            </nodedefs>
        </xsl:variable>

        <!-- Call the validate-nodes template which does the heavy lifting -->
        <xsl:variable name="sError">
            <xsl:call-template name="validate-nodes">
                <xsl:with-param name="nsValidDef" select="exsl:node-set($rtfValidNodes)"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Figure out the attributes of the column (if applicable) -->
        <xsl:variable name="idSanitized">
            <xsl:if test="enable-column-settings[value='Yes']">
                <xsl:value-of select="string:sanitizeHtmlId(string(column-settings/id))"/>
            </xsl:if>
        </xsl:variable>

        <!-- Determine if there's an additional class to be applied to this column -->
        <xsl:variable name="sClassAdditional">
            <xsl:if test="enable-column-settings[value='Yes'] and normalize-space(column-settings/class) != ''">
                <xsl:value-of select="normalize-space(column-settings/class)"/>
            </xsl:if>
        </xsl:variable>

        <!-- Figure out what the style string should be (if enable-column-settings is set) -->
        <xsl:variable name="sStyle">
            <xsl:if test="enable-column-settings[value='Yes']">
                <xsl:for-each select="column-settings">
                    <xsl:call-template name="grid-build-style-string"/>
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>

        <!-- Determine how many span columns this column should span -->
        <xsl:variable name="rtfColumnClass">
            <xsl:apply-templates select="responsive-settings/*"/>
        </xsl:variable>

        <!-- Convert into node set for easier processing -->
        <xsl:variable name="nsColumnClass" select="exsl:node-set($rtfColumnClass)"/>

        <!-- Join class columns together with spaces -->
        <xsl:variable name="sClassColBootstrap">
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns" select="$nsColumnClass/*"/>
                <xsl:with-param name="glue" select="' '"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Concatentate the Bootstrap column definition with the specified columns (if defined) -->
        <xsl:variable name="sClassCol">
            <xsl:choose>
                <xsl:when test="$sClassAdditional != ''">
                    <xsl:value-of select="concat($sClassColBootstrap, ' ', $sClassAdditional)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$sClassColBootstrap"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Generate the RTF for the WYSIWYG and linked content blocks -->
        <xsl:variable name="rtfContent">
            <xsl:if test="title[text() != '']">
                <h2><xsl:value-of select="title"/></h2>
            </xsl:if>
            <!-- WYSIWYG content -->
            <xsl:apply-templates select="content" mode="paragraph-wrap"/>

            <!-- Run down the display chain for any blocks -->
            <xsl:apply-templates select="ablock"/>
        </xsl:variable>

        <!-- Final output - if there's no validation error then generate the column. -->
        <xsl:choose>
            <xsl:when test="$sError = ''">
                <xsl:call-template name="bs3-column">
                    <xsl:with-param name="rtfContent" select="$rtfContent"/>
                    <xsl:with-param name="sClass" select="normalize-space($sClassCol)"/>
                    <xsl:with-param name="sStyle" select="normalize-space($sStyle)"/>
                    <xsl:with-param name="id" select="$idSanitized"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$sError"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:short>Bootstrap 3 layer named template to wrap a set of columns in a row.</xd:short>
        <xd:detail>
            <p>This template accepts row and style information and then wraps the
            passed in column RTF in a Bootstrap 3 row accordingly.</p>
        </xd:detail>
        <xd:param name="rtfColumns" type="rtf">Set of columns to wrap into a row</xd:param>
        <xd:param name="sClass" type="string">Additional class information to apply to row</xd:param>
        <xd:param name="sStyle" type="string">Additional style information to apply to row</xd:param>
        <xd:param name="id" type="string">Row identifier</xd:param>
    </xd:doc>
    <xsl:template name="bs3-row">
        <xsl:param name="rtfColumns"/>
        <xsl:param name="sClass" select="''"/>
        <xsl:param name="sStyle" select="''"/>
        <xsl:param name="id" select="''"/>
        <div>
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="$sClass != ''">
                        <xsl:value-of select="concat('row ', $sClass)"/>
                    </xsl:when>
                    <xsl:otherwise>row</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:if test="$sStyle != ''">
                <xsl:attribute name="style">
                    <xsl:value-of select="$sStyle"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$id != ''">
                <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="$rtfColumns"/>
        </div>
    </xsl:template>

    <xd:doc>
        <xd:short>Bootstrap 3 layer named template to wrap content in a column definition</xd:short>
        <xd:detail>
            <p>This template accepts row and style information and then wraps the
            passed in content RTF in a Bootstrap 3 column definition accordingly.</p>
            <p>The caller should either set the sColSpan parameter or pass in a Bootstrap
            column definition class (e.g. 'col-sm-8').</p>
        </xd:detail>
        <xd:param name="rtfContent" type="rtf">Set of columns to wrap into a columm</xd:param>
        <xd:param name="nColSpan" type="string">
            Number of columns (out of $nColMax) that this column should occupy.
            If set, this generates a 'col-$sViewportDefault-$nColSpan' class.
        </xd:param>
        <xd:param name="sClass" type="string">Bootstrap class information to apply to column</xd:param>
        <xd:param name="sStyle" type="string">Additional style information to apply to column</xd:param>
        <xd:param name="id" type="string">Column identifier</xd:param>
    </xd:doc>
    <xsl:template name="bs3-column">
        <xsl:param name="rtfContent"/>
        <xsl:param name="nColSpan"/>
        <xsl:param name="sClass">
            <xsl:if test="$nColSpan != ''">
                <xsl:value-of select="concat('col-', $sViewportDefault, '-', '$nColSpan')"/>
            </xsl:if>
        </xsl:param>
        <xsl:param name="sStyle" select="''"/>
        <xsl:param name="id" select="''"/>
        <div class="{$sClass}">
            <xsl:if test="$sStyle != ''">
                <xsl:attribute name="style">
                    <xsl:value-of select="$sStyle"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$id != ''">
                <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="$rtfContent"/>
        </div>
    </xsl:template>

    <xd:doc>
        <xd:short>Helper template to build the class definition (column span and offset) for the responsive column.</xd:short>
        <xd:detail>
            <p>For more information on the grid classes, see the Bootstrap 3 page:<br/>
                http://getbootstrap.com/css/#grid</p>
                <p>For each type of viewport size (currently: xs, sm, md, lg), build Bootstrap class definition snippet by:</p>
                <ul>
                    <li>determine # of columns remaining to allocate (max # of columns - sum of defined columns (!auto))</li>
                    <li>split that number evenly (default column #)</li>
                    <li>if # of columns is set to auto, then set to to default column #</li>
                    <li>else if # columns are defined, then set to defined column #</li>
                    <li>else omit style string (inherit)</li>
                </ul>
                <p>The output format will look like:</p>
                &lt;columnclass&gt;<br/>
                    &lt;colspan&gt;col-md-5&lt;/colspan&gt;<br/>
                    &lt;offset&gt;col-md-offset-2&lt;/offset&gt;<br/>
                &lt;/columnclass&gt;<br/>
        </xd:detail>
    </xd:doc>
    <xsl:template match="column/responsive-settings/*">
        <!-- Preserve the name of the current node for use in select statements -->
        <xsl:variable name="sName" select="name()"/>

        <!-- Get the total set of visible columns at this level which are marked to be not hidden -->
        <xsl:variable name="nsCol" select="(ancestor::row)[1]/column/responsive-settings/*[name() = $sName][not(hide/value = 'Yes')]/columns"/>

        <!--
        nsColDerived is comprised of the union of the following:
            All columns (spans) at the given viewport size whose value is not 'inherit'

        The nsColDerived set may contain values of 'auto'.
        -->
        <xsl:variable name="nsColDerived" select="$nsCol[. != 'inherit']"/>

        <!-- Get # of columns left to allocate -->
        <xsl:variable name="nColRemaining">
            <xsl:choose>
                <xsl:when test="count($nsColDerived) = 0">
                    <xsl:value-of select="$nColumnTotal"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$nColumnTotal - sum($nsColDerived[. != 'auto'])"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Determine the default # of columns -->
        <xsl:variable name="nColDefault">
            <xsl:choose>
                <!-- Test if we have remaining columns to allocate -->
                <xsl:when test="($nColRemaining &gt; 0) and ($nsColDerived[. = 'auto'])">
                    <!-- Yes!  Divide amongst 'auto' columns -->
                    <xsl:value-of select="floor($nColRemaining div count($nsColDerived[. = 'auto']))"/>
                </xsl:when>
                <!-- Otherwise, use the 'NaN' value to denote error or invalid condition -->
                <xsl:otherwise>NaN</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="sClassSpan">
            <xsl:choose>
                <!-- If this column is hidden, set the column class as hidden -->
                <xsl:when test="hide/value = 'Yes'"><xsl:value-of select="concat('hidden-', name())"/></xsl:when>
                <!--
                If this column is set to auto,
                    and all sibling columns are set to auto for this size,
                    and this is the default column specifier,
                then split the columns evenly
                 -->
                <xsl:when test="
                    columns = 'auto'
                    and count($nsCol[. != 'auto']) = 0
                    and name() = $sViewportDefault
                    ">
                    <xsl:value-of select="concat('col-', name(), '-', $nColDefault)"/>
                </xsl:when>

                <!-- If this column is set to auto and there are sibling columns which are set explicitly, then set this column to be the default column width -->
                <xsl:when test="
                    columns = 'auto'
                    and $nsCol[. != 'auto']">
                    <xsl:value-of select="concat('col-', name(), '-', $nColDefault)"/>
                </xsl:when>

                <!-- If the column size isn't auto then output it -->
                <xsl:when test="columns != 'auto' and columns != 'inherit'">
                    <xsl:value-of select="concat('col-', name(), '-', columns)"/>
                </xsl:when>

                <!-- No default action - the sViewportDefault case should handle this -->
            </xsl:choose>
        </xsl:variable>

        <!-- Build offset span string -->
        <xsl:variable name="sClassOffset">
            <xsl:choose>
                <!-- If this column is to be hidden then do nothing -->
                <xsl:when test="hide/value = 'Yes'"></xsl:when>
                <!-- Do nothing for this case - it's handled by smaller viewport sizes -->
                <xsl:when test="offset = 'inherit'"></xsl:when>
                <!-- Do nothing for the 0 case -->
                <xsl:when test="offset = 0"></xsl:when>
                <xsl:otherwise><xsl:value-of select="concat('col-', name(), '-offset-', offset)"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Output column class definition RTF which will be converted into node set by caller -->
        <xsl:if test="$sClassSpan != ''">
            <colspan><xsl:value-of select="$sClassSpan"/></colspan>
        </xsl:if>
        <xsl:if test="$sClassOffset != ''">
            <offset><xsl:value-of select="$sClassOffset"/></offset>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:short>Generates a valid CSS string based on row-settings or column-settings parameters.</xd:short>
        <xd:detail>
            <p>Takes the current context node (column-settings) and builds a CSS style string.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template name="grid-build-style-string" priority="-1">
        <xsl:for-each select="background-image | background-color | background-position | background-repeat | background-size">
            <xsl:choose>
                <!-- if this is a real background image then output the style -->
                <xsl:when test="name() = 'background-image' and @type='file'">
                    <xsl:value-of select="concat('background-image: url(', path, '); ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <!--
                    if this is a background-color style and it's not blank
                        or if the background-image is specified,
                    then output the style parameter
                     -->
                    <xsl:if test="(name() = 'background-color' and text() != '') or parent::column_settings/background-image[@type='file']">
                        <xsl:value-of select="concat(name(), ': ', text(), '; ')"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
