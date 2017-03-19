<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:ows="http://www.opengis.net/ows">

    <xsl:param name="columnSeparator" select="','"/>
    <xsl:param name="valueSeparator" select="'|'"/>
    <xsl:output omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>  
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="node()[ancestor::field and not(self::text())]">
        <xsl:apply-templates/>
    </xsl:template>
    
	<xsl:template match="/">
       
        <xsl:text>identifier</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>date</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>title</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>source</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>format</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>subject</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>abstract</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>description</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>getcapabilities_uri</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>bb_lowercorner</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>bb_uppercorner</xsl:text><xsl:value-of select="$columnSeparator"/>
        
        <xsl:apply-templates select="//csw:Record"/>
        
	</xsl:template>
    
    <xsl:template match="csw:Record">
       
        <xsl:text>&#xa;</xsl:text>
        
        <!--    column: identifier   -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="dc:identifier"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--    column: date   -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="dc:date"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--    column: title  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="dc:title"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--    column: source  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="dc:source"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--    column: format  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="dc:format"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
         <!--   column: subject    -->
        <xsl:text>&quot;</xsl:text>
        <xsl:variable name="total" select="count(dc:subject)" as="xs:integer"/>
        <xsl:for-each select="dc:subject">
            <xsl:value-of select="."/>
            <xsl:if test="position() &lt; $total">
                <xsl:value-of select="$valueSeparator"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--    column: abstract  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="dct:abstract"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--    column: description  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="dc:description"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--    column: getcapabilities uri  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="dc:URI[contains(@protocol, 'get-capabilities')]"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
         <!--    column: bb_lowercorner  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="ows:BoundingBox/ows:LowerCorner"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
         <!--    column: bb_uppercorner  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="ows:BoundingBox/ows:UpperCorner"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
    </xsl:template>
</xsl:stylesheet>