<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes="exsl xd"
                >
    <xsl:import href='bs2-sidebar-social.xslt'/>
    <xsl:import href="../include/locations.xslt"/>
    <xsl:import href="bs2-modal-simple.xslt"/>
    <xsl:import href="../modules/mapdisplay.xslt"/>

    <xsl:strip-space elements="*"/>
    <xsl:output
                method='html'
                indent='yes'
                omit-xml-declaration='yes'
                />

    <xsl:variable name="labelPhoneWrap">12</xsl:variable>

    <!--
   This template is intended to be used at the top most level
   and works on all dept-address system-data-structure blocks found
   below the root.

   This match and apply section will work for either the dept-address data
   definition by itself or wrapped up in a "blocks"=type data definition.

   CSS classes defined:
       sidebar-address
           sidebar-phone
           sidebar-email
           sidebar-hours
           sidebar-social
   -->
    <xsl:template match="/system-data-structure[.//system-data-structure/dept-address]" priority='-2'>
        <xsl:apply-templates select="descendant-or-self::system-data-structure/dept-address"/>
    </xsl:template>

    <!-- This template is intended to match as part of a normal signature search (i.e. ablock chaining) -->
    <xsl:template match="system-data-structure[dept-address] | system-data-structure/blocks/page[@type='page']/content/system-data-structure[dept-address]">
        <xsl:apply-templates select="dept-address"/>
    </xsl:template>


    <xsl:template match="dept-address">
        <xsl:param name="sTitlePrefix" select="Contact "/>
        <xsl:variable name="idDiv" select="translate(normalize-space((ancestor::blocks[1])/id), ' ', '')"/>

        <!-- Figure out if we should get a modal window together to display the address -->
        <xsl:variable name="sBuilding" select="building"/>
        <xsl:variable name="sLocationShortcode">
            <xsl:for-each select="$nsLocations">
                <xsl:value-of select="key('keyLocationToShortCode', $sBuilding)[1]/shortcode"/>
            </xsl:for-each>
        </xsl:variable>

        <!-- Generate the map content and then convert to node-set for dumping -->
        <xsl:variable name="rtfMap">
            <xsl:call-template name="mapdisplay">
                <xsl:with-param name="urlSrc" select="$sUrlLocationData"/>
                <xsl:with-param name="sType" select="'roadmap'"/>
                <xsl:with-param name="idShow" select="$sLocationShortcode"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="nsMap" select="exsl:node-set($rtfMap)"/>

        <xsl:if test="$sLocationShortcode != ''">
            <!-- Generate the modal using the map node-set generated earlier -->
            <xsl:call-template name="modal">
                <!-- We'll use a generated ID to open up this modal later on -->
                <xsl:with-param name="id" select="generate-id()"/>
                <xsl:with-param name="title" select="building"/>
                <xsl:with-param name="content" select="$nsMap"/>
            </xsl:call-template>
        </xsl:if>

        <div class="sidebar-address">
            <xsl:if test="$idDiv != ''">
                <xsl:attribute name="id"><xsl:value-of select="$idDiv"/></xsl:attribute>
            </xsl:if>

            <!-- Display the title -->
            <h2><xsl:value-of select="concat($sTitlePrefix, department)"/></h2>

            <!-- Address -->
            <address class="muted">
                <xsl:if test="$sLocationShortcode != ''">
                    <a data-toggle="modal" href="{concat('#', generate-id())}">
                        <xsl:attribute name="alt">Open up the building locator map</xsl:attribute>
                        <xsl:choose>
                            <!-- Handle special situations -->
                            <xsl:when test="$sLocationShortcode = 'sitka-office'">
                                <xsl:if test="Office[text()]">
                                    <xsl:value-of select="concat('Room ', Office)"/>
                                </xsl:if>
                                <xsl:if test="Campus/value[text()]">
                                    <xsl:value-of select="concat(', ', Campus, ' Campus')"/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring-after(building, ':')"/>
                                <xsl:if test="Office[text()]">
                                    <xsl:value-of select="concat('&#160;', Office)"/>
                                </xsl:if>
                                <xsl:if test="Campus/value[text()]">
                                    <xsl:value-of select="concat(', ', Campus, ' Campus')"/>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                    <br/>
                </xsl:if>
                <xsl:value-of select="street"/><br/>
                <xsl:value-of select="city"/>,
                <xsl:value-of select="state"/>,
                <xsl:value-of select="zip"/>
            </address>

            <!-- Phone number list -->
            <xsl:if test="phone/node() | fax/node()">
                <div class="sidebar-phone">
                    <ul class="unstyled">
                        <xsl:apply-templates select="phone[phone-number] | fax[fax-number]"/>
                    </ul>
                </div>
            </xsl:if>

            <!-- Contact string of links -->
            <div class="sidebar-email">
                <ul class="inline">
                    <!-- Display email addresses as first part of inline list -->
                    <xsl:apply-templates select="emails[normalize-space(email/text()) != ''] | staffsite[normalize-space(text()) != ''] | website[normalize-space(text()) != '']"/>
                </ul>
            </div>

            <!-- Display hours -->
            <xsl:if test="hours/node()">
                <div class="sidebar-hours">
                    <xsl:call-template name="paragraph-wrap">
                        <xsl:with-param name="nodeToWrap" select="hours"/>
                        <xsl:with-param name="classWrap" select="small"/>
                    </xsl:call-template>
                </div>
            </xsl:if>

            <!-- Social media icons -->
            <xsl:if test="soc[normalize-space(soc-type) != '']">
                <div class="sidebar-social">
                    <xsl:apply-templates select="soc" mode="sidebar-social"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>

   <!-- Handle phone / fax numbers -->
    <xsl:template match="phone | fax">
        <!-- Generate the label that we'll use, displayed within parentheses after the number -->
        <xsl:variable name="label">
            <xsl:choose>
                <!-- If it's a phone that we're processing then grab the phone label -->
                <xsl:when test="name() = 'phone'"><xsl:value-of select="normalize-space(phone-label)"/></xsl:when>
                <!-- If it's a fax number, than grab the fax label. If no fax label present, just use "Fax" -->
                <xsl:when test="name() = 'fax'">
                    <xsl:choose>
                        <xsl:when test="normalize-space(fax-label) != ''">
                            <xsl:value-of select="normalize-space(fax-label)"/>
                        </xsl:when>
                        <xsl:otherwise>Fax</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- Figure out the phone number that we'll display based on the node type -->
        <xsl:variable name="number">
            <xsl:choose>
                <xsl:when test="name() = 'phone'"><xsl:value-of select="normalize-space(phone-number)"/></xsl:when>
                <xsl:when test="name() = 'fax'"><xsl:value-of select="normalize-space(fax-number)"/></xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!-- Wrap the link to the number along with the label within a list item -->
        <xsl:if test="$number != ''">
            <li>
                <a>
                    <xsl:attribute name="href"><xsl:value-of select="concat('tel:+1-',$number)"/></xsl:attribute>
                    <xsl:value-of select="$number"/>
                </a>
                <xsl:if test="$label != ''">
                    <xsl:if test="string-length($label) &gt; $labelPhoneWrap">
                        <br/>
                    </xsl:if>
                    <span class="muted"><xsl:value-of select="concat( ' (', $label, ')' )"/></span>
                </xsl:if>
            </li>
        </xsl:if>
    </xsl:template>

    <!--
    This amounts to the contact link line, and should contain the following in order:
        email addresses
        staff website
        department home page
    -->
    <xsl:template match="emails | staffsite | website">
        <!-- Figure out what the link title should be -->
        <xsl:variable name="label">
            <xsl:choose>
                <!-- Handle email addresses and provide a default value as well -->
                <xsl:when test="name() = 'emails'">
                    <xsl:choose>
                        <xsl:when test="normalize-space(email-label) != ''"><xsl:value-of select="normalize-space(email-label)"/></xsl:when>
                        <xsl:otherwise>Email Us</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <!-- Handle website address -->
                <xsl:when test="name() = 'staffsite'">Directory</xsl:when>
                <xsl:when test="name() = 'website'">Home Page</xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!--
       If we're not at the first item and the # of items in the node list is greater than 1,
       then display the | character
       -->
        <xsl:if test="position() &gt; 1 and last() &gt; 1">
            <xsl:text> | </xsl:text>
        </xsl:if>

        <!--
        Create the link within the list item
        -->
        <li>
            <a>
                <!--
                The link target (href) is going to be of a different form depending on the
                type of element we're processing
                -->
                <xsl:attribute name="href">
                    <xsl:choose>
                        <xsl:when test="name() = 'emails'">mailto:<xsl:value-of select="normalize-space(email)"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="normalize-space(.)"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:value-of select="$label"/>
            </a>
        </li>
    </xsl:template>
</xsl:stylesheet>
