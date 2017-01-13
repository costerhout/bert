<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2017-01-12T16:10:20-09:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-01-13T10:13:20-09:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->


<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:string="my:string"
    exclude-result-prefixes="string xd"
    >

    <xsl:import href="../include/filetype.xslt"/>
    <xsl:import href="../include/error.xslt"/>
    <xsl:import href="../include/string.xslt"/>
    <xd:doc type="stylesheet">
        <xd:short></xd:short>
        <xd:detail>
            <p>Meant to be invoked from modules/filetype.xslt, this provides a Bootstrap 2 specific method of outputing files and folders using the collapsible transition.</p>
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
        <xd:short>Output a folder as part of a file list in Bootstrap 2 collapsible format.</xd:short>
        <xd:detail>
            <p>Outputs a list item and a collapsed div element used to represent a folder. The list item contains a link with the necessary Bootstrap 2 logic necessary to expand the div.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-folder" mode="collapsible">
        <!-- Generate folder contents which will be hidden from the user by default -->
        <xsl:variable name="rtfFolderContents">
            <div id="{@id}" class="collapse">
                <ul>
                    <xsl:apply-templates select="system-folder[is-published='true']" mode="collapsible"/>
                    <xsl:apply-templates select="system-file[is-published='true']" mode="collapsible"/>
                </ul>
            </div>
        </xsl:variable>

        <!-- Generate link title based on node metadata -->
        <xsl:variable name="sTitle">
            <xsl:call-template name="create-node-name"/>
        </xsl:variable>

        <!-- Create RTF of the enclosed content -->
        <li class="folder">
            <!-- Create link to drop down the enclosed content -->
            <a href="{concat('#', @id)}" data-toggle="collapse"><xsl:value-of select="$sTitle"/></a>
            <xsl:copy-of select="$rtfFolderContents"/>
        </li>
    </xsl:template>

    <xd:doc>
        <xd:short>Output a file as part of a file list in Bootstrap 2 collapsible format.</xd:short>
        <xd:detail>
            <p>Outputs a list item used to represent a file with a class that corresponds to the file type.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-file" mode="collapsible">
        <!-- Determine class based on file extension -->
        <xsl:variable name="sClass">
            <xsl:call-template name="getfileclass">
                <xsl:with-param name="path" select="path"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Determine the title for the link -->
        <xsl:variable name="sTitle">
            <xsl:call-template name="create-node-name"/>
        </xsl:variable>

        <!-- Output link -->
        <li>
            <xsl:if test="normalize-space($sClass) != ''">
                <xsl:attribute name="class">
                    <xsl:value-of select="$sClass"/>
                </xsl:attribute>
            </xsl:if>

            <a href="{path}"><xsl:value-of select="$sTitle"/></a>
        </li>
    </xsl:template>
</xsl:stylesheet>
