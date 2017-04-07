<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:exsl="http://exslt.org/common"
                xmlns:string="my:string"
                exclude-result-prefixes="xd exsl string"
                >
    <xsl:import href='../include/string.xslt'/>
    <xsl:strip-space elements="*"/>
    <xsl:output method="html" indent='yes' omit-xml-declaration='yes'/>

    <!-- Wrap the entire structure in a div.accordion element -->
    <xd:doc>
        <xd:short>hero-unit</xd:short>
        <xd:detail>
            &lt;p&gt;Named template to create Bootstrap 2 hero unit based on the passed hero unit descriptor.&lt;/p&gt;
            &lt;p&gt;The hero-unit descriptor node-set should look like:&lt;/p&gt;
            &lt;hero-unit&gt;
                &lt;id&gt;Optional id string to apply to this hero-unit section. Defaults to "hero-unit-N" where N is random.&lt;/id&gt;
                &lt;class&gt;Optional class string to apply to this hero-unit section. Is appended to default class string &quot;hero-unit&quot;&lt;/class&gt;
                &lt;title&gt;This is the title of the hero-unit inside of element H1.&lt;/title&gt;
                &lt;subtitle&gt;This is the subtitle displayed below the title with class subtitle&lt;/subtitle&gt;
                &lt;body&gt;Text to display in paragraph form under the subtitle&lt;/body&gt;
                &lt;background-image&gt;Path to image to display in the background&lt;/background-image&gt;
            &lt;/hero-unit&gt;

            The final hero-unit will come out in this fashion:
            &lt;div class=&quot;hero-unit classOptional&quot; id=&quot;idOptional&quot;&gt;
                &lt;h1&gt;Title&lt;/h1&gt;
                &lt;p class=&quot;subtitle&quot;&gt;Sub-title&lt;/p&gt;
                &lt;p&gt;Body text, if any&lt;/p&gt;
            &lt;/div&gt;
        </xd:detail>
        <xd:param name="nsHeroUnit" type="node-set">Set of accordion-item nodes to display</xd:param>
    </xd:doc>
    <xsl:template name="hero-unit">
            <xsl:param name="nsHeroUnit"/>
            <!-- Build the class string based on the default + additional class, if specified -->
            <xsl:for-each select="$nsHeroUnit/hero-unit">
                <xsl:variable name="idHeroUnit">
                    <xsl:choose>
                        <xsl:when test="id"><xsl:value-of select="id"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="string:generateId('hero-unit-')"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="rtfClass">
                    <node>hero-unit</node>
                    <xsl:choose>
                        <xsl:when test="class[text() != '']">
                            <node>
                                <xsl:value-of select="normalize-space(class)"/>
                            </node>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="sClass">
                    <xsl:call-template name="nodeset-join">
                        <xsl:with-param name="ns" select="exsl:node-set($rtfClass)/*"/>
                        <xsl:with-param name="glue" select="' '"/>
                    </xsl:call-template>
                </xsl:variable>
                <div class="{$sClass}" id="{$idHeroUnit}">
                    <xsl:if test="background-image/path != '/'">
                        <xsl:attribute name="style">
                            <xsl:text>background-image: url('</xsl:text>
                            <xsl:value-of select="background-image/path"/>
                            <xsl:text>');</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    <div class="hero-inner">
                        <h1>
                            <xsl:value-of select="title"/>
                        </h1>
                        <xsl:if test="normalize-space(subtitle) != ''">
                            <p class="subtitle">
                                <xsl:value-of select="subtitle"/>
                            </p>
                        </xsl:if>
                        <xsl:call-template name="paragraph-wrap">
                            <xsl:with-param name="nodeToWrap" select="body"/>
                        </xsl:call-template>
                    </div>
                </div>
            </xsl:for-each>
        </xsl:template>
            <xsl:template match="system-data-structure[hero-unit]">
        <xsl:variable name="rtfHeroUnit">
            <hero-unit>
                <title>
                    <xsl:value-of select="hero-unit/title"/>
                </title>
                <subtitle>
                    <xsl:value-of select="hero-unit/subtitle"/>
                </subtitle>
                <id>
                    <xsl:value-of select="hero-unit/id"/>
                </id>
                <xsl:if test="hero-unit/body[node()] or hero-unit/body[text()]">
                    <body>
                        <xsl:call-template name="paragraph-wrap">
                            <xsl:with-param name="nodeToWrap" select="hero-unit/body"/>
                        </xsl:call-template>
                    </body>
                </xsl:if>
                <xsl:if test="hero-unit/background-image/path != '/'">
                    <xsl:copy-of select="hero-unit/background-image"/>
                </xsl:if>
            </hero-unit>
        </xsl:variable>
        <xsl:call-template name="hero-unit">
            <xsl:with-param name="nsHeroUnit" select="exsl:node-set($rtfHeroUnit)"/>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
