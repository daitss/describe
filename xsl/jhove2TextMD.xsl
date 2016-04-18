<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="ihttp://www.loc.gov/premis/v3" xmlns:j="http://hul.harvard.edu/ois/xml/ns/jhove" >
  <xsl:strip-space elements="*"/>
  <xsl:template match="/j:jhove">
    <textMD>
      <!-- 
      encoding:
      encoding is specific to the environment of the creation of the text, not the actual text
      jhove really doesnt touch this
      -->			

      <!-- character info -->
      <character_info>
        <charset>
          <xsl:variable name="charset" select="substring-after(j:repInfo/j:mimeType, 'charset=')"/>
          <xsl:choose>
            <xsl:when test="$charset='US-ASCII'">ISO_646.basic:1983</xsl:when>
            <xsl:otherwise><xsl:value-of select="$charset"/></xsl:otherwise>
          </xsl:choose>
        </charset>
        <byte_order>big</byte_order>
        <byte_size>8</byte_size>
        <character_size>variable</character_size>
        <linebreak>
          <xsl:variable name="lineEnding" select="//j:property[j:name='ASCIIMetadata']/j:values/j:property[j:name='LineEndings']/j:values/j:value"/>
          <xsl:choose>
            <xsl:when test="$lineEnding='CRLF'">CR/LF</xsl:when>
            <xsl:otherwise><xsl:value-of select="$lineEnding"/></xsl:otherwise>
          </xsl:choose>
        </linebreak>
      </character_info>

    </textMD>
  </xsl:template>
</xsl:stylesheet>
