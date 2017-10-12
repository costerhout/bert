<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-10-05T16:16:31-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-10-11T11:23:43-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xd exsl hh string" version="1.0"
    xmlns:exsl="http://exslt.org/common"
    xmlns:hh="http://www.hannonhill.com/XSL/Functions"
    xmlns:string="my:string"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc">
    <xsl:import href="../include/format-date.xslt"/>
    <xsl:import href="../include/string.xslt"/>

    <xd:doc type="stylesheet">
        <xd:short/>
        <xd:detail>
            <p>This stylesheet is designed to be used directly on the Evening at Egan page.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <xsl:variable name="tsNow" select="hh:dateFormat('V')"/>
    <xd:doc>
        Filter out all the events that happen in the future
    </xd:doc>
    <xsl:key match="youtube-video" name="keyFilterFuturePresentation" use="(number(date-time) + 86400000) &gt; $tsNow"/>

    <xsl:template match="system-index-block">
        <!-- Create the video player modal window -->
        <xsl:variable name="id_video_player" select="generate-id()"/>
        <xsl:variable name="id_video_label" select="concat($id_video_player, '_label')"/>
        <xsl:variable name="id_video_player_wrapper" select="concat($id_video_player, '_wrapper')"/>
        <xsl:variable name="nsPresentationFuture" select="key('keyFilterFuturePresentation', 'true')"/>
        <xsl:variable name="nsPresentationPast" select="key('keyFilterFuturePresentation', 'false')"/>

        <xsl:if test="count($nsPresentationFuture)">
            <div class="yt-videoset">
                <h2>Upcoming Presentations</h2>
                <!-- Cycle through all the blocks at the root level of the index block -->
                <xsl:apply-templates select="$nsPresentationFuture">
                    <xsl:with-param name="id_video_player_wrapper" select="$id_video_player_wrapper"/>
                </xsl:apply-templates>
            </div>
        </xsl:if>

        <xsl:if test="count($nsPresentationPast)">
            <div class="yt-videoset">
                <h2>Past Presentations</h2>
                <!-- Cycle through all the blocks at the root level of the index block -->
                <xsl:apply-templates select="$nsPresentationPast">
                    <xsl:with-param name="id_video_player_wrapper" select="$id_video_player_wrapper"/>
                </xsl:apply-templates>
            </div>
        </xsl:if>

        <div aria-hidden="true" aria-labeledby="{$id_video_label}" class="modal hide fade yt-modal" data-yt-modal-template="true" id="{$id_video_player_wrapper}" role="dialog">
            <div class="modal-header">
                <button aria-hidden="true" class="close" data-dismiss="modal" type="button">x</button>
                <h3 id="{$id_video_label}">Video Title</h3>
            </div>
            <div class="modal-body">
                <div class="yt-player" id="{$id_video_player}"></div>
                <p class="yt-presenter"></p>
                <p class="yt-description"></p>
            </div>
            <div class="modal-footer">
                <button aria-hidden="true" class="btn" data-dismiss="modal">Close</button>
            </div>
        </div>
    </xsl:template>

    <!-- Create a span4 encapsulated thumbnail entry for every youtube-video structure -->
    <xsl:template match="youtube-video">
        <xsl:param name="id_video_player_wrapper">videoModal</xsl:param>
        <!--
        Thanks: http://stackoverflow.com/questions/11378564/how-can-i-parse-a-youtube-url-using-xslt for
        the assist in parsing arbitrary URL parameter string
        -->
        <xsl:variable name="youtube_id" select="concat                                                 (substring-before(substring-after(concat(url,'&amp;'),'?v='),'&amp;'),                                                 substring-before(substring-after(concat(url,'&amp;'),'&amp;v='),'&amp;')                                                 )"/>
        <div class="yt-media-wrapper">
            <div class="media">
                <div class="pull-left yt-thumbnail hidden-phone">
                <xsl:choose>
                    <xsl:when test="$youtube_id != ''">
                        <a class="pull-left hidden-phone">
                            <xsl:attribute name="href">#<xsl:value-of select="$id_video_player_wrapper"/></xsl:attribute>
                            <xsl:attribute name="data-toggle">modal</xsl:attribute>
                            <xsl:attribute name="data-youtube-id"><xsl:value-of select="$youtube_id"/></xsl:attribute>
                            <xsl:attribute name="data-title"><xsl:value-of select="title"/></xsl:attribute>
                            <xsl:attribute name="data-description"><xsl:value-of select="description"/></xsl:attribute>
                            <xsl:attribute name="data-presenter"><xsl:value-of select="presenter"/></xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="img-thumbnail[@type='file']">
                                    <xsl:call-template name="media-thumbnail">
                                        <xsl:with-param name="src_thumbnail"><xsl:value-of select="img-thumbnail/path"/></xsl:with-param>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="media-thumbnail">
                                        <xsl:with-param name="src_thumbnail"><xsl:value-of select="concat('//img.youtube.com/vi/', $youtube_id, '/default.jpg')"/></xsl:with-param>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </a>
                    </xsl:when>
                    <xsl:when test="img-thumbnail/path != '/'">
                        <xsl:call-template name="media-thumbnail">
                            <xsl:with-param name="src_thumbnail"><xsl:value-of select="img-thumbnail/path"/></xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="media-thumbnail"/>
                    </xsl:otherwise>
                </xsl:choose>
                </div>

                <div class="media-body">
                    <p class="yt-datetime">
                        <xsl:call-template name="format-date">
                            <xsl:with-param name="date" select="date-time"/>
                            <xsl:with-param name="mask">dddd, mmmm d</xsl:with-param>
                        </xsl:call-template>
                    </p>
                    <h3 class="media-heading">
                        <xsl:choose>
                            <xsl:when test="$youtube_id = ''">
                                <xsl:value-of select="title"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <a>
                                    <xsl:attribute name="href">#<xsl:value-of select="$id_video_player_wrapper"/></xsl:attribute>
                                    <xsl:attribute name="data-toggle">modal</xsl:attribute>
                                    <xsl:attribute name="data-youtube-id"><xsl:value-of select="$youtube_id"/></xsl:attribute>
                                    <xsl:attribute name="data-title"><xsl:value-of select="title"/></xsl:attribute>
                                    <xsl:attribute name="data-description"><xsl:value-of select="description"/></xsl:attribute>
                                    <xsl:attribute name="data-presenter"><xsl:value-of select="presenter"/></xsl:attribute>
                                    <xsl:value-of select="title"/>
                                </a>
                            </xsl:otherwise>
                        </xsl:choose>
                    </h3>
                    <xsl:if test="presenter != ''">
                        <p class="yt-presenter"><xsl:value-of select="presenter"/></p>
                    </xsl:if>
                    <xsl:if test="description != ''">
                        <p class="yt-desc"><xsl:value-of select="description"/></p>
                    </xsl:if>
                </div>
            </div>
        </div>
    </xsl:template>

    <!-- Create a thumbnail on the left side with an image specified via parameter or a default image of Spike -->
    <xsl:template name="media-thumbnail">
        <xsl:param name="src_thumbnail">//uas.alaska.edu/a_assets/images/video-coming-soon.png</xsl:param>
        <img>
            <xsl:attribute name="src"><xsl:value-of select="$src_thumbnail"/></xsl:attribute>
            <xsl:attribute name="alt">Presentation thumbnail image</xsl:attribute>
        </img>
    </xsl:template>
</xsl:stylesheet>
