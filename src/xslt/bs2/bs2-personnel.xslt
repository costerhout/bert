<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:exsl="http://exslt.org/common"
    xmlns:string="my:string"
    exclude-result-prefixes="exsl string xd">

    <!-- Base imports -->
    <xsl:import href="../include/error.xslt"/>
    <xsl:import href="../include/string.xslt"/>
    <xsl:import href="../include/pathfilter.xslt"/>
    <xsl:import href="../include/locations.xslt"/>
    <xsl:import href="bs2-modal-simple.xslt"/>
    <xsl:import href="../widgets/mapdisplay.xslt"/>

    <xd:doc type="stylesheet">
        <xd:short>Templates to markup the faculty bio data definition into HTML.</xd:short>
        <xd:detail>
            <p>Templates to markup the staff / faculty "Personnel" data definition
            into HTML.  The default output consists of two Bootstrap spans side
            by side with the picture on the right side and the biographical and
            contact information on the left.</p>
            <p>Derives from previous template work done by John French, published in the CMS at "/dir/_common/stylesheets/personnel"</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctoterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <xsl:strip-space elements="*"/>
    <xsl:output method='html' indent='yes' omit-xml-declaration='yes'/>

    <xd:doc>
        Define set of field id to field labels to allow for easier loop processing.
    </xd:doc>
    <xsl:key name="keyIdToFieldDef" match="field" use="id"/>
    <xsl:variable name="rtfFields">
        <fields>
            <field>
                <id>Hours</id>
                <label>Hours</label>
            </field>
            <field>
                <id>Education</id>
                <label>Education</label>
            </field>
            <field>
                <id>Research</id>
                <label>Research</label>
            </field>
            <field>
                <id>representative-recent-publications</id>
                <label>Publications</label>
            </field>
            <field>
                <id>professional-affiliations</id>
                <label>Affiliations</label>
            </field>
            <field>
                <id>Courses-Taught</id>
                <label>Courses Taught</label>
            </field>
            <field>
                <id>Biography</id>
                <label>Biography</label>
            </field>
            <field>
                <id>Misc</id>
                <label>Other</label>
            </field>
        </fields>
    </xsl:variable>
    <xsl:variable name="nsFields" select="exsl:node-set($rtfFields)"/>

    <xd:doc>
        Define map of contact field IDs to class strings and protocols. Allows
        for easier loop processing.  A '.' signifies that the field itself is the link
        and that no protocol should be prepended.
    </xd:doc>
    <xsl:variable name="rtfContactFields">
        <fields>
            <field>
                <id>Phone</id>
                <class>contact tel</class>
                <protocol>tel</protocol>
            </field>
            <field>
                <id>Phone2</id>
                <class>contact tel</class>
                <label>Second Phone</label>
                <protocol>tel</protocol>
            </field>
            <field>
                <id>Fax</id>
                <class>contact tel fax</class>
                <label>Fax</label>
            </field>
            <field>
                <id>Email</id>
                <class>contact email</class>
                <protocol>mailto</protocol>
            </field>
            <field>
                <id>URL</id>
                <class>contact url</class>
                <protocol>.</protocol>
            </field>
        </fields>
    </xsl:variable>
    <xsl:variable name="nsContactFields" select="exsl:node-set($rtfContactFields)"/>

    <xd:doc>
        Matching template to display a 'Personnel' data structure in a chained fashion.
    </xd:doc>
    <xsl:template match="system-data-structure[Personnel]">
        <xsl:apply-templates select="Personnel"/>
    </xsl:template>

    <xd:doc>
        <xd:short>Matching template to provide a default display of a 'Personnel' data
        structure</xd:short>
        <xd:detail>
            <p>Creates a vcard &lt;div&gt; with contact information, a picture, and
            a modal pop-up map display with their office location.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="Personnel">
        <!-- Wrap the whole shebang in a vcard -->
        <div class="vcard">
            <xsl:choose>
                <!-- Is there a picture defined? -->
                <xsl:when test="image[@type='file']/path != '/'">
                    <!-- Yes - create a row with contact info on the left, and the
                    picture on the right -->

                    <!-- Generate image URL and pass through the pathfilter to clean up the path -->
                    <xsl:variable name="sPathImage">
                        <xsl:call-template name="pathfilter">
                            <xsl:with-param name="path" select="image/path"/>
                        </xsl:call-template>
                    </xsl:variable>

                    <xsl:variable name="sUrlImage" select="concat($sUrlBase, $sPathImage)"/>

                    <!-- Generate the row split into two parts: contact info (2/3) and picture (1/3)-->
                    <div class="row-fluid">
                        <div class="span8">
                            <xsl:call-template name="contact_info"/>
                        </div>
                        <div class="span4">
                            <img border="0" class="photo">
                                <xsl:attribute name="class">photo</xsl:attribute>
                                <xsl:attribute name="src"><xsl:value-of select="$sUrlImage"/></xsl:attribute>
                                <xsl:attribute name="alt">
                                    <xsl:value-of select="Last-Name"/>
                                </xsl:attribute>
                            </img>
                        </div>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <!-- No picture defined - simply print out the contact info -->
                    <xsl:call-template name="contact_info"/>
                </xsl:otherwise>
            </xsl:choose>
        </div>

        <!-- Process all of the child nodes with a field definition in nsFields -->
        <xsl:variable name="nodeCurrent" select="."/>

        <xsl:for-each select="*">
            <!-- Prime the iteration variables -->
            <!-- Get the field name - needed to look up in the field defs node-set -->
            <xsl:variable name="sField" select="string(name())"/>

            <!-- Get the field label from the nsFields node-set -->
            <xsl:variable name="sFieldString">
                <xsl:for-each select="$nsFields">
                    <xsl:value-of select="key('keyIdToFieldDef', $sField)[1]/label"/>
                </xsl:for-each>
            </xsl:variable>

            <!--
            If there's a mapping defined for this field, it implies that we should treat it
            special.  Call the helper template with variables set.
            -->
            <xsl:if test="$sFieldString != ''">
                <xsl:call-template name='personnel-list-output-field-section'>
                    <xsl:with-param name='nodeCurrent' select="$nodeCurrent"/>
                    <xsl:with-param name='field' select='name()'/>
                    <xsl:with-param name='fieldString' select='$sFieldString'/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:short>Named template to dump out contact information</xd:short>
        <xd:detail>
            <p>Print out name, title, position, department, and contact information</p>
        </xd:detail>
    </xd:doc>
    <xsl:template name="contact_info">
        <h1 class="fn n small">
            <span class="given-name">
                <xsl:value-of select="First-Name"/>
            </span>
            <xsl:if test="Middle-Name[text()]">
                <xsl:value-of select="'&#160;'"/>
                <span class="additional-name">
                    <xsl:value-of select="Middle-Name"/>
                </span>
            </xsl:if>
            <xsl:value-of select="'&#160;'"/>
            <span class="family-name">
                <xsl:value-of select="Last-Name"/>
            </span>
            <xsl:if test="Degree/value[text()]">
                <xsl:value-of select="',&#160;'"/>
                <xsl:call-template name="nodeset-join">
                    <xsl:with-param name="ns" select="Degree/value"/>
                    <xsl:with-param name="glue" select="', '"/>
                </xsl:call-template>
            </xsl:if>
        </h1>

        <h2 class="role small">
            <xsl:if test="title[text()]">
                <span class="title">
                    <xsl:value-of select="title"/>
                </span>
                <xsl:value-of select="'&#160;'"/>
            </xsl:if>

            <xsl:for-each select="Academic-Services | Academic-Schools | Administrative-Services | Student-Services">
                <xsl:if test="value[text()]">
                    <br/>
                    <xsl:call-template name="nodeset-join">
                        <xsl:with-param name="ns" select="value"/>
                        <xsl:with-param name="glue" select="' / '"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each>
        </h2>

        <!-- Spit out the basic contact information, but only for fields that have text -->
        <xsl:for-each select="(Phone | Phone2 | Fax | Email | URL)[text()]">
            <xsl:variable name="sFieldName" select="name()"/>
            <xsl:variable name="sClassContact">
                <xsl:for-each select="$nsContactFields">
                    <xsl:value-of select="(key('keyIdToFieldDef', $sFieldName))[1]/class"/>
                </xsl:for-each>
            </xsl:variable>

            <xsl:variable name="sLabelContact">
                <xsl:for-each select="$nsContactFields">
                    <xsl:value-of select="key('keyIdToFieldDef', $sFieldName)[1]/label"/>
                </xsl:for-each>
            </xsl:variable>

            <xsl:variable name="sProtocolContact">
                <xsl:for-each select="$nsContactFields">
                    <xsl:if test="key('keyIdToFieldDef', $sFieldName)[1]/protocol != ''">
                        <xsl:value-of select="concat(key('keyIdToFieldDef', $sFieldName)[1]/protocol, ':')"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>

            <p class="{$sClassContact}">
                <xsl:choose>
                    <!-- If the field itself is the link -->
                    <xsl:when test="$sProtocolContact = '.:'">
                        <a target="_self">
                            <xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
                            <xsl:attribute name="alt"><xsl:value-of select="concat('Find out more about ', ../First-Name, ' ', ../Last-Name)"/></xsl:attribute>
                            <xsl:call-template name="personnel-list-output-contact">
                                <xsl:with-param name="sLabelContact" select="$sLabelContact"/>
                            </xsl:call-template>
                        </a>
                    </xsl:when>
                    <!-- If there's a protocol defined then provide a link -->
                    <xsl:when test="$sProtocolContact != ''">
                        <a target="_self">
                            <xsl:attribute name="href"><xsl:value-of select="concat($sProtocolContact, .)"/></xsl:attribute>
                            <xsl:attribute name="alt"><xsl:value-of select="concat('Contact ', ../First-Name, ' ', ../Last-Name)"/></xsl:attribute>
                            <xsl:call-template name="personnel-list-output-contact">
                                <xsl:with-param name="sLabelContact" select="$sLabelContact"/>
                            </xsl:call-template>
                        </a>
                    </xsl:when>
                    <!-- Otherwise, don't bother -->
                    <xsl:otherwise>
                        <xsl:call-template name="personnel-list-output-contact">
                            <xsl:with-param name="sLabelContact" select="$sLabelContact"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </p>
        </xsl:for-each>

        <!-- Figure out if we have a known building to generate a map to -->
        <xsl:variable name="sBuilding" select="building"/>
        <xsl:variable name="sLocationShortcode">
            <xsl:for-each select="$nsLocations">
                <xsl:value-of select="key('keyLocationToShortCode', $sBuilding)[1]/shortcode"/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:if test="$sLocationShortcode != ''">
            <!-- Generate the map content and then convert to node-set for dumping -->
            <xsl:variable name="rtfMap">
                <xsl:call-template name="mapdisplay">
                    <xsl:with-param name="urlSrc" select="$sUrlLocationData"/>
                    <xsl:with-param name="sType" select="'roadmap'"/>
                    <xsl:with-param name="idShow" select="$sLocationShortcode"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="nsMap" select="exsl:node-set($rtfMap)"/>

            <!-- Generate the modal using the map node-set generated earlier -->
            <xsl:call-template name="modal">
                <!-- We'll use a generated ID to open up this modal later on -->
                <xsl:with-param name="id" select="generate-id()"/>
                <xsl:with-param name="title" select="building"/>
                <xsl:with-param name="content" select="$nsMap"/>
            </xsl:call-template>

            <!-- OK now dump out the location contact information with link
            to building map modal -->
            <p class="contact location">
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
            </p>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:short>Helper template to output contact string and label</xd:short>
        <xd:detail>
            <p>This template simply outputs a contact string and an optional label
            in parentheses.</p>
        </xd:detail>
        <xd:param name="sLabelContact" type="string">Label for the contact information</xd:param>
    </xd:doc>
    <xsl:template name="personnel-list-output-contact">
        <xsl:param name="sLabelContact"/>
        <xsl:value-of select="."/>
        <xsl:if test="$sLabelContact != ''">
            <xsl:value-of select="concat(' (', $sLabelContact, ')')"/>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:short>Helper template to output section of biographical information on the person.</xd:short>
        <xd:detail>
            <p>This template outputs a section of information about a person.
                It's able to intelligently wrap bare WYSIWYG content in a &lt;p&gt; tag and
                will only output sections if there's content.</p>
        </xd:detail>
        <xd:param name="nodeCurrent" type="node">Current Personnel node to process</xd:param>
        <xd:param name="field" type="string">Field name within the Personnel node to work on</xd:param>
        <xd:param name="fieldString" type="string">Human-readable field name within the Personnel node to work on</xd:param>
    </xd:doc>
    <xsl:template name='personnel-list-output-field-section'>
        <xsl:param name='nodeCurrent'/>
        <xsl:param name='field'/>
        <xsl:param name='fieldString'/>

        <!-- Does the node actually have this field defined non-null? -->
        <xsl:if test="$nodeCurrent/*[name() = $field]/* | $nodeCurrent/*[name() = $field]/text()">
            <div>
                <h3 class="muted"><xsl:value-of select="concat($fieldString, ':')"/></h3>
                <xsl:choose>
                    <!-- Is this a bare text() node?  If so, wrap in <p> tag -->
                    <xsl:when test="$nodeCurrent/*[name() = $field]/text()">
                        <p><xsl:value-of select="$nodeCurrent/*[name() = $field]"/></p>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$nodeCurrent/*[name() = $field]/*"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
