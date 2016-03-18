<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="html"/>
    <xsl:strip-space elements="*"/>

    <!-- Convenience variables used for constructing the URL containing schedule information later on -->
    <xsl:variable name="urlBase">http://www.uas.alaska.edu/schedule/schedule4.cgi?db=</xsl:variable>
    <xsl:variable name="urlPost">&amp;format=xml</xsl:variable>
    
    <!-- Result tree fragment used as table header (and footer) row -->
    <xsl:variable name="tableHeaderRow">
        <tr>
            <th>COURSE</th>
            <th>CRN</th>
            <th>SEC</th>
            <th>Title</th>
            <th>Credits</th>
            <th>Meets</th>
            <th>Instructor</th>
        </tr>
    </xsl:variable>
    
    <!-- Define key to look up course SECTION based on CRN -->
    <xsl:key name="crnToSection" match="SECTION" use="CRN"/>
    
    <!--
    Top level template operates on output of an index block
    -->   
    <xsl:template match="/system-index-block">
        <!-- If we have more than one folder we're working with than create a table of contents for it -->
        <xsl:if test="count(system-folder) &gt; 1">
            <h2>Available Semesters</h2>
            <p>Course information is available for the following semesters:</p>
            <ul>
                <xsl:apply-templates select="system-folder" mode="toc"/>           
            </ul>
        </xsl:if>
        
        <!-- Produce a table set for each folder contained within the set -->
        <xsl:apply-templates select="system-folder" mode="ger-table"/>
    </xsl:template>

   <!--
   Each system-folder which has "system-block" information should contain a semester's worth of 
   CRN information for short courses.

   This template generates a simple table of contents entry for the system folder based on 
   a generated id number unique to this invocation.
   -->
    <xsl:template match="system-folder[system-block]" mode="toc">
        <li>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat('#', generate-id())"/>
                </xsl:attribute>
                <xsl:value-of select="name"/>
            </a>
        </li>
    </xsl:template>

    <!--
   Each system-folder which has "system-block" information should contain a semester's worth of 
   CRN information for short courses.
   
   This template defines a searchable table wrapped up in a div.ger-semester section.  Individual
   body rows of the table are handled by a separate template.
    -->
    <xsl:template match="system-folder" mode="ger-table">
        <!--
        Define the following variables:
            $semester (string) -> name of the system folder.  Used to construct the URL later ('Spring', 'Summer', ...).
            $url (string) -> external document containing semester schedule as XML
            $nsSemesterSchedule (node-set) -> external semester schedule document is loaded up into this variable for later
                processing in the system-block template.
         -->
        <xsl:variable name="semester" select="name"/>
        <xsl:variable name="url"><xsl:value-of select="concat($urlBase, $semester, $urlPost)"/></xsl:variable>
        <xsl:variable name="nsSemesterSchedule" select="document($url)"/>
        
        <!-- Header, link to full schedule, simple instructions, and semester table are encapsulated in div.ger-semester -->
        <div class="ger-semester">
            <!-- Header with semester name also serves as anchor to allow TOC entry to link here -->
            <h2><xsl:attribute name="id"><xsl:value-of select="generate-id()"/></xsl:attribute><xsl:value-of select="$semester"/> Semester Courses</h2>
            <div class="pull-right"><a href="http://www.uas.alaska.edu/schedule/index.html" target="_blank">View Full UAS Schedule</a><br/></div>
            <p class="disappear"><b>Click any header to sort column.</b></p>
            
            <!-- Begin table definition -->
            <table class="table table-bordered table-striped table-autosort:0 sc">
                <xsl:attribute name="id"><xsl:value-of select="generate-id()"/></xsl:attribute>
                <thead>
                    <xsl:copy-of select="$tableHeaderRow"/>
                </thead>
                <tbody>
                   <!-- For each system-block contained within this folder output a row -->
                    <xsl:apply-templates select="system-block[system-data-structure[@definition-path='courses_short_new']]">
                        <xsl:with-param name="nsSemesterSchedule" select="$nsSemesterSchedule"/>
                    </xsl:apply-templates>
                </tbody>
                <tfoot>
                    <xsl:copy-of select="$tableHeaderRow"/>
                </tfoot>
            </table>
        </div>
    </xsl:template>
    
    <!--
    This template converts matched system-block entities to CRNs which are looked up in the 
    passed in node-set and acted on accordingly.
    -->
    <xsl:template match="system-block[system-data-structure[@definition-path='courses_short_new']]">
        <xsl:param name="nsSemesterSchedule"/>
        <xsl:variable name="crn"><xsl:value-of select='name'/></xsl:variable>
        <!-- The for-each here sets the processing context to the semester schedule node-set stored in a variable -->
        <xsl:for-each select="$nsSemesterSchedule">
           <!-- Pull out the section based on the CRN -->
            <xsl:apply-templates select="key('crnToSection', $crn)"/>
        </xsl:for-each>
    </xsl:template>

   <!--
   This template outputs a table row based on the contents of the matched SECTION.
   
   Row cells:
       * Course subject code + Course number, e.g. "ANTH 160"
       * Section CRN, e.g. 35707
       * Section code, e.g. JD1
       * Course title
       * Course credits
       * Section meeting description, e.g. "Mon, Wed at 11:30a - 1:00p"
       * Name of instructor
   -->
    <xsl:template match="SECTION">
        <tr>
           <xsl:attribute name="id"><xsl:value-of select="CRN"/></xsl:attribute>
            <td><xsl:value-of select="concat(ancestor::COURSE/SUBJ, '&#160;', ancestor::COURSE/NUMBER)"/></td>
            <td><xsl:value-of select="CRN"/></td>
            <td><xsl:value-of select="SECT"/></td>
            <td><xsl:value-of select="ancestor::COURSE/TITLE"/></td>
            <td><xsl:value-of select="ancestor::COURSE/CR"/></td>
            <td>
                <xsl:choose>
                    <xsl:when test="string(MEET/days)"><xsl:value-of select="MEET/days"/> at <xsl:value-of select="MEET/times"/></xsl:when>
                    <xsl:otherwise>No meeting time</xsl:otherwise>
                </xsl:choose>
            </td>
            <td><xsl:value-of select="INST"/></td>
        </tr>
    </xsl:template>
</xsl:stylesheet>