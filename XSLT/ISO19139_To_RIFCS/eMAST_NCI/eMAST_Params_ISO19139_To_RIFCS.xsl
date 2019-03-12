<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:import href="ISO19139_RIFCS.xsl"/>
    <xsl:param name="global_defaultOriginatingSource" select="'external'"/>
    <xsl:param name="global_acronym" select="'eMAST'"/>
    <xsl:param name="global_originatingSource" select="'eMAST'"/> <!-- Only used as originating source if organisation name cannot be determined from Point Of Contact -->
    <xsl:param name="global_group" select="'Ecosystem Modelling and Scaling Infrastructure (eMAST) Facility'"/> 
    <xsl:param name="global_path" select="'/geonetwork/srv/eng/catalog.search#/metadata/'"/>
    <xsl:param name="global_baseURI" select="'geonetworkrr9.nci.org.au'"/>
    <xsl:param name="global_ActivityKeyNCI" select="'ncris.innovation.gov.au/activity/20'"/>
    <xsl:param name="global_SourceFacilityKey" select="'NCI/EcosystemModellingandScalingInfrastructure(eMAST)Facility'"/>
    
        
</xsl:stylesheet>
