<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:dc="http://purl.org/dc/terms/" 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:gmx="http://www.isotc211.org/2005/gmx" 
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" exclude-result-prefixes="dc">
    
    <xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/>
    
    <xsl:param name="global_originatingSource" select="'Monash University Figshare'"/>
    <xsl:param name="global_baseURI" select="'monash.edu.au'"/>
    <xsl:param name="global_group" select="'Monash University'"/>
    <xsl:param name="global_publisherName" select="'Monash University'"/>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects 
            http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
          
            <xsl:message select="concat('name(oai:OAI-PMH): ', name(oai:OAI-PMH))"/>
            <xsl:apply-templates select="oai:OAI-PMH/*/oai:record"/>
            
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="oai:OAI-PMH/*/oai:record">
         
         <xsl:if test="count(oai:metadata/oai_dc:dc) > 0">
             <xsl:if test="contains(lower-case(oai:metadata/oai_dc:dc/dc:type), 'dataset')">
                 <xsl:apply-templates select="oai:metadata/oai_dc:dc" mode="collection"/>
                 <xsl:apply-templates select="oai:metadata/oai_dc:dc/dc:funding" mode="funding_party"/>
                 <xsl:apply-templates select="oai:metadata/oai_dc:dc" mode="party"/>
             </xsl:if>
         </xsl:if>
    </xsl:template>
    
    <xsl:template match="oai_dc:dc" mode="collection">
        
        <xsl:variable name="class" select="'collection'"/>
        <xsl:variable name="type" select="dc:type"/>
        
        <xsl:message select="concat('type: ', dc:type)"/>
        <xsl:variable name="key" select="custom:formatKey(custom:getKey(., true()))"/>
        
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <key>
                <xsl:value-of select="$key"/>
            </key>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            <xsl:element name="{$class}">
                
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="$type = 'Dataset'">
                            <xsl:text>dataset</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$type"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                
                <!-- ensuring that the DOI of the package is stored for later use, separated from the other identifiers -->
                <xsl:variable name="doiOfThisPackage">
                    <xsl:for-each select="dc:identifier">
                        <xsl:if test="(string-length(.) > 0) and 
                            not(boolean(contains(., ' '))) and 
                            (contains(lower-case(.), 'doi')) or (starts-with(., '10.'))">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
        
                <!-- identifier -->
                <xsl:for-each select="dc:identifier">
                    <xsl:variable name="identifierExtracted_sequence" as="xs:string*">
                        <xsl:choose>
                            <xsl:when test="contains(lower-case(.), 'http') and
                                not(boolean(contains(., ' ')))">
                                <xsl:analyze-string select="normalize-space(.)"
                                    regex="(http|https):[^&quot;]*">
                                    <xsl:matching-substring>
                                        <xsl:value-of select="regex-group(0)"/>
                                    </xsl:matching-substring>
                                </xsl:analyze-string>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:for-each select="distinct-values($identifierExtracted_sequence)">
                        <xsl:if test="
                            contains(., $global_baseURI) or
                            (contains(lower-case(.), 'doi')) or (starts-with(., '10.'))">
                                 <xsl:variable name="identifierType" select="custom:identifierType(.)"></xsl:variable>
                                 <xsl:if test="string-length(.) > 0">
                                      <identifier type="{$identifierType}">
                                          <xsl:choose>
                                            <xsl:when test="(starts-with(., '10.'))">
                                                <xsl:value-of select="concat('http://doi.org/', .)"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="."/>
                                            </xsl:otherwise>
                                          </xsl:choose>
                                      </identifier>
                                 </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
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
                <xsl:choose>
                    <xsl:when test="string-length($doiOfThisPackage) > 0">
                        <location>
                            <address>
                                <electronic type="url" target="landingPage">
                                    <value>
                                         <xsl:choose>
                                            <xsl:when test="(starts-with($doiOfThisPackage, '10.'))">
                                                <xsl:value-of select="concat('http://doi.org/', $doiOfThisPackage)"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$doiOfThisPackage"/>
                                            </xsl:otherwise>
                                          </xsl:choose>
                                    </value>
                                </electronic>
                            </address>
                        </location>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="dc:identifier">
                            <xsl:if test="(string-length(.) > 0) and contains(., $global_baseURI)">
                                <location>
                                    <address>
                                        <electronic type="url" target="landingPage">
                                            <value>
                                                <xsl:value-of select="."/>
                                            </value>
                                        </electronic>
                                    </address>
                                </location>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:for-each select="dc:author">
                    <xsl:if test="string-length(.) > 0">
                        <relatedObject>
                            <key>
                                <xsl:value-of select="custom:formatKey(.)"/>
                            </key>
                            <relation type="hasCollector"/>
                            
                        </relatedObject>
                    </xsl:if>
                </xsl:for-each>
                
                <!-- related object -->
                <xsl:for-each select="dc:creator">
                    <xsl:if test="string-length(.) > 0">
                        <relatedObject>
                            <key>
                                <xsl:value-of select="custom:formatKey(.)"/>
                            </key>
                            <relation type="isEnrichedBy"/>
                        </relatedObject>
                    </xsl:if>
                </xsl:for-each>
                
                <xsl:for-each select="dc:funding">
                    <xsl:if test="string-length(.) > 0">
                        <relatedObject>
                            <key>
                                <xsl:value-of select="custom:formatKey(.)"/>
                            </key>
                            <relation type="isOutputOf"/>
                            
                        </relatedObject>
                    </xsl:if>
                </xsl:for-each>
                
                
                
               <!-- subject -->
                <xsl:for-each select="dc:subject">
                    <xsl:if test="string-length(.) > 0">
                        <subject type="local">
                            <xsl:value-of select="."/>
                        </subject>
                    </xsl:if>
                </xsl:for-each>
                
                <xsl:for-each select="dc:identifier">
                    <xsl:if test="string-length(.) > 0">
                        <xsl:for-each select="tokenize(.,',')">
                            <xsl:if test="contains(., 'ANZSRC-FOR:')">
                                <xsl:variable name="forCode" select="substring-after(., ':')"/>
                                <xsl:if test="string-length($forCode) > 0">
                                    <subject type="anzsrc-for">
                                       <xsl:value-of select="$forCode"/>
                                    </subject>
                                </xsl:if>
                             </xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:for-each>
                
                <!-- description - full -->       
                <xsl:if test="string-length(dc:description) > 0">
                    <description type="full">
                        <xsl:value-of select="dc:description"/>
                    </description>
                </xsl:if>
                
                <!-- coverage - temporal -->
                <xsl:variable name="temporalCoverage_sequence" as="xs:string*">
                    <xsl:for-each select="dc:coverage.temporal">
                        <xsl:if test="string-length(.) > 0">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                
                <xsl:if test="count($temporalCoverage_sequence) &gt; 0 and count($temporalCoverage_sequence) &lt; 3">
                    <coverage>
                        <temporal>
                            <xsl:for-each select="distinct-values($temporalCoverage_sequence)">
                                <xsl:variable name="temporalType">
                                    <xsl:choose>
                                        <xsl:when test="position() = 1">
                                            <xsl:text>dateFrom</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="position() = 2">
                                            <xsl:text>dateTo</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <!-- assert confirms no otherwise -->      
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:if test="string-length($temporalType) > 0">
                                    <date type="{$temporalType}" dateFormat="W3CDTF">
                                        <xsl:value-of select="."/>
                                    </date>
                                </xsl:if>
                            </xsl:for-each>
                        </temporal>
                    </coverage>
                </xsl:if>
                
                <!-- spatial coverage - text -->
                <xsl:if test="string-length(dc:coverage.spatial) > 0">
                    <coverage>
                        <spatial type="text">
                            <xsl:value-of select="dc:coverage.spatial"/>
                        </spatial>
                    </coverage>
                </xsl:if>
                
                
                <!-- spatial coverage - points -->
                <xsl:if test="string-length(dc:coverage.spatial.long) > 0 and string-length(dc:coverage.spatial.lat)">
                     <coverage>
                        <spatial type="gmlKmlPolyCoords">
                            <xsl:value-of select="concat(dc:coverage.spatial.long, ',', dc:coverage.spatial.lat)"/>
                        </spatial>
                    </coverage>
                </xsl:if>
                
                <!-- dates -->
                
                <xsl:call-template name="dates">
                    <xsl:with-param name="currentType" select="'available'"/>
                </xsl:call-template>  
                
                <xsl:call-template name="dates">
                    <xsl:with-param name="currentType" select="'created'"/>
                </xsl:call-template>  
                
                <xsl:call-template name="dates">
                    <xsl:with-param name="currentType" select="'dateAccepted'"/>
                </xsl:call-template>  
                
                <xsl:call-template name="dates">
                    <xsl:with-param name="currentType" select="'dateSubmitted'"/>
                </xsl:call-template>  
                
                <xsl:call-template name="dates">
                    <xsl:with-param name="currentType" select="'issued'"/>
                </xsl:call-template>    
                
                <xsl:call-template name="dates">
                    <xsl:with-param name="currentType" select="'valid'"/>
                </xsl:call-template>    
                
                
                <!-- rights -->
                <xsl:if test="(count(dc:rights.license) = 1) and string-length(dc:rights.license) > 0">
                    <xsl:variable name="licenseLink" select="dc:rights.license"/>
                    <xsl:for-each
                        select="$licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='LicenseCode']/gmx:codeEntry/gmx:CodeDefinition">
                        <xsl:if test="string-length(normalize-space(gml:remarks))">
                            <xsl:if test="contains($licenseLink, gml:remarks)">
                                <rights>
                                    <licence>
                                        <xsl:attribute name="type" select="gml:identifier"/>
                                        <xsl:attribute name="rightsUri" select="$licenseLink"/>
                                        <xsl:if test="string-length(normalize-space(gml:name))">
                                            <xsl:value-of select="normalize-space(gml:name)"/>
                                        </xsl:if>
                                    </licence>
                                </rights>
                            </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
                
                <xsl:if test="(count(dc:rights.accessRights) = 1) and string-length(dc:rights.accessRights) > 0">
                    <xsl:if test="lower-case(dc:rights.accessRights) = 'open'">
                          <rights>
                            <accessRights type="open"/>
                          </rights>
                    </xsl:if>
                </xsl:if>
                
               <!-- citationInfo -->
                <xsl:if test="string-length(dc:identifier.bibliographicCitation)">
                    <citationInfo>
                        <fullCitation>
                            <xsl:value-of select="dc:identifier.bibliographicCitation"/>
                        </fullCitation>
                    </citationInfo>
                </xsl:if>
                
            </xsl:element>
        </registryObject>
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
            <xsl:when test="(contains(lower-case($identifier), 'doi')) or (starts-with($identifier, '10.'))">
                <xsl:text>doi</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>uri</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template name="dates">
        <xsl:param name="currentType"/>
        <xsl:for-each select="*[contains(name(), $currentType)]">
            <xsl:if test="string-length(.) > 0">
                <!--xsl:message select="concat('Node name:', name())"/-->
                <xsl:variable name="type">
                    <xsl:choose>
                        <xsl:when test="position() = 1">
                            <xsl:text>dateFrom</xsl:text>
                        </xsl:when>
                        <xsl:when test="position() = 2">
                            <xsl:text>dateTo</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- assert confirms no otherwise -->      
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="string-length($type) > 0">
                    <xsl:variable name="dctype" select="substring-after(name(.), 'dc:date.')"/>
                    <dates type="{$dctype}">
                        <date type="{$type}" dateFormat="W3CDTF">
                            <xsl:value-of select="."/>
                        </date>
                    </dates>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    
    <xsl:template match="oai_dc:dc/dc:funding" mode="funding_party">
        
        <xsl:if test="string-length(normalize-space(.)) > 0">
        
            <registryObject group="{$global_group}">
                <key>
                    <xsl:value-of select="custom:formatKey(.)"/>
                </key>
                <originatingSource>
                    <xsl:value-of select="$global_originatingSource"/>
                </originatingSource>
                
                <activity type="grant">
                    <name type="primary">
                        <namePart>
                            <xsl:value-of select="normalize-space(.)"/>
                        </namePart>
                    </name>
                </activity>
            </registryObject>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template match="oai_dc:dc" mode="party">
        
        <xsl:for-each select="dc:author|dc:creator">
            
            <xsl:variable name="name" select="normalize-space(.)"/>
            
            <xsl:if test="string-length($name) > 0">
                
                <xsl:variable name="htmlFormatted">
                    <xsl:variable name="html" select="../dc:identifier[contains(text(), '&lt;')]"/>
                    <xsl:if test="string-length($html) > 0">
                        <xsl:value-of select="fn:replace(fn:replace(fn:replace($html, '&lt;br /&gt;' , ''), '&lt;br/&gt;' , ''), '&amp;', '&amp;amp;')"/>
                    </xsl:if>
                </xsl:variable>
                    
                <!--xsl:message select="concat('htmlFormatted: ', $htmlFormatted)"/-->
                
                <!-- Retrieve organisations related to this party -->
                <xsl:variable name="organisation_sequence" select="custom:getOrganisationForName_sequence(normalize-space(.), $htmlFormatted)" as="xs:string*"/>
                
                <!-- Retrieve identifiers for this party -->
                <xsl:variable name="identifier_sequence" select="custom:getIdentifiersForName_sequence($name, $htmlFormatted)" as="xs:string*"/>
                
                <xsl:variable name="objectType_sequence" as="xs:string*">
                     <xsl:choose>
                         <xsl:when test="contains(., ',')">
                             <xsl:text>party</xsl:text>
                             <xsl:text>person</xsl:text>
                         </xsl:when>
                         <xsl:otherwise>
                             <xsl:text>party</xsl:text>
                             <xsl:text>group</xsl:text>
                         </xsl:otherwise>
                     </xsl:choose>
                 </xsl:variable> 
                 
                 <xsl:variable name="object" select="$objectType_sequence[1]"/>
                 <xsl:variable name="type" select="$objectType_sequence[2]"/>
                 
                 <xsl:if test="string-length(normalize-space(.)) > 0">
                     <registryObject group="{$global_group}">
                         <key>
                             <xsl:value-of select="custom:formatKey(.)"/>
                         </key>
                         <originatingSource>
                             <xsl:value-of select="$global_originatingSource"/>
                         </originatingSource>
                         
                         <xsl:element name="{$object}">
                             <xsl:attribute name="type" select="$type"/>
                             <xsl:if test="count($identifier_sequence) > 0">
                                 <xsl:for-each select="distinct-values($identifier_sequence)">
                                     <xsl:if test="string-length(normalize-space(.)) > 0">
                                         <xsl:message select="concat('Identifier for ', $name, ': ', .)"/>
                                         <identifier type="{custom:identifierType(.)}">
                                             <xsl:value-of select="."/>
                                          </identifier>
                                     </xsl:if>
                                 </xsl:for-each>
                             </xsl:if>
                             <name type="primary">
                                 <namePart>
                                     <xsl:value-of select="$name"/>
                                 </namePart>
                             </name>
                             
                             
                             <xsl:for-each select="distinct-values($organisation_sequence)">
                                 <xsl:if test="string-length(normalize-space(.)) > 0">
                                     <!--xsl:message select="concat('Organisation for ', $name, ': ', .)"/-->
                                     <relatedObject>
                                         <key>
                                             <xsl:value-of select="custom:formatKey(.)"/>
                                         </key>
                                         <relation type="isAssociatedWith"/>
                                     </relatedObject>
                                 </xsl:if>
                             </xsl:for-each>
                         </xsl:element>
                     </registryObject>
                     
                     <xsl:for-each select="distinct-values($organisation_sequence)">
                         <xsl:variable name="organisationName" select="normalize-space(.)"/>
                         
                         <xsl:message select="concat('Organisation for ', $name, ': ', $organisationName)"/>
                         
                         <xsl:if test="string-length($organisationName) > 0">
                             
                             <registryObject group="{$global_group}">
                                 <key>
                                     <xsl:value-of select="custom:formatKey(.)"/>
                                 </key>
                                 <originatingSource>
                                     <xsl:value-of select="$global_originatingSource"/>
                                 </originatingSource>
                                 
                                 <party type="group">
                                     <name type="primary">
                                         <namePart>
                                             <xsl:value-of select="$organisationName"/>
                                         </namePart>
                                     </name>
                                 </party>
                             </registryObject>
                         </xsl:if>
                     </xsl:for-each>
                 </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:function name="custom:getIdentifiersForName_sequence" as="xs:string*">
        <xsl:param name="soughtName" as="xs:string"/>
        <xsl:param name="html" as="xs:string"/>
        
        <xsl:if test="string-length($html) > 0">
            <xsl:variable name="unescapedContent" select="saxon:parse(concat('&lt;root&gt;', $html, '&lt;/root&gt;'))" as="document-node()*"/>
            <xsl:if test="count($unescapedContent) > 0">
                <!--xsl:message select="concat('unescapedContent ', $unescapedContent)"/-->
                <xsl:variable name="namePosition_sequence" as="xs:integer*">
                    <xsl:for-each select="$unescapedContent/root/p">
                        <xsl:variable name="personPosition" select="position()" as="xs:integer"/>
                        <xsl:if test="count(strong) > 0">
                            <xsl:value-of select="$personPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                
                <!--xsl:for-each select="$namePosition_sequence">
                    <xsl:message select="concat('$namePosition_sequence entry: ', ., ' at position: ', position())"/>
                </xsl:for-each-->
                   
                <xsl:variable name="currentPersonPositionRange_sequence" as="xs:integer*">
                     <xsl:for-each select="$unescapedContent/root/p">
                         <xsl:variable name="currentPPosition" select="position()"  as="xs:integer"/>
                         <xsl:variable name="lastPPosition" select="last()"  as="xs:integer"/>
                         <xsl:variable name="currentName" select="custom:getName(.)"/>
                         <xsl:if test="string-length($currentName) > 0">
                             <xsl:if test="string-length(.) > 0 and (contains(., ' ') or contains(., ','))">
                                 
                                 <xsl:if test="boolean(custom:nameMatch($soughtName, $currentName)) = true()">
                                     <xsl:message select="concat('Match! - ', $soughtName)"/>
                                         
                                         <!-- Return first index in range -->
                                         <xsl:copy-of select="$currentPPosition"/>
                                         <xsl:for-each select="distinct-values($namePosition_sequence)">
                                             <xsl:variable name="iterPersonPosition" select="." as="xs:integer"/>
                                             <xsl:variable name="posInt" select="position()" as="xs:integer"/>
                                             <!--xsl:message select="concat('iterPersonPosition: ', $iterPersonPosition)"/-->
                                             <!--xsl:message select="concat('$posInt: ', number($posInt))"/-->
                                             <xsl:if test="number($iterPersonPosition) = number($currentPPosition)">
                                                 <!-- Return last index in range -->
                                                 <xsl:choose>
                                                     <xsl:when test="count($namePosition_sequence) > $posInt">
                                                         <!--xsl:message select="concat('Returning $namePosition_sequence[number($posInt)+1]: ', $namePosition_sequence[number($posInt)+1])"/-->
                                                         <xsl:copy-of select="$namePosition_sequence[number($posInt)+1]"/>
                                                     </xsl:when>
                                                     <xsl:otherwise>
                                                         <!--xsl:message select="concat('Returning $lastPPosition + 1: ', $lastPPosition + 1)"/-->
                                                         <xsl:copy-of select="$lastPPosition + 1"/>
                                                     </xsl:otherwise>
                                                 </xsl:choose>
                                             </xsl:if>
                                         </xsl:for-each>
                                 </xsl:if>
                             </xsl:if>
                         </xsl:if>
                     </xsl:for-each>
                </xsl:variable>
                
                <xsl:if test="count($currentPersonPositionRange_sequence) > 0">
                    <xsl:message select="concat('count($currentPersonPositionRange_sequence): ', count($currentPersonPositionRange_sequence))"/>
                    
                    <xsl:message select="concat('$currentPersonPositionRange_sequence[1]: ', $currentPersonPositionRange_sequence[1])"/>
                    <xsl:message select="concat('$currentPersonPositionRange_sequence[2]: ', $currentPersonPositionRange_sequence[2])"/>
                    
                    <xsl:for-each select="$unescapedContent/root/p">
                        <xsl:variable name="currentPPosition" select="position()"  as="xs:integer"/>
                        <xsl:if test="($currentPersonPositionRange_sequence[2] > $currentPPosition) and
                                      ($currentPPosition > $currentPersonPositionRange_sequence[1])">
                            
                            <!--xsl:message select="concat('$currentPPosition: ', $currentPPosition)"/-->
                            <xsl:if test="string-length(normalize-space(a/@href)) > 0">
                                <!--xsl:message select="concat('a/@href: ', a/@href)"/-->
                                <xsl:value-of select="normalize-space(a/@href)"/>
                            </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
            </xsl:if>
        </xsl:if>
     </xsl:function>
    

    <xsl:function name="custom:getOrganisationForName_sequence" as="xs:string*">
        <xsl:param name="soughtName" as="xs:string"/>
        <xsl:param name="html" as="node()"/>
        
        <!--xsl:message select="concat('html: ', $html)"/-->
        
        <xsl:if test="string-length($html) > 0">
            <xsl:variable name="unescapedContent" select="saxon:parse(concat('&lt;root&gt;', $html, '&lt;/root&gt;'))" as="document-node()*"/>
            <xsl:if test="count($unescapedContent) > 0">
                <!--xsl:message select="concat('unescapedContent ', $unescapedContent)"/-->
                <xsl:for-each select="$unescapedContent/root/p">
                    <xsl:if test="count(strong) > 0">
                        <xsl:variable name="currentName" select="custom:getName(.)"/>
                        <xsl:if test="string-length($currentName) > 0 and (contains($currentName, ' ') or contains($currentName, ','))">
                            <xsl:if test="boolean(custom:nameMatch($soughtName, $currentName)) = true()">
                                <xsl:message select="concat('Match $currentName ', $currentName)"/>
                                <xsl:variable name="organisation_sequence" select="em" as="xs:string*"/>
                                <xsl:if test="count($organisation_sequence) > 0">
                                    <xsl:if test="count($organisation_sequence) > 0">
                                        <xsl:copy-of select="$organisation_sequence"/>
                                    </xsl:if>
                                </xsl:if>
                            </xsl:if>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="custom:formatName">
        <xsl:param name="name"/>
        <xsl:choose>
            <xsl:when test="contains($name, ', ')">
                <xsl:value-of select="concat(normalize-space(substring-after($name, ',')), ' ', normalize-space(substring-before($name, ',')))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="custom:nameMatch" as="xs:boolean">
        <xsl:param name="name"/>
        <xsl:param name="match"/>
        
        <xsl:choose>
             <xsl:when test="
                 tokenize(custom:formatName($name), ' ')[1] = tokenize(custom:formatName($match), ' ')[1] and
                 tokenize(custom:formatName($name), ' ')[last()] = tokenize(custom:formatName($match), ' ')[last()]">
                 <xsl:copy-of select="true()"/>
             </xsl:when>
             <xsl:otherwise>
                 <xsl:copy-of select="false()"/>
             </xsl:otherwise>
         </xsl:choose>
    </xsl:function>
    
    <xsl:function name="custom:formatKey">
        <xsl:param name="input"/>
        <xsl:variable name="raw" select="translate(normalize-space($input), ' ', '')"/>
        <xsl:variable name="temp">
            <xsl:choose>
                <xsl:when test="substring($raw, string-length($raw), 1) = '.'">
                    <xsl:value-of select="substring($raw, 0, string-length($raw))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$raw"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($global_baseURI, '/', $temp)"/>
    </xsl:function>
    
    <xsl:function name="custom:getKey" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="handleOK" as="xs:boolean"/>
        
        <xsl:variable name="doi_sequence" as="node()*">
            <xsl:for-each select="$node/dc:identifier">
                <xsl:if test="not(contains(., ' ')) and starts-with(., 'http')">
                    <xsl:if test=" (contains(lower-case(.), 'doi')) or (starts-with(., '10.'))">
                        <xsl:value-of select="."/>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="uri_sequence" as="node()*">
            <xsl:for-each select="$node/dc:identifier">
                <xsl:if test="not(contains(., ' ')) and not(contains(., 'doi')) and not(starts-with(., '.10')) and starts-with(., 'http')">
                    <xsl:value-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="buffer" as="xs:string">
            <xsl:choose>
                <xsl:when test="count($doi_sequence) > 0">
                    <xsl:value-of select="fn:string-to-codepoints($doi_sequence[1])"/>
                </xsl:when>
                <xsl:when test="count($uri_sequence) > 0">
                    <xsl:value-of select="fn:string-to-codepoints($uri_sequence[1])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space($node/dc:title)) > 0">
                            <xsl:value-of select="fn:string-to-codepoints(translate($node/dc:title, ' ', ''))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="generate-id($node)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:value-of select="substring($buffer, string-length($buffer)-40+1, 40)"/>
        
    </xsl:function>
    
    
    <xsl:function name="custom:getName">
        <xsl:param name="node" as="node()"/>
        <xsl:variable name="name_sequence" as="xs:string*">
            <xsl:for-each select="$node/strong">
                <xsl:if test="string-length(normalize-space(.)) > 0">
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="fn:string-join($name_sequence, ' ')"/>
    </xsl:function>
    
   <xsl:template match="node() | text() | @*"/>

</xsl:stylesheet>
