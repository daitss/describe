<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="/">
		<textMD xmlns='http://www.loc.gov/standards/textMD'>
			<xsl:variable name= "encoding" select = "normalize-space(repInfo/properties/property[normalize-space(name)='XMLMetadata']/values/property[normalize-space(name)='Encoding']/values/value)"/> 
			<xsl:variable name= "markupURI" select = "normalize-space(repInfo/properties/property[normalize-space(name)='XMLMetadata']/values/property[normalize-space(name)='Schemas']/values/property[normalize-space(name)='Schema']/values/property[normalize-space(name)='NamespaceURI']/values/value)"/>
			<xsl:variable name= "processingInstr" select = "normalize-space(repInfo/properties/property[normalize-space(name)='XMLMetadata']/values/property[normalize-space(name)='ProcessingInstructions']/values/property[normalize-space(name)='ProcessingInstruction']/values/property[normalize-space(name)='Target']/values/value)"/>
			<encoding>
				<encoding_platform>
					<xsl:attribute name="linebreak">CR/LF</xsl:attribute>
				</encoding_platform>
			</encoding>
			<character_info>
				<xsl:element name = "charset">
					<xsl:variable name = "charset" select = "$encoding"/>
					<xsl:value-of select="$charset"/>
				</xsl:element>
				<xsl:element name = "linebreak">CR/LF</xsl:element>
			</character_info>
			<language>
				<xsl:element name = "markup_basis">XML</xsl:element>
				<xsl:element name = "markup_language">
					<xsl:value-of select="$markupURI"/>
				</xsl:element>
				<xsl:if test = "boolean($processingInstr)" >
					<xsl:element name = "processingNote">
						<xsl:value-of select="$processingInstr"/>
					</xsl:element>
				</xsl:if>
			</language>
		</textMD>
	</xsl:template>
</xsl:stylesheet>
