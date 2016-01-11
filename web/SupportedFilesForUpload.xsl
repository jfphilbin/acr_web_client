<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="/">
    <html>
      <head>
        <title>ATI Web list of supported files</title>
      </head>
      <body>
        <table class="supportedFilesTable" cellspacing="0" cellpadding="0">
          <tr>
            <th>Modality Name</th>
            <th>Image File Format</th>
            <th>Movie File Format</th>
          </tr>
          <xsl:for-each select="help/row">
            <tr>
              <td>
                <xsl:value-of select="Modality" />
              </td>
              <td>
                <xsl:value-of select="Images" />
              </td>
              <td>
                <xsl:value-of select="Movies" />
              </td>
            </tr>
          </xsl:for-each>
        </table>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet> 