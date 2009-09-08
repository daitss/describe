<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="/">
		<doc xmlns='http://www.fcla.edu/dls/md/docmd'>
			<document>      
				<xsl:element name = "PageCount">
					<xsl:value-of select = "count(//property[name='Page'])"/>
				</xsl:element >
				<xsl:if test = "boolean(//property[name='Language'])" >
					<xsl:element name = "Language">
						<xsl:value-of select = "(//property[name='Language']/values/value)"/>
					</xsl:element>
				</xsl:if>
				<xsl:for-each select = "//property[name='Fonts']/values/property/values/property[name='Font']">
					<xsl:for-each select = "values/property[name='FontDescriptor']">
						<xsl:variable name= "fontName" select = "normalize-space(values/property[name='FontName']/values)"/>
						<xsl:choose>
							<xsl:when test="normalize-space(values/property[starts-with(name/text(), 'FontFile')]/values) = 'true'">
								<!-- font is embedded, records -->
								<xsl:element name = "Font">
									<xsl:attribute name = "FontName"><xsl:value-of select="substring-after($fontName,'+')"/></xsl:attribute>
									<xsl:attribute name = "isEmbedded">true</xsl:attribute>
								</xsl:element>
							</xsl:when>
							<xsl:when test="normalize-space(values/property[starts-with(name/text(), 'FontFile')]/values) = 'false'">
								<xsl:element name = "Font">
									<xsl:attribute name = "FontName"><xsl:value-of select="substring-after($fontName,'+')"/></xsl:attribute>
									<xsl:attribute name = "isEmbedded">false</xsl:attribute>
								</xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name = "Font">
									<xsl:attribute name = "FontName"><xsl:value-of select="$fontName"/></xsl:attribute>
									<xsl:attribute name = "isEmbedded">false</xsl:attribute>
								</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:for-each>
				<!-- <xsl:if test = "boolean(profiles[profile='Tagged PDF'])" >
								<Feature>isTagged</Feature>
							</xsl:if> -->
				<xsl:if test = "boolean(//property[name='Outlines'])" >
					<Feature>hasOutline</Feature>
				</xsl:if>
				<xsl:if test = "normalize-space(//property[name/text()='Thumb']/values) = 'true' " >
					<Feature>hasThumbnails</Feature>
				</xsl:if>
				<xsl:if test = "boolean(//property[name='Annotation'])" >
					<Feature>hasAnnotations</Feature>
				</xsl:if>
			</document>
		</doc>
	</xsl:template>
</xsl:stylesheet>
