<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-03-16T14:18:27-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-08-11T11:05:15-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

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
                    <li>generateId(s) - Append a somewhat initially random, incrementing identifer onto a base string</li>
                    <ul>
                        <li>s - string to append unique identifier onto</li>
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
        <xsl:param name="nodeToWrap" select="."/>
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
        <xd:short>Helper template to encapsulate node's children in a CDATA section.</xd:short>
        <xd:detail>
            <p>Storing HTML within XML requires that we encapsulate the data within a CDATA section to avoid deeper parsing by XML parsers down the line. This is handy for example when transmitting a set of articles, each written in HTML, to a browser within an XML container document.</p>
            <p>One thing to consider: HTML entities such as &amp;#160; will be output as &amp;amp;#160;. This will likely need further processing down the road.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template name="cdata-wrap">
        <xsl:param name="nodeToWrap" select="."/>
        <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
        <xsl:choose>
            <xsl:when test="$nodeToWrap[text()]">
                    <xsl:value-of select="."/>
            </xsl:when>
            <xsl:when test="$nodeToWrap[node()]">
                <xsl:copy-of select="$nodeToWrap/*"/>
            </xsl:when>
        </xsl:choose>
        <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
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

    <xd:doc>
        <xd:short>Helper template to output attributes in data-friendly way.</xd:short>
        <xd:detail>
            <p>If you want data parameters to be output as attributes for some other element, then you'd invoke this template. Each item is output with the same name as the variable but prefixed with 'data-'.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="node()" mode='data-attribute'>
        <xsl:attribute name="{concat('data-', name())}">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <xalan:component functions="sanitizeHtmlId upperCase lowerCase regexTest generateId" prefix="my">
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

            /*
            * generateId - Add a unique identifier onto a base string. The identifier will increment with every call.
            *
            * Parameters
            *   s - string to append the identifier onto
            *
            * Based on function found here (via jfriend00): http://stackoverflow.com/questions/6860853/generate-random-string-for-div-id
            */
            var generateId = (function () {
                var globalIdCounter = Math.floor(Math.random() * (9999999 - 1000000) + 1000000);
                return function(s) {
                    return(s + globalIdCounter++);
                }
            })();
            ]]>
        </xalan:script>
    </xalan:component>

</xsl:stylesheet>
