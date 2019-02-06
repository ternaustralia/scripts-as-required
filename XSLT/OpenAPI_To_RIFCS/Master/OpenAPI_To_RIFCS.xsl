<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:fn = "http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:custom="http://custom.nowhere.yet"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="xsl xsi fn xs custom">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:param name="global_debug" select="true()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    <xsl:param name="global_originatingSource" select="'{default}'"/>
    <xsl:param name="global_baseURI" select="'{default}'"/>
    <xsl:param name="global_acronym" select="'{default}'"/>
    <xsl:param name="global_group" select="'{default}'"/>
    <xsl:param name="global_publisherName" select="'{default}'"/>
    
    <!-- =========================================== -->
    <!-- dataset (datasets) Template             -->
    <!-- =========================================== -->

    <xsl:template match="/">
        <xsl:message select="'Process'"/>
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
        
            <xsl:apply-templates select="root" mode="service"/>
            
        </registryObjects>
            
    </xsl:template>
    
    <!-- ====================================== -->
    <!-- Service RegistryObject - Template -->
    <!-- ====================================== -->

    <!-- Service Registry Object -->
    <xsl:template match="root" mode="service">
       
        
        <xsl:variable name="basePath" select="concat('http://', host, basePath)"/>
        <xsl:variable name="title" select="info/title"/>
        
        <xsl:message select="concat('basePath: ', $basePath)"/>
        
        <xsl:for-each select="paths/key">
        
            <xsl:variable name="fullPath" select="concat($basePath, @name)"/>
            <xsl:message select="concat('fullPath: ', $fullPath)"/>
             
            <xsl:for-each select="get">
                <registryObject group="{$global_group}">
       
                           <key>
                               <xsl:value-of select="substring(string-join(for $n in fn:string-to-codepoints(reverse($fullPath)) return string($n), ''), 0, 500)"/>
                           </key>
       
                           <originatingSource>
                               <xsl:value-of select="$global_originatingSource"/>
                           </originatingSource>
       
                           <service type="webservice">
                               
                               <identifier type="url">
                                   <xsl:value-of select="$fullPath"/>
                               </identifier>
       
                               <identifier type="local">
                                   <xsl:value-of select="operationId"/>
                               </identifier>
       
                               <xsl:variable name="serviceName" select="serviceURI"/>
       
                               <name type="primary">
                                   <namePart>
                                       <xsl:value-of select="operationId"/>
                                   </namePart>
                               </name>
       
                              <description>
                                   <xsl:attribute name="type">
                                       <xsl:text>brief</xsl:text>
                                   </xsl:attribute>
                                  <xsl:choose>
                                      <xsl:when test="string-length(description) > 0">
                                          <xsl:value-of select="description"/>
                                      </xsl:when>
                                      <xsl:when test="string-length(summary) > 0">
                                          <xsl:value-of select="summary"/>
                                      </xsl:when>
                                  </xsl:choose>
                               </description>
                               
                               <description type="full">
                                   <xsl:value-of select="concat(operationId, ' operation available at ', $title)"/>
                               </description>
                               
                               <xsl:if test="count(parameters/item) > 0">
                                 <description>
                                     <xsl:attribute name="type">
                                         <xsl:text>notes</xsl:text>
                                     </xsl:attribute>
                                     <xsl:text>&lt;b&gt;Parameters&lt;/b&gt;</xsl:text>
                                     <xsl:text>&lt;br/&gt;</xsl:text>
                                     <xsl:for-each select="parameters/item">
                                         <xsl:value-of select="concat(name, ' - ', type, '(', required, ')')"></xsl:value-of>
                                         <xsl:text>&lt;br/&gt;</xsl:text>     
                                     </xsl:for-each>
                                 </description>
                               </xsl:if>
        
                                <xsl:for-each select="tags/item">
                                    <subject type="local">
                                        <xsl:value-of select="."/>
                                    </subject>
                                </xsl:for-each>
       
                               <location>
                                   <address>
                                       <electronic>
                                           <xsl:attribute name="type">
                                               <xsl:text>url</xsl:text>
                                           </xsl:attribute>
                                           <value>
                                               <xsl:value-of select="$fullPath"/>
                                           </value>
                                       </electronic>
                                   </address>
                               </location>
       
                              
                           </service>
                       </registryObject>
            </xsl:for-each>
        </xsl:for-each>

    </xsl:template>
</xsl:stylesheet>
