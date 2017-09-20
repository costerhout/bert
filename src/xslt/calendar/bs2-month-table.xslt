<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2017-08-11T09:20:23-08:00
@Email:  ctosterhout@alaska.edu
@Project: BERT
@Last modified by:   ctosterhout
@Last modified time: 2017-09-20T11:29:36-08:00
@License: Released under MIT License. Copyright 2016 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:hh="http://www.hannonhill.com/XSL/Functions"
    xmlns:string="my:string"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xd exsl hh string hh"
    >
    <xsl:import href="../include/format-date.xslt"/>
    <xsl:import href="../include/string.xslt"/>
    <xsl:import href="../bs2/bs2-modal-simple.xslt"/>
    <xsl:import href="../bs2/bs2-event-list.xslt"/>
    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to generate buttons corresponding to the next set of months</xd:short>
        <xd:detail>
            <p>On the Activities calendar main page are a series of buttons which link to pages with the activities specific to those months. This stylesheet generates those buttons.</p>
        </xd:detail>
        <xd:author>Colin Osterhout (ctoterhout@alaska.edu)</xd:author>
        <xd:copyright>University of Alaska Southeast, 2017</xd:copyright>
    </xd:doc>

    <xsl:strip-space elements="*"/>
    <xsl:output
          method='html'
          indent='yes'
          omit-xml-declaration='yes'
          />

    <!-- Pluck events by their DateTime/date -->
    <xsl:key match="DateTime" use="date" name="keyDateTimeByDate"/>

    <xd:doc>
        Set up variables we'll need throughout the stylesheet
    </xd:doc>

    <!-- Variable which defines the numeric month of the year that this page represents -->
    <xsl:variable name="nMonthPage" select="/system-index-block/calling-page/system-page/name"/>

    <!-- The next month beyond what this page represents -->
    <xsl:variable name="nMonthPageNext" select="($nMonthPage + 1) mod 12"/>

    <!-- The current month/year/nextyear for when this script is running -->
    <xsl:variable name="nMonthCurrent" select="hh:dateFormat('mm')"/>
    <xsl:variable name="nYearCurrent" select="hh:dateFormat('yyyy')"/>
    <xsl:variable name="nYearNext" select="$nYearCurrent + 1"/>

    <!-- The year in which this page represents. If the month is less than the current month, it's a page that represents events in the future -->
    <xsl:variable name="nYearPage">
        <xsl:choose>
            <xsl:when test="$nMonthPage &lt; $nMonthCurrent"><xsl:value-of select="$nYearNext"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$nYearCurrent"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- The year in which the month beyond what this page represents. If the month is less than the current month, it's a page that represents events in the future -->
    <xsl:variable name="nYearPageNext">
        <xsl:choose>
            <xsl:when test="$nMonthPageNext &lt; $nMonthCurrent"><xsl:value-of select="$nYearNext"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$nYearCurrent"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- The timestamp for first day (at midnight) of the month that this page represents -->
    <xsl:variable name="tsFirstDay" select="
        hh:calendarFormat(
            concat(string($nMonthPage), '-', '01', '-', $nYearPage),
            'V'
        )"
    />

    <!-- The timestamp for first day (at midnight) of the next month that this page represents -->
    <xsl:variable name="tsFirstDayNextMonth" select="
        hh:calendarFormat(
            concat(string($nMonthPageNext), '-', '01', '-', $nYearPageNext),
            'V'
        )"
    />

    <!-- The timestamp for the last day of the month that this page represents -->
    <xsl:variable name="tsLastDay" select="$tsFirstDayNextMonth - 24 * 60 * 60 * 1000"/>

    <!-- What day of the week the month starts on that this page represents -->
    <xsl:variable name="nDOWFirstDay" select="hh:dateFormat(number($tsFirstDay), 'D')"/>

    <!-- Total number of days for the month -->
    <xsl:variable name="nDays" select="hh:dateFormat(number($tsLastDay), 'd')"/>

    <!-- Total number of rows required to represent this month -->
    <xsl:variable name="nRows" select="ceiling(($nDays + $nDOWFirstDay) div 7)"/>

    <!-- How many days should the last row have? Important to figure out  -->
    <xsl:variable name="nDaysLastRow" select="7 - (($nRows * 7) - ($nDays + $nDOWFirstDay))"/>

    <xd:doc>
        Match an index block and begin building the table
    </xd:doc>
    <xsl:template match="/system-index-block">
        <!-- Determine the title for this table based on the month / year that this page represents -->
        <xsl:variable name="sMonth" select="hh:dateFormat(number($tsFirstDay), 'mmmm')"/>
        <xsl:variable name="sTitle" select="concat(hh:dateFormat(number($tsFirstDay), 'mmmm'), ' ', hh:dateFormat(number($tsFirstDay), 'yyyy'))"/>

        <!-- Get day of week for the month's first day -->
        <!-- Get set of events for this month/day -->
        <table class="table table-borderd table-month">
            <caption class="sr-only">Activities Calendar for <xsl:value-of select="$sTitle"/></caption>

            <!-- Generate header row -->
            <thead>
                <tr>
                    <th scope="col">Sunday</th>
                    <th scope="col">Monday</th>
                    <th scope="col">Tuesday</th>
                    <th scope="col">Wednesday</th>
                    <th scope="col">Thursday</th>
                    <th scope="col">Friday</th>
                    <th scope="col">Saturday</th>
                </tr>
            </thead>

            <!-- Call the template to generate rows -->
            <tbody>
                <xsl:call-template name="build-row"/>
            </tbody>
        </table>
    </xsl:template>

    <xd:doc>
        Generate the rows for the table. Uses the global variables to determine month information / number of rows, etc.
        Will recursively call itself until all the rows have been output.
    </xd:doc>
    <xsl:template name="build-row">
        <!-- Keep count of which row we're outputting -->
        <xsl:param name="nRowCurrent" select="1"/>

        <xsl:choose>
            <!-- First row, there may be empty spaces -->
            <xsl:when test="$nRowCurrent = 1 and $nDOWFirstDay != 0">
                <tr>
                    <xsl:call-template name="build-cell-blank">
                        <xsl:with-param name="nMaxDays" select="$nDOWFirstDay"/>
                    </xsl:call-template>
                    <xsl:call-template name="build-cell">
                        <xsl:with-param name="nRowCurrent" select="$nRowCurrent"/>
                        <xsl:with-param name="nDayOfWeek" select="$nDOWFirstDay"/>
                    </xsl:call-template>
                </tr>
                <xsl:call-template name="build-row">
                    <xsl:with-param name="nRowCurrent" select="$nRowCurrent + 1"/>
                </xsl:call-template>
            </xsl:when>
            <!-- Middle rows, all cells filled. Also includes the case where the last row is entirely populated (no blank cells) -->
            <xsl:when test="$nRowCurrent &lt; $nRows or ($nDaysLastRow = 0 and $nRowCurrent = $nRows)">
                <tr>
                    <!-- Call the template to build out the first cell, which will then recursively call itself 6 more times to complete the row -->
                    <xsl:call-template name="build-cell">
                        <xsl:with-param name="nRowCurrent" select="$nRowCurrent"/>
                    </xsl:call-template>
                </tr>
                <xsl:call-template name="build-row">
                    <xsl:with-param name="nRowCurrent" select="$nRowCurrent + 1"/>
                </xsl:call-template>
            </xsl:when>
            <!-- Handling the last row when will be blank cells at the end -->
            <xsl:when test="$nRowCurrent = $nRows">
                <tr>
                    <!-- Call the template to build out the first cell, which will then recursively call itself 6 more times to complete the row -->
                    <xsl:call-template name="build-cell">
                        <xsl:with-param name="nRowCurrent" select="$nRowCurrent"/>
                        <!-- Modify the loop counter so that we only output the number of cells needed to finish the month -->
                        <xsl:with-param name="nMaxDays" select="$nDaysLastRow"/>
                    </xsl:call-template>

                    <!-- Call the template to build out the blank cells -->
                    <xsl:call-template name="build-cell-blank">
                        <xsl:with-param name="nMaxDays" select="7 - $nDaysLastRow"/>
                    </xsl:call-template>
                </tr>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        Generate a cell for the week. Uses the global variables to determine what the date is
    </xd:doc>
    <xsl:template name="build-cell">
        <xsl:param name="nDayOfWeek" select="0"/>
        <xsl:param name="nMaxDays" select="7"/>
        <xsl:param name="nRowCurrent"/>
        <!-- Get timestamp for the current day -->
        <xsl:variable name="tsDate" select="hh:calendarFormat(
            concat(
                $nMonthPage, '-',
                1 + (($nRowCurrent - 1) * 7 + $nDayOfWeek - $nDOWFirstDay), '-',
                $nYearPage
            ),
            'V')"/>

        <!-- Get events for the current day -->
        <xsl:variable name="nsDateTime" select="key('keyDateTimeByDate', hh:dateFormat($tsDate, 'mm-dd-yyyy'))"/>

        <!-- Determine current date -->
        <xsl:variable name="nDate" select="hh:dateFormat(number($tsDate), 'd')"/>

        <!-- Only output anything if we haven't reached the end of the week -->
        <xsl:if test="$nDayOfWeek &lt; $nMaxDays">
            <!-- Build modal windows for the events -->
            <xsl:apply-templates select="$nsDateTime/parent::Event" mode="modal"/>

            <!-- Build table entries for the events -->
            <td class="MonthDay">
                <div class="DayNumber">
                    <xsl:value-of select="$nDate"/>
                </div>
                <xsl:apply-templates select="$nsDateTime">
                    <xsl:sort data-type="text" order="ascending" select="am-pm"/>
                    <xsl:sort data-type="text" order="ascending" select="hour"/>
                    <xsl:sort data-type="text" order="ascending" select="minute"/>
                </xsl:apply-templates>
            </td>

            <!-- Generate the next cell -->
            <xsl:call-template name="build-cell">
                <xsl:with-param name="nDayOfWeek" select="$nDayOfWeek + 1"/>
                <xsl:with-param name="nRowCurrent" select="$nRowCurrent"/>
                <xsl:with-param name="tsFirstDay" select="$tsFirstDay"/>
                <xsl:with-param name="nMaxDays" select="$nMaxDays"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        Generate blank cells with the parameter nMaxDays set to the number of blank cells to generate
    </xd:doc>
    <xsl:template name="build-cell-blank">
        <xsl:param name="nMaxDays"/>
        <xsl:param name="nCurDay" select="0"/>

        <xsl:if test="$nCurDay &lt; $nMaxDays">
            <td class="MonthDay-OtherMonth">&#160;</td>
            <xsl:call-template name="build-cell-blank">
                <xsl:with-param name="nMaxDays" select="$nMaxDays"/>
                <xsl:with-param name="nCurDay" select="$nCurDay + 1"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        Generate the event listing with link to the description modal
    </xd:doc>
    <xsl:template match="DateTime">
        <xsl:variable name="nodeEvent" select="./ancestor::Event"/>
        <xsl:variable name="timeEvent" select="normalize-space(concat(hour, minute, am-pm))"/>
        <xsl:variable name="idModalEvent">
            <xsl:for-each select="parent::Event">
                <xsl:call-template name="event-generate-description-modal-id"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="sTitle" select="$nodeEvent/Event_Name"/>

        <div class="vevent">
            <xsl:value-of select="$timeEvent"/>
            <a href="#{$idModalEvent}" data-toggle="modal">&#160;-&#160;<xsl:value-of select="$sTitle"/></a>
        </div>
    </xsl:template>
</xsl:stylesheet>
