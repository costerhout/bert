<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2015-09-16T16:38:04-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-06-01T15:26:32-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                xmlns:string="my:string"
                exclude-result-prefixes="exsl string"
                >
    <xsl:import href="../include/string.xslt"/>
    <xsl:strip-space elements="*"/>
    <xsl:output method="html" indent='yes' omit-xml-declaration='yes'/>

    <!-- Match the root level system-data-structure only, looking for the modal-simple signature  -->
    <xsl:template match="system-data-structure[modal-simple-header][modal-simple-body]">
        <xsl:call-template name="modal">
            <xsl:with-param name="id" select="id"/>
            <xsl:with-param name="title" select="modal-simple-header/title"/>
            <xsl:with-param name="content" select="modal-simple-body/modal-simple-content"/>
            <xsl:with-param name="ablock" select="modal-simple-body/ablock[@type='block']"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="modal" priority="-1">
        <xsl:param name="id"/>
        <xsl:param name="title"/>
        <xsl:param name="content"/>
        <xsl:param name="sClassExtra"/>
        <xsl:param name="rtfThumbnail"/>
        <xsl:param name="sIdTitle" select="string:generateId('modal-')"/>
        <xsl:param name="nsAttr"/>
        <xsl:param name="ablock"/>

        <!-- Build the class string -->
        <xsl:variable name="rtfClass">
            <node>modal</node>
            <node>fade</node>
            <xsl:if test="$sClassExtra != ''">
                <node><xsl:value-of select="$sClassExtra"/></node>
            </xsl:if>
        </xsl:variable>

        <xsl:variable name="sClass">
            <xsl:call-template name="nodeset-join">
                <xsl:with-param name="ns" select="exsl:node-set($rtfClass)/*"/>
                <xsl:with-param name="glue" select="' '"/>
            </xsl:call-template>
        </xsl:variable>

        <!--
        The ID is what we use to call the modal from the document, like so:
            <a data-toggle="modal" href="#modal-id">Launch my modal box</a>
        -->
        <div id="{$id}" class="{$sClass}" tabindex="-1" role="dialog">
            <!-- Set the ARIA label for this dialog -->
            <xsl:attribute name="aria-labelledby">
                <xsl:value-of select="$sIdTitle"/>
            </xsl:attribute>

            <!-- Set any additional attributes -->
            <xsl:if test="$nsAttr">
                <xsl:for-each select="$nsAttr/*">
                    <xsl:variable name="sAttrName">
                        <xsl:value-of select="./@name"/>
                    </xsl:variable>
                    <xsl:attribute name="{$sAttrName}">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </xsl:for-each>
            </xsl:if>

            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <!-- Put an X in the top right of the header bar, and then list title  -->
                        <button aria-hidden="true" aria-label="Close" class="close" data-dismiss="modal" type="button"><span aria-hidden="true">&#215;</span></button>
                        <h3 id="{$sIdTitle}">
                            <xsl:value-of select="$title"/>
                        </h3>
                    </div>
                    <div class="modal-body">
                        <!--
                        The body consists of the WYSIWYG text plus any additional content blocks along
                        with an optional thumbnail + caption in the form of a result tree fragment.
                        -->

                        <!-- Display the thumbnail result tree fragment -->
                        <xsl:if test="exsl:node-set($rtfThumbnail)/*">
                            <xsl:copy-of select="$rtfThumbnail"/>
                        </xsl:if>

                        <!-- Display the rest of the content -->
                        <xsl:copy-of select="$content/*"/>

                        <!-- This stylesheet assumes that there's a stylesheet already included to handle ablock content -->
                        <xsl:if test="$ablock">
                            <xsl:apply-templates select="$ablock"/>
                        </xsl:if>
                    </div>
                    <div class="modal-footer">
                        <!-- Put a close button down in the footer -->
                        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>
