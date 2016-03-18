<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
    <xsl:strip-space elements="*"/>
    <xsl:output method="html" indent='yes' omit-xml-declaration='yes'/>

    <xsl:template match="system-index-block">
       <!-- Create the video player modal window -->
        <xsl:variable name="id_video_player" select="generate-id()"/>
        <xsl:variable name="id_video_label" select="concat($id_video_player, '_label')"/>
        <xsl:variable name="id_video_player_wrapper" select="concat($id_video_player, '_wrapper')"/>

        <div id="{$id_video_player_wrapper}" class="modal hide fade yt-modal" role="dialog" aria-labeledby="{$id_video_label}" aria-hidden="true">
            <div class="modal-header">
                <button type="button" data-dismiss="modal" aria-hidden="true" class="close">x</button>
                <h3 id="{$id_video_label}">Video Title</h3>
            </div>
            <div class="modal-body">
                <div class="yt-player" id="{$id_video_player}"></div>
                <p class="yt-presenter"></p>
                <p class="yt-description"></p>
            </div>
            <div class="modal-footer">
                <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
            </div>
        </div>
        
        <!-- Cycle through the system-folders -->
        <xsl:apply-templates select="system-folder">
            <xsl:with-param name="id_video_player_wrapper" select="$id_video_player_wrapper"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- For every system folder we're encapsulating them as a section on a page -->
    <xsl:template match="system-folder">
        <xsl:param name="id_video_player_wrapper"/>
        <div class="yt-videoset">
            <h2><xsl:value-of select="display-name"/></h2>
            <xsl:apply-templates select="system-block">
                <xsl:with-param name="id_video_player_wrapper" select="$id_video_player_wrapper"/>
            </xsl:apply-templates>
        </div>
    </xsl:template>
    
    <!-- Break up the system-blocks into groups of 3 and create a row-fluid per group -->
    <xsl:template match="system-block">
        <xsl:param name="id_video_player_wrapper"/>
        <xsl:if test="(position() mod 3) = 1">
            <div class="row-fluid">
                <xsl:apply-templates select="./system-data-structure/youtube-video | following-sibling::*[position() &lt; 3]/system-data-structure/youtube-video">
                    <xsl:with-param name="id_video_player_wrapper" select="$id_video_player_wrapper"/>
                </xsl:apply-templates>
            </div>
        </xsl:if>
    </xsl:template>
    
    <!-- Create a span4 encapsulated thumbnail entry for every youtube-video structure -->
    <xsl:template match="youtube-video">
        <xsl:param name="id_video_player_wrapper">videoModal</xsl:param>
        <!-- 
        Thanks: http://stackoverflow.com/questions/11378564/how-can-i-parse-a-youtube-url-using-xslt for 
        the assist in parsing arbitrary URL parameter string
        -->
        <xsl:variable name="youtube_id" select="concat
                                                (substring-before(substring-after(concat(url,'&amp;'),'?v='),'&amp;'),
                                                substring-before(substring-after(concat(url,'&amp;'),'&amp;v='),'&amp;')
                                                )"/>
        <div class="span4">
            <div class="thumbnail">
                <h3><xsl:value-of select="title"/></h3>
                <a>
                    <xsl:attribute name="href">#<xsl:value-of select="$id_video_player_wrapper"/></xsl:attribute>
                    <xsl:attribute name="data-toggle">modal</xsl:attribute>
                    <xsl:attribute name="class">thumbnail</xsl:attribute>
                    <xsl:attribute name="data-youtube-id"><xsl:value-of select="$youtube_id"/></xsl:attribute>
                    <xsl:attribute name="data-title"><xsl:value-of select="title"/></xsl:attribute>
                    <xsl:attribute name="data-description"><xsl:value-of select="description"/></xsl:attribute>
                    <xsl:attribute name="data-presenter"><xsl:value-of select="presenter"/></xsl:attribute>
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
        </div>
    </xsl:template>

    <!-- Create a thumbnail reference from a system asset -->
    <xsl:template match="img-thumbnail[@type='file']">
        <img>
            <xsl:attribute name='src'><xsl:value-of select="path"/></xsl:attribute>
            <xsl:attribute name='alt'>Youtube video thumbnail</xsl:attribute>
        </img>
    </xsl:template>
</xsl:stylesheet>