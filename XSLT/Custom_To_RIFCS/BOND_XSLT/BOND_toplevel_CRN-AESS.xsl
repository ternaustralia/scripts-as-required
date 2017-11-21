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
    
    <xsl:param name="global_parentIdentifierCRN_library" select="'http://epublications.bond.edu.au/crn_library'"/>
    <xsl:param name="global_parentIdentifierCRN_videos" select="'http://epublications.bond.edu.au/crn_videos'"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
            <xsl:apply-templates select="//oai:record[not(custom:sequenceContains(oai:header/oai:setSpec, 'publication:crn_publications')) and (custom:sequenceContains(oai:header/oai:setSpec, 'publication:crn_videos'))]/oai:metadata/*:document-export/*:documents/*:document" mode="collection">
                <xsl:with-param name="parentIdentifier" select="$global_parentIdentifierCRN_videos"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="//oai:record[not(custom:sequenceContains(oai:header/oai:setSpec, 'publication:crn_publications')) and not(custom:sequenceContains(oai:header/oai:setSpec, 'publication:crn_videos'))]/oai:metadata/*:document-export/*:documents/*:document" mode="collection">
                <xsl:with-param name="parentIdentifier" select="$global_parentIdentifierCRN_library"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="//oai:record[not(custom:sequenceContains(oai:header/oai:setSpec, 'publication:crn_publications'))]/oai:metadata/*:document-export/*:documents/*:document" mode="party"/>
        </registryObjects>
    </xsl:template>
  
    
</xsl:stylesheet>
    
