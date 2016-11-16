<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2015-12-03T15:18:50-09:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-11-16T09:15:09-09:00

Derived from previous work done by John French at the University of Alaska Southeast.
-->

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

    <xd:doc type="stylesheet">
        <xd:short>Format and display lists of personnel.</xd:short>
        <xd:detail>
            <p>There's currently two ways that personnel can be listed via this stylesheet: either via an index list of personnel (default), or via a "Personnel List" data definition instance.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>
    <!--
    Whether or not the display should be a flat listing of users or to treat
    folders specially.
    -->
    <xsl:param name="personnel-list-mode">false</xsl:param>

    <xd:doc>
        Top level maching template to operate on lists of personnel
    </xd:doc>
    <xsl:template match="system-index-block[descendant::system-data-structure[Personnel | dept-address]]">
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

        <!-- Generate heading: department title -->
        <xsl:variable name="sTitle">
            <xsl:value-of select="department"/>
        </xsl:variable>

        <!-- Get department body  -->
        <xsl:variable name="sBody">
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
        </xsl:variable>

        <!-- Now output according to personnel-list-mode -->
        <xsl:choose>
            <xsl:when test="$personnel-list-mode = 'dept-open'">
                <!-- For the dept-open style put the heading inside the div -->
                <div class="personnel-list-dept-address vcard">
                    <h2>
                        <xsl:value-of select="$sTitle"/>
                    </h2>

                    <div class="row-fluid">
                        <xsl:copy-of select="$sBody"/>
                    </div>
                </div>
            </xsl:when>
            <xsl:when test="$personnel-list-mode = 'dept-suppress'">
                <!-- We've come all this way to do nothing -->
            </xsl:when>
            <xsl:otherwise>
                <!-- For all else, create an accordion -->
                <!-- Starting with the link to drop it down -->
                <h2>
                    <a data-toggle="collapse" type="button">
                        <xsl:attribute name="href">#<xsl:value-of select="concat(generate-id(), '-accordion')"/></xsl:attribute>
                            <img border="0" src="http://www.uas.alaska.edu/a_assets/images/arrows/info-arrow-down.png" style="margin-right:15px;" width="30px"/>
                    </a>
                    <a data-toggle="collapse">
                        <xsl:attribute name="href">#<xsl:value-of select="concat(generate-id(), '-accordion')"/></xsl:attribute>
                        <xsl:value-of select="$sTitle"/>
                    </a>
                </h2>
                <div class="collapse row-fluid vcard" id="{concat(generate-id(), '-accordion')}">
                    <xsl:copy-of select="$sBody"/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
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

            <!-- If there's an entry for this section then we'll display it -->
            <xsl:if test="$nodeCurrent/*[name() = $nodeField/id]/*[name() = $nodeField/data]/text()">
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
                    <a href="{concat($sProtocol, $sData)}">
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
        <div class="dept-address">
            <span class="fn">
                <xsl:choose>
                    <xsl:when test="$sLocationShortCode != ''">
                        <a data-toggle="modal" href="#{concat(generate-id(), '-modal')}"><xsl:call-template name="personnel-list-output-location-name"/></a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="personnel-list-output-location-name"/>
                    </xsl:otherwise>
                </xsl:choose>
            </span><br/>
            <span class="street-address">
                <xsl:value-of select="street"/>
                <xsl:if test="mailstop[text()]"> (<xsl:value-of select="mailstop"/>)</xsl:if>
            </span><br/>
            <span class="locality"><xsl:value-of select="city"/></span>, <span class="region"><xsl:value-of select="state"/></span>
                <span class="postal-code" style="margin-left:5px;">&#160;<xsl:value-of select="zip"/></span>
        </div>
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
        Inner template to output a list of personnel. Behavior changes depending on the global parameter "personnel-list-mode".
    </xd:doc>
    <xsl:template name="personnel-list-inner">
        <xsl:choose>
            <xsl:when test="$personnel-list-mode = 'flat'">
                <xsl:apply-templates select="descendant::system-data-structure/Personnel" mode="personnel-list"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- Display any Personnel data structures at this level (potentially nestled within a system-page) -->
                <xsl:apply-templates select="system-page/descendant::system-data-structure/Personnel | system-data-structure/Personnel" mode="personnel-list"/>

                <!-- Look for any folders present, and then if so, dive into them -->
                <xsl:apply-templates select="system-folder" mode="personnel-list"/>
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
        <!-- Check for children of this folder - only display section header if there's children present -->
        <xsl:if test="system-page">
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
                            <h3><xsl:value-of select="display-name"/></h3>
                        </td>
                    </tr>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Do nothing at this point -->
                </xsl:otherwise>
            </xsl:choose>

            <!-- Continue our recursion into directories and displaying personnel-list entries in this current level -->
            <xsl:call-template name="personnel-list-inner"/>
        </xsl:if>
    </xsl:template>

    <xd:doc>Create a vcard table row for every Personnel content block</xd:doc>
    <xsl:template match="Personnel" mode="personnel-list">
        <!-- nsRolesDocument is the set of all "roles" that a person has in document order -->
        <xsl:param name="nsRolesDocument" select="(Academic-Services | Academic-Schools | Administrative-Services | Student-Services )/value[text() != '']"/>

        <!-- Repackage into a friendly format -->
        <xsl:variable name="rtfRoles">
            <xsl:for-each select="$nsRolesDocument">
                <node><xsl:value-of select="."/></node>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="nsRoles" select="exsl:node-set($rtfRoles)"/>

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
                                <!-- <xsl:call-template name="personnel-generate-name"/> -->
                                <xsl:call-template name="personnel-generate-name">
                                    <xsl:with-param name="bAppendTitle" select="false()"/>
                                </xsl:call-template>

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
                            <xsl:value-of select="normalize-space(Email)"/>
                            </a></p>
                        <div class="collapse row-fluid">
                            <xsl:attribute name="id"><xsl:value-of select="concat(generate-id(), '-accordion')"/></xsl:attribute>

                            <!-- If the set of roles is non-empty, build a string to describe what they do -->
                            <xsl:if test="count($nsRoles/*) &gt; 0">
                                <p>
                                    <span class="role">
                                        <xsl:call-template name="nodeset-join">
                                            <xsl:with-param name="ns" select="$nsRoles/*"/>
                                            <xsl:with-param name="glue" select="', '"/>
                                        </xsl:call-template>
                                    </span>
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
                            <!-- Special case - if this is for the Sitka Campus then don't output this value - the previous stanza will take care of that along with outputing a map. -->
                            <xsl:if test="Campus/value[text()] and $sLocationShortcode != 'sitka-campus'">
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
        <xsl:variable name="rtfLocationInfo">
            <xsl:choose>
                <!-- Handle special situations -->
                <xsl:when test="$sLocationShortcode = 'sitka-office'">
                    <xsl:if test="Office[text()]">
                        <node><xsl:value-of select="concat('Room ', Office)"/></node>
                    </xsl:if>
                    <xsl:if test="Campus/value[text()]">
                        <node><xsl:value-of select="concat(Campus, ' Campus')"/></node>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <node><xsl:value-of select="substring-after(building, ': ')"/></node>
                    <xsl:if test="Office[text()]">
                        <node><xsl:value-of select="Office"/></node>
                    </xsl:if>
                    <xsl:if test="Campus/value[text()]">
                        <node><xsl:value-of select="concat(Campus, ' Campus')"/></node>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="nsLocationInfo" select="exsl:node-set($rtfLocationInfo)"/>
        <xsl:call-template name="nodeset-join">
            <xsl:with-param name="ns" select="$nsLocationInfo/*"/>
            <xsl:with-param name="glue" select="', '"/>
        </xsl:call-template>
        <!-- <xsl:choose>
            <xsl:when test="$sLocationShortcode = 'sitka-office'">
                <xsl:if test="Office[text()]">
                    <xsl:value-of select="concat('Room ', Office)"/>
                </xsl:if>
                <xsl:if test="Campus/value[text()]">
                    <xsl:value-of select="concat(', ', Campus, ' Campus')"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring-after(building, ': ')"/>
                <xsl:if test="Office[text()]">
                    <xsl:value-of select="concat('&#160;', Office)"/>
                </xsl:if>
                <xsl:if test="Campus/value[text()]">
                    <xsl:value-of select="concat(', ', Campus, ' Campus')"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose> -->
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

    <xd:doc>
        <xd:short>Output personnel information for custom data definition of type "Personnel List"</xd:short>
        <xd:detail>
            <p>Most of the time on the site we just want to display a list of personnel along with their directory information contained within a drop down accordion box. However there are times when there doesn't exist sufficient information within their directory entry to fit the context. For instance: Staff Council officials list, with bios that speak directly to their experience on Staff Council.</p>
            <p>This template begins a custom personnel list in Bootstrap 2 semantics, with one row per person split into two columns.</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="system-data-structure[person]">
        <div class="personnel-list">
            <xsl:apply-templates select="person" mode="custom-personnel-list"/>
        </div>
    </xsl:template>

    <xd:doc>
        <xd:short>Template which actually generates the row / columns for the person for the custom personnel list display</xd:short>
        <xd:detail>
            <p>Creates one row per person with a left and right span. The left span contains a div of class "personnel-list-image", while the right span contains a div of class "personnel-list-details".</p>
        </xd:detail>
    </xd:doc>
    <xsl:template match="person" mode="custom-personnel-list">
        <xsl:variable name="nSpanLeft">
            <xsl:choose>
                <xsl:when test="image/path != ''">span3</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="nSpanRight">
            <xsl:choose>
                <xsl:when test="image/path != ''">span9</xsl:when>
                <xsl:otherwise>span12</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Create one row per person -->
        <div class="row-fluid">
            <!-- The left column is the person's image, but only display if there's an image -->
            <xsl:if test="$nSpanLeft">
                <div class="{$nSpanLeft}">
                    <div class="personnel-list-image">
                        <img src="{image/path}" alt="{name}"/>
                    </div>
                </div>
            </xsl:if>
            <!-- The right column is the person's name, title, and description -->
            <div class="{$nSpanRight}">
                <div class="personnel-list-details">
                    <h2>
                        <xsl:choose>
                            <xsl:when test="link/path != ''">
                                <a href="{link/path}" title="{concat('Contact page for ', name)}"><xsl:value-of select="name"/></a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="name"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </h2>
                    <h2 class="subtitle"><xsl:value-of select="title"/></h2>
                    <xsl:call-template name="paragraph-wrap">
                        <xsl:with-param name="nodeToWrap" select="description"/>
                    </xsl:call-template>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>
