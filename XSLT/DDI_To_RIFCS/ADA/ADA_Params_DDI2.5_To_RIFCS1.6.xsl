<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:ddi="http://www.icpsr.umich.edu/DDI" 
    xmlns:oai_ddi="https://dataverse-test.ada.edu.au/oai"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:localFunc="http://www.localfunc.net"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:local="http://local.to.here"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:math="https://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="saxon local xs oai ddi oai_ddi fn localFunc math">
    
    <xsl:import href="DDI2_5_To_RIFCS1_6.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'Australian Data Archive'"/>
    <xsl:param name="global_baseURI" select="'www.ada.edu.au'"/>
    <xsl:param name="global_group" select="'Australian Data Archive'"/>
    <xsl:param name="global_publisherName" select="'Australian Data Archive'"/>
    <xsl:param name="global_baseURL" select="'https://www.ada.edu.au/ada/'"/>
    
</xsl:stylesheet>
