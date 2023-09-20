<?xml version="1.0"?>
<!--

XSLT for transforming nginx's autoindex xml output into something that
looks as close as possible to Apache's mod_autoindex's FancyIndexing
(F=2) format.


LICENCE: MIT

Copyright 2023 Anders Waldenborg

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
“Software”), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


  This is the nginx config needed:

      location / { # or whatever location
          autoindex on;
          autoindex_format xml;
          xslt_stylesheet /path/to/this/file/style.xsl;
          set $sortC M;
          set $sortO D;
          if ($args ~ 'C=(.)' ) {
              set $sortC $1;
          }
          if ($args ~ 'O=(.)' ) {
              set $sortO $1;
          }

          xslt_string_param sort-C $sortC;
          xslt_string_param sort-O $sortO;
          xslt_string_param location $uri;
      }

-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="sort-C" />
    <xsl:param name="sort-O" />
    <xsl:param name="location" />

    <!--

        These icons are public domain and copied from Apache
        https://svn.apache.org/viewvc/httpd/httpd/trunk/docs/icons/

        These icons were originally made for Mosaic for X and have been
        included in the NCSA httpd and Apache server distributions in the
        past. They are in the public domain and may be freely included in any
        application. The originals were done by Kevin Hughes (kevinh@kevcom.com).
        Andy Polyakov tuned the icon colors and added a few new images.

    -->

    <!-- back.gif -->
    <xsl:param name="img_parentdir" select="'data:image/gif;base64,R0lGODlhFAAWAMIAAP///8z//5mZmWZmZjMzMwAAAAAAAAAAACH+TlRoaXMgYXJ0IGlzIGluIHRoZSBwdWJsaWMgZG9tYWluLiBLZXZpbiBIdWdoZXMsIGtldmluaEBlaXQuY29tLCBTZXB0ZW1iZXIgMTk5NQAh+QQBAAABACwAAAAAFAAWAAADSxi63P4jEPJqEDNTu6LO3PVpnDdOFnaCkHQGBTcqRRxuWG0v+5LrNUZQ8QPqeMakkaZsFihOpyDajMCoOoJAGNVWkt7QVfzokc+LBAA7'" />

    <!-- dir.gif -->
    <xsl:param name="img_dir" select="'data:image/gif;base64,R0lGODlhFAAWAMIAAP/////Mmcz//5lmMzMzMwAAAAAAAAAAACH+TlRoaXMgYXJ0IGlzIGluIHRoZSBwdWJsaWMgZG9tYWluLiBLZXZpbiBIdWdoZXMsIGtldmluaEBlaXQuY29tLCBTZXB0ZW1iZXIgMTk5NQAh+QQBAAACACwAAAAAFAAWAAADVCi63P4wyklZufjOErrvRcR9ZKYpxUB6aokGQyzHKxyO9RoTV54PPJyPBewNSUXhcWc8soJOIjTaSVJhVphWxd3CeILUbDwmgMPmtHrNIyxM8Iw7AQA7'" />

    <!-- unknown.gif -->
    <xsl:param name="img_file" select="'data:image/gif;base64,R0lGODlhFAAWAMIAAP///8z//5mZmTMzMwAAAAAAAAAAAAAAACH+TlRoaXMgYXJ0IGlzIGluIHRoZSBwdWJsaWMgZG9tYWluLiBLZXZpbiBIdWdoZXMsIGtldmluaEBlaXQuY29tLCBTZXB0ZW1iZXIgMTk5NQAh+QQBAAABACwAAAAAFAAWAAADaDi6vPEwDECrnSO+aTvPEQcIAmGaIrhR5XmKgMq1LkoMN7ECrjDWp52r0iPpJJ0KjUAq7SxLE+sI+9V8vycFiM0iLb2O80s8JcfVJJTaGYrZYPNby5Ov6WolPD+XDJqAgSQ4EUCGQQEJADs='" />


    <xsl:variable name="sort-order">
        <xsl:choose>
            <xsl:when test="$sort-O = 'D'">
                <xsl:text>descending</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>ascending</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="sort-order-other">
        <xsl:choose>
            <xsl:when test="$sort-O = 'D'">
                <xsl:text>A</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>D</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:template match="/">
        <html>
            <head>
                <title>
                    Index of
                    <xsl:value-of select="$location" />
                </title>
            </head>
            <body>

                <h1>Index of
                <xsl:value-of select="$location" />
                </h1>
                <table>
                    <tbody>
                        <tr>
                            <th valign="top"><img src="data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs=" alt="[   ]" /></th>
                            <th><a href="?C=N;O={$sort-order-other}">
                                Name
                            </a></th>
                            <th><a href="?C=M;O={$sort-order-other}">
                                Last modified
                            </a></th>
                            <th><a href="?C=S;O={$sort-order-other}">
                                Size
                            </a></th>
                            <th><a href="?C=D;O={$sort-order-other}">
                                Description
                            </a></th>
                        </tr>
                        <tr>
                            <th colspan="5"><hr /></th>
                        </tr>
                        <tr>
                            <td valign="top"><img src="{$img_parentdir}" alt="[PARENTDIR]" /></td>
                            <td><a href="/">Parent Directory</a></td>
                            <td>-</td>
                            <td align="right">  - </td>
                            <td>&#xA0;</td>
                        </tr>

                        <xsl:for-each select="list/*">
                            <xsl:sort select="name()" order="ascending" /> <!-- remember: tagname == dir/file -->
                            <!-- substring/div trick as described by Jeni Tennison -->
                            <xsl:sort select="substring(@mtime, 1 div ($sort-C = 'M'))" order="{$sort-order}" />
                            <xsl:sort select="substring(@size, 1 div ($sort-C = 'S'))" order="{$sort-order}" data-type="number" />
                            <xsl:sort select="text()" order="{$sort-order}" />

                            <tr data-type="{name()}" data-name="{.}" data-mtime="{@mtime}" data-size="{@size}">

                                <xsl:choose>
                                    <xsl:when test="name() = 'directory'">
                                        <td valign="top"><img src="{$img_dir}" alt="[DIR]" /></td>
                                        <td><a href="{.}/"><xsl:value-of select="." /></a></td>
                                    </xsl:when>

                                    <xsl:otherwise>
                                        <td valign="top"><img src="{$img_file}" alt="[   ]" /></td>
                                        <td><a href="{.}"><xsl:value-of select="." /></a></td>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <td align="right">
                                    <xsl:value-of select="@mtime" />
                                </td>
                                <td align="right">
                                    <xsl:choose>
                                        <xsl:when test="name() = 'file'">
                                            <xsl:value-of select="@size" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            -
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                                <td>&#xA0;</td>
                            </tr>

                        </xsl:for-each>
                    </tbody>
                </table>
            </body>
        </html>

    </xsl:template>
</xsl:stylesheet>
