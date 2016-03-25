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
    <xsl:variable name="nColumnTotal">12</xsl:variable>
    <xsl:variable name="nViewportDefault">sm</xsl:variable>

    <!-- Top level block pattern to match the "tab" data definition -->
    <xsl:template match="system-data-structure[row]">
        <xsl:apply-templates select="row"/>
    </xsl:template>

    <xd:doc>Create key for easier calculation of column spans</xd:doc>
    <xsl:key name="keyColSpan" match="responsive-settings/*[not(hide/value)]/columns" use="name(..)"/>

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
                <!-- Generate column information -->
                <xsl:variable name="rtfColumns">
                    <xsl:apply-templates select="column"/>
                </xsl:variable>

                <xsl:call-template name="bs3-row">
                    <xsl:with-param name="rtfColumns"><xsl:copy-of select="$rtfColumns"/></xsl:with-param>
                    <xsl:with-param name="sStyle" select="normalize-space($sStyle)"/>
                    <xsl:with-param name="sClass" select="normalize-space(row-settings/class)"/>
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
        <xsl:variable name="rtfClassCol">
            <xsl:apply-templates select="responsive-settings/*"/>
        </xsl:variable>

        <!-- Convert into node set for easier processing -->
        <xsl:variable name="nsClassCol" select="exsl:node-set($rtfClassCol)"/>

        <!-- Join class columns together with spaces -->
        <xsl:variable name="sClassColBootstrap">
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns" select="$nsClassCol/columnclass/colspan[text() != ''] | $nsClassCol/columnclass/offset[text() != '']"/>
                <xsl:with-param name="glue" select="' '"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Concatentate the Bootstrap column definition with the specified columns (if defined) -->
        <xsl:variable name="sClassCol">
            <xsl:choose>
                <xsl:when test="class != ''">
                    <xsl:value-of select="concat($sClassColBootstrap, ' ', class)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$sClassColBootstrap"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Generate the RTF for the WYSIWYG and linked content blocks -->
        <xsl:variable name="rtfContent">
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
            If set, this generates a 'col-$nViewportDefault-$nColSpan' class.
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
                <xsl:value-of select="concat('col-', $nViewportDefault, '-', '$nColSpan')"/>
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
        <!-- Get the total set of columns at this level which are marked to be not hidden -->
        <xsl:variable name="nsCol" select="key('keyColSpan', name(.))"/>

        <!--
        nsColDerived is comprised of the following:
            All columns (spans) at the given viewport size whose value is not 'inherit'
            The columns node of the nearest preceding sibling whose columns value is not marked as 'inherit'

        The nsColDerived set may contain values of 'auto'.
        -->
        <xsl:variable name="nsColDerived" select="$nsCol[. != 'inherit'] | ($nsCol[. = 'inherit']/../preceding-sibling::*[columns != 'inherit'][1]/columns)"/>

        <!-- Get # of columns left to allocate -->
        <xsl:variable name="nColRemaining" select="$nColumnTotal - sum($nsColDerived[. != 'auto'])"/>

        <!-- Get # of columns for default columns -->
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

        <!-- Build class span string -->
        <xsl:variable name="sClassSpan">
            <xsl:choose>
                <!-- If this column is to be hidden then set the class to be hidden -->
                <xsl:when test="hide/value = 'Yes'"><xsl:value-of select="concat('hidden-', name())"/></xsl:when>
                <!-- This is an auto span column. Set the column span to be the default span (if valid) -->
                <xsl:when test="columns = 'auto' and $nColDefault != 'NaN'"><xsl:value-of select="concat('col-', name(), '-', $nColDefault)"/></xsl:when>
                <!-- Do nothing for this case. Would be good spot for assertion. -->
                <xsl:when test="columns = 'auto' and $nColDefault = 'NaN'"></xsl:when>
                <!-- Do nothing for this case -->
                <xsl:when test="columns = 'inherit'"></xsl:when>
                <xsl:otherwise><xsl:value-of select="concat('col-', name(), '-', columns)"/></xsl:otherwise>
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
        <columnclass>
            <colspan><xsl:value-of select="$sClassSpan"/></colspan>
            <offset><xsl:value-of select="$sClassOffset"/></offset>
        </columnclass>
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

    <xd:doc>
        <xd:short>Validate the background settings for either column- or row-settings</xd:short>
        <xd:detail><p>This helper template defines valid settings for certain
        child parameters of column- and row-settings nodes such as background-color,
        background-position, etc. based on regular expressions using the
        error.xslt library function validate-nodes.</p></xd:detail>
    </xd:doc>
    <xsl:template name="grid-validate-background-settings" priority="-1">
        <!-- Define the valid node specifications -->
        <xsl:variable name="rtfValidNodes">
            <nodedefs>
                <node>
                    <path>background-color</path>
                    <regex>^$|^#[a-f0-9]{6}$|^#[a-f0-9]{3}$|^rgb\((?:(?:\s*\d+\s*,){2}\s*\d+|(?:\s*\d+(?:\.\d+)?%\s*,){2}\s*\d+(?:\.\d+)?%)\s*\)$|^rgba\((?:(?:\s*\d+\s*,){3}|(?:\s*\d+(?:\.\d+)?%\s*,){3})\s*\d+(?:\.\d+)?\s*\)$</regex>
                    <flags>i</flags>
                    <level>warning</level>
                    <message>Invalid background-color specified</message>
                </node>
                <node>
                    <path>background-position</path>
                    <regex>^(?:left|right|center)\s+(top|center|bottom)|\d+(?:px|%|rem|ch|vh|vw|em|pt|ex|cm|mm|in|pc)\s+\d+(?:px|%|rem|ch|vh|vw|em|pt|ex|cm|mm|in|pc)$</regex>
                    <flags>i</flags>
                    <level>warning</level>
                    <message>Invalid background-position specified</message>
                </node>
                <node>
                    <path>background-repeat</path>
                    <regex>^(?:repeat|repeat-x|repeat-y|no-repeat|initial|inherit)$</regex>
                    <flags>i</flags>
                    <level>warning</level>
                    <message>Invalid background-repeat specified</message>
                </node>
                <node>
                    <path>background-size</path>
                    <regex>^(?:cover|contain|auto)$</regex>
                    <flags>i</flags>
                    <level>warning</level>
                    <message>Invalid background-size specified</message>
                </node>
                <node>
                    <path>background-image/path</path>
                    <regex>(?:jpg|gif|png|jpeg)$</regex>
                    <flags>i</flags>
                    <level>warning</level>
                    <message>Invalid background-image format specified</message>
                </node>
            </nodedefs>
        </xsl:variable>

        <!-- Call the validate-nodes template which does the heavy lifting -->
        <xsl:call-template name="validate-nodes">
            <xsl:with-param name="nsValidDef" select="exsl:node-set($rtfValidNodes)"/>
            <xsl:with-param name="nodeParentNode" select="."/>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
