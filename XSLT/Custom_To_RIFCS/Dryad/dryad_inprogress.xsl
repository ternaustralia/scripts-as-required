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
    <xsl:param name="global_baseURI" select="'http://datadryad.org'"/>
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
            <xsl:apply-templates select="oai:metadata/oai_dc:dc" mode="party"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="oai_dc:dc" mode="collection">
        <xsl:param name="key"/>
        
        <!-- ensuring that the DOI of the package is stored for later use, separated from the other identifiers -->
        <xsl:variable name="doiOfThisPackage">
            <xsl:for-each select="dc:identifier">
                <xsl:variable name="identifierAllContent" select="."/>
                <xsl:if test="(string-length($identifierAllContent) > 0) and 
                    not(boolean(contains($identifierAllContent, ' '))) and 
                    contains($identifierAllContent, 'doi')">
                    <xsl:value-of select="$identifierAllContent"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <key>
                <xsl:value-of select="$key"/>
            </key>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
           
           <!-- desired to source from the correct type (in Dryad records it is captured as Article) -->
            <!--  <xsl:variable name="type" select="oai:metadata/oai_dc:dc/dc:type"/> -->
            
            <xsl:element name="{'collection'}">
                <xsl:attribute name="type">
                    <xsl:text>dataset</xsl:text>
                </xsl:attribute>
            
                <!-- identifier -->
                <xsl:for-each select="dc:identifier">
                    <xsl:variable name="identifierAllContent" select="."/>
                    <xsl:if test="(string-length($identifierAllContent) > 0) and not(boolean((contains($identifierAllContent, ' '))))">
                        <xsl:message select="concat('identifierAllContent: ', $identifierAllContent)"></xsl:message>
                        <xsl:variable name="identifierType" select="custom:identifierType($identifierAllContent)"></xsl:variable>
                        <xsl:if test="string-length(.) > 0">
                            <identifier type="{$identifierType}">
                                <xsl:value-of select="."/>
                            </identifier>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
                
                <!-- name -->
                <xsl:if test="string-length(dc:title) > 0">
                    <name type="primary">
                        <namePart>
                            <xsl:value-of select="dc:title"/>
                        </namePart>
                    </name>
                </xsl:if>
                
                <!-- location -->
                <xsl:if test="string-length($doiOfThisPackage) > 0">
                    <location>
                        <address>
                            <electronic type="url" target="landingPage">
                                <value>
                                    <xsl:value-of select="concat('http://dx.doi.org/', substring-after($doiOfThisPackage, 'doi:'))"/>
                                </value>
                            </electronic>
                        </address>
                    </location>
                </xsl:if>
                
                
                
                <!-- Illustration below explains that '.' is where you are currenlty within a process -->
                <!-- You can specify locations relative to it -->
                <!-- <dc:relation><dc:child1></dc:child1><dc:child2></dc:child2></dc:relation> -->
                <!--xsl:for-each select="dc:relation">
                    <xsl:message select="concat('relation child1: ', ./dc:child1)"></xsl:message>
                    <xsl:message select="concat('relation child2: ', ./dc:child2)"></xsl:message>
                </xsl:for-each-->
                
                <xsl:for-each select="dc:creator">
                    <xsl:if test="string-length(.) > 0">
                        <relatedObject>
                            <key>
                                <!-- ' |.' = translate both spaces & '.' to empty char -->
                                <xsl:value-of select="concat($global_baseURI, '/', translate(normalize-space(.), ' |.', ''))"/>
                            </key>
                            <relation type="isEnrichedBy"/>
                            
                        </relatedObject>
                    </xsl:if>
                </xsl:for-each>
                 
                <!-- description - full -->       
                <xsl:if test="string-length(dc:description) > 0">
                    <description type="full">
                        <xsl:value-of select="dc:description"/>
                    </description>
                </xsl:if>
                
                <xsl:for-each select="dc:relation">
                    <xsl:variable name="relationAllContent" select="."/>
                    <xsl:if test="(string-length($relationAllContent) > 0) and 
                        not(boolean((contains($relationAllContent, ' '))))">
                        <xsl:message select="concat('relationAllContent: ', $relationAllContent)"/>
                        <xsl:variable name="identifierType" select="custom:identifierType($relationAllContent)"/>
                        <xsl:variable name="relatedInfoTypeAndRelation_sequence" select="custom:relatedInfoTypeAndRelation($doiOfThisPackage, $relationAllContent)"/>
                        <xsl:if test="string-length($identifierType) > 0 and count($relatedInfoTypeAndRelation_sequence) = 2">
                            <relatedInfo type="{$relatedInfoTypeAndRelation_sequence[1]}">
                                <identifier type="{$identifierType}">
                                    <xsl:value-of select="concat('http://dx.doi.org/', substring-after($relationAllContent, 'doi:'))"/>
                                </identifier>
                                <relation type="{$relatedInfoTypeAndRelation_sequence[2]}"/>
                            </relatedInfo>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:element>
        </registryObject>
        
    </xsl:template>
    
    <xsl:template match="oai_dc:dc" mode="party">
        <xsl:for-each select="dc:creator|dc:author">
            <xsl:if test="string-length(normalize-space(.)) > 0"></xsl:if>
            
            <xsl:variable name="key" select="translate(normalize-space(.), ' |.', '')"/>
            
            <xsl:variable name="type">
                <xsl:choose>
                    <xsl:when test="contains(., ',')">
                        <xsl:text>person</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>group</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable> 
            
            <xsl:if test="string-length($key) > 0">
                <registryObject group="{$global_group}">
                    <key>
                        <xsl:value-of select="concat($global_baseURI, '/', $key)"/>
                    </key>
                    <originatingSource>
                        <xsl:value-of select="$global_originatingSource"/>
                    </originatingSource>
                    <party type="{$type}">
                        <name type="primary">
                            <namePart>
                                <xsl:value-of select="."/>
                            </namePart>
                        </name>
                    </party>
                </registryObject>
            </xsl:if>
        </xsl:for-each>
        
    </xsl:template>
    <!-- Functions -->
    
    <xsl:function name="custom:identifierType" as="xs:string">
        <xsl:param name="identifier" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="contains(lower-case($identifier), 'scopus')">
                <xsl:text>scopus</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'orcid')">
                <xsl:text>orcid</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'doi')">
                <xsl:text>doi</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'pmid')">
                <xsl:text>pubMedId</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>uri</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="custom:relatedInfoTypeAndRelation" as="xs:string*">
        <xsl:param name="doiOfThisPackage" as="xs:string"/>
        <xsl:param name="identifier" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="contains(lower-case($identifier), 'doi') and contains($identifier, $doiOfThisPackage)">
                <xsl:text>dataset</xsl:text>
                <xsl:text>hasPart</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'doi') and not(boolean(contains($identifier, $doiOfThisPackage)))">
                <xsl:text>publication</xsl:text>
                <xsl:text>isReferencedBy</xsl:text>
            </xsl:when>
            <!-- PMID processing may be required if a DOI is not provided for a related pub -->
            <!-- Desired: to related the related article to its related journal (as captured in dc.relation.ispartofseries) -->
            
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
