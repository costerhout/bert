<?xml version="1.0" encoding="UTF-8"?>
<!--
@Author: Colin Osterhout <ctosterhout>
@Date:   2019-11-18T16:00:53-09:00
@Email:  ctosterhout@alaska.edu
@Project: bert
@Last modified by:   ctosterhout
@Last modified time: 2019-11-18T16:14:07-09:00
@License: Released under MIT License. Copyright 2019 University of Alaska Southeast.  For more details, see https://opensource.org/licenses/MIT
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

    <xsl:output method="html" />
    <xsl:strip-space elements="*" />

    <xsl:template match="/videos">
        <table class="table table-bordered table-filtered">
            <caption class="sr-only">List of Alaska Native Language videos</caption>
            <thead>
                <tr>
                    <th scope="col">Index</th>
                    <th scope="col">Description</th>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates select="video" />
            </tbody>
        </table>
    </xsl:template>

    <xsl:template match="video">
        <tr>
            <td>
                <xsl:value-of select="index"/>
            </td>
            <td>
                <a target="_blank" href="{link}">
                    <xsl:value-of select="title" />
                </a>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>