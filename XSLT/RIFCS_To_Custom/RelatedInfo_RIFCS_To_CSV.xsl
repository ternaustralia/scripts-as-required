<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:custom="http://nowhere.yet"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xpath-default-namespace="http://ands.org.au/standards/rif-cs/registryObjects"
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
       
        <xsl:text>&#xa;</xsl:text>
        
        <xsl:text>type</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>title</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>identifier</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>relation</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>url_dataset_description</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>url_dataset</xsl:text><xsl:value-of select="$columnSeparator"/>
        
        <xsl:message select="concat('result: ', count(//*:relatedInfo[@type='service']))"></xsl:message>
        
        <xsl:apply-templates select="//*:relatedInfo"/>
    
    </xsl:template>
    
    
    <xsl:template match="relatedInfo">
       
        <xsl:text>&#xa;</xsl:text>
        
        <!--	column: type  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="@type"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: title  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="normalize-space(title)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: identifier  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="identifier"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: relation -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="relation/@type"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: url_description -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="normalize-space(relation/description)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: url_dataset -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="normalize-space(relation/url)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
    </xsl:template>
    
</xsl:stylesheet>
