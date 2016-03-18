<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:string="my:string"
    exclude-result-prefixes="string"
    >
    
    <xsl:import href="string.xslt"/>
    <xsl:strip-space elements="*"/>
    <xsl:output 
                method='html'
                indent='yes'
                omit-xml-declaration='yes'
                />
                
    <!-- 
    Template: log-info

    Outputs <proc-msg> HTML element to document an info string for the browser.

    Parameters:
        message (string) - Message to display, description of info
        nsToLog (node set) - Node set to dump out
    -->
    <xsl:template name="log-info" priority="-1">
        <xsl:param name="message" select="Unknown"/>
        <xsl:param name="nsToLog" select="."/>
        <xsl:call-template name="proc-msg">
            <xsl:with-param name="message" select="$message"/>
            <xsl:with-param name="nsToLog" select="$nsToLog"/>
            <xsl:with-param name="level">info</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- 
    Template: log-warning
    
    Outputs <proc-msg> HTML element to document a warning for the browser.
    
    Parameters:
        message (string) - Message to display, description of warning
        nsToLog (node set) - Node set to dump out
    -->
    <xsl:template name="log-warning" priority="-1">
        <xsl:param name="message" select="Unknown"/>
        <xsl:param name="nsToLog" select="."/>
        <xsl:call-template name="proc-msg">
            <xsl:with-param name="message" select="$message"/>
            <xsl:with-param name="nsToLog" select="$nsToLog"/>
            <xsl:with-param name="level">warning</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- 
    Template: log-error

    Outputs <proc-msg> HTML element to document a warning for the browser.

    Parameters:
        message (string) - Message to display, description of warning
        nsToLog (node set) - Node set to dump out
    -->
    <xsl:template name="log-error" priority="-1">
        <xsl:param name="message" select="Unknown"/>
        <xsl:param name="nsToLog" select="."/>
        <xsl:call-template name="proc-msg">
            <xsl:with-param name="message" select="$message"/>
            <xsl:with-param name="nsToLog" select="$nsToLog"/>
            <xsl:with-param name="level">error</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- 
    Template: proc-msg

    Outputs <proc-msg> HTML element to document a message for the browser.

    Parameters:
        message (string) - Message to display, description of warning
        nsToLog (node set) - Node set to dump out
        level - log level. Defined by user agent
    -->
    <xsl:template name="proc-msg">
        <xsl:param name="message"/>
        <xsl:param name="nsToLog"/>
        <xsl:param name="level"/>
        <!-- The indentation below is off on purpose -->
        <proc-msg level="{$level}">
            <xsl:value-of select="$nl"/>
            <xsl:value-of select="concat(string:upperCase(string($level)), ': ', $message)"/>
            <xsl:if test="$nsToLog">
                <xsl:for-each select="$nsToLog">
    **************************************************
    <xsl:value-of select="concat('Node (', position(), '/', last(), ')')"/>
    Type of node: <xsl:value-of select="name(.)"/>
                    <xsl:if test="name">
    Node name: <xsl:value-of select="name"/>
                    </xsl:if>
    Node dump:
<xsl:call-template name="node-path-dump">
    <xsl:with-param name="nodeToDump" select="."/>
</xsl:call-template>
    **************************************************
                </xsl:for-each>
            </xsl:if>
        </proc-msg>
    </xsl:template>
    
    <!-- Recursively dump out the names of the current and node and its ancestors -->
    <xsl:template name="node-path-dump">
        <xsl:param name="nodeToDump" select="."/>
        <xsl:text>        </xsl:text><xsl:value-of select="concat('- ', name($nodeToDump), $nl)"/>
        <xsl:if test="$nodeToDump/.. and string-length(name($nodeToDump/..))">
            <xsl:call-template name="node-path-dump">
                <xsl:with-param name="nodeToDump" select="$nodeToDump/.."/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>