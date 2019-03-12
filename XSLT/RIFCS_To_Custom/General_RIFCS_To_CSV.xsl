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
       
        <xsl:text>location</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>key</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>class</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>type</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>identifier_local</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>name</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>electronic_url</xsl:text><xsl:value-of select="$columnSeparator"/>
        
        <xsl:message select="concat('result: ', count(//registryObject[count(collection|service) > 0]))"></xsl:message>
        
        <xsl:apply-templates select="//registryObject[count(collection|service) > 0]"/>
    
    </xsl:template>
    
    
    <xsl:template match="registryObject">
       
        <xsl:text>&#xa;</xsl:text>
        
        <!--	column: location -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="concat('https://demo.ands.org.au/view?key=', key)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: key	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="key"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: class	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:choose>
            <xsl:when test="count(service) > 0">
                <xsl:text>service</xsl:text>
            </xsl:when>
            <xsl:when test="count(collection) > 0">
                <xsl:text>collection</xsl:text>
            </xsl:when>
            <xsl:when test="count(party) > 0">
                <xsl:text>party</xsl:text>
            </xsl:when>
            <xsl:when test="count(activity) > 0">
                <xsl:text>activity</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: type	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="(collection|service|party|activity)/@type"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: identifier_local	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="*/identifier[@type = 'local']"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: name	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="*/name/namePart"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: electronic url (mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="*/location/address/electronic[@type = 'url']/value"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
         
    </xsl:template>
    
</xsl:stylesheet>
