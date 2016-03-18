<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:my="my:string"
                xmlns:xalan="http://xml.apache.org/xalan"
                exclude-result-prefixes="my xalan"
                >

    <xsl:variable name="nl"><xsl:text>&#xa;</xsl:text></xsl:variable>

    <xsl:strip-space elements="*"/>
    <xsl:output 
                method='html'
                indent='yes'
                omit-xml-declaration='yes'
                />
    
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
                sReplace = sReplace === undefined ? sReplace : '';
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