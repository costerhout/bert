<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output indent="yes" method="xml" omit-xml-declaration="yes"/>
    <xsl:include href="pathfilter.xslt"/>

    <!-- Walk through the given system index block -->
    <xsl:template match="system-index-block">
       <!-- Desktop / Tablet devices -->
        <div class="hidden-phone">
            <div class="p7TMM10" id="p7TMM_1">
                <ul class="p7TMM">
                    <xsl:apply-templates select="system-page | system-folder"/>
                </ul>
                <script type="text/javascript">
                    P7_TMMop('p7TMM_1',1,0,0,3,1,1,1,0,-1);
                </script> 
            </div>  
        </div>
        <!-- Small form factor (phone) devices -->
        <div class="visible-phone">
            <div class="p7TMM10" id="p7TMM_2">
                <ul class="p7TMM">
                    <xsl:apply-templates mode="no-index" select="system-page | system-folder"/>
                </ul>
                <script type="text/javascript">
                    P7_TMMop('p7TMM_2',0,0,0,3,1,0,0,1,-1);
                </script> 
            </div>      
        </div>                 
    </xsl:template>

   <!-- Phone menu - create a submenu and recurse -->
    <xsl:template match="system-folder" mode="no-index">       
        <xsl:if test="dynamic-metadata[name='Include in Navigation']/value = 'Yes'">   
            <xsl:if test="system-page[name = 'index']">
                <li>
                    <a class="subFolder" href="#">
                        <xsl:value-of select="display-name"/>
                    </a>
                    <div>
                        <ul>
                            <xsl:apply-templates mode="no-index" select="system-page | system-folder">
                                <xsl:with-param name="sub-folder">true</xsl:with-param>
                            </xsl:apply-templates>
                        </ul>
                    </div>
                </li>      
            </xsl:if>
        </xsl:if>
    </xsl:template>

   <!-- Phone menu - create menu entry -->
    <xsl:template match="system-page" mode="no-index">
        <xsl:if test="dynamic-metadata[name='Include in Navigation']/value = 'Yes'">
            <li>
                <a>
                    <xsl:attribute name="href">
                        <xsl:call-template name="pathfilter"><xsl:with-param name='path'><xsl:value-of select="system-page[name = 'index']/path"/></xsl:with-param></xsl:call-template>
                    </xsl:attribute>

                    <xsl:attribute name="title">
                        <xsl:value-of select="title"/>
                    </xsl:attribute>
                    <xsl:value-of select="display-name"/>
                </a>
            </li>
        </xsl:if>
    </xsl:template>

   <!-- Desktop menu - create a submenu and recurse -->
    <xsl:template match="system-folder">
       <!-- Subsequent recursions invoke this template with sub-folder set to 'true' -->
        <xsl:param name="sub-folder">false</xsl:param>
        <xsl:variable name="index-name">
            <xsl:choose>
                <xsl:when test="system-page[name='default']">default</xsl:when>
                <xsl:otherwise>index</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- select to display +/- images when a subfolder exists and put a horizontal line above -->
        <xsl:if test="dynamic-metadata[name='Include in Navigation']/value = 'Yes'">
            <xsl:if test="system-page[name = 'index']">
                <xsl:choose>
                    <xsl:when test="count(system-page[dynamic-metadata[name='Include in Navigation']/value = 'Yes']) = 1">
                        <xsl:choose>
                            <xsl:when test="system-folder[dynamic-metadata[name='Include in Navigation']/value = 'Yes']/system-page[dynamic-metadata[name='Include in Navigation']/value = 'Yes']/name = 'index'">

                                <li>
                                    <a class="subFolder"><xsl:attribute name="href"><xsl:call-template name="pathfilter"><xsl:with-param name='path'><xsl:value-of select="system-page[name = 'index']/path"/></xsl:with-param></xsl:call-template></xsl:attribute>
                                        <xsl:value-of select="display-name"/>
                                    </a>
                                    <div>
                                        <ul>
                                            <xsl:apply-templates select="system-page | system-folder">
                                                <xsl:with-param name="sub-folder">true</xsl:with-param>
                                            </xsl:apply-templates>
                                        </ul>
                                    </div>
                                </li>
                            </xsl:when>
                            <xsl:otherwise>
                                <li>
                                    <a class="subFolder"><xsl:attribute name="href"><xsl:call-template name="pathfilter"><xsl:with-param name='path'><xsl:value-of select="system-page[name = 'index']/path"/></xsl:with-param></xsl:call-template></xsl:attribute>
                                        <xsl:value-of select="display-name"/>
                                    </a>

                                </li>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <li>
                            <a><xsl:attribute name="href"><xsl:call-template name="pathfilter"><xsl:with-param name='path'><xsl:value-of select="system-page[name = 'index']/path"/></xsl:with-param></xsl:call-template></xsl:attribute>
                                <xsl:value-of select="display-name"/>
                            </a>
                            <div>
                                <ul>
                                    <xsl:apply-templates select="system-page | system-folder">
                                        <xsl:with-param name="sub-folder">true</xsl:with-param>
                                    </xsl:apply-templates>
                                </ul>
                            </div>
                        </li>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <!-- select to display links with the display name as the text -->
    <xsl:template match="system-page">
        <xsl:choose>
            <xsl:when test="dynamic-metadata[name='Include in Navigation']/value = 'Yes'">
                <xsl:choose>
                    <!-- IF IT IS IN A FOLDER --> 
                    <xsl:when test="parent::system-folder[dynamic-metadata[name='Include in Navigation']/value = 'Yes']">
                        <xsl:choose>
                            <!-- DO NOT SHOW INDEX PAGE because it already has a link to its folder --> 

                            <xsl:when test="name = 'index'">
                                <xsl:choose>
                                    <xsl:when test="count(ancestor::system-folder) &gt; 1">

                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <li>
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:call-template name="pathfilter"><xsl:with-param name='path'><xsl:value-of select="system-page[name = 'index']/path"/></xsl:with-param></xsl:call-template>
                                        </xsl:attribute>

                                        <xsl:attribute name="title">
                                            <xsl:value-of select="title"/>
                                        </xsl:attribute>
                                        <xsl:value-of select="display-name"/>
                                    </a>
                                </li>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <li>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:call-template name="pathfilter"><xsl:with-param name='path'><xsl:value-of select="system-page[name = 'index']/path"/></xsl:with-param></xsl:call-template>
                                </xsl:attribute>

                                <xsl:attribute name="title">
                                    <xsl:value-of select="title"/>
                                </xsl:attribute>
                                <xsl:value-of select="display-name"/>
                            </a>
                        </li>
                    </xsl:otherwise>
                </xsl:choose>  
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>  
    </xsl:template>

</xsl:stylesheet>