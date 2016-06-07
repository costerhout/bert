<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2015-09-16T16:38:04-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-06-01T23:08:49-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes="exsl"
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
        <xsl:param name="sIdTitle" select="concat(generate-id(), '-modal-title')"/>
        <xsl:param name="nsAttr"/>
        <!-- Not currently used... the calling template context 'ablock' is used instead (area for improvement) -->
        <!-- <xsl:param name="ablock"/> -->

        <!-- Build the class string -->
        <xsl:variable name="rtfClass">
            <node>modal</node>
            <node>hide</node>
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

        <div class="{$sClass}" role="dialog">
            <!-- Set the ARIA label for this dialog -->
            <xsl:attribute name="aria-labeled-by">
                <xsl:value-of select="$sIdTitle"/>
            </xsl:attribute>
            
            <!-- Set any additional attributes -->
            <xsl:for-each select="$nsAttr/*">
                <xsl:variable name="sAttrName">
                    <xsl:value-of select="./@name"/>
                </xsl:variable>
                <xsl:attribute name="{$sAttrName}">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:for-each>
            <!--
            The ID is what we use to call the modal from the document, like so:
                <a data-toggle="modal" href="#modal-id">Launch my modal box</a>
            -->
            <xsl:attribute name='id'><xsl:value-of select="$id"/></xsl:attribute>
            <div class="modal-header">
                <!-- Put an X in the top right of the header bar, and then list title  -->
                <button aria-hidden="true" class="close" data-dismiss="modal" type="button">&#215;</button>
                <h3>
                    <xsl:if test="$sIdTitle">
                        <xsl:attribute name="id"><xsl:value-of select="$sIdTitle"/></xsl:attribute>
                    </xsl:if>
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
                <xsl:apply-templates select="ablock"/>
            </div>
            <div class="modal-footer">
                <!-- Put a close button down in the footer -->
                <a class="btn" data-dismiss="modal" href="#">Close</a>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>
