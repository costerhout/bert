<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2019-03-22T13:46:33-08:00
@Email:  ctosterhout@alaska.edu
@Last modified by:   ctosterhout
@Last modified time: 2019-03-22T14:32:56-08:00
@License: Released under MIT License. Copyright 2017 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:hh="http://www.hannonhill.com/XSL/Functions"
    exclude-result-prefixes="exsl xd hh"
    >
    <xsl:import href="../bs2/bs2-default.xslt"/>
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="html"/>

    <xd:doc>
        Limit the number of events to display
    </xd:doc>
    <xsl:variable name="nEventLimit">6</xsl:variable>

    <xd:doc>
        Match the top level system-data-structure which should contain a scholarship item definition
    </xd:doc>
    
    <xsl:template match="ablock[content/system-index-block//system-page/system-data-structure/item]">
        <xsl:for-each select="content/system-index-block">
            <xsl:call-template name="generate-scholarship-table">
                <xsl:with-param name="category" select="ancestor::tab/tab_id"/>
            </xsl:call-template>
            
            <xsl:apply-templates select=".//item" mode="modal"/>
        </xsl:for-each>
    </xsl:template>
    
    <xd:doc>
        Build out the initial scholarship div and table. Table rows and modal windows per item are generated through matching templates on 'item'
    </xd:doc>
    
    <xsl:template name="generate-scholarship-table">
        <xsl:param name="category"/>
        <xsl:copy-of select="ancestor::tab/tab_content/*"/>
        
        <div id="scholarships">
            <xsl:choose>
                <xsl:when test=".//item/category = $category">
                    <p>Available scholarships specific to this area of study include:</p>
                    <table class="display table-autosort:0 table table-bordered table-striped">
                        <caption class="sr-only">Scholarships available for <xsl:value-of select="$category"/></caption>
                        <thead>
                            <tr>                                
                                <th scope="col">Category</th>
                                <th scope="col">Title</th>
                                <th scope="col" class="hidden-phone">Deadline</th>
                                <th scope="col" class="hidden-phone">Application Package</th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:apply-templates select=".//item" mode="table-row">
                                <xsl:sort data-type="text" order="ascending" select="substring-after(substring-after(descendant-or-self::date,'-'),'-')"/>
                                <xsl:sort data-type="text" order="ascending" select="substring-before(descendant-or-self::date,'-')"/>
                                <xsl:sort data-type="text" order="ascending" select="substring-before(substring-after(descendant-or-self::date,'-'), '-')"/>
                            </xsl:apply-templates>
                        </tbody>                        
                    </table>
                </xsl:when>
            </xsl:choose>                
                
            <div class="pull-right"><p><a class="external" href="/financial_aid/scholarships" target="_blank">View more information about applying for scholarships</a></p><br class="clearfix"/></div>            
        </div>
    </xsl:template>
    
    <xd:doc>
        Generate a table row for each item
    </xd:doc>
    
    <xsl:template match="item" mode="table-row">
        <xsl:variable name="idModal" select="concat('modal-', generate-id())"/>
        
        <tr>      
            <td>
                <xsl:value-of select="category"/>            
            </td>
            <td>
                <a href="{concat('#', $idModal)}" data-toggle="modal"><xsl:value-of select="title"/></a>     
            </td>         
            <td class="hidden-phone">
                <xsl:choose>
                    <xsl:when test="date[text()]"><xsl:value-of select="date"/></xsl:when>
                    <xsl:otherwise>No Deadline</xsl:otherwise>
                </xsl:choose>
            </td>           
            <td class="hidden-phone">
                <xsl:choose>
                    <xsl:when test="inclusions/value">
                        <xsl:value-of select="inclusions/value"/>
                    </xsl:when>
                    <xsl:otherwise>None</xsl:otherwise>
                </xsl:choose>
            </td>           
        </tr>
    </xsl:template>
    
    <xd:doc>
        Generate a modal window for each item    
    </xd:doc>
    
    <xsl:template match="item"
              mode="modal">
        <xsl:variable name="idModal"
                      select="concat('modal-', generate-id())" />
        <xsl:variable name="idModalTitle"
                      select="concat('modal-title-', generate-id())" />
        <xsl:variable name="rtfContent">
            <dl>
                <dt>Link</dt>
                <dd><a class="external" target="_blank" href="{link}" title="{title}">Scholarship Website</a></dd>
                <xsl:if test="date[text()]">
                    <dt>Application deadline</dt>
                    <dd><xsl:value-of select="date" /></dd>                    
                </xsl:if>
                <xsl:if test="description[string()]">
                    <dt>Description</dt>
                    <dd>
                        <xsl:for-each select="description">
                            <xsl:call-template name="paragraph-wrap"/>
                        </xsl:for-each>
                    </dd>
                </xsl:if>
                <xsl:if test="requirements[string()]">
                    <dt>Requirements</dt>
                    <dd>
                        <xsl:for-each select="requirements">
                            <xsl:call-template name="paragraph-wrap"/>
                        </xsl:for-each>
                    </dd>
                </xsl:if>
                <dt>Category/Location</dt>
                <dd><xsl:value-of select="category" /></dd>
            </dl>
        </xsl:variable>

        <xsl:call-template name="modal">
            <xsl:with-param name="id"
                            select="$idModal" />
            <xsl:with-param name="title"
                            select="title" />
            <xsl:with-param name="content"
                            select="exsl:node-set($rtfContent)" />
            <xsl:with-param name="sIdTitle"
                            select="$idModalTitle" />
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
