<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:custom="http://nowhere.yet"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xpath-default-namespace="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" >
    
    <xsl:param name="columnSeparator" select="'^'"/>
    <xsl:param name="valueSeparator" select="','"/>
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
       
        <xsl:text>key</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>title</xsl:text><xsl:value-of select="$columnSeparator"/>
        
        <xsl:message select="concat('result: ', count(//registryObject[count(collection) > 0]))"></xsl:message>
        
        <xsl:apply-templates select="//registryObject[count(collection) > 0]"/>
    
    </xsl:template>
    
    
    <xsl:template match="registryObject">
       
        <xsl:text>&#xa;</xsl:text>
        
        <!--	column: key	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="concat('https://demo.ands.org.au/view?key=', key)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: title	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="collection/name[@type = 'primary']/namePart"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
    </xsl:template>
    
</xsl:stylesheet>
