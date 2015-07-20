<?xml version="1.0" encoding="UTF-8"?>
<!-- The namespaces below have been chosen because these are the ones that we think we will need. -->
<!-- Add more as required... -->
<xsl:stylesheet xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx" 
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:custom="http://custom.nowhere.yet"
    version="2.0" exclude-result-prefixes="dc">
    
    <!-- Call in any references files for later use -->
    <!--xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/-->
   
    <!-- Set any global default parameters -->
    <xsl:param name="global_originatingSource" select="'dryad'"/>
    <xsl:param name="global_baseURI" select="'http://datadryad.org/'"/>
    <xsl:param name="global_group" select="'dryad'"/>
    <xsl:param name="global_publisherName" select="'dryad'"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
            <xsl:apply-templates select="//oai:record" mode="collection"/>
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="oai:record" mode="collection">
        <xsl:variable name="key" select="oai:header/oai:identifier"/>
        
        <xsl:if test="string-length($key) > 0">
            <xsl:apply-templates select="oai:metadata/oai_dc:dc" mode="collection">
                <xsl:with-param name="key" select="$key"/>
            </xsl:apply-templates>
            
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="oai_dc:dc" mode="collection">
        <xsl:param name="key"/>
        
        <xsl:variable name="type" select="oai:metadata/oai_dc:dc/dc:type"/>
        
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <key>
                <xsl:value-of select="$key"/>
            </key>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
           
            <xsl:element name="{'collection'}">
                <xsl:attribute name="type">
                    <xsl:text>dataset</xsl:text>
                </xsl:attribute>
            </xsl:element>
        </registryObject>
        
    </xsl:template>
</xsl:stylesheet>
