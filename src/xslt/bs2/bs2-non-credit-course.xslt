<?xml version="1.0" encoding="UTF-8"?>

<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2015-11-04T11:45:55-09:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2016-06-01T23:08:54-08:00

Derived from previous work done by John French at the University of Alaska Southeast.
-->

<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes="exsl"
                >
    <xsl:import href="../include/format-date.xslt"/>
    <xsl:strip-space elements="*"/>
    <xsl:output method="html" indent='yes' omit-xml-declaration='yes'/>

    <!-- Treat each course with its own table -->
    <xsl:template match='system-data-structure[non-credit-course]'>
        <!-- Emit a header above each table with the course title -->
        <h2><xsl:value-of select='non-credit-course/title'/></h2>
        <!-- If there's a fee for this course then print it -->
        <xsl:if test="normalize-space(non-credit-course/fee) != ''">
            <p class="non-credit-course-fee">Fee: <xsl:value-of select='normalize-space(non-credit-course/fee)'/></p>
        </xsl:if>
        <!-- If there's a course code then print it -->
        <xsl:if test="normalize-space(non-credit-course/code) != ''">
            <p class="non-credit-course-code"><xsl:value-of select='normalize-space(non-credit-course/code)'/></p>
        </xsl:if>
        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th>Section</th>
                    <th>Dates</th>
                    <th>Location</th>
                    <!-- If any of the courses list an instructor, include this column -->
                    <xsl:if test="count(non-credit-course/section[instructor != '']) &gt; 0">
                        <th>Instructor</th>
                    </xsl:if>
                </tr>
            </thead>
            <tbody>
               <!-- Apply the section template, letting it know whether or not the
               instructor column should be present -->
                <xsl:apply-templates select="non-credit-course/section" mode='non-credit-course'>
                    <xsl:with-param name="list-instructor" select="count(non-credit-course/section[instructor != '']) &gt; 0"/>
                </xsl:apply-templates>
            </tbody>
        </table>
    </xsl:template>

    <!-- Each course will have one or more sections - each section gets a row -->
    <!-- Each row consists of the course section ID, the dates, and the fee -->
    <xsl:template match='section' mode='non-credit-course'>
      <!-- Define parameter to know whether or not to include the instructor column -->
       <xsl:param name='list-instructor' select='false'/>
        <tr>
            <td><xsl:value-of select='id'/></td>
            <td>
                <ul class="unstyled">
                    <xsl:apply-templates select='dates' mode='non-credit-course'/>
                </ul>
            </td>
            <td><xsl:value-of select='location'/></td>
            <!-- If we're told to list the instructor, go ahead and do so -->
            <xsl:if test="$list-instructor">
                <td><xsl:value-of select='instructor'/></td>
            </xsl:if>
        </tr>
    </xsl:template>

    <!-- Print out a list item for the starting and ending date -->
    <xsl:template match='dates' mode='non-credit-course'>
       <!--
       Create two date masks, one for the starting datetime and one for the end datetime.
       If the start date and end date are the same, then the end date will omit the date portion.
       -->
       <!-- Compare the two dates' isoDate string versions -->
       <xsl:param name="date-start">
           <xsl:call-template name="format-date">
               <xsl:with-param name="date" select="datetime-start" />
               <xsl:with-param name="mask">isoDate</xsl:with-param>
           </xsl:call-template>
       </xsl:param>
        <xsl:param name="date-end">
            <xsl:call-template name="format-date">
                <xsl:with-param name="date" select="datetime-end" />
                <xsl:with-param name="mask">isoDate</xsl:with-param>
            </xsl:call-template>
        </xsl:param>
        <xsl:param name="mask-start">m/d/yy h:MM tt</xsl:param>
        <xsl:param name="mask-end">
            <xsl:choose>
                <xsl:when test="$date-start=$date-end">h:MM tt</xsl:when>
                <xsl:otherwise>m/d/yy h:MM aa</xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <li>
            <xsl:call-template name="format-date">
                <xsl:with-param name="date" select="datetime-start" />
                <xsl:with-param name="mask"><xsl:value-of select="$mask-start"/></xsl:with-param>
            </xsl:call-template>&#x2013;<xsl:call-template name="format-date">
            <xsl:with-param name="date" select="datetime-end" />
            <xsl:with-param name="mask"><xsl:value-of select="$mask-end"/></xsl:with-param>
            </xsl:call-template>
        </li>
    </xsl:template>
</xsl:stylesheet>
