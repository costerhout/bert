<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-03-08T10:36:49-09:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-06-01T23:14:40-08:00

Derived from previous work done by John French at the University of Alaska Southeast.
-->


<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:hh="http://www.hannonhill.com/XSL/Functions"
                xmlns:key="my:key-value-map"
                extension-element-prefixes="key"
                >
    <xsl:import href="../util/key-value-map.xslt"/>
    <xsl:import href="../calendars/format-date.xslt"/>
    <xsl:import href="../navigation/format-filesize.xslt"/>

    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>
    <!-- Typically 'index' or 'default' goes here as the base page in a folder-->
    <xsl:variable name="index-page">index</xsl:variable>
    <xsl:variable name="maskDate">shortDate</xsl:variable>

    <!-- The following match is in the event it is from an index block in the data definition -->
    <xsl:template match="path | name"/>

    <xsl:template match="/system-index-block">
        <!-- Set up map for extension of file -> class later on -->
        <key:mapInit name='mapExtensionToClass' casesensitive='false'>
            <entry name='pdf' value='pdf'/>
            <entry name='img' value='img'/>
            <entry name='jpg' value='img'/>
            <entry name='jpeg' value='img'/>
            <entry name='gif' value='img'/>
            <entry name='png' value='img'/>
            <entry name='doc' value='word'/>
            <entry name='docx' value='word'/>
            <entry name='xls' value='excel'/>
            <entry name='xlsx' value='excel'/>
            <entry name='ppt' value='ppt'/>
            <entry name='pptx' value='ppt'/>
            <entry name='swf' value='flash'/>
        </key:mapInit>

        <!-- Set up map for extension of file -> description -->
        <key:mapInit name='mapExtensionToDesc' casesensitive='false'>
            <entry name='pdf' value='Adobe PDF file'/>
            <entry name='img' value='image'/>
            <entry name='jpg' value='image'/>
            <entry name='jpeg' value='image'/>
            <entry name='gif' value='image'/>
            <entry name='png' value='image'/>
            <entry name='doc' value='Microsoft Word (.doc)'/>
            <entry name='docx' value='Microsoft Word (.docx)'/>
            <entry name='xls' value='Microsoft Excel (.xls)'/>
            <entry name='xlsx' value='Microsoft Excel (.xlsx)'/>
            <entry name='ppt' value='Microsoft Powerpoint (.ppt)'/>
            <entry name='pptx' value='Microsoft Powerpoint (.pptx)'/>
            <entry name='swf' value='flash'/>
        </key:mapInit>

        <ul class="site">
            <xsl:apply-templates select="system-page | system-file | system-symlink"/>
            <xsl:apply-templates select="system-folder[system-page | system-file | system-symlink | system-folder]"/>

        </ul>
    </xsl:template>

    <!--
    Match folders that have children only - this gets around the empty list syndrome.
    -->
    <xsl:template match="system-folder[system-page | system-file | system-symlink | system-folder]">
        <li class="folder">
            <a class="sitemap" href="{path}/{$index-page}">
                <xsl:choose>
                    <xsl:when test="display-name"><xsl:value-of select="display-name"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="name"/></xsl:otherwise>
                </xsl:choose>
            </a>

            <ul>
                <xsl:apply-templates select="system-page | system-file | system-symlink"/>
                <xsl:apply-templates select="system-folder[system-page | system-file | system-symlink | system-folder]"/>
            </ul>
        </li>
    </xsl:template>

    <xsl:template match="system-page">
        <xsl:variable name="dateModified" select="hh:dateFormat(number(last-modified), $maskDate)"/>
        <li class="page">
            <a href="{path}"><xsl:attribute name="title">Last modified on <xsl:value-of select="$dateModified"/> by <xsl:value-of select="last-modified-by"/></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="display-name"><xsl:value-of select="display-name"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="name"/></xsl:otherwise>
                </xsl:choose>
            </a>
            <xsl:choose>
                <xsl:when test="description[string()]"> - <xsl:value-of select="description"/></xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </li>
    </xsl:template>

    <xsl:template match="system-file">
        <!-- Get file size string -->
        <xsl:variable name="sizeFile"><xsl:call-template name="format-filesize"/></xsl:variable>

        <!-- Set up variables for file extension, file class, file description, and file size -->
        <xsl:variable name="extFile" select="substring-after(name, '.')"/>
        <xsl:variable name='classFile' select="key:mapValue('mapExtensionToClass', string($extFile))"/>
        <xsl:variable name='descFile' select="key:mapValue('mapExtensionToDesc', string($extFile))"/>
        <xsl:variable name="dateModified" select="hh:dateFormat(number(last-modified), $maskDate)"/>

        <li>
            <!-- List item class determined by type of file -->
            <xsl:attribute name="class"><xsl:value-of select="$classFile"/></xsl:attribute>

            <!-- Each list item is a link -->
            <a href="{path}">
                <xsl:attribute name="title">
                    <xsl:choose>
                        <xsl:when test="description[string()]"><xsl:value-of select="description"/></xsl:when>
                        <xsl:when test="summary[string()]"><xsl:value-of select="summary"/></xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>Last modified on <xsl:value-of select="$dateModified"/> by <xsl:value-of select="last-modified-by"/></xsl:attribute>
                <!-- Link text -->
                <xsl:choose>
                    <xsl:when test="display-name"><xsl:value-of select="display-name"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="name"/></xsl:otherwise>
                </xsl:choose>
            </a>
            <!-- Output file description string -->
            <xsl:value-of select="concat(' (', $classFile, ': ', $sizeFile, ')')"/>
        </li>
    </xsl:template>

    <xsl:template match="system-symlink">
        <li><xsl:attribute name="class">link</xsl:attribute>
            <a href="{link}"><xsl:attribute name="title">
                <xsl:choose>
                    <xsl:when test="description[string()]"><xsl:value-of select="description"/></xsl:when>
                    <xsl:when test="summary[string()]"><xsl:value-of select="summary"/></xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="display-name"><xsl:value-of select="display-name"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="name"/></xsl:otherwise>
                </xsl:choose>
            </a> - link
        </li>
    </xsl:template>
</xsl:stylesheet>
