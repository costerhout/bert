<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-03-16T14:18:27-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-06-01T23:13:31-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->


<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:my="my:string"
                xmlns:xalan="http://xml.apache.org/xalan"
                exclude-result-prefixes="my xd xalan"
                >

    <xsl:variable name="nl"><xsl:text>&#xa;</xsl:text></xsl:variable>
    <xsl:variable name="nbsp"><xsl:text>&#160;</xsl:text></xsl:variable>

    <xsl:strip-space elements="*"/>
    <xsl:output
                method='html'
                indent='yes'
                omit-xml-declaration='yes'
                />

    <xd:doc type="stylesheet">
        <xd:short>Provides useful string manipulation functions and templates.</xd:short>
        <xd:detail>
            <p>This component provides the following string functions:</p>
                <ul>
                    <li>sanitizeHtmlId(sHtmlId, sReplace) - Clean up a string suitable for an HTML ID field</li>
                    <ul>
                        <li>
                            sHtmlId - string to operate on
                        </li>
                        <li>
                            sReplace (optional) - character to replace invalid characters with
                        </li>
                    </ul>
                    <li>upperCase(s) - Convert a string to upper case</li>
                    <li>lowerCase(s) - Convert a string to lower case</li>
                    <li>regexTest(s, s_re, flags) - Returns true if s matches s_re, false otherwise</li>
                    <ul>
                        <li>s - string to operate on</li>
                        <li>s_re - regular expression pattern, without slashes or flags</li>
                        <li>flags (optional) - set of flags to manipulate regular expression searching</li>
                    </ul>
                </ul>
            <p>In addition, the following helper templates are defined:</p>
            <ul>
                <li>nodeset-join</li>
            </ul>
        </xd:detail>
    </xd:doc>

    <xd:doc>
        <xd:short>Helper utility to join together nodes into one longer string</xd:short>
        <xd:detail></xd:detail>
        <xd:param name="ns" type='nodeset'>Node set to join together</xd:param>
        <xd:param name="glue" type="string">String used in between nodes. By default the string ', ' is used.</xd:param>
    </xd:doc>
    <xsl:template name='nodeset-join'>
        <xsl:param name="ns" select="."/>
        <xsl:param name='glue'>, </xsl:param>
        <xsl:for-each select="$ns">
            <!-- Only output non-empty node -->
            <xsl:if test="text() or node()">
                <xsl:value-of select="."/>
                <!-- Only output glue if there's a node following that has text -->
                <xsl:if test='(position() != last()) and ./following-sibling::*[text() or node()]'><xsl:value-of select="$glue"/></xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:short>Helper template to wrap bare text in a node.</xd:short>
        <xd:detail><p>Wraps bare text() in a &lt;p&gt; tag by default, or a &lt;div&gt;
            tag if classWrap is defined and the nodeToWrap passed in is a node
            (not a text node).</p></xd:detail>
        <xd:param name="nodeToWrap" type="node">The text() or node() node to wrap</xd:param>
        <xd:param name="classWrap" type="string">Class string to apply to the &lt;p&gt; tag.</xd:param>
    </xd:doc>
    <xsl:template name="paragraph-wrap">
        <xsl:param name="nodeToWrap"/>
        <xsl:param name="classWrap"/>
        <xsl:choose>
            <xsl:when test="$nodeToWrap[text()]">
                <p>
                    <xsl:if test="$classWrap != ''">
                        <xsl:attribute name="class"><xsl:value-of select="$classWrap"/></xsl:attribute>
                    </xsl:if>
                    <xsl:copy-of select="normalize-space(string($nodeToWrap))"/>
                </p>
            </xsl:when>
            <xsl:when test="$nodeToWrap[node()]">
                <xsl:choose>
                    <xsl:when test="$classWrap != ''">
                        <div class="{$classWrap}">
                            <xsl:copy-of select="$nodeToWrap/*"/>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$nodeToWrap/*"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:short>Helper template to convert a string with delimiters into a set of nodes as a result tree fragment (RTF).</xd:short>
        <xd:detail>
            <p>Modified from original found at http://www.heber.it/?p=1088</p>
        </xd:detail>
        <xd:param name="sString" type="string">String to parse</xd:param>
        <xd:param name="sDelimiter" type="string">Character[s] to break up string on.</xd:param>
    </xd:doc>
    <xsl:template name="tokenize-string">
        <xsl:param name="sString"/>
        <xsl:param name="sDelimiter"/>

        <xsl:choose>
            <!-- Search for the delimiter -->
            <xsl:when test="contains($sString, $sDelimiter)">
                <xsl:if test="not(starts-with($sString, $sDelimiter))">
                    <!-- Delimiter found, create RTF node of everything prior to the delimiter -->
                    <node>
                        <xsl:value-of select="substring-before($sString,$sDelimiter)"/>
                    </node>
                </xsl:if>
                <!-- Recursively call the template to continue parsing -->
                <xsl:call-template name="tokenize-string">
                    <!-- Pass what remains of the string after the current parsed token -->
                    <xsl:with-param name="sString" select="substring-after($sString,$sDelimiter)"/>
                    <xsl:with-param name="sDelimiter" select="$sDelimiter"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <!-- Check for the empty string case -->
                    <xsl:when test="$sString = ''">
                        <xsl:text/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Output last node -->
                        <node>
                            <xsl:value-of select="$sString"/>
                        </node>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xalan:component functions="sanitizeHtmlId upperCase lowerCase regexTest" prefix="my">
        <xalan:script lang="javascript">
            <![CDATA[
            /*
            * sanitizeHtmlId - check for valid HTML id (HTML 4.01 and above) and replace invalid
            *     characters with a replacement character.
            *
            * Parameters
            *    sHtmlId - HTML element ID to operate on
            *    sReplace - String to replace with, or removed if not provided
            */
            function sanitizeHtmlId (sHtmlId, sReplace) {
                var re = /^[^a-zA-Z]|[^\w\-]/g;

                if (typeof sReplace === 'undefined') {
                    sReplace = '';
                }

                return sHtmlId.replace(re, sReplace);
            }

            function upperCase (s) {
                return s.toUpperCase();
            }

            function lowerCase (s) {
                return s.toLowerCase();
            }

            function regexTest (s, s_re, flags) {
                if (flags === undefined) {
                    flags = '';
                }

                var re = new RegExp(s_re, flags);
                return re.test(s);
            }
            ]]>
        </xalan:script>
    </xalan:component>

</xsl:stylesheet>
