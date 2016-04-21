<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:string="my:string"
    xmlns:exsl="http://exslt.org/common"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:dyn="http://exslt.org/dynamic"
    extension-element-prefixes="exsl dyn"
    exclude-result-prefixes="string exsl dyn xd"
    >

    <xsl:import href="string.xslt"/>
    <xsl:strip-space elements="*"/>
    <xsl:output
                method='html'
                indent='yes'
                omit-xml-declaration='yes'
                />

    <xsl:param name="sEnableDebugMessages" select="false"/>

    <xd:doc>
        <xd:short>Produce an info message via the proc-msg template</xd:short>
        <xd:detail><p>This is a wrapper template which calls proc-msg with an level of 'info'.</p></xd:detail>
        <xd:param name="message" type="string">Message to output in &lt;message&gt; field</xd:param>
        <xd:param name="nsToLog" type="node-set">Node set to log as a part of the message</xd:param>
    </xd:doc>
    <xsl:template name="log-info" priority="-1">
        <xsl:param name="message" select="Unknown"/>
        <xsl:param name="nsToLog" select="."/>
        <xsl:call-template name="proc-msg">
            <xsl:with-param name="message" select="$message"/>
            <xsl:with-param name="nsToLog" select="$nsToLog"/>
            <xsl:with-param name="level">info</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:short>Produce an error message via the proc-msg template</xd:short>
        <xd:detail><p>This is a wrapper template which calls proc-msg with an level of 'warning'.</p></xd:detail>
        <xd:param name="message" type="string">Message to output in &lt;message&gt; field</xd:param>
        <xd:param name="nsToLog" type="node-set">Node set to log as a part of the message</xd:param>
    </xd:doc>
    <xsl:template name="log-warning" priority="-1">
        <xsl:param name="message" select="Unknown"/>
        <xsl:param name="nsToLog" select="."/>
        <xsl:call-template name="proc-msg">
            <xsl:with-param name="message" select="$message"/>
            <xsl:with-param name="nsToLog" select="$nsToLog"/>
            <xsl:with-param name="level">warning</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:short>Produce an error message via the proc-msg template</xd:short>
        <xd:detail><p>This is a wrapper template which calls proc-msg with an level of 'error'.</p></xd:detail>
        <xd:param name="message" type="string">Message to output in &lt;message&gt; field</xd:param>
        <xd:param name="nsToLog" type="node-set">Node set to log as a part of the message</xd:param>
    </xd:doc>
    <xsl:template name="log-error" priority="-1">
        <xsl:param name="message" select="Unknown"/>
        <xsl:param name="nsToLog" select="."/>
        <xsl:call-template name="proc-msg">
            <xsl:with-param name="message" select="$message"/>
            <xsl:with-param name="nsToLog" select="$nsToLog"/>
            <xsl:with-param name="level">error</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:short>Produce a proc-msg node so we can post process errors</xd:short>
        <xd:detail>
            <p>This template produces an XML structure that a browser or
            other user agent can parse at a later time and inform the user.</p>
            <p>Sample output:</p>
            &lt;proc-msg level=&quot;warning&quot;&gt;<br/>
                &lt;message&gt;Invalid background-image specified: &quot;/juneau/images/eagle-soar-sm.jpeg&quot;&lt;/message&gt;<br/>
                &lt;node&gt;<br/>
                    &lt;type&gt;row-settings&lt;/type&gt;<br/>
                    &lt;trace&gt;/system-data-structure/row/row-settings/background-image/path&lt;/trace&gt;<br/>
                &lt;/node&gt;<br/>
            &lt;/proc-msg&gt;
        </xd:detail>
        <xd:param name="message" type="string">Message to output in &lt;message&gt; field</xd:param>
        <xd:param name="nsToLog" type="node-set">Node set to log as a part of the message</xd:param>
        <xd:param name="level" type="string">Error level, e.g. 'error', 'warning', or 'info'</xd:param>
    </xd:doc>
    <xsl:template name="proc-msg">
        <xsl:param name="message"/>
        <xsl:param name="nsToLog"/>
        <xsl:param name="level"/>
        <!-- Output the message in XML-parser friendly format -->
        <!-- The indentation below is off on purpose -->
        <proc-msg level="{$level}">
            <message><xsl:value-of select="$message"/></message>
            <xsl:if test="$nsToLog">
                <xsl:for-each select="$nsToLog">
                    <node>
                        <type><xsl:value-of select="name(.)"/></type>
                        <xsl:if test="name">
                            <name><xsl:value-of select="name"/></name>
                        </xsl:if>
                        <trace>
                            <xsl:call-template name="node-path-dump">
                                <xsl:with-param name="nodeToDump" select="."/>
                            </xsl:call-template>
                        </trace>
                    </node>
                </xsl:for-each>
            </xsl:if>
        </proc-msg>

        <!-- If we're in debug mode, then output warning and info messages to the parser's error handler -->
        <!-- We always output error messages -->
        <xsl:if test="$sEnableDebugMessages or $level = 'error'">
            <xsl:message><xsl:value-of select="$message"/></xsl:message>
            <xsl:for-each select="$nsToLog">
                <xsl:message>Type: <xsl:value-of select="name(.)"/></xsl:message>
                <xsl:if test="name">
                    <xsl:message>Name: <xsl:value-of select="name"/></xsl:message>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:short>Validate nodeset based on node definitions and build error
            message result tree fragment (RTF)</xd:short>
        <xd:detail>
            <p>Input node definition format:</p>
            <code>
                &lt;nodedefs&gt;<br/>
                    &lt;node&gt;<br/>
                        &lt;path&gt;background-color&lt;/path&gt;<br/>
                        &lt;regex&gt;^$|^#[a-f0-9]{6}$|^#[a-f0-9]{3}$|^rgb\((?:(?:\s*\d+\s*,){2}\s*\d+|(?:\s*\d+(?:\.\d+)?%\s*,){2}\s*\d+(?:\.\d+)?%)\s*\)$|^rgba\((?:(?:\s*\d+\s*,){3}|(?:\s*\d+(?:\.\d+)?%\s*,){3})\s*\d+(?:\.\d+)?\s*\)$&lt;/regex&gt;<br/>
                        &lt;flags&gt;i&lt;/flags&gt;<br/>
                        &lt;level&gt;error&lt;/level&gt;<br/>
                        &lt;message&gt;Invalid background-color specified&lt;/message&gt;<br/>
                    &lt;/node&gt;<br/>
                &lt;/nodedefs&gt;<br/>
            </code>
            <p>Output sample RTF (based on proc-msg template format):</p>
            &lt;proc-msg level=&quot;error&quot;&gt;<br/>
                &lt;message&gt;Invalid background-color specified: &quot;badrgb(12,12,12)&quot;&lt;/message&gt;<br/>
                &lt;node&gt;<br/>
                &lt;type&gt;background-color&lt;/type&gt;<br/>
                &lt;trace&gt;/system-data-structure/row/row-settings/background-color&lt;/trace&gt;<br/>
                &lt;/node&gt;<br/>
            &lt;/proc-msg&gt;<br/>
        </xd:detail>
        <xd:param name="nsValidDef" type="node-set">Valid child node definitions in node-set form</xd:param>
        <xd:param name="nodeParentNode" type="node">Parent node to serve as root of search path</xd:param>
    </xd:doc>
    <xsl:template name="validate-nodes">
        <xsl:param name="nsValidDef"/>
        <xsl:param name="nodeParentNode" select="."/>

        <!-- Set the context for checking to a node definition -->
        <xsl:for-each select="$nsValidDef/nodedefs/node">
            <!-- Get the set of definitions to check against -->
            <!-- Set up the variables we'll use to check against the various nsNodesToCheck -->
            <xsl:variable name="regex" select="regex"/>
            <xsl:variable name="flags" select="flags"/>
            <xsl:variable name="path" select="path"/>
            <xsl:variable name="level" select="level"/>
            <xsl:variable name="message" select="message"/>

            <!-- Set the context to the set of nodes to check -->
            <xsl:for-each select="$nodeParentNode">
                <!-- Use the exslt library's dynamic evaluation function to
                evaluate an XPath expression generated on the fly, checking
                the value against the regular expression -->
                <xsl:if test="dyn:evaluate($path) and not(string:regexTest(string(dyn:evaluate($path)), string($regex), string($flags)))">
                    <!-- We have an error.  Call the proc-msg template
                    with error parameters -->
                    <xsl:call-template name="proc-msg">
                        <xsl:with-param name="message" select="concat($message, ': &quot;', dyn:evaluate($path), '&quot;')"/>
                        <xsl:with-param name="nsToLog" select="dyn:evaluate($path)"/>
                        <xsl:with-param name="level" select="$level"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:short>Recursively dump out the names of the current and node and its ancestors</xd:short>
        <xd:detail>
            <p>This template creates the node path for the passed in node (or current node by default)
            in the form of "/root/path/to/node"</p>
        </xd:detail>
        <xd:param name="nodeToDump" type="node">Node to dump</xd:param>
        <xd:param name="level" type="number">Path segment to dump</xd:param>
    </xd:doc>
    <xsl:template name="node-path-dump">
        <xsl:param name="nodeToDump" select="."/>
        <xsl:param name="level" select='-1'/>
        <!-- Decision tree based on the value of the level parameter -->
        <xsl:choose>
            <!-- Init condition: print the initial '/' and then recurse, starting from
            the first ancestor -->
            <xsl:when test="$level = -1">
                <xsl:value-of select="'/'"/>
                <xsl:call-template name="node-path-dump">
                    <xsl:with-param name="nodeToDump" select="$nodeToDump"/>
                    <xsl:with-param name="level" select="count(./ancestor::*)"/>
                </xsl:call-template>
            </xsl:when>

            <!-- We're not to the end yet, print out this path segment -->
            <xsl:when test="$level &gt; 0">
                <xsl:value-of select="concat(name($nodeToDump/ancestor::*[$level]), '/')"/>

                <xsl:call-template name="node-path-dump">
                    <xsl:with-param name="nodeToDump" select="$nodeToDump"/>
                    <xsl:with-param name="level" select="$level - 1"/>
                </xsl:call-template>
            </xsl:when>

            <!-- We're now at the end of the line, print out the current node
            name and stop recursing -->
            <xsl:when test="$level = 0">
                <xsl:value-of select="name($nodeToDump)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
