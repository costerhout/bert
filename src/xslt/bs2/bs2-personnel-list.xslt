<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:exsl="http://exslt.org/common"
                xmlns:string="my:string"
                exclude-result-prefixes="xd exsl string"
                >

    <xsl:import href="../include/locations.xslt"/>
    <xsl:import href="../include/pathfilter.xslt"/>
    <xsl:import href="bs2-personnel.xslt"/>
    <xsl:import href="bs2-modal-simple.xslt"/>
    <xsl:import href="bs2-sidebar-social.xslt"/>
    <xsl:import href="../modules/mapdisplay.xslt"/>

    <xsl:strip-space elements="*"/>
    <xsl:output method="html" indent='yes' omit-xml-declaration='yes'/>

    <!--
    Whether or not the display should be a flat listing of users or to treat
    folders specially.
    -->
    <xsl:param name="personnel-list-flat">false</xsl:param>

    <xd:doc>
        Top level maching template to operate on lists of personnel
    </xd:doc>
    <xsl:template match="system-index-block[descendant::system-data-structure[Personnel]]">
        <!-- First determine if there's a departmental address located within this level -->
        <xsl:apply-templates select="system-page/system-data-structure/dept-address" mode="personnel-list"/>

        <!-- Create the personnel table -->
        <table class="table table-striped table-personnel">
            <tbody>
               <xsl:call-template name="personnel-list-inner"/>
            </tbody>
        </table>
    </xsl:template>

    <xd:doc>
        <xd:short>Display departmental contact information as section heading</xd:short>
        <xd:detail>
            <p>This template is used to output the name of the department and the contact information for that department.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="dept-address" mode="personnel-list">
        <!-- Set up location key via building string -->
        <xsl:variable name="sBuilding" select="building"/>
        <xsl:variable name="sLocationShortcode">
            <xsl:for-each select="$nsLocations">
                <xsl:value-of select="key('keyLocationToShortCode', $sBuilding)[1]/shortcode"/>
            </xsl:for-each>
        </xsl:variable>

        <!-- Generate the map content and then convert to node-set for dumping -->
        <xsl:if test="$sLocationShortcode != ''">
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
                <xsl:with-param name="id" select="concat(generate-id(), '-modal')"/>
                <xsl:with-param name="title" select="building"/>
                <xsl:with-param name="content" select="$nsMap"/>
            </xsl:call-template>
        </xsl:if>

        <!-- Output heading as department title -->
        <h2>
            <a data-toggle="collapse" type="button">
                <xsl:attribute name="href">#<xsl:value-of select="concat(generate-id(), '-accordion')"/></xsl:attribute>
                    <img border="0" src="http://www.uas.alaska.edu/a_assets/images/arrows/info-arrow-down.png" style="margin-right:15px;" width="30px"/>
            </a>
            <a data-toggle="collapse">
                <xsl:attribute name="href">#<xsl:value-of select="concat(generate-id(), '-accordion')"/></xsl:attribute>
                <xsl:value-of select="department"/>
            </a>
        </h2>

        <!-- Output contact information in the form of a drop down accordion box -->
        <div class="collapse row-fluid vcard">
            <xsl:attribute name="id">
                <xsl:value-of select="concat(generate-id(), '-accordion')"/>
            </xsl:attribute>
            <xsl:choose>
                <!-- Alter the output depending on whether or not hours are specified -->
                <xsl:when test="string(hours)">
                    <!-- Hours are specified. Break content into three columns -->
                    <div class="span4">
                        <!-- Output contact information -->
                        <xsl:call-template name="dept-address-contact"/>
                    </div>
                    <div class="span4">
                        <!-- Output address information -->
                        <div class="adr">
                            <xsl:call-template name="dept-address-address">
                                <xsl:with-param name="sLocationShortCode" select="$sLocationShortcode"/>
                            </xsl:call-template>
                        </div>
                    </div>
                    <div class="span4">
                        <!-- Output hours information -->
                        <div class="hours">
                            <xsl:call-template name="dept-address-hours"/>
                        </div>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <!-- No hours specified -->
                    <div class="span6">
                        <!-- Output contact information -->
                        <xsl:call-template name="dept-address-contact"/>
                    </div>
                    <div class="span6">
                        <!-- Output address information -->
                        <div class="adr">
                            <xsl:call-template name="dept-address-address">
                                <xsl:with-param name="sLocationShortCode" select="$sLocationShortcode"/>
                            </xsl:call-template>
                        </div>
                        <xsl:call-template name="dept-address-social"/>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xd:doc>
        Helper template to output selected departmental contact information
    </xd:doc>
    <xsl:template name="dept-address-contact">
        <xsl:variable name="nodeCurrent" select="."/>
        <xsl:variable name="rtfContactFields">
            <fields>
                <field>
                    <id>phone</id>
                    <label>phone-label</label>
                    <data>phone-number</data>
                    <title>Phone</title>
                </field>
                <field>
                    <id>emails</id>
                    <label>email-label</label>
                    <data>email</data>
                    <protocol>mailto:</protocol>
                    <title>Email</title>
                </field>
                <field>
                    <id>fax</id>
                    <label>fax-label</label>
                    <data>fax-number</data>
                    <title>Fax</title>
                </field>
            </fields>
        </xsl:variable>
        <xsl:variable name="nsContactFields" select="exsl:node-set($rtfContactFields)"/>

        <xsl:for-each select="$nsContactFields/fields/*">
            <xsl:variable name="nodeField" select="."/>

            <xsl:if test="$nodeCurrent/*[name() = $nodeField/id]">
                <!-- Create a div to encapsulate this section -->
                <div>
                    <!-- Output header -->
                    <h3><xsl:value-of select="$nodeField/title"/></h3>

                    <!-- Loop through entries and output -->
                    <ul class="unstyled">
                        <xsl:apply-templates select="$nodeCurrent/*[name() = $nodeField/id]" mode="personnel-list">
                            <xsl:with-param name="nodeFieldDef" select="$nodeField"/>
                        </xsl:apply-templates>
                    </ul>
                </div>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:short>Helper template to output individual contact fields</xd:short>
        <xd:detail>
            <p>Matches phone, fax, or emails information.  Uses the parameter $nodeFieldDef to determine how to display the contact information (label, link-ability).</p>
        </xd:detail>
        <xd:param name="nodeFieldDef" type="node">Field definition for the current field being processed, in the form of:
            &lt;field&gt;
                &lt;id&gt;emails&lt;/id&gt;
                &lt;label&gt;email-label&lt;/label&gt;
                &lt;data&gt;email&lt;/data&gt;
                &lt;protocol&gt;mailto:&lt;/protocol&gt;
                &lt;title&gt;Email&lt;/title&gt;
            &lt;/field&gt;

            <p><strong>Fields</strong></p>
            <ul>
                <li>id: which field this is currently</li>
                <li>label: name of label field</li>
                <li>data: name of contact information data field</li>
                <li>protocol: if present, this contact information should be a display as a link with this link prefix</li>
                <li>title: contact information section title</li>
            </ul>
        </xd:param>
    </xd:doc>
    <xsl:template match="phone | fax | emails" mode="personnel-list">
        <xsl:param name="nodeFieldDef"/>

        <!-- Figure out which fields we're to use for the label and contact information -->
        <xsl:variable name="sFieldLabel">
            <xsl:value-of select="$nodeFieldDef/label"/>
        </xsl:variable>

        <xsl:variable name="sFieldData">
            <xsl:value-of select="$nodeFieldDef/data"/>
        </xsl:variable>

        <!-- Gather variables to display -->
        <xsl:variable name="sProtocol">
            <xsl:value-of select="$nodeFieldDef/protocol"/>
        </xsl:variable>

        <xsl:variable name="sLabel">
            <xsl:value-of select="./*[name() = $sFieldLabel]"/>
        </xsl:variable>

        <xsl:variable name="sData">
            <xsl:value-of select="./*[name() = $sFieldData]"/>
        </xsl:variable>

        <li>
            <!-- If we're to use a label then output the contact information with label in front -->
            <xsl:choose>
                <xsl:when test="$sLabel != ''">
                    <xsl:value-of select="concat($sLabel, ': ')"/>
                </xsl:when>
                <xsl:otherwise>
                </xsl:otherwise>
            </xsl:choose>
            <!-- If this field is a link, then wrap the data in a link -->
            <xsl:choose>
                <!-- The protocol field is really just a link prefix, e.g. mailto: -->
                <xsl:when test="$sProtocol != ''">
                    <a href="{concat($sProtocol, $sData)}" alt="{concat('Contact us by ', $nodeFieldDef/title)}">
                        <xsl:value-of select="$sData"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$sData"/>
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>

    <xd:doc>
        Helper template to display a department's address
    </xd:doc>
    <xsl:template name="dept-address-address">
        <xsl:param name="sLocationShortCode"/>
        <h3>Address</h3>
        <xsl:if test="substring-after(building,':')">
            <p>
                <xsl:choose>
                    <xsl:when test="$sLocationShortCode != ''">
                        <a>
                            <xsl:attribute name="href">#<xsl:value-of select="concat(generate-id(), '-modal')"/></xsl:attribute>
                            <xsl:call-template name="personnel-list-output-location-name"/>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="personnel-list-output-location-name"/>
                    </xsl:otherwise>
                </xsl:choose>
            </p>
        </xsl:if>
        <p class="street-address">
            <xsl:value-of select="street"/>
            <xsl:if test="mailstop[text()]"> (<xsl:value-of select="mailstop"/>)</xsl:if>
        </p>
        <p class="locality"><xsl:value-of select="city"/>, <span class="region"><xsl:value-of select="state"/></span>
            <span class="postal-code" style="margin-left:5px;">&#160;<xsl:value-of select="zip"/></span></p>
    </xsl:template>

    <xd:doc>
        Helper template to display a department's hours
    </xd:doc>
    <xsl:template name="dept-address-hours">
        <h3>Hours</h3>
        <xsl:copy-of select="hours"/>
    </xsl:template>

    <xd:doc>
        Helper template to display a department's social networking information (if present)
    </xd:doc>
    <xsl:template name="dept-address-social">
        <!-- Check to see if we have any social media contacts -->
        <xsl:if test="soc/soc-type/text()">
            <h3>Social Media</h3>
            <xsl:for-each select="soc">
                <!-- Save away soc-type for use within for-each -->
                <xsl:variable name="sSocType" select="soc-type"/>
                <xsl:variable name="urlIcon">
                    <xsl:for-each select="$nsSocToIcon">
                        <xsl:value-of select="key('keySocToIcon', string:lowerCase(string($sSocType)))/icon"/>
                    </xsl:for-each>
                </xsl:variable>
                <a class="external-hide-icon" target="_blank">
                    <xsl:attribute name="href">
                        <xsl:value-of select="soc-url"/>
                    </xsl:attribute>
                    <img alt="Follow us on social media" src="{$urlIcon}"/>
                </a>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        Inner template to output a list of personnel. Behavior changes depending on the global parameter "personnel-list-flat".
    </xd:doc>
    <xsl:template name="personnel-list-inner">
        <xsl:choose>
            <xsl:when test="$personnel-list-flat = 'true'">
                <xsl:apply-templates select="descendant::system-data-structure/Personnel" mode="personnel-list"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- Look for any folders present, and then if so, dive into them -->
                <xsl:apply-templates select="system-folder" mode="personnel-list"/>

                <!-- Display any Personnel data structures at this level (potentially nestled within a system-page) -->
                <xsl:apply-templates select="system-page/descendant::system-data-structure/Personnel | system-data-structure/Personnel" mode="personnel-list"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <p>Handle system folders. We handle system folders by:</p>
        <ul>
            <li>displaying a row with the display name of the folder,</li>
            <li>recursing into folders at this level, and then</li>
            <li>displaying all staff at this level</li>
        </ul>
    </xd:doc>
    <xsl:template match="system-folder" mode="personnel-list">
        <xsl:choose>
            <!-- Check to see if there is a department address structure at this level -->
            <xsl:when test="system-page/system-data-structure/dept-address">
                <!-- Create the section header using any pages that contain dept-address information -->
                <tr>
                    <td>
                        <xsl:apply-templates select="system-page/system-data-structure/dept-address" mode="personnel-list"/>
                    </td>
                </tr>
            </xsl:when>
            <!-- No dept-address structure, check to see if there's a display name at least -->
            <xsl:when test="display-name">
                <tr>
                    <td colspan="2"><xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
                        <!--
                        John's original template had this line in order to display the name of the parent folder
                        followed by a ':' character:
                        <xsl:if test="parent::system-folder/display-name"><xsl:value-of select="parent::system-folder/display-name"/>: </xsl:if>
                        -->
                        <xsl:value-of select="display-name"/>
                    </td>
                </tr>
            </xsl:when>
            <xsl:otherwise>
                <!-- Do nothing at this point -->
            </xsl:otherwise>
        </xsl:choose>

        <!-- Continue our recursion into directories and displaying personnel-list entries in this current level -->
        <xsl:call-template name="personnel-list-inner"/>
    </xsl:template>

    <xd:doc>Create a vcard table row for every Personnel content block</xd:doc>
    <xsl:template match="Personnel" mode="personnel-list">
        <!-- nodeRoles is the set of all "roles" that a person has -->
        <xsl:param name="nodeRoles" select="Academic-Services/value | Academic-Schools/value | Administrative-Services/value | Student-Services/value"/>

        <!-- Save away the building node for later usage when building the map -->
        <xsl:variable name="sBuilding" select="building"/>
        <xsl:variable name="sLocationShortcode">
            <xsl:for-each select="$nsLocations">
                <xsl:value-of select="key('keyLocationToShortCode', $sBuilding)[1]/shortcode"/>
            </xsl:for-each>
        </xsl:variable>

        <!-- If there's a building code found, then build a modal to contain the map -->
        <xsl:if test="$sLocationShortcode != ''">
            <!-- Save away the building node for later usage when building the map -->
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

            <!-- Generate the modal using the map node-set generated earlier -->
            <xsl:call-template name="modal">
                <!-- We'll use a generated ID to open up this modal later on -->
                <xsl:with-param name="id" select="concat(generate-id(), '-modal')"/>
                <xsl:with-param name="title" select="building"/>
                <xsl:with-param name="content" select="$nsMap"/>
            </xsl:call-template>
        </xsl:if>

        <tr class="vcard" valign="top">
            <td class="vcard_details">
                <div class="row-fluid">
                    <div class="span2">
                        <!-- Is there an image associated with this entry? -->
                        <xsl:choose>
                            <xsl:when test="image/name[text()]">
                                <div class="thumbnail disappear">
                                    <img class="photo">
                                        <xsl:attribute name="src"><xsl:call-template name="pathfilter"><xsl:with-param name='path' select='image/path'/></xsl:call-template></xsl:attribute>
                                    </img>
                                </div>
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                    </div>

                    <!-- Display the name, contact info, and basic bio of the person -->
                    <div class="span10">
                        <p class="fn">
                            <!-- Create the link that will operate the drop down for more information -->
                            <a data-toggle="collapse" type="button"><xsl:attribute name="href">#<xsl:value-of select="concat(generate-id(), '-accordion')"/></xsl:attribute>
                                <span class="given-name"><xsl:value-of select="First-Name"/> </span>
                                <xsl:if test="Middle-Name[text()]">
                                    <xsl:text disable-output-escaping="yes">&#160;</xsl:text>
                                    <span class="additional-name"><xsl:value-of select="Middle-Name"/></span>
                                </xsl:if>
                                <span><xsl:text disable-output-escaping="yes">&#160;</xsl:text></span>
                                <span class="family-name"><xsl:value-of select="Last-Name"/></span>
                            </a>
                            <!-- Degree names -->
                            <!--  <xsl:text>&#160;</xsl:text><xsl:apply-templates select='Degree/value' mode='join-string'/> -->
                        </p>

                        <!-- Person's title -->
                        <xsl:if test="title[string()]">
                            <p class="title"><xsl:value-of select="title"/>
                            </p>
                        </xsl:if>

                        <!-- Contact info -->
                        <p>
                            <xsl:if test="Phone[text()]">
                                <xsl:choose>
                                    <xsl:when test="contains(Phone, 'N')">Phone: <a target="_self"><xsl:attribute name="href">tel:<xsl:value-of select="Phone"/></xsl:attribute><xsl:value-of select="Phone"/></a></xsl:when>
                                    <xsl:otherwise>Phone: <span class="tel"><a target="_self"><xsl:attribute name="href">tel:<xsl:value-of select="Phone"/></xsl:attribute><xsl:value-of select="Phone"/></a></span>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:if>
                            <xsl:if test="Phone2[text()]">
                                <xsl:text disable-output-escaping="yes">,&#160;</xsl:text><span class="type"><xsl:text>Second Phone: </xsl:text></span><span class="contact tel">
                                <a target="_self"><xsl:attribute name="href">tel:<xsl:value-of select="Phone2"/></xsl:attribute><xsl:value-of select="system-data-structure/Personnel/Phone2"/></a></span>
                            </xsl:if>
                            <xsl:if test="Fax[text()]">
                                <xsl:text disable-output-escaping="yes">,&#160;</xsl:text><span class="type"><xsl:text>Fax: </xsl:text></span> <span class="contact tel fax">
                                <xsl:value-of select="Fax"/></span>
                            </xsl:if>
                        </p>
                        <p>Email: <a class="email">
                            <xsl:attribute name="href">mailto:<xsl:value-of select="Email"/></xsl:attribute>
                            <xsl:value-of select="Email"/>
                            </a></p>
                        <div class="collapse row-fluid">
                            <xsl:attribute name="id"><xsl:value-of select="concat(generate-id(), '-accordion')"/></xsl:attribute>

                            <!-- If the set of roles is non-empty, build a string to describe what they do -->
                            <xsl:if test="$nodeRoles">
                                <p>
                                    <span class="role"><xsl:apply-templates select='$nodeRoles' mode='join-string'/></span>
                                </p>
                            </xsl:if>

                            <!-- Check to see if they are located somewhere -->
                            <xsl:if test="building != ''">
                                <p class="contact location">
                                    <xsl:choose>
                                        <!--
                                        Check to see if we were able to map the building to a building code
                                        If so, then set up thee link to open up the modal window
                                        -->
                                        <xsl:when test="$sLocationShortcode != ''">
                                            <a data-toggle="modal" href="{concat('#', generate-id(), '-modal')}">
                                                <xsl:attribute name="alt">Open up the building locator map</xsl:attribute>
                                                <xsl:call-template name='personnel-list-output-location-name'>
                                                    <xsl:with-param name="sLocationShortcode" select="$sLocationShortcode"/>
                                                </xsl:call-template>
                                            </a>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name='personnel-list-output-location-name'>
                                                <xsl:with-param name="sLocationShortcode" select="$sLocationShortcode"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </p>
                            </xsl:if>
                            <xsl:if test="Campus/value[text()]">
                                <p class="contact location"><xsl:value-of select="Campus"/> Campus</p>
                            </xsl:if>
                            <xsl:if test="URL[text()]">
                                <p class="contact url">
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="URL"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="target">_blank</xsl:attribute>
                                        <xsl:value-of select="URL"/>
                                    </a>
                                </p>
                            </xsl:if>

                            <!-- Save away the current node for later usage within a different context -->
                            <xsl:variable name="nodeCurrent" select="."/>

                            <!-- Process all of the child nodes (but only if there's a mapping defined)  -->
                            <xsl:for-each select="*">
                                <!-- Prime the iteration variables -->
                                <xsl:variable name="sField" select="string(name(.))"/>

                                <!-- Get the field label from the nsPersonnelFields node-set imported from bs2-personnel.xslt -->
                                <xsl:variable name="sFieldString">
                                    <xsl:for-each select="$nsPersonnelFields">
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
                                        <xsl:with-param name='field' select='$sField'/>
                                        <xsl:with-param name='fieldString' select='$sFieldString'/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:for-each>
                        </div>
                    </div>
                </div>
            </td>
        </tr>
    </xsl:template>

    <xd:doc>
        Helper template to output the name of the building
    </xd:doc>
    <xsl:template name='personnel-list-output-location-name'>
        <xsl:param name="sLocationShortcode" select="''"/>
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
    </xsl:template>

    <xd:doc>
        <xd:short>Helper template to output section of biographical information on the person.</xd:short>
        <xd:detail>
            <p></p>
        </xd:detail>
        <xd:param name="nodeCurrent" type="node">current Personnel node to process</xd:param>
        <xd:param name="field" type="string">field name within the Personnel node to work on</xd:param>
        <xd:param name="fieldString" type="string">Human-readable field name within the Personnel node to work on</xd:param>
    </xd:doc>
    <xsl:template name='personnel-list-output-field-section'>
        <xsl:param name='nodeCurrent'/>
        <xsl:param name='field'/>
        <xsl:param name='fieldString'/>

        <!-- Does the node actually have this field defined non-null? -->
        <xsl:if test="$nodeCurrent/*[name() = $field]/* | $nodeCurrent/*[name() = $field]/text()">
            <div>
                <h3><xsl:value-of select="$fieldString"/></h3>
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
