<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    

    <xsl:import href="BOND_document-export_To_Rifcs.xsl"/>
    
    <xsl:param name="global_parentIdentifier" select="'http://epublications.bond.edu.au/triathlon_data'"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
            <xsl:apply-templates select="//oai:record/oai:metadata/*:document-export/*:documents/*:document" mode="collection">
                <xsl:with-param name="parentIdentifier" select="$global_parentIdentifier"/>
            </xsl:apply-templates>
            <!-- xsl:apply-templates select="//oai:record/oai:metadata/*:document-export/*:documents/*:document" mode="activity"/-->
            <xsl:apply-templates select="//oai:record/oai:metadata/*:document-export/*:documents/*:document" mode="party"/>
        </registryObjects>
    </xsl:template>
  
    
</xsl:stylesheet>
    
