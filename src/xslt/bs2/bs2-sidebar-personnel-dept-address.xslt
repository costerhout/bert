<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-01-19T10:09:04-09:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2018-09-25T11:53:36-08:00

Derived from previous work done by John French at the University of Alaska Southeast.
-->

<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes="exsl xd"
                >
    <xsl:import href="bs2-personnel-list.xslt"/>
    <xsl:import href="bs2-sidebar-address.xslt"/>

    <xsl:strip-space elements="*"/>
    <xsl:output
                method='html'
                indent='yes'
                omit-xml-declaration='yes'
                />

    <xd:doc type="stylesheet">
        <xd:short>bs2-sidebar-personnel-dept-address.xslt - Display a personnel and department address listing suitable for right or left sidebar display.</xd:short>
        <xd:detail>
            <p>Imports the bs2-personnel-list.xslt to output a condensed form of a personnel contact (/dir entry) as well as bs2-sidebar-address.xslt to output a department contact listing. The entire output is enclosed in a div.well to set it off from other content on the page.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2017</xd:copyright>
    </xd:doc>
    <!--
   This template is intended to be used at the top most level
   and works on all Personnel system-data-structure blocks found
   below the root.

   This match and apply section will work for either the Personnel data
   definition by itself or wrapped up in a "blocks"=type data definition.

   CSS classes defined:
       sidebar-personnel
           sidebar-contact
   -->
   <xsl:template match="/system-data-structure[.//Personnel] | /system-data-structure[.//dept-address]">
       <div class="well">
           <h3>Contact</h3>
           <xsl:apply-templates select=".//system-data-structure[dept-address] | .//system-data-structure[Personnel]" mode="sidebar-personnel-dept-address"/>
       </div>
   </xsl:template>
   
   <xsl:template match="system-data-structure[dept-address] | system-data-structure[Personnel]" mode="sidebar-personnel-dept-address">
       <xsl:apply-templates select="dept-address"/>
       <xsl:apply-templates select="Personnel" mode="personnel-condensed"/>
   </xsl:template>
</xsl:stylesheet>
