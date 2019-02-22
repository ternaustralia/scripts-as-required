<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:murFunc="http://mur.nowhere.yet"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <xsl:import href="OAI_DC_Eprints_To_Rifcs.xsl"/>

    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'University of Tasmania'"/>
    <xsl:param name="global_group" select="'University of Tasmania EPrints'"/>
    <xsl:param name="global_acronym" select="'UTAS'"/>
    <xsl:param name="global_publisherName" select="'University of Tasmania'"/>
    <xsl:param name="global_baseURI" select="'https://eprints.utas.edu.au'"/>
    <xsl:param name="global_path" select="'/id/eprint'"/>
    
</xsl:stylesheet>
    
