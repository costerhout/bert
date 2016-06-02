<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-04-08T12:03:32-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-06-01T23:13:53-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->


<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:hh="http://www.hannonhill.com/XSL/Functions"
    xmlns:string="my:string"
    exclude-result-prefixes="string xd hh exsl"
    >

    <xsl:import href="../include/error.xslt"/>
    <xsl:import href="../include/string.xslt"/>
    <xsl:import href="../include/pathfilter.xslt"/>
    <xsl:import href="../include/format-date.xslt"/>
    <xsl:import href="../include/format-filesize.xslt"/>
    <xsl:import href="../include/filetype.xslt"/>

    <xd:doc type="stylesheet">
        <xd:short>Generate a simple list of files suitable for use
        in sitemaps, document lists, etc.</xd:short>
        <xd:detail>
            <p>Used to generate lists of files from index block output wrapped in a content block of type "File list" and that can specify optional formatting options.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctoterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <xsl:strip-space elements="*"/>
    <xsl:output
          method='html'
          indent='yes'
          omit-xml-declaration='yes'
          />

    <xd:doc>
        Class strings for use in folders and files
    </xd:doc>
    <xsl:variable name="sClassPrefix">filelist</xsl:variable>
    <xsl:variable name="sClassFolder"><xsl:value-of select="concat($sClassPrefix, '-folder')"/></xsl:variable>

    <xsl:template match="system-data-structure[filelist]">
        <!--
        Check for:
            - valid class string
            - valid id
        -->
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
            <xsl:with-param name="nodeParentNode" select="filelist"/>
        </xsl:call-template>

        <!-- Get to business -->
        <xsl:apply-templates select="filelist"/>
    </xsl:template>

    <xd:doc>
        <xd:short>Matching template to process the 'filelist' data structure</xd:short>
        <xd:detail>
            <p>Process the 'filelist' data definition structure according to the type of list display desired. Assigns 'class' and 'id' attributes if set, and puts a title and simple description ahead of the list display.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="filelist">
        <!-- Set up the class string for this module instance -->
        <xsl:variable name="sClassBase">
            <xsl:value-of select="concat($sClassPrefix, ' ', $sClassPrefix, '-', type)"/>
        </xsl:variable>

        <xsl:variable name="sClass">
            <xsl:choose>
                <xsl:when test="class[text()]">
                    <xsl:value-of select="concat($sClassBase, ' ', normalize-space(class))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$sClassBase"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Wrap the entire contents in a div -->
        <xsl:if test="ablock/content/system-index-block/system-folder[is-published='true']">
            <div>
                <!-- Set class attribute -->
                <xsl:attribute name="class">
                    <xsl:value-of select="$sClass"/>
                </xsl:attribute>

                <!-- Set ID attribute, if defined, as sanitized string -->
                <xsl:if test="id[text()]">
                    <xsl:attribute name="id">
                        <xsl:value-of select="string:sanitizeHtmlId(string(normalize-space(id)))"/>
                    </xsl:attribute>
                </xsl:if>

                <!-- Display the optional title -->
                <xsl:if test="title[text()]">
                    <h2><xsl:value-of select="title"/></h2>
                </xsl:if>

                <!-- Display the optional description -->
                <xsl:if test="description[text()]">
                    <p><xsl:value-of select="description"/></p>
                </xsl:if>

                <!-- Depending on the type of list desired apply the corresponding template -->
                <xsl:choose>
                    <xsl:when test="type = 'folder-set'">
                        <!-- Output the set of top-level folders -->
                        <xsl:apply-templates select="ablock/content/system-index-block/system-folder[is-published='true']" mode="folder-set">
                            <xsl:with-param name="nsOptions" select="options"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:when test="type = 'recursive'">
                        <!-- Display all the files / folders recursively -->
                        <xsl:apply-templates select="ablock/content/system-index-block/system-folder[is-published='true']" mode="recursive">
                            <xsl:with-param name="nsOptions" select="options"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Some type that we don't know about yet -->
                        <xsl:call-template name="log-error">
                            <xsl:with-param name="message" select="concat('Invalid filelist type specified: ', type)"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:short>Output a folder contents, recursively</xd:short>
        <xd:detail>
            <p>Generates a folder listing for the 'recursive' mode of file listing. The current folder content (files) will be output and any other folders listed underneath will be recursed into as well.</p>
        </xd:detail>
        <xd:param name="nsOptions" type="node-set">Set of options to control output.</xd:param>
    </xd:doc>
    <xsl:template match="system-folder" mode="recursive">
        <xsl:param name="nsOptions"/>

        <!-- We'll use the 'Display Name' field of the folder as the title if possible -->
        <xsl:variable name="sTitle">
            <xsl:choose>
                <xsl:when test="normalize-space(display-name) != ''">
                    <xsl:value-of select="normalize-space(display-name)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(name)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <li class="{$sClassFolder}">
            <xsl:value-of select="$sTitle"/>
            <xsl:choose>
                <!-- Create li element with appropriate folder class -->
                <xsl:when test="system-file[is-published='true'] or system-folder[is-published='true']">
                    <ul>
                        <xsl:apply-templates select="system-folder[is-published='true']" mode="recursive">
                            <xsl:with-param name="nsOptions" select="$nsOptions"/>
                        </xsl:apply-templates>
                        <xsl:choose>
                            <!-- Should we sort this list alphabetically? -->
                            <xsl:when test="$nsOptions/value[text() = 'alphabetical']">
                                <xsl:apply-templates select="system-file[is-published='true']">
                                    <xsl:with-param name="nsOptions" select="$nsOptions"/>
                                    <xsl:sort select="name"/>
                                </xsl:apply-templates>
                            </xsl:when>
                            <!-- If not, just display in document order -->
                            <xsl:otherwise>
                                <xsl:apply-templates select="system-file[is-published='true']">
                                    <xsl:with-param name="nsOptions" select="$nsOptions"/>
                                </xsl:apply-templates>
                            </xsl:otherwise>
                        </xsl:choose>
                    </ul>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Could put some sort of 'Folder empty' sort of indication -->
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>

    <xd:doc>
        <xd:short>Output a folder contents but do not recurse into the directory.</xd:short>
        <xd:detail>
            <p>Generates a folder listing for the 'folder-set' mode of file listing. The current folder content (files) will be output.</p>
        </xd:detail>
        <xd:param name="nsOptions" type="node-set">Set of options to control output.</xd:param>
    </xd:doc>
    <xsl:template match="system-folder" mode="folder-set">
        <xsl:param name="nsOptions"/>

        <!-- We'll use the 'Display Name' field of the folder as the title if possible -->
        <xsl:variable name="sTitle">
            <xsl:choose>
                <xsl:when test="normalize-space(display-name) != ''">
                    <xsl:value-of select="normalize-space(display-name)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Folder contents</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <!-- If there's files to output then display the title and output them -->
            <xsl:when test="system-file[is-published='true']">
                <h3><xsl:value-of select="$sTitle"/></h3>
                <ul>
                    <!-- Specifically don't recurse into folders found here... -->
                    <!-- But do list the files -->
                    <xsl:choose>
                        <!-- Should we sort this list alphabetically? -->
                        <xsl:when test="$nsOptions/value[text() = 'alphabetical']">
                            <xsl:apply-templates select="system-file[is-published='true']">
                                <xsl:with-param name="nsOptions" select="$nsOptions"/>
                                <xsl:sort select="name"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <!-- If not, just display in document order -->
                        <xsl:otherwise>
                            <xsl:apply-templates select="system-file[is-published='true']">
                                <xsl:with-param name="nsOptions" select="$nsOptions"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </ul>
            </xsl:when>
            <xsl:otherwise>
                <!-- Could put some sort of 'Folder empty' sort of indication -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:short>Output a file listing</xd:short>
        <xd:detail>
            <p>Generates a listing for a single file. Depending on the 'nsOptions' parameter will alter the output of the file listing to include the size of the file as well as the last modified date. If the 'description' field is present it will output a &lt;span&gt;-wrapped (class 'filelist-link-desc') link description.</p>
        </xd:detail>
        <xd:param name="nsOptions" type="node-set">Set of options to control output.</xd:param>
    </xd:doc>
    <xsl:template match="system-file">
        <xsl:param name="nsOptions"/>

        <!-- Build the file path string, filtering out any known workaround issues -->
        <xsl:variable name="sFilePath">
            <xsl:call-template name="pathfilter">
                <xsl:with-param name="path" select="path"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Build the date modified string -->
        <xsl:variable name="sDateModified">
            <xsl:value-of select="hh:dateFormat(number(last-modified),'longDate')"/>
        </xsl:variable>

        <!-- Build the File Size string -->
        <xsl:variable name="sFileSize">
            <xsl:call-template name="format-filesize"/>
        </xsl:variable>

        <!-- Build the file class string -->
        <xsl:variable name="sClass">
            <xsl:value-of select="$sClassPrefix"/>-<xsl:call-template name="getfileclass">
                <xsl:with-param name="path" select="path"/>
            </xsl:call-template>
        </xsl:variable>

        <!--
        Build the alt string text.  Order of precedence:
            - description field
            - display name w/ "modified on" text
            - title name w/ "modified on" text
            - Last modifed text
         -->
        <xsl:variable name="sAlt">
            <xsl:choose>
                <xsl:when test="description[text()]">
                    <xsl:value-of select="description"/>
                </xsl:when>
                <xsl:when test="title[text()]">
                    <xsl:value-of select="concat('Find out more about ', normalize-space(title), ', last modified: ', $sDateModified)"/>
                </xsl:when>
                <xsl:when test="display-name[text()]">
                    <xsl:value-of select="concat('Find out more about ', normalize-space(display-name), ', last modified: ', $sDateModified)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('Last modified: ', $sDateModified)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Build the link text optional string -->
        <!-- First the RTF representation -->
        <xsl:variable name="rtfLinkTextOptional">
            <xsl:for-each select="$nsOptions/value">
                <node>
                    <xsl:choose>
                        <xsl:when test="text() = 'filesize'">
                            <xsl:value-of select="concat('Size: ', $sFileSize)"/>
                        </xsl:when>
                        <xsl:when test="text() = 'last-modified'">
                            <xsl:value-of select="concat('Last modified: ', $sDateModified)"/>
                        </xsl:when>
                    </xsl:choose>
                </node>
            </xsl:for-each>
        </xsl:variable>

        <!-- Then the actual string as a concatenation glued together by a comma -->
        <xsl:variable name="sLinkTextOptional">
            <xsl:if test="$nsOptions/value">
                <span class="{$sClassPrefix}-link-optional">
                    <xsl:text>(</xsl:text>
                    <xsl:call-template name="nodeset-join">
                        <xsl:with-param name="ns" select="exsl:node-set($rtfLinkTextOptional)/*"/>
                        <xsl:with-param name="glue" select="', '"/>
                    </xsl:call-template>
                    <xsl:text>)</xsl:text>
                </span>
            </xsl:if>
        </xsl:variable>

        <!--
        Build the link text from the display name, if available, or else the file name.

        Also tacks on additional text based on the options provided:
            - filesize
            - last-modified
        -->
        <xsl:variable name="sLinkText">
            <xsl:choose>
                <xsl:when test="display-name[text()]">
                    <xsl:value-of select="normalize-space(display-name)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Build the link description text from the description field, if present -->
        <xsl:variable name="sLinkDescription">
            <xsl:choose>
                <xsl:when test="description[text()]">
                    <span class="filelist-link-desc">
                        <xsl:value-of select="normalize-space(description)"/>
                    </span>
                </xsl:when>
                <!-- Left open to other tests in the future -->
                <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Output the link entry -->
        <li class="{$sClass}">
            <a href="{$sFilePath}" alt="{$sAlt}">
                <xsl:value-of select="$sLinkText"/>
                <xsl:copy-of select="$sLinkTextOptional"/>
            </a>
            <xsl:copy-of select="$sLinkDescription"/>
        </li>
    </xsl:template>
</xsl:stylesheet>
