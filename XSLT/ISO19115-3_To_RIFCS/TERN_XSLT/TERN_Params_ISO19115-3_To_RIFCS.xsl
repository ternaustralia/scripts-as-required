<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:import href="ISO19115-3_To_RIFCS.xsl"/>
    
    <xsl:param name="global_PID_Codespace" select="'pid'"/>
    <xsl:param name="global_debug" select="true()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    <xsl:param name="global_originatingSource" select="'Terrestrial Ecosystem Research Network (TERN)'"/>
    <xsl:param name="global_acronym" select="'TERN'"/>
    <xsl:param name="global_baseURI" select="'geonetwork.tern.org.au'"/>
    <xsl:param name="global_baseURI_PID" select="'pid.tern.org.au'"/>
    <xsl:param name="global_path_PID" select="'/dataset/tern/'"/>
    <xsl:param name="global_path" select="'/geonetwork/srv/eng/catalog.search#/metadata/'"/>
    <xsl:param name="global_group" select="'Terrestrial Ecosystem Research Network (Geonetwork)'"/>
    <xsl:param name="global_publisherName" select="'Terrestrial Ecosystem Research Network (TERN)'"/>
    <xsl:param name="global_publisherPlace" select="'Australia'"/>
    <xsl:param name="global_spatialProjection" select="''"/>
    
  </xsl:stylesheet>
