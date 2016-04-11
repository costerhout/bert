<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:string="my:string"
                exclude-result-prefixes="exsl xd"
                >
    <xsl:import href="../include/string.xslt"/>

    <xsl:output method="html" indent='yes' omit-xml-declaration='yes'/>

    <!-- Set up nodeset for file extension to file type -->
    <xsl:variable name="rtfFileTypes">
        <filetypes>
            <filetype>
                <ext>jpg</ext>
                <ext>jpeg</ext>
                <ext>png</ext>
                <ext>gif</ext>
                <ext>bmp</ext>
                <type>image</type>
                <class>image</class>
            </filetype>
            <filetype>
                <ext>pdf</ext>
                <type>document</type>
                <class>pdf</class>
            </filetype>
            <filetype>
                <ext>doc</ext>
                <ext>docx</ext>
                <type>document</type>
                <class>word</class>
            </filetype>
            <filetype>
                <ext>xls</ext>
                <ext>xlsx</ext>
                <type>document</type>
                <class>excel</class>
            </filetype>
        </filetypes>
    </xsl:variable>

    <xsl:variable name="nsFileTypes" select="exsl:node-set($rtfFileTypes)"/>
    <xsl:key name="keyExtToFileType" match='filetype' use='ext'/>

    <xd:doc>
        <xd:short>Determine type of file based on the filename extension</xd:short>
        <xd:detail>
            <p>Determine type of file based on the filename extension (portion of filename after the final '.').  Performs case insensitive search.</p>
        </xd:detail>
        <xd:param name="path" type="string">File path to parse</xd:param>
    </xd:doc>
    <xsl:template name="getfiletype">
        <xsl:param name="path"/>

        <!-- Determine the file extension with a helper template -->
        <xsl:variable name="extension"><xsl:call-template name="get-file-extension">
            <xsl:with-param name="path" select="$path"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Retrieve file type from nodeset -->
        <xsl:for-each select="$nsFileTypes">
            <xsl:value-of select="key('keyExtToFileType', string:lowerCase(string($extension)))/type"/>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:short>Determine class of file based on the filename extension</xd:short>
        <xd:detail>
            <p>Determine CSS class of file based on the filename extension (portion of filename after the final '.').  Performs case insensitive search.</p>
        </xd:detail>
        <xd:param name="path" type="string">File path to parse</xd:param>
    </xd:doc>
    <xsl:template name="getfileclass">
        <xsl:param name="path"/>

        <!-- Determine the file extension with a helper template -->
        <xsl:variable name="extension"><xsl:call-template name="get-file-extension">
            <xsl:with-param name="path" select="$path"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Retrieve file class from nodeset -->
        <xsl:for-each select="$nsFileTypes">
            <xsl:value-of select="key('keyExtToFileType', string:lowerCase(string($extension)))/class"/>
        </xsl:for-each>
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
