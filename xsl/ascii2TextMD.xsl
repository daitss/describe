<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="/">
		<textMD xmlns='http://www.loc.gov/standards/textMD/textMD.xsd'>
			<xsl:variable name= "lineEnding" select = "normalize-space(repInfo/properties/property[normalize-space(name)='ASCIIMetadata']/values/property[normalize-space(name)='LineEndings']/values/value)"/> 
			<encoding>
				<encoding_platform>
					<xsl:choose>
						<xsl:when test= "$lineEnding='CRLF'">
							<xsl:attribute name="linebreak" >CR/LF</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="linebreak">
								<xsl:value-of select= "$lineEnding"/>
							</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</encoding_platform>
			</encoding>
			<character_info>
				<xsl:element name = "charset">
					<xsl:variable name = "charset" select = "substring-after(repInfo/mimeType, 'charset=')"/>
					<xsl:value-of select="$charset"/>
				</xsl:element>
				<xsl:element name = "linebreak">
					<xsl:choose>
						<xsl:when test= "$lineEnding='CRLF'">CR/LF</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select= "$lineEnding"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</character_info>
		</textMD>
	</xsl:template>
</xsl:stylesheet>
