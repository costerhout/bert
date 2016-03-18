<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:key="my:key-value-map"
                extension-element-prefixes="key"
                >
    <xsl:import href="../util/key-value-map.xslt"/>
    <xsl:output method="html" indent='yes' omit-xml-declaration='yes'/>
    
    <!--
    getfiletype
        Determine type of file based on the filename extension (portion of 
        filename after the final '.').  Performs case insensitive search.
        Following types of files are defined:
            image: jpg, jpeg, png, gif, bmp
            document: pdf, doc, xls, xlsx, docx, ppt, pptx
    
    Parameters:
        path (string) - File path to parse, in UNIX form (e.g. /some/path/to/file.jpg)
        
    Returns:
        (string) - Either "image", "document", or the empty string if unknown.
    -->
    <xsl:template name="getfiletype">
        <xsl:param name="path"/>
        
        <!-- Determine the file extension with a helper template -->
        <xsl:variable name="extension"><xsl:call-template name="get-file-extension">
            <xsl:with-param name="path" select="$path"/>
            </xsl:call-template>
        </xsl:variable>
        
        <!-- Initialize the map of extensions to file types -->
        <key:mapInit name="extensionToFileType" casesensitive="false">
            <entry name="jpg" value="image"/>
            <entry name="jpeg" value="image"/>
            <entry name="png" value="image"/>
            <entry name="gif" value="image"/>
            <entry name="bmp" value="image"/>
            <entry name="pdf" value="document"/>
            <entry name="doc" value="document"/>
            <entry name="docx" value="document"/>
            <entry name="xls" value="document"/>
            <entry name="xlsx" value="document"/>
            <entry name="ppt" value="document"/>
            <entry name="pptx" value="document"/>
        </key:mapInit>
        
        <!-- Retrieve file type from map -->
        <xsl:value-of select="key:mapValue('extensionToFileType', string($extension))"/>        
    </xsl:template>

    <!-- Helper template to parse the file name and return the extension -->
    <!-- Derived from https://www.oxygenxml.com/archives/xsl-list/200412/msg01162.html -->
    <xsl:template name="get-file-extension">
        <xsl:param name="path" />
        <xsl:choose>
           <!-- Walk along the path until there are no more '/' characters -->
            <xsl:when test="contains( $path, '/' )">
                <xsl:call-template name="get-file-extension">
                    <xsl:with-param name="path"
                                    select="substring-after($path, '/')" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains( $path, '.' )">
                <xsl:call-template name="get-file-extension-temp">
                    <xsl:with-param name="x"
                                    select="substring-after($path, '.')" />
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

   <!--
   Helper template to walk along filename chomping the filename until no
   periods remain.
   -->
    <!-- Derived from https://www.oxygenxml.com/archives/xsl-list/200412/msg01162.html -->
    <xsl:template name="get-file-extension-temp">
        <xsl:param name="x" />

        <xsl:choose>
            <xsl:when test="contains($x, '.')">
                <xsl:call-template name="get-file-extension-temp">
                    <xsl:with-param name="x"
                                    select="substring-after($x, '.')" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$x" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>