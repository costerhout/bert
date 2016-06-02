<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2015-11-11T13:23:09-09:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-06-01T23:12:00-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->


<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="* | text()">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="system-data-structure[@definition-path='youtube-video']">
        <!--
        Thanks: http://stackoverflow.com/questions/11378564/how-can-i-parse-a-youtube-url-using-xslt for
        the assist in parsing arbitrary URL parameter string
        -->
        <xsl:variable name="youtube_id" select="concat
                                                (substring-before(substring-after(concat(url,'&amp;'),'?v='),'&amp;'),
                                                substring-before(substring-after(concat(url,'&amp;'),'&amp;v='),'&amp;')
                                                )"/>
        <xsl:comment><xsl:value-of select="$youtube_id"/></xsl:comment>
        <div class="thumbnail">
            <h3><xsl:value-of select="title"/></h3>
            <a>
                <xsl:attribute name="href">#videoModal</xsl:attribute>
                <xsl:attribute name="data-toggle">modal</xsl:attribute>
                <xsl:attribute name="class">thumbnail</xsl:attribute>
                <xsl:attribute name="data-youtube-id"><xsl:value-of select="$youtube_id"/></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="img-thumbnail[@type='file']">
                        <xsl:apply-templates select="img-thumbnail"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <img>
                            <xsl:attribute name='src'><xsl:value-of select="concat('//img.youtube.com/vi/', $youtube_id, '/default.jpg')"/></xsl:attribute>
                            <xsl:attribute name='alt'>Youtube video thumbnail</xsl:attribute>
                        </img>
                    </xsl:otherwise>
                </xsl:choose>
            </a>
            <xsl:if test="presenter != ''">
                <p class="yt-presenter"><xsl:value-of select="presenter"/></p>
            </xsl:if>
            <xsl:if test="description != ''">
                <p class="yt-desc"><xsl:value-of select="description"/></p>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template match="img-thumbnail[@type='file']">
        <img>
            <xsl:attribute name='src'><xsl:value-of select="path"/></xsl:attribute>
            <xsl:attribute name='alt'>Youtube video thumbnail</xsl:attribute>
        </img>
    </xsl:template>
</xsl:stylesheet>
