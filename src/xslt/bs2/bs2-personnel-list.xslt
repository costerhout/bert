<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes="xd"
                >

    <xsl:import href="../include/locations.xslt"/>
    <xsl:import href="../include/pathfilter.xslt"/>
    <xsl:import href="bs2-modal-simple.xslt"/>
    <xsl:import href="../widgets/mapdisplay.xslt"/>

    <xsl:strip-space elements="*"/>
    <xsl:output method="html" indent='yes' omit-xml-declaration='yes'/>

    <!--
    Whether or not the display should be a flat listing of users or to treat
    folders specially.
    -->
    <xsl:param name="personnel-list-flat">false</xsl:param>

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

    <!-- Match lists of personnel -->
    <xsl:template match="system-index-block[descendant::system-data-structure[Personnel]]">
        <!-- Create the personnel table -->
        <table class="table table-striped table-personnel">
            <tbody>
               <xsl:call-template name="personnel-list-inner"/>
            </tbody>
        </table>
    </xsl:template>

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

    <!--
    We handle system folders by:
      * displaying a row with the display name of the folder,
      * recursing into folders at this level, and then
      * displaying all staff at this level
    -->
    <xsl:template match="system-folder" mode="personnel-list">
        <xsl:if test="display-name">
            <tr>
                <th colspan="2"><xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
                    <!--
                    John's original template had this line in order to display the name of the parent folder
                    followed by a ':' character:
                    <xsl:if test="parent::system-folder/display-name"><xsl:value-of select="parent::system-folder/display-name"/>: </xsl:if>
                    -->
                    <xsl:value-of select="display-name"/>
                </th>
            </tr>
        </xsl:if>
        <!-- Continue our recursion into directories and displaying personnel-list entries in this current level -->
        <xsl:call-template name="personnel-list-inner"/>
    </xsl:template>

    <!-- Create a vcard table row for every Personnel content block -->
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
                            <a data-toggle="collapse" type="button"><xsl:attribute name="href">#<xsl:value-of select="generate-id()"/></xsl:attribute>
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
                            <xsl:attribute name="id"><xsl:value-of select="generate-id()"/></xsl:attribute>

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
                                            <a data-toggle="modal" href="{concat('#', generate-id())}">
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

    <!--
    Helper template to output the name of the building
    -->
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

    <!--
    Helper template to output section of biographical information on the person.

    Parameters (all required):
        node (node) - current Personnel node to process
        field (string) - field name within the Personnel node to work on
        fieldString (string) - Human-readable field name within the Personnel node to work on
    -->
    <xsl:template name='personnel-list-output-field-section'>
        <xsl:param name='nodeCurrent'/>
        <xsl:param name='field'/>
        <xsl:param name='fieldString'/>

        <!-- Does the node actually have this field defined non-null? -->
        <xsl:if test="$nodeCurrent/*[name() = $field]/* | $nodeCurrent/*[name() = $field]/text()">
            <div>
                <h3><xsl:value-of select="concat($fieldString, ':')"/></h3>
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

    <!-- Helper utility to join together nodes into one longer string wrapped in a span.role element -->
    <xsl:template match='value' mode='join-string'>
       <xsl:param name='glue'>, </xsl:param>
        <xsl:value-of select="."/>
        <xsl:if test='position() != last()'><xsl:value-of select="$glue"/></xsl:if>
    </xsl:template>
</xsl:stylesheet>
