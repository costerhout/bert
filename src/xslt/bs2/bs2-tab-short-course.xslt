<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout> based on original work by John French <jhfrench>
@Date:   2016-11-16T14:52:04-09:00
@Email:  ctosterhout@alaska.edu
@Last modified by:   ctosterhout
@Last modified time: 2019-02-25T11:40:53-09:00
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xd hh exsl"
                version="1.0"
                xmlns:exsl="http://exslt.org/common"
                xmlns:hh="http://www.hannonhill.com/XSL/Functions"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc">

    <xsl:import href="../include/class-variables-term.xslt" />
    <xsl:import href="../include/format-date.xslt" />

    <xsl:output method="html" />
    <xsl:strip-space elements="*" />

    <xsl:key name="keyCrnLookup"
             match="sections"
             use="crn" />

    <xsl:variable name="semester">
        <xsl:value-of select="system-index-block/@name" /></xsl:variable>
    <xsl:variable name="sTerm"
                  select="$nsSemestersAvailable/semester[title=$semester]/term" />
    <xsl:variable name="url">http://www.uas.alaska.edu/schedule/schedule-bs.cgi?term=<xsl:value-of select="$sTerm" /><xsl:text disable-output-escaping="yes">&amp;</xsl:text>export=xml</xsl:variable>
    <xsl:variable name="sDateFormat"
                  select="'m/d'" />
    <xsl:variable name="rtfHelpBySite">
        <site name="Juneau">
            <p>For questions regarding upcoming short courses, please contact the UAS Juneau campus:<br/> By phone: 907-796-6100 or Toll Free 877-465-4827<br/> By email: <a href="mailto:registrar@uas.alaska.edu">registrar@uas.alaska.edu</a>
            </p>
        </site>
        <site name="Ketchikan">
            <p>For questions regarding upcoming short courses, please contact the UAS Ketchikan campus:<br/> By phone: 907-228-4511 or Toll Free 888-550-6177<br/> By email: <a href="mailto:ketch.info@uas.alaska.edu">ketch.info@uas.alaska.edu</a>
            </p>
        </site>
        <site name="Sitka">
            <p>For questions regarding upcoming short courses, please contact the UAS Sitka campus:<br/> By phone: 907-747-6653 or Toll Free 800-478-6653<br/> By email: <a href="mailto:student.info@uas.alaska.edu">student.info@uas.alaska.edu</a>
            </p>
        </site>
    </xsl:variable>
    <xsl:variable name="nsHelpBySite"
                  select="exsl:node-set($rtfHelpBySite)" />

    <!--
    xmL : http://www.uas.alaska.edu/schedule/schedule4.cgi?db=Spring&format=xml
    -->

    <xsl:template match="/system-index-block">
        <a>
            <xsl:attribute name="id">top</xsl:attribute>
        </a>
        <div class="tabbable">
            <ul class="nav nav-tabs">
                <xsl:apply-templates mode="site-toc"
                                     select="system-folder" />
            </ul>

            <div class="tab-content">
                <xsl:apply-templates mode="site-tabpane"
                                     select="system-folder" />
            </div>
        </div>
        <p style="text-align:center">
            <a class="btn"
               href="#top"
               title="return to top">&#8593; Return to Top of Page</a>
        </p>
    </xsl:template>

    <xsl:template match="system-folder"
                  mode="site-toc">
        <li>
            <xsl:if test="position() = 1">
                <xsl:attribute name="class">active</xsl:attribute>
            </xsl:if>
            <a data-toggle="tab"
               href="{concat('#', name)}">
                <xsl:value-of select="name" />
            </a>
        </li>
    </xsl:template>

    <xsl:template match="system-folder"
                  mode="site-tabpane">
        <xsl:variable name="sCampus"
                      select="name" />
        <xsl:variable name="rtfHeaderRow">
            <tr>
                <th scope="col">CRN</th>
                <th scope="col">COURSE</th>
                <th scope="col">SEC</th>
                <th scope="col">Title</th>
                <th scope="col">Credits</th>
                <th scope="col">Begins</th>
                <th scope="col">Drop</th>
                <th scope="col">Withdraw</th>
                <th scope="col">Ends</th>
            </tr>
        </xsl:variable>

        <!-- Generate the set of rows based on the system blocks under this folder -->
        <xsl:variable name="rtfTableBody">
            <xsl:apply-templates select=".//system-block[system-data-structure/Last_Drop_Date]" />
        </xsl:variable>
        <xsl:variable name="nsTableBody"
                      select="exsl:node-set($rtfTableBody)" />

        <!-- Output the tab pane for this folder/site -->
        <div id="{$sCampus}">
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="position() = 1">tab-pane active</xsl:when>
                    <xsl:otherwise>tab-pane</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <h2><xsl:value-of select="concat($sCampus, ' Short Courses')"/></h2>
            <xsl:choose>
                <!-- Only output the table if there's rows to output -->
                <xsl:when test="$nsTableBody/tr">
                    <div class="table-legend">
                        <p class="well">Short courses do not have the same drop/withdraw dates as full semester courses. For full semester drop/withdraw dates visit the <a href="http://www.uas.alaska.edu/calendar/academic.html">Academic Calendar</a>.</p>
                        <h3>Drop / Withdraw Dates</h3>
                        <dl class="dl-horizontal">
                            <dt>Drop</dt>
                            <dd>Drop the course by this date to receive 100% refund. Dropped courses will not appear on your academic transcripts.</dd>
                            <dt>Withdraw</dt>
                            <dd>A grade of a 'W' will appear on your academic transcripts. This grade will not affect the Grade Point Average (GPA). No refund is given.</dd>
                        </dl>
                    </div>
                    <div class="disappear">
                        <p class="pull-right"><a href="http://www.uas.alaska.edu/schedule/index.html"
                               target="_blank">View Full UAS Schedule</a></p>
                        <p><strong>Click any header to sort column.</strong></p>
                    </div>
                    <table class="table table-bordered table-striped table-autosort:0">
                        <thead>
                            <xsl:copy-of select="$rtfHeaderRow" />
                        </thead>
                        <tbody>
                            <xsl:copy-of select="$nsTableBody" />
                        </tbody>
                        <tfoot>
                            <xsl:copy-of select="$rtfHeaderRow" />
                        </tfoot>
                    </table>
                </xsl:when>
                <!-- If the table body doesn't contain any rows then output a helpful error message -->
                <xsl:otherwise>
                    <xsl:copy-of select="$nsHelpBySite/site[@name = $sCampus]/*" />
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template match="system-block[system-data-structure/Last_Drop_Date]">
        <xsl:variable name="nodeCurrent"
                      select="." />
        <xsl:variable name="sCrn"
                      select="name" />
        <xsl:variable name="sDateDrop">
            <xsl:choose>
                <xsl:when test="not(system-data-structure/Last_Drop_Date/text()) and not(system-data-structure/Last_Withdraw_Date/text())">TBA</xsl:when>
                <xsl:when test="not(system-data-structure/Last_Drop_Date/text())">N/A</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="hh:calendarFormat(string(system-data-structure/Last_Drop_Date), $sDateFormat)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sDateWithdraw">
            <xsl:choose>
                <xsl:when test="not(system-data-structure/Last_Drop_Date/text()) and not(system-data-structure/Last_Withdraw_Date/text())">TBA</xsl:when>
                <xsl:when test="not(system-data-structure/Last_Withdraw_Date/text())">N/A</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="hh:calendarFormat(string(system-data-structure/Last_Withdraw_Date), $sDateFormat)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:for-each select="document($url)">
            <xsl:variable name="nodeSection"
                          select="key('keyCrnLookup', $sCrn)" />
            <xsl:variable name="nodeCourse"
                          select="$nodeSection/parent::COURSE" />
            <!-- Sort ascending by month, then by date, then take the last meeting end date -->
            <xsl:variable name="sDateEnd">
                <xsl:for-each select="$nodeSection/meet">
                    <xsl:sort select="substring-before(end, '/')" data-type="number"></xsl:sort>
                    <xsl:sort select="substring-after(end, '/')" data-type="number"></xsl:sort>
                    <xsl:if test="position() = last()">
                        <xsl:value-of select="end"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>

            <!-- Only output row if the section and course are found -->
            <xsl:if test="$nodeSection and $nodeCourse">
                <!-- Format the date string -->

                <tr id="{$sCrn}">
                    <td>
                        <xsl:value-of select="$sCrn" />
                    </td>
                    <td>
                        <xsl:value-of select="concat($nodeCourse/subj, ' S', $nodeCourse/numb)" />
                    </td>
                    <td>
                        <xsl:value-of select="$nodeSection/sect" />
                    </td>
                    <td>
                        <xsl:value-of select="$nodeCourse/title" />
                    </td>
                    <td>
                        <xsl:value-of select="$nodeCourse/cr" />
                    </td>
                    <td>
                        <xsl:value-of select="$nodeSection/meet/start" />
                    </td>
                    <td>
                        <xsl:value-of select="$sDateDrop" />
                    </td>
                    <td>
                        <xsl:value-of select="$sDateWithdraw" />
                    </td>
                    <td>
                        <xsl:value-of select="$sDateEnd" />
                    </td>
                </tr>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>