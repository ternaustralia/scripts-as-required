<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:custom="http://nowhere.yet"
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns="http://www.isotc211.org/2005/gmd"
    xpath-default-namespace="http://www.isotc211.org/2005/gmd"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" >
    
    <xsl:param name="landingPagePrefix" select="'http://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/'"/>
    <xsl:param name="rawXMLPrefix" select="'http://geonetwork.tern.org.au/geonetwork/srv/eng/xml.metadata.get?uuid='"/>
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
        <xsl:text>fileIdentifier</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>landingPage</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>rawXML</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>linkage</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>protocol</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>name</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>description</xsl:text><xsl:value-of select="$columnSeparator"/>
        
        <xsl:apply-templates select="//gmd:MD_Metadata"/>
    </xsl:template>
    
    <xsl:template match="gmd:MD_Metadata">
       
        <xsl:message select="concat('result: ', count(gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[not(contains(gmd:protocol, 'metadata')) and not(contains(gmd:linkage, 'doi'))]))"></xsl:message>
        
        <xsl:variable name="fileIdentifier" select="gmd:fileIdentifier"></xsl:variable>
        
        <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[not(contains(gmd:protocol, 'metadata')) and not(contains(gmd:linkage, 'doi'))]">
            
            <xsl:apply-templates select=".">
                <xsl:with-param name="fileIdentifier" select="$fileIdentifier"/>
            </xsl:apply-templates>
        </xsl:for-each>
        
    </xsl:template>
    
    
    <xsl:template match="gmd:CI_OnlineResource">
        <xsl:param name="fileIdentifier"/>
       
        <xsl:text>&#xa;</xsl:text>
        
        <!--	column: fileIdentifier  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$fileIdentifier"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: landingPage  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="concat($landingPagePrefix, $fileIdentifier)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: rawXML  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="concat($rawXMLPrefix, $fileIdentifier)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: linkage  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="normalize-space(gmd:linkage/gmd:URL)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: protocol  -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="gmd:protocol"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: name -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="gmd:name"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: url_description -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="gmd:description"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
    </xsl:template>
    
</xsl:stylesheet>
