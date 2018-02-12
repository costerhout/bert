<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2015-11-11T13:23:09-09:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2018-01-03T16:40:43-09:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
    xmlns:exsl="http://exslt.org/common"
    xmlns:string="my:string"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="exsl xd string"
    >
    <xsl:import href="bs2-modal-simple.xslt"/>
    <xsl:import href='../include/string.xslt'/>

    <xd:doc type="stylesheet">
        <xd:short>Output YouTube video in a thumbnail</xd:short>
        <xd:detail>
            <p>Takes a youtube-video data structure and generates a modal window with an embedded YouTube video player.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <xsl:output indent="yes" method="html" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>

    <xd:doc>
        Match on a youtube-video system data structure. Turn around and invoke a stylesheet which generates the thumbnail.
    </xd:doc>
    <xsl:template match="system-data-structure[youtube-video]">
        <xsl:variable name="id_video_player" select="string:generateId('video-player-')"/>
        <xsl:variable name="id_video_label" select="concat($id_video_player, '_label')"/>
        <xsl:variable name="id_video_player_wrapper" select="concat($id_video_player, '_wrapper')"/>

        <xsl:apply-templates select="youtube-video" mode='thumbnail'>
            <xsl:with-param name="id_video_player" select="$id_video_player"/>
            <xsl:with-param name="id_video_label" select="$id_video_label"/>
            <xsl:with-param name="id_video_player_wrapper" select="$id_video_player_wrapper"/>
        </xsl:apply-templates>
    </xsl:template>

    <xd:doc>
        Output video thumbnail, title, presenter, description in a thumbnail.
    </xd:doc>
    <xsl:template match="youtube-video" mode="thumbnail">
        <xsl:param name="id_video_player"/>
        <xsl:param name="id_video_label"/>
        <xsl:param name="id_video_player_wrapper"/>
        <!--
        Thanks: http://stackoverflow.com/questions/11378564/how-can-i-parse-a-youtube-url-using-xslt for
        the assist in parsing arbitrary URL parameter string
        -->
        <xsl:variable name="youtube_id" select="concat
                                                (substring-before(substring-after(concat(url,'&amp;'),'?v='),'&amp;'),
                                                substring-before(substring-after(concat(url,'&amp;'),'&amp;v='),'&amp;')
                                                )"/>

        <!-- Create supporting modal IDs -->
        <xsl:variable name="idModal" select="string:generateId('modal-')"/>
        <xsl:variable name="idModalTitle" select="string:generateId('modal-title-')"/>

        <!-- Create the video player modal window -->
        <xsl:variable name="rtfModalBody">
            <div class="yt-player" id="{$id_video_player}"></div>
            <p class="yt-presenter"></p>
            <p class="yt-description"></p>
        </xsl:variable>

        <xsl:variable name="rtfModalAttr">
            <node name="data-yt-modal-template">true</node>
        </xsl:variable>

        <!-- Create video display modal window to be invoked with image link in thumbnail -->
        <xsl:call-template name="modal">
            <xsl:with-param name="id" select="$idModal"/>
            <xsl:with-param name="sIdTitle" select="$idModalTitle"/>
            <xsl:with-param name="title" select="title"/>
            <xsl:with-param name="sClassExtra" select="'yt-modal'"/>
            <xsl:with-param name="content" select="exsl:node-set($rtfModalBody)"/>
            <xsl:with-param name="nsAttr" select="exsl:node-set($rtfModalAttr)"/>
        </xsl:call-template>

        <div class="thumbnail">
            <h3><xsl:value-of select="title"/></h3>
            <a href="#{$idModal}"
                data-toggle='modal'
                data-youtube-id="{$youtube_id}"
                data-title='{title}'
                data-description='{description}'
                data-presenter='{presenter}'
                >
                <xsl:choose>
                    <xsl:when test="img-thumbnail[@type='file']">
                        <xsl:apply-templates select="img-thumbnail"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <img
                            src="{concat('//img.youtube.com/vi/', $youtube_id, '/0.jpg')}"
                            alt='Youtube video thumbnail'
                        />
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
