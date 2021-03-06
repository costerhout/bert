<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2015-09-17T09:25:17-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-08-15T14:16:54-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
                version="1.0"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xd"
                >

    <xsl:import href='../include/error.xslt'/>

    <xsl:include href='bs2-ablock-content.xslt'/>
    <xsl:include href="bs2-accordion-group.xslt"/>
    <xsl:include href='bs2-columns.xslt'/>
    <xsl:include href='bs2-description-list.xslt'/>
    <xsl:include href='bs2-email-form.xslt'/>
    <xsl:include href='bs2-faq.xslt'/>
    <xsl:include href='bs2-modal-simple.xslt'/>
    <xsl:include href='bs2-non-credit-course.xslt'/>
    <xsl:include href='bs2-personnel-list.xslt'/>
    <xsl:include href='bs2-personnel.xslt'/>
    <xsl:include href='bs2-tabs.xslt'/>
    <xsl:include href='bs2-thumbnail-with-caption.xslt'/>
    <xsl:include href='bs2-sidebar-address.xslt'/>
    <xsl:include href='bs2-links.xslt'/>
    <xsl:include href='bs2-youtube-media-list.xslt'/>
    <xsl:include href='bs2-youtube-thumbnail.xslt'/>
    <xsl:include href="bs2-video-container.xslt"/>
    <xsl:include href="bs2-event-list.xslt"/>
    <xsl:include href="bs2-filelist.xslt"/>
    <xsl:include href='../modules/gallery.xslt'/>
    <xsl:include href="../modules/zopim.xslt"/>
    <xsl:include href="../modules/filelist.xslt"/>
    <xsl:include href="../modules/mapdisplay.xslt"/>
    <xsl:include href="../modules/decisiontree.xslt"/>
    <xsl:include href="../modules/container.xslt"/>

    <xsl:variable name="nl"><xsl:text>&#xa;</xsl:text></xsl:variable>

    <xsl:strip-space elements="*"/>
    <xsl:output
                method='html'
                indent='yes'
                omit-xml-declaration='yes'
                />

    <xd:doc>
        By default (at a very low priority) output nodes and attributes as-is
    </xd:doc>
    <xsl:template match="@*|node()" priority="-1000">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        Fall back - output nothing by default for system-index-block data.
        Included stylesheets need to put matching specifiers with greater specificity.
    </xd:doc>
    <xsl:template match="/system-index-block" priority="-1000"></xsl:template>

    <xd:doc>
        Fall back template for unknown system-data-structures: log a warning
    </xd:doc>
    <xsl:template match="system-data-structure" priority='-1000'>
        <xsl:call-template name="log-warning">
            <xsl:with-param name="message">Unhandled node encountered</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
