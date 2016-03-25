<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
    <xsl:strip-space elements="*"/>
    <xsl:output method="html" indent='yes' omit-xml-declaration='yes'/>

    <!-- Match the root level system-data-structure only -->
    <xsl:template match="system-data-structure[layout][dl-group]">
        <!-- Determine the type of layout desired -->
       <xsl:choose>
           <!-- Use a description list -->
            <xsl:when test="(layout = 'Horizontal') or (layout = 'Vertical')">
               <xsl:apply-templates select="." mode="dl"/>
           </xsl:when>
           <!-- Use an accordion list -->
           <xsl:when test="layout = 'Accordion'">
               <xsl:apply-templates select="." mode="accordion"/>
           </xsl:when>
           <xsl:otherwise>
              <!-- Punt -->
               <xsl:comment> *** Invalid layout: <xsl:value-of select='layout'/> *** </xsl:comment>
           </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Wrap the entire structure in a DL element -->
    <xsl:template match="system-data-structure[layout][dl-group]" mode="dl">
        <dl>
            <xsl:if test="layout = 'Horizontal'">
                <xsl:attribute name="class">dl-horizontal</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="dl-group" mode="dl"/>
        </dl>
    </xsl:template>
    
    <!-- Wrap the entire structure in a div.accordion element -->
    <xsl:template match="system-data-structure[layout][dl-group]" mode="accordion">
        <div class="accordion">
            <xsl:attribute name='id'><xsl:value-of select="generate-id()"/></xsl:attribute>
            <xsl:apply-templates select="dl-group" mode="accordion">
                <xsl:with-param name="accordion_id" select="generate-id()"/>
            </xsl:apply-templates>
        </div>
    </xsl:template>
    
    <!-- For each dl-group create a dt+dd pair -->
    <xsl:template match="dl-group" mode="dl">
        <dt><xsl:value-of select="term"/></dt>
        <dd>
            <!-- Dump out the HTML expression as well as anything unencapsulated -->
            <xsl:copy-of select="definition/* | definition/text()"/>

            <!-- Nested blocks are OK - perform apply-templates accordingly -->
            <xsl:if test="ablock[@type='block']">
                <xsl:apply-templates select="ablock"/>
            </xsl:if>
        </dd>
    </xsl:template>
    
    <!-- For each dl-group create a div.accordion-group > (div.accordion-heading+div.accordion-body>div.accordion-body) set -->
    <xsl:template match="dl-group" mode="accordion">
        <xsl:param name="accordion_id"/>

        <!-- Each div.accordion-group consists of a div.accordion-heading followed
            by a div.accordion-inner -->
        <div class="accordion-group">
            <!-- Create the heading -->
            <div class="accordion-heading">
                <a class="accordion-toggle" data-toggle="collapse">
                    <xsl:attribute name="data-parent">#<xsl:value-of select="$accordion_id"/></xsl:attribute>
                    <xsl:attribute name="href"><xsl:value-of select="concat('#', generate-id())"/></xsl:attribute>
                    <xsl:value-of select="term"/>
                </a>
            </div>

            <!-- Now create the body of the accordion -->
            <div class="accordion-body collapse">
                <xsl:attribute name='id'><xsl:value-of select="generate-id()"/></xsl:attribute>
                <div class="accordion-inner">
                    <xsl:copy-of select="definition/* | definition/text()"/>

                    <!-- Nested blocks are OK - perform apply-templates accordingly -->
                    <xsl:if test="ablock[@type='block']">
                        <xsl:apply-templates select="ablock"/>
                    </xsl:if>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>