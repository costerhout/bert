<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2016-03-4T12:13:03-08:00
@Email:  ctosterhout@alaska.edu
@Last modified by:   ctosterhout
@Last modified time: 2018-08-17T12:51:23-08:00
@License: Released under MIT License. Copyright 2017 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="hh xalan xd"
                version="1.0"
                xmlns:hh="http://www.hannonhill.com/XSL/Functions"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xalan="http://xml.apache.org/xalan">
    <xsl:import href="../include/format-date.xslt" />
    <xsl:output method="text"
                omit-xml-declaration="yes" />
    <xsl:variable name="nl">
        <xsl:text>
        </xsl:text>
    </xsl:variable>

    <!-- Default event length, in hours -->
    <xsl:param name="eventDefaultLength">1</xsl:param>

    <!-- Sample Output -->
    <!--
    BEGIN:VCALENDAR
    VERSION:2.0
    PRODID:-//hacksw/handcal//NONSGML v1.0//EN
    BEGIN:VEVENT
    UID:uid1@example.com
    DTSTAMP:19970714T170000Z
    DTSTART:19970714T170000Z
    DTEND:19970715T035959Z
    SUMMARY:Bastille Day Party
    END:VEVENT
    END:VCALENDAR
    -->

    <xsl:template match="/system-index-block">
        <!-- Provide opening tag and boilerplate information -->
        <xsl:comment>#protect-top
            <xsl:text>BEGIN:VCALENDAR</xsl:text>
            <xsl:value-of select="$nl" />
            <xsl:text>VERSION:2.0</xsl:text>
            <xsl:value-of select="$nl" />
            <xsl:text>PRODID:-//uas.alaska.edu//events-to-ics//en</xsl:text>
            <xsl:value-of select="$nl" />

            <!-- Output all academic calendar events -->
            <xsl:apply-templates select=".//system-data-structure[Event]">
                <xsl:sort select="hh:calendarFormat(string(Event/DateTime[1]/date), 'yyyymmdd')" />
            </xsl:apply-templates>

            <!-- Provide closing tag -->
            <xsl:text>END:VCALENDAR</xsl:text>
            <xsl:value-of select="$nl" />#protect-top</xsl:comment>
    </xsl:template>


    <!--

The following is an example of the "VEVENT" calendar component used
to represent a reminder that will not be opaque, but rather
transparent, to searches for busy time:

  BEGIN:VEVENT
  UID:19970901T130000Z-123402@host.com
  DTSTAMP:19970901T1300Z
  DTSTART:19970401T163000Z
  DTEND:19970402T010000Z
  SUMMARY:Laurel is in sensitivity awareness class.
  CLASS:PUBLIC
  CATEGORIES:BUSINESS,HUMAN RESOURCES
  TRANSP:TRANSPARENT
  END:VEVENT

   Each calendar event as system-data-structure may contain more than one DateTime entries
   
    -->

    <xsl:template match="system-data-structure">
        <xsl:apply-templates select="Event/DateTime">
            <xsl:with-param name="summary"
                            select="Event/Event_Name" />
            <xsl:with-param name="description"
                            select="Event/Description" />
            <xsl:with-param name="uid_base"
                            select="parent::system-page/@id" />
            <xsl:with-param name="uid_suffix">@uas.alaska.edu</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <!-- 
    For each event, we need to set the following variables:
    UID - set to be the value of generate-id()?
    DTSTAMP - time of the creation of this file in UTC
    DTSTART - time of the event in UTC
    DTEND / DTDURATION - either time of the end of the event or the duration
    SUMMARY - Title of the event
    CLASS:PUBLIC - specifies that anyone may see it
    CATEGORIES - Set to be value of the components of the path, upper case and comma separated
    TRANSP:TRANSPARENT - Does not affect users' free / busy data
    -->

    <xsl:template match="DateTime">
        <xsl:param name="summary" />
        <xsl:param name="description" />
        <xsl:param name="uid_base" />
        <xsl:param name="uid_suffix" />
        <xsl:variable name="maskUTCDateTime">UTC:yyyymmdd'T'HHMMss'Z'</xsl:variable>
        <xsl:variable name="maskDate">yyyymmdd</xsl:variable>
        <xsl:variable name="maskUTCTimeStamp">V</xsl:variable>

        <!--
        Generate a unique ID by using the value passed in along with the index 
        of the current processing node in the Event set.
        -->
        <xsl:variable name="uid">
            <xsl:choose>
                <xsl:when test="last() &gt; 1">
                    <xsl:value-of select="concat($uid_base, '-', position(), $uid_suffix)" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($uid_base, $uid_suffix)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!--
        The tsDateStart variable holds the UTC time stamp of the date specified in the event
        -->
        <xsl:variable name="tsDateStart">
            <xsl:value-of select="hh:calendarFormat(string(date), $maskUTCTimeStamp)" />
        </xsl:variable>

        <!--
        Get the timestamp value for the start time of the event. If no start time specified, use the start date
        time stamp, equivalent to 12:00am
        -->
        <xsl:variable name="tsDateTimeStart">
            <xsl:choose>
                <xsl:when test="am-pm = 'PM'">
                    <xsl:value-of select="number($tsDateStart) + (12 + number(hour)) * 60 * 60 * 1000 + number(substring-after(minute, ':') * 60 * 1000)" />
                </xsl:when>
                <xsl:when test="am-pm = 'AM'">
                    <xsl:value-of select="number($tsDateStart) + number(hour) * 60 * 60 * 1000 + number(substring-after(minute, ':') * 60 * 1000)" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$tsDateStart" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!--
        Create a variable to hold the default time slot end timestamp value
        -->
        <xsl:variable name="tsDateTimeEndDefault">
            <xsl:value-of select="number($tsDateTimeStart) + number($eventDefaultLength) * 60 * 60 * 1000" />
        </xsl:variable>

        <!-- 
        Figure out the event end time stamp.
        If it's an all day event, then add 24*60*60*1000 milliseconds onto the date start timestamp.
        If there's an end time specified, attempt to use that.
        If there's no end time specified, then assign the default timeslot value.
        -->
        <xsl:variable name="tsDateTimeEnd">
            <xsl:choose>
                <!--
                An all day event ends 24 hours after the start date
                -->
                <xsl:when test="am-pm = 'All Day'">
                    <xsl:value-of select="number($tsDateStart) + 24 * 60 * 60 * 1000" />
                </xsl:when>
                <!-- 
                Parse the End_Time field and pass in the start of the day timestamp as the offset
                -->
                <xsl:when test="End_Time[text()]">
                    <xsl:value-of select="hh:parseTime(string(normalize-space(End_Time)), number($tsDateStart), $maskUTCTimeStamp)" />
                </xsl:when>
                <!--
                No End_Time specified.  
                -->
                <xsl:otherwise>
                    <xsl:value-of select="$tsDateTimeEndDefault" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!--
        Create the VEVENT compatible DATE-TIME string values for the start and end
        -->
        <xsl:variable name="dtStart">
            <xsl:choose>
                <xsl:when test="am-pm = 'All Day'">
                    <xsl:value-of select="hh:dateFormat(number($tsDateTimeStart), $maskDate)" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="hh:dateFormat(number($tsDateTimeStart), $maskUTCDateTime)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="dtEnd">
            <xsl:choose>
                <xsl:when test="am-pm = 'All Day'">
                    <xsl:value-of select="hh:dateFormat(number($tsDateTimeEnd), $maskDate)" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="hh:dateFormat(number($tsDateTimeEnd), $maskUTCDateTime)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!--
        Create the DTSTART and DTEND prefix for all day events, if necessary
        -->
        <xsl:variable name="dtDateType">
            <xsl:choose>
                <xsl:when test="am-pm = 'All Day'">;VALUE=DATE</xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>

        <!-- 
        The VEVENT also needs a date / time stamp. Calling the hh:dateFormat with just a mask
        value specifies the current date / time.
        -->
        <xsl:variable name="dtStamp">
            <xsl:value-of select="hh:dateFormat($maskUTCDateTime)" />
        </xsl:variable>

        <!--
        Output the VEVENT definition
        -->

        <xsl:value-of select="concat('BEGIN:VEVENT',$nl)" />
        <xsl:value-of select="concat('UID:', $uid, $nl)" />
        <xsl:value-of select="concat('DTSTAMP:', $dtStamp, $nl)" />
        <xsl:value-of select="concat('DTSTART', $dtDateType, ':', $dtStart, $nl)" />
        <xsl:value-of select="concat('DTEND', $dtDateType, ':', $dtEnd, $nl)" />
        <xsl:value-of select="concat('SUMMARY:', $summary, $nl)" />
        <xsl:if test="normalize-space($description) != ''">
            <xsl:text>DESCRIPTION:</xsl:text>
            <xsl:apply-templates select="$description/text() | $description/*" mode="strip-newlines"/>
            <xsl:value-of select="$nl"/>
        </xsl:if>
        <xsl:value-of select="concat('CLASS:PUBLIC', $nl)" />
        <xsl:value-of select="concat('TRANSP:TRANSPARENT', $nl)" />
        <xsl:value-of select="concat('END:VEVENT',$nl)" />
    </xsl:template>
    
    <xd:doc>
        Identity transform to cover vast majority of elements in data.
    </xd:doc>
    <xsl:template match="@*|node()" mode="strip-newlines">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="strip-newlines"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()" mode="strip-newlines">
        <xsl:value-of select="translate(., '&#010;', ' ')"/>
    </xsl:template>
</xsl:stylesheet>