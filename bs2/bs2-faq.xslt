<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
    <xsl:strip-space elements="*"/>
    <xsl:output method="html" indent='yes' omit-xml-declaration='yes'/>

    <!-- Match Groups of FAQs -->
    <xsl:template match="system-data-structure[faq-group]">
        <xsl:for-each select="faq-group">
            <xsl:copy-of select="group-intro/*"/>
            <xsl:call-template name="faq-group"/>
        </xsl:for-each>       
    </xsl:template>

    <!-- Match sets of faq-item-wysiwyg system-data-structure blocks -->
    <xsl:template match="system-data-structure[faq-item-wysiwyg]">
        <xsl:call-template name="faq-group"/>
    </xsl:template>

    <!-- For each group of faq-item-wysiwyg items set up the accordion structure -->
    <xsl:template name="faq-group">        
        <div class="accordion">
            <xsl:attribute name='id'><xsl:value-of select="generate-id()"/></xsl:attribute>
            <xsl:apply-templates select="faq-item-wysiwyg">
                <xsl:with-param name="accordion_id" select="generate-id()"/>
            </xsl:apply-templates>
        </div>
    </xsl:template>         

    <!-- For each dl-group create a div.accordion-group > (div.accordion-heading+div.accordion-body>div.accordion-body) set -->
    <xsl:template match="faq-item-wysiwyg">
        <xsl:param name="accordion_id"/>

        <!-- Each div.accordion-group consists of a div.accordion-heading followed
            by a div.accordion-inner -->
        <div class="accordion-group">
            <!-- Create the heading -->
            <div class="accordion-heading">
                <a class="accordion-toggle" data-toggle="collapse">
                    <xsl:attribute name="data-parent">#<xsl:value-of select="$accordion_id"/></xsl:attribute>
                    <xsl:attribute name="href"><xsl:value-of select="concat('#', generate-id())"/></xsl:attribute>
                    <xsl:value-of select="question"/>
                </a>
            </div>

            <!-- Now create the body of the accordion -->
            <div class="accordion-body collapse">
                <xsl:attribute name='id'><xsl:value-of select="generate-id()"/></xsl:attribute>
                <div class="accordion-inner">
                    <xsl:copy-of select="answer/* | definition/text()"/>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>