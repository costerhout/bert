<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2015-12-11T12:54:48-09:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2019-07-23T12:00:24-08:00

Derived from previous work done by John French at the University of Alaska Southeast.
-->

<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes="xd exsl"
                >
    <xsl:import href="bs2-accordion-group.xslt"/>
    <xsl:import href='../include/string.xslt'/>
    <xsl:strip-space elements="*"/>
    <xsl:output method="html" indent='yes' omit-xml-declaration='yes'/>
    <xsl:variable name="config_method">post</xsl:variable>
    <xsl:variable name="form_class_default">form-horizontal</xsl:variable>
    <xsl:variable name="max_simple_group_count">6</xsl:variable>
    <xsl:variable name="field_default_size">30</xsl:variable>
    <xsl:variable name="prefix_file">attachment</xsl:variable>

    <xd:doc type="stylesheet">
        <xd:short>bs2-email-form.xslt</xd:short>
        <xd:detail>
            <p>Stylesheet to convert an index of form configuration and form sections into a form which will email the results back to the intended recipient.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctosterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2016</xd:copyright>
    </xd:doc>

    <xd:doc>
        Top level matching template. Matches index block with the signature of having a 'form section config' data definition.
    </xd:doc>
    <xsl:template match="system-index-block[descendant::system-block/system-data-structure[@definition-path='form section config']]">
        <!-- Form detected.  Set all variables gathered from the form's "form section config" structure -->
        <xsl:variable name="form_div_id"><xsl:value-of select="generate-id()"/></xsl:variable>
        <xsl:variable name="config_action"><xsl:value-of select="descendant::system-data-structure[@definition-path='form section config']/config/action"/></xsl:variable>
        <xsl:variable name="config_onsubmit"><xsl:value-of select="descendant::system-data-structure[@definition-path='form section config']/config/onsubmit"/></xsl:variable>
        <xsl:variable name="config_formid"><xsl:value-of select="descendant::system-data-structure[@definition-path='form section config']/config/formid"/></xsl:variable>
        <xsl:variable name="config_MAILTO"><xsl:value-of select="descendant::system-data-structure[@definition-path='form section config']/config/MAILTO"/></xsl:variable>
        <xsl:variable name="config_SUBJECT"><xsl:value-of select="descendant::system-data-structure[@definition-path='form section config']/config/SUBJECT"/></xsl:variable>
        <xsl:variable name="config_FOLLOWUP"><xsl:value-of select="descendant::system-data-structure[@definition-path='form section config']/config/FOLLOWUP"/></xsl:variable>
        <xsl:variable name="config_DISABLEAUTOFOCUS"><xsl:value-of select="descendant::system-data-structure[@definition-path='form section config']/config/disable-autofocus/value"/></xsl:variable>
        <xsl:variable name="config_submit_button_text"><xsl:value-of select="descendant::system-data-structure[@definition-path='form section config']/config/submit_button_text"/></xsl:variable>
        <!-- This was a late addition to the 'form section config' data definition so we can't count on it being there -->
        <xsl:variable name="form_class">
            <xsl:choose>
                <xsl:when test="descendant::system-data-structure[@definition-path='form section config']/config/label-position">form-<xsl:value-of select="descendant::system-data-structure[@definition-path='form section config']/config/label-position"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="$form_class_default"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <div class="form">
            <xsl:attribute name="id"><xsl:value-of select="$form_div_id"/></xsl:attribute>
            <!-- Perform any output / processing before the actual output of the form -->
            <xsl:call-template name="paragraph-wrap">
                <xsl:with-param name="nodeToWrap" select="descendant::system-block/system-data-structure[@definition-path='form section config']/opening" />
            </xsl:call-template>
            <xsl:if test='count(descendant::system-data-structure/form_group) &gt; $max_simple_group_count'>
                <div class="form-toc">
                    <h2>Form Sections</h2>
                    <ul>
                        <xsl:apply-templates select="descendant::system-data-structure/form_group" mode='form-toc'/>
                    </ul>
                </div>
            </xsl:if>

            <form>
               <!-- Class to assign to the form itself (if necessary) -->
                <xsl:choose>
                   <!--
                   xsl:when is used here to allow space for additional form types to be added
                   in the future, such as form-inline and form-search.
                   -->
                    <xsl:when test="$form_class = 'form-horizontal'">
                        <xsl:attribute name="class"><xsl:value-of select="$form_class"/></xsl:attribute>
                    </xsl:when>
                </xsl:choose>
                <!-- If there's any file upload elements, the form should encode data in a special manner -->
                <xsl:choose>
                    <xsl:when test="descendant::form_item[type='file']">
                        <xsl:attribute name="enctype">multipart/form-data</xsl:attribute>
                    </xsl:when>
                </xsl:choose>
                <xsl:attribute name="method"><xsl:value-of select="$config_method"/></xsl:attribute>
                <xsl:attribute name="action"><xsl:value-of select="$config_action"/></xsl:attribute>
                <xsl:if test="$config_onsubmit != ''">
                    <xsl:attribute name="onsubmit">
                        <xsl:value-of select="$config_onsubmit"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:attribute name="name"><xsl:value-of select="$config_formid"/></xsl:attribute>
                <xsl:attribute name="id"><xsl:value-of select="$config_formid"/></xsl:attribute>
                <input name="MAILTO" type="hidden">
                    <xsl:attribute name="value"><xsl:value-of select="$config_MAILTO"/></xsl:attribute>
                </input>

                <input name="SUBJECT" type="hidden">
                    <xsl:attribute name="value"><xsl:value-of select="$config_SUBJECT"/></xsl:attribute>
                </input>

                <input name="FOLLOWUP" type="hidden">
                    <xsl:attribute name="value"><xsl:value-of select="$config_FOLLOWUP"/></xsl:attribute>
                </input>

                <!-- Call the matching template to handle each form group -->
                <xsl:apply-templates select="descendant::system-data-structure[form_group]">
                    <xsl:with-param name="idFormDiv" select="$form_div_id"/>
                    <xsl:with-param name="form_class" select="$form_class"/>
                    <xsl:with-param name="disableAutofocus" select="$config_DISABLEAUTOFOCUS"/>
                </xsl:apply-templates>

                <div class="form-actions">
                    <input class="btn btn-primary" type="submit">
                        <xsl:attribute name="value">
                            <xsl:choose>
                                <xsl:when test="normalize-space($config_submit_button_text)">
                                    <xsl:value-of select="normalize-space($config_submit_button_text)"/>
                                </xsl:when>
                                <xsl:otherwise>Submit</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </input>
                    <input class="btn" type="reset" value="Reset Form"/>
                </div>
            </form>
        </div>
    </xsl:template>
    
    <xd:doc>
        Top level matching template which will match on pages using the "default global" definition
    </xd:doc>
    <xsl:template match="/system-data-structure[config]">
        <!-- Form detected.  Set all variables gathered from the form's "form section config" structure -->
        <xsl:variable name="form_div_id"><xsl:value-of select="generate-id()"/></xsl:variable>
        <xsl:variable name="config_action"><xsl:value-of select="config/action"/></xsl:variable>
        <xsl:variable name="config_onsubmit"><xsl:value-of select="config/onsubmit"/></xsl:variable>
        <xsl:variable name="config_formid"><xsl:value-of select="config/formid"/></xsl:variable>
        <xsl:variable name="config_MAILTO"><xsl:value-of select="config/MAILTO"/></xsl:variable>
        <xsl:variable name="config_SUBJECT"><xsl:value-of select="config/SUBJECT"/></xsl:variable>
        <xsl:variable name="config_FOLLOWUP"><xsl:value-of select="config/FOLLOWUP"/></xsl:variable>
        <xsl:variable name="config_DISABLEAUTOFOCUS"><xsl:value-of select="config/disable-autofocus/value"/></xsl:variable>
        <xsl:variable name="config_submit_button_text"><xsl:value-of select="config/submit_button_text"/></xsl:variable>
        <!-- This was a late addition to the 'form section config' data definition so we can't count on it being there -->
        <xsl:variable name="form_class">
            <xsl:choose>
                <xsl:when test="config/label-position">form-<xsl:value-of select="config/label-position"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="$form_class_default"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <div class="form">
            <xsl:attribute name="id"><xsl:value-of select="$form_div_id"/></xsl:attribute>
            <!-- Perform any output / processing before the actual output of the form -->
            <xsl:call-template name="paragraph-wrap">
                <xsl:with-param name="nodeToWrap" select="opening" />
            </xsl:call-template>

            <xsl:if test='count(form_group) &gt; $max_simple_group_count'>
                <div class="form-toc">
                    <h2>Form Sections</h2>
                    <ul>
                        <xsl:apply-templates select="form_group" mode='form-toc'/>
                    </ul>
                </div>
            </xsl:if>

            <form>
               <!-- Class to assign to the form itself (if necessary) -->
                <xsl:choose>
                   <!--
                   xsl:when is used here to allow space for additional form types to be added
                   in the future, such as form-inline and form-search.
                   -->
                    <xsl:when test="$form_class = 'form-horizontal'">
                        <xsl:attribute name="class"><xsl:value-of select="$form_class"/></xsl:attribute>
                    </xsl:when>
                </xsl:choose>
                <!-- If there's any file upload elements, the form should encode data in a special manner -->
                <xsl:choose>
                    <xsl:when test="descendant::form_item[type='file']">
                        <xsl:attribute name="enctype">multipart/form-data</xsl:attribute>
                    </xsl:when>
                </xsl:choose>
                <xsl:attribute name="method"><xsl:value-of select="$config_method"/></xsl:attribute>
                <xsl:attribute name="action"><xsl:value-of select="$config_action"/></xsl:attribute>
                <xsl:if test="$config_onsubmit != ''">
                    <xsl:attribute name="onsubmit">
                        <xsl:value-of select="$config_onsubmit"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:attribute name="name"><xsl:value-of select="$config_formid"/></xsl:attribute>
                <xsl:attribute name="id"><xsl:value-of select="$config_formid"/></xsl:attribute>
                <!-- We can get rid of this emf() call easily by using jQuery -->
                <input name="MAILTO" type="hidden">
                    <xsl:attribute name="value"><xsl:value-of select="$config_MAILTO"/></xsl:attribute>
                </input>

                <input name="SUBJECT" type="hidden">
                    <xsl:attribute name="value"><xsl:value-of select="$config_SUBJECT"/></xsl:attribute>
                </input>

                <input name="FOLLOWUP" type="hidden">
                    <xsl:attribute name="value"><xsl:value-of select="$config_FOLLOWUP"/></xsl:attribute>
                </input>

                <!-- Call the matching template to handle each form group -->
                <xsl:apply-templates select="form_group" mode='form-section'>
                    <xsl:with-param name="idFormDiv" select="$form_div_id"/>
                    <xsl:with-param name="form_class" select="$form_class"/>
                    <xsl:with-param name="disableAutofocus" select="$config_DISABLEAUTOFOCUS"/>
                </xsl:apply-templates>

                <div class="form-actions">
                    <input class="btn btn-primary" type="submit">
                        <xsl:attribute name="value">
                            <xsl:choose>
                                <xsl:when test="normalize-space($config_submit_button_text)">
                                    <xsl:value-of select="normalize-space($config_submit_button_text)"/>
                                </xsl:when>
                                <xsl:otherwise>Submit</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </input>
                    <input class="btn" type="reset" value="Reset Form"/>
                </div>
            </form>
        </div>
    </xsl:template>
    
    <xd:doc>
        Generates the form section contents based on the input fields. If &quot;accordion&quot; is set, the contents will be wrapped within an &lt;accordion-item&gt; node. This template operates at a lower priority so that the previous template which matches on the top level system-data-structure will match over this one provided its conditions are met.
    </xd:doc>
    <xsl:template match="system-data-structure[form_group]" priority="-0.5">
        <xsl:param name="idFormDiv"/>
        <xsl:param name="form_class" select="$form_class_default"/>
        <xsl:param name="disableAutofocus"/>
        <xsl:variable name="rtfFormContents">
            <xsl:choose>
                <xsl:when test="accordion/value = 'Yes'">
                    <accordion>
                        <xsl:apply-templates select="form_group" mode='form-section-accordion'>
                            <xsl:with-param name="idFormDiv" select="$idFormDiv"/>
                            <xsl:with-param name="form_class" select="$form_class"/>
                            <xsl:with-param name="disableAutofocus" select="$disableAutofocus"/>
                        </xsl:apply-templates>
                    </accordion>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="form_group" mode='form-section'>
                        <xsl:with-param name="idFormDiv" select="$idFormDiv"/>
                        <xsl:with-param name="form_class" select="$form_class"/>
                        <xsl:with-param name="disableAutofocus" select="$disableAutofocus"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="accordion/value = 'Yes'">
                <xsl:call-template name="accordion">
                    <xsl:with-param name="nsAccordionGroup" select="exsl:node-set($rtfFormContents)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$rtfFormContents"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- If there's front matter to the form then go ahead and output that -->
    <xd:doc>
        Matching template to output the form opening introduction.
    </xd:doc>
    <xsl:template match="opening">
        <xsl:call-template name="paragraph-wrap" />
    </xsl:template>

   <xd:doc>
       Produce a list item for every group of the form for the table of contents.
   </xd:doc>
    <xsl:template match="form_group" mode="form-toc">
        <li><a><xsl:attribute name="href">#<xsl:value-of select="generate-id()"/></xsl:attribute><xsl:value-of select="group_label"/></a></li>
    </xsl:template>

    <xd:doc>
        Create an accordion-item whose body contents are generated via the form_group (mode: form-section) matching template.
    </xd:doc>
    <xsl:template match="form_group" mode="form-section-accordion">
        <xsl:param name="idFormDiv"/>
        <xsl:param name="form_class" select="$form_class_default"/>
        <xsl:param name="disableAutofocus"/>

        <accordion-item>
            <title><xsl:value-of select="group_label"/></title>
            <body>
                <xsl:apply-templates select="." mode="form-section">
                    <xsl:with-param name="idFormDiv" select="$idFormDiv"/>
                    <xsl:with-param name="form_class" select="$form_class"/>
                    <xsl:with-param name="bSuppressHeader" select="'true'"/>
                </xsl:apply-templates>
            </body>
            <open>
                <xsl:choose>
                    <xsl:when test="accordion-open/value = 'Yes'">true</xsl:when>
                    <xsl:otherwise>false</xsl:otherwise>
                </xsl:choose>
            </open>
        </accordion-item>
    </xsl:template>

   <xd:doc>
       Produce a fieldset for every form group
   </xd:doc>
    <xsl:template match="form_group" mode="form-section">
        <xsl:param name="idFormDiv"/>
        <xsl:param name="form_class" select="$form_class_default"/>
        <xsl:param name="disableAutofocus"/>
        <xsl:param name="bSuppressHeader"/>
        <fieldset>
            <xsl:attribute name="id"><xsl:value-of select="generate-id()"/></xsl:attribute>
            <xsl:if test="group_label[text()] and not($bSuppressHeader='true')">
                <legend>
                    <xsl:value-of select="group_label"/>
                </legend>
            </xsl:if>
            <xsl:if test="group_description != ''">
                <div class="group_description">
                    <xsl:call-template name="paragraph-wrap">
                        <xsl:with-param name="nodeToWrap" select="group_description"/>
                    </xsl:call-template>
                </div>
            </xsl:if>

            <xsl:choose>
                <!--
                If we're told that there could be multiple values for this, then wrap the form item in two divs.
                The inner div (form-multiple-group) is the group of items to be copied, while the outer div,
                (form-multiple-wrapper) serves to group the set of items together for easier processing through
                JavaScript.
                -->
                <xsl:when test="multiple/value = 'Yes'">
                    <div class="form-multiple-wrapper">
                        <div class="form-multiple-group">
                            <xsl:apply-templates select="form_item">
                                <xsl:with-param name="form_class" select="$form_class"/>
                                <xsl:with-param name="disableAutofocus" select="$disableAutofocus"/>
                            </xsl:apply-templates>
                        </div>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="form_item">
                        <xsl:with-param name="form_class" select="$form_class"/>
                        <xsl:with-param name="disableAutofocus" select="$disableAutofocus"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="last() &gt; $max_simple_group_count">
                <a class="pull-right" href="#{$idFormDiv}">Return to top of form  &#8593;</a>
            </xsl:if>
        </fieldset>
    </xsl:template>

   <xd:doc>
       This begins the meat of the form processing - the form_item display. Contains the initial
       logic to determine processing based on the class of the form and sets up variables / parameters.
   </xd:doc>
    <xsl:template match="form_item">
        <xsl:param name="form_class" select="$form_class_default"/>
        <xsl:param name="disableAutofocus"/>
        <xsl:variable name="value">
            <xsl:choose>
                <xsl:when test="value[string()]"><xsl:value-of select="value"/></xsl:when>
                <xsl:when test="default_value[text()]"><xsl:value-of select="default_value"/></xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="name"><xsl:call-template name="fixName"/></xsl:variable>
        <!-- Figure out if this is the very first form_item processed for the entire index block or not -->
        <xsl:variable name="bAutofocus">
            <xsl:value-of select="$disableAutofocus != 'Yes' and generate-id() = generate-id(ancestor::system-index-block/descendant::form_item[type='text' or type='textarea' or type='password' or type='dropdown' or type='tel' or type='email' or type='url' or type='date' or type='number'][1])"/>
        </xsl:variable>

        <!-- Construct a result tree fragment for the form item -->
        <xsl:variable name="rtfFormItem">
            <!--
            If we're told that there could be multiple values for this, then wrap the form item in two divs.
            The inner div (form-multiple-group) is the group of items to be copied, while the outer div,
            (form-multiple-wrapper) serves to group the set of items together for easier processing through
            JavaScript.
            -->
            <xsl:choose>
                <xsl:when test="multiple/value = 'Yes'">
                    <div class="form-multiple-wrapper">
                        <div class="form-multiple-group">
                            <xsl:call-template name="form_item_inner">
                                <xsl:with-param name="value" select="$value"/>
                                <xsl:with-param name="name" select="$name"/>
                                <xsl:with-param name="bAutofocus" select="$bAutofocus"/>
                                <xsl:with-param name="form_class" select="$form_class"/>
                            </xsl:call-template>
                        </div>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="form_item_inner">
                        <xsl:with-param name="value" select="$value"/>
                        <xsl:with-param name="name" select="$name"/>
                        <xsl:with-param name="bAutofocus" select="$bAutofocus"/>
                        <xsl:with-param name="form_class" select="$form_class"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- If this is a horizontal form we'll wrap the form item result tree fragment in an additional div -->
        <xsl:choose>
            <xsl:when test="$form_class = 'form-horizontal'">
                <div class="control-group">
                    <xsl:copy-of select="$rtfFormItem"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$rtfFormItem"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        The inner logic of the form, deciding on what to output and how based on the
        type of the form item.
    </xd:doc>
    <xsl:template name="form_item_inner">
        <xsl:param name="value"/>
        <xsl:param name="name"/>
        <xsl:param name="bAutofocus"/>
        <xsl:param name="form_class"/>
        <xsl:choose>
            <!-- Check for hidden input field. -->
            <xsl:when test="type='hidden'">
                <input id="{identifier}" name="{$name}" type="hidden">
                    <xsl:attribute name="value"><xsl:value-of select="$value"/></xsl:attribute>
                </input>
            </xsl:when>
            <xsl:otherwise>
                <!-- Normal field - choose how to output by field type -->
                <xsl:choose>
                    <!--
                        If there's an associated content block with structure (e.g. input field) then display it
                        instead of anything else for this form_item.
                        -->
                    <xsl:when test="ablock/content/*">
                        <xsl:call-template name="form-item-label">
                            <xsl:with-param name="bOmitFor" select="true()"/>
                        </xsl:call-template>
                        <div class="controls">
                            <xsl:copy-of select="ablock/content/*"/>
                        </div>
                    </xsl:when>

                    <!-- Dropdown input field -->
                    <xsl:when test="type='dropdown'">
                        <xsl:call-template name="form-item-label"/>
                        <div class="controls">
                            <select id="{$name}" name="{$name}" size="1">
                                <xsl:call-template name="form-item-require"/>
                                <xsl:if test="$bAutofocus = 'true'"><xsl:attribute name="autofocus">autofocus</xsl:attribute></xsl:if>
                                <!-- If there is a default put it at the top -->
                                <xsl:choose>
                                    <xsl:when test="default_value[string()]">
                                        <option selected="selected" value="{default_value}">
                                            <xsl:value-of select="default_value"/>
                                        </option>
                                    </xsl:when>
                                    <xsl:otherwise><option value="">-- Select --</option></xsl:otherwise>
                                </xsl:choose>
                                <!--
                                        If the associated content block contains a simple string then
                                        display that.
                                        -->
                                <xsl:choose>
                                    <xsl:when test="ablock/content[string()]">
                                        <xsl:copy-of select="ablock/content/*"/>
                                    </xsl:when>

                                    <!-- If form has specific labels/value pairs use those instead of the value boxes -->
                                    <xsl:when test="radio_checkbox/label[string()]">
                                        <xsl:for-each select="radio_checkbox">
                                            <option value="{value}">
                                                <xsl:value-of select="label"/>
                                            </option>
                                        </xsl:for-each>
                                    </xsl:when>

                                    <!-- Otherwise just use the list of values for value and label -->
                                    <xsl:otherwise>
                                        <xsl:for-each select="value">
                                            <!--
                                               Protect against the user entering in a value in both the
                                               default value spot as well as one of the value spots.
                                               -->
                                            <xsl:if test="not( ../default_value[string()] and ( . = ../default_value ))">
                                                <option value="{.}">
                                                    <xsl:value-of select="."/>
                                                </option>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </select>
                        </div>
                    </xsl:when>

                    <!-- Checkbox or radio input field -->
                    <xsl:when test="type='checkbox' or type='radio'">
                       <xsl:choose>
                           <xsl:when test="label[string()]">
                             <xsl:choose>
                                 <!--
                                 For horizontal forms use the label element as we
                                 would for the other element types.

                                 Otherwise encapsulate the contents within a child frameset.
                                 -->
                                 <xsl:when test="$form_class = 'form-horizontal'">
                                     <xsl:call-template name="form-item-label">
                                         <xsl:with-param name="form_class" select="$form_class"/>
                                         <xsl:with-param name="bOmitFor" select="true()"/>
                                     </xsl:call-template>
                                     <xsl:call-template name="form_item_radio_checkbox">
                                         <xsl:with-param name="value" select="$value"/>
                                         <xsl:with-param name="name" select="$name"/>
                                         <xsl:with-param name="bAutofocus" select="$bAutofocus"/>
                                         <xsl:with-param name="form_class" select="$form_class"/>
                                     </xsl:call-template>
                                 </xsl:when>
                                 <xsl:otherwise>
                                     <fieldset>
                                         <legend><xsl:value-of select="label"/></legend>
                                         <xsl:call-template name="form_item_radio_checkbox">
                                             <xsl:with-param name="value" select="$value"/>
                                             <xsl:with-param name="name" select="$name"/>
                                             <xsl:with-param name="bAutofocus" select="$bAutofocus"/>
                                             <xsl:with-param name="form_class" select="$form_class"/>
                                         </xsl:call-template>
                                     </fieldset>
                                 </xsl:otherwise>
                             </xsl:choose>
                           </xsl:when>
                           <xsl:otherwise>
                               <xsl:call-template name="form_item_radio_checkbox">
                                   <xsl:with-param name="value" select="$value"/>
                                   <xsl:with-param name="name" select="$name"/>
                                   <xsl:with-param name="bAutofocus" select="$bAutofocus"/>
                                   <xsl:with-param name="form_class" select="$form_class"/>
                               </xsl:call-template>
                           </xsl:otherwise>
                       </xsl:choose>
                    </xsl:when>

                    <!-- Textarea input field -->
                    <!--
                        TODO - Improvements to make: provide the ability to use hardcoded cols and rows into programmable values from the data definition - by default the value
                        is given within CSS based on viewport sizes.
                        -->
                    <xsl:when test="type='textarea'">
                        <xsl:call-template name="form-item-label"/>
                        <div class="controls">
                            <textarea>
                                <xsl:attribute name="id"><xsl:value-of select="$name"/></xsl:attribute>
                                <xsl:attribute name="name"><xsl:value-of select="$name"/></xsl:attribute>
                                <xsl:if test="$bAutofocus = 'true'"><xsl:attribute name="autofocus">autofocus</xsl:attribute></xsl:if>
                                <xsl:choose>
                                    <xsl:when test="placeholder[text()]"><xsl:attribute name="placeholder"><xsl:value-of select="placeholder"/></xsl:attribute></xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                                <xsl:call-template name="form-item-require"/>
                            </textarea>
                        </div>
                    </xsl:when>

                    <!-- All others: some sort of text input field -->
                    <xsl:otherwise>
                        <xsl:call-template name="form-item-label"/>
                        <div class="controls">
                            <input type="{type}">
                                <xsl:attribute name="id"><xsl:value-of select="$name"/></xsl:attribute>
                                <xsl:attribute name="name"><xsl:value-of select="$name"/></xsl:attribute>
                                <xsl:if test="$bAutofocus = 'true'"><xsl:attribute name="autofocus">autofocus</xsl:attribute></xsl:if>
                                <!--
                                    If the user really wants a default value, then make that the initial
                                    value of the field.

                                    If the user doesn't set a default value but does set a placeholder value,
                                    this is used as the initial, grayed-out text.
                                    -->
                                <xsl:choose>
                                    <xsl:when test="default_value != ''"><xsl:attribute name="value"><xsl:value-of select="default_value"/></xsl:attribute></xsl:when>
                                    <xsl:when test="placeholder[text()]"><xsl:attribute name="placeholder"><xsl:value-of select="placeholder"/></xsl:attribute></xsl:when>
                                    <!--
                                        Not putting logic in here to handle someone putting something in a
                                        value field (multiple allowed), but this is where it would go.
                                        -->
                                    <xsl:otherwise/>
                                </xsl:choose>
                                <xsl:call-template name="form-item-require"/>
                                <xsl:choose>
                                    <xsl:when test="size[text()]"><xsl:attribute name="size"><xsl:value-of select="size"/></xsl:attribute></xsl:when>
                                    <xsl:otherwise><xsl:attribute name="size"><xsl:value-of select="$field_default_size"/></xsl:attribute></xsl:otherwise>
                                </xsl:choose>
                            </input>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="form-item-more-info"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        Special processing logic for the radio / checkbox items based on the class of
        the form (horizontal / vertical).
    </xd:doc>
    <xsl:template name="form_item_radio_checkbox">
        <xsl:param name="value"/>
        <xsl:param name="name"/>
        <xsl:param name="bAutofocus"/>
        <xsl:param name="form_class"/>
        <!--
        xsl:when is used here to allow space for additional form types to be added
        in the future, such as form-inline and form-search.
        -->
        <xsl:choose>
            <xsl:when test="$form_class = 'form-horizontal'">
                <!-- this type of form_class needs to be wrapped in div.controls -->
                <div class="controls">
                    <xsl:call-template name="form_item_radio_checkbox_inner">
                        <xsl:with-param name="value" select="$value"/>
                        <xsl:with-param name="name" select="$name"/>
                        <xsl:with-param name="bAutofocus" select="$bAutofocus"/>
                        <xsl:with-param name="form_class" select="$form_class"/>
                    </xsl:call-template>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="form_item_radio_checkbox_inner">
                    <xsl:with-param name="value" select="$value"/>
                    <xsl:with-param name="name" select="$name"/>
                    <xsl:with-param name="bAutofocus" select="$bAutofocus"/>
                    <xsl:with-param name="form_class" select="$form_class"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xd:doc>
        Helper template to allow for different form classes (horizontal / vertical)
    </xd:doc>
    <xsl:template name="form_item_radio_checkbox_inner">
        <xsl:param name="value"/>
        <xsl:param name="name"/>
        <xsl:param name="bAutofocus"/>
        <xsl:param name="form_class"/>

        <xsl:choose>
            <!--
            If form has specific labels/value pairs use those.
            Note that there's no way to specify a default 'checked' state in this fashion
            -->
            <xsl:when test="radio_checkbox/label[string()]">
                <xsl:for-each select="radio_checkbox">
                    <label class="{../type}">
                        <input type="{../type}">
                            <xsl:attribute name="name">
                                <xsl:value-of select="$name"/>
                            </xsl:attribute>
                            <xsl:attribute name="value">
                                <xsl:value-of select="value"/>
                            </xsl:attribute>
                            <xsl:attribute name="id">
                                <xsl:value-of select="generate-id()"/>
                            </xsl:attribute>

                            <!-- Check to see if action is required -->
                            <!-- We have to set the context node to be the nearest form_item ancestor -->
                            <xsl:for-each select="ancestor::form_item[1]">
                                <xsl:call-template name="form-item-require"/>
                            </xsl:for-each>
                        </input>
                        <!-- This will appear as the actual label -->
                        <xsl:value-of select="label"/>
                    </label>
                </xsl:for-each>
            </xsl:when>
            <!--
            Otherwise just combine the list of values and default_value for value and label.
            Default value gets the "checked" attribute
            -->
            <xsl:otherwise>
                <!--
                Grab the union of all the value nodes whose value is not the default_value and the
                default value itself, if present.
                -->
                <xsl:for-each select="value[text() != string(../default_value)] | default_value[text()]">
                    <label class="{../type}">
                        <input type="{../type}" class="{../type}" name="{$name}" value="{.}">
                            <!-- This is a test for the default value itself -->
                            <xsl:if test="generate-id() = generate-id(../default_value)">
                                <xsl:attribute name="checked">
                                    <xsl:value-of select="checked"/>
                                </xsl:attribute>
                            </xsl:if>

                            <!-- Check to see if action is required -->
                            <!-- We have to set the context node to be the nearest form_item ancestor -->
                            <xsl:for-each select="ancestor::form_item[1]">
                                <xsl:call-template name="form-item-require"/>
                            </xsl:for-each>
                        </input>

                        <!-- This will appear as the actual label -->
                        <xsl:value-of select="."/>
                    </label>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        Helper template to generate a name baed on the label if there's no identifier given.
    </xd:doc>
    <xsl:template name="fixName">
        <xsl:variable name="prefix">
            <xsl:choose>
                <!-- If this is a file, then insert a prefix so that the processing code knows that this is a file -->
                <xsl:when test="type='file'"><xsl:value-of select="concat($prefix_file, count(preceding::form_item[type='file']) + 1, '_')"/></xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="identifier != ''">
                <xsl:value-of select="concat($prefix, identifier)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="output">
                    <xsl:value-of select="translate(label,' ','_')"/>
                </xsl:variable>
                <xsl:variable name="output2">
                    <xsl:value-of select="translate($output,'/','_')"/>
                </xsl:variable>
                <xsl:value-of select="concat($prefix, translate($output2,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        Helper template to display help block associated with a form control
    </xd:doc>
    <xsl:template name="form-item-more-info">
        <xsl:if test="more-info[text()] or more-info/*">
            <xsl:call-template name="paragraph-wrap">
                <xsl:with-param name="nodeToWrap" select="more-info"/>
                <xsl:with-param name="classWrap">controls help-block</xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

   <xd:doc>
       Output the form item label with additional class if necessary based on the
       desired form layout (e.g. form-horizontal)
   </xd:doc>
    <xsl:template name="form-item-label">
        <xsl:param name="form_class" select="$form_class_default"/>
        <xsl:param name="bOmitFor" select="false()"/>
        <xsl:variable name="name"><xsl:call-template name="fixName"/></xsl:variable>
        <label>
            <!-- If we're not told to omit the 'for' attribute then output it -->
            <xsl:if test="$bOmitFor = false()">
                <xsl:attribute name="for"><xsl:value-of select="$name"/></xsl:attribute>
            </xsl:if>
           <!-- If we're creating an horizontal form then apply the form-horizontal class -->
            <xsl:choose>
                <!--
                xsl:when is used here to allow space for additional form types to be added
                in the future, such as form-inline and form-search.
                -->
                <xsl:when test="$form_class = 'form-horizontal'">
                    <xsl:attribute name="class">control-label</xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:value-of select="label"/>
        </label>
    </xsl:template>

    <xd:doc>
        Helper template which outputs attributes based on the value of the required and type fields.
    </xd:doc>
    <xsl:template name="form-item-require">
        <!--
        Check to see if the form item is required.  If it is, add the require class.
        Possible improvement: checking to see if "required != 'No'" instead, as there doesn't
        seem to be valid values to the "required" field that aren't listed in cases here.
        -->
        <xsl:choose>
            <xsl:when test="required = 'Required'"><xsl:attribute name="class">required</xsl:attribute></xsl:when>
            <xsl:when test="required = 'Required Email'"><xsl:attribute name="class">required</xsl:attribute></xsl:when>
            <xsl:when test="required = 'Required URL'"><xsl:attribute name="class">required</xsl:attribute></xsl:when>
            <xsl:when test="required = 'Required Phone'"><xsl:attribute name="class">required</xsl:attribute></xsl:when>
            <xsl:when test="required = 'Required Date'"><xsl:attribute name="class">required</xsl:attribute></xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
        <!--
        Set the field type based on the "required" value.  This seems redundant, since in HTML5 and in the
        data definition there is already type values for {email,url,tel,date,number}. In addition, we set the
        'type' attribute in text fields already. My guess is that this is probably around for legacy purposes
        and that the Data Definition 'type' field was expanded to accommodate the new HTML5 input types.
        -->
        <xsl:choose>
            <xsl:when test="required = 'Required'"><xsl:attribute name="required">required</xsl:attribute></xsl:when>
            <xsl:when test="required = 'Required Email'"><xsl:attribute name="type">email</xsl:attribute><xsl:attribute name="required">required</xsl:attribute></xsl:when>
            <xsl:when test="required = 'Required URL'"><xsl:attribute name="type">url</xsl:attribute><xsl:attribute name="required">required</xsl:attribute></xsl:when>
            <xsl:when test="required = 'Required Phone'"><xsl:attribute name="type">tel</xsl:attribute><xsl:attribute name="required">required</xsl:attribute></xsl:when>
            <xsl:when test="required = 'Required Date'"><xsl:attribute name="type">date</xsl:attribute><xsl:attribute name="required">required</xsl:attribute></xsl:when>
            <xsl:when test="type = 'number'"><xsl:attribute name="type">number</xsl:attribute><xsl:attribute name="required">required</xsl:attribute></xsl:when>
            <!-- Do not attach the 'type' attribute to textarea elements -->
            <xsl:when test="type = 'textarea'"></xsl:when>
            <xsl:otherwise><xsl:attribute name="type"><xsl:value-of select="type"/></xsl:attribute></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
