<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx" 
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:custom="http://custom.nowhere.yet"
    version="2.0" exclude-result-prefixes="dc">
    
    <xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/>
    
    <xsl:param name="global_originatingSource" select="'Southern Cross University'"/>
    <xsl:param name="global_baseURI" select="'epubs.scu.edu.au'"/>
    <xsl:param name="global_group" select="'Southern Cross University'"/>
    <xsl:param name="global_publisherName" select="'Southern Cross University'"/>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects 
            http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
          
            <xsl:apply-templates select="oai:OAI-PMH/*/oai:record"/>
            
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="oai:OAI-PMH/*/oai:record">
         <xsl:variable name="oai_identifier" select="oai:header/oai:identifier"/>
         <xsl:message select="concat('identifier: ', oai:header/oai:identifier)"/>
         <xsl:if test="string-length($oai_identifier) > 0">
             
             <xsl:if test="count(oai:metadata/oai_dc:dc) > 0">
                 <xsl:apply-templates select="oai:metadata/oai_dc:dc" mode="collection">
                     <xsl:with-param name="oai_identifier" select="$oai_identifier"/>
                 </xsl:apply-templates>
                 
                 <xsl:variable name="nameIdentifier_sequence" as="xs:string*" select="custom:getNameIdentifier_sequence(oai:metadata/oai_dc:dc)"/>
                 <xsl:message select="concat('count nameIdentifier_sequence: ', count($nameIdentifier_sequence))"/>
                 <xsl:for-each select="$nameIdentifier_sequence">
                     <xsl:message select="concat('nameIdentifier_sequence entry: ', .)"/>
                 </xsl:for-each>
                 
                 <xsl:variable name="nameIndex_sequence" select="custom:getNameIndex_sequence($nameIdentifier_sequence)"  as="xs:integer*"/>
                 <xsl:for-each select="$nameIndex_sequence">
                     <xsl:message select="concat('nameIndex_sequence entry: ', .)"/>
                 </xsl:for-each>
                 
                 
                 <xsl:apply-templates select="oai:metadata/oai_dc:dc" mode="party">
                     <xsl:with-param name="nameIndex_sequence" select="$nameIndex_sequence" as="xs:integer*"/>
                     <xsl:with-param name="nameIdentifier_sequence" select="$nameIdentifier_sequence" as="xs:string*"/>
                 </xsl:apply-templates>
                 
             </xsl:if>
         </xsl:if>
    </xsl:template>
    
    <xsl:template match="oai_dc:dc" mode="collection">
        <xsl:param name="oai_identifier"/>
        
        <xsl:variable name="class" select="'collection'"/>
        <xsl:variable name="type" select="dc:type"/>
        
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <key>
                <xsl:value-of select="$oai_identifier"/>
            </key>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            <xsl:element name="{$class}">
                
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="$type = 'Data'">
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
                        <xsl:variable name="identifierAllContent" select="."/>
                        <xsl:if test="(string-length($identifierAllContent) > 0) and 
                            not(boolean(contains($identifierAllContent, ' '))) and 
                            contains($identifierAllContent, 'doi')">
                            <xsl:value-of select="$identifierAllContent"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
        
                <!-- identifier -->
                <xsl:for-each select="dc:identifier">
                    <xsl:variable name="identifierAllContent" select="."/>
                    <xsl:variable name="identifierExtracted_sequence" as="xs:string*">
                        <xsl:choose>
                            <xsl:when test="contains(lower-case($identifierAllContent), 'http') and
                                not(boolean(contains($identifierAllContent, ' ')))">
                                <xsl:analyze-string select="normalize-space($identifierAllContent)"
                                    regex="(http|https):[^&quot;]*">
                                    <xsl:matching-substring>
                                        <xsl:value-of select="regex-group(0)"/>
                                    </xsl:matching-substring>
                                </xsl:analyze-string>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$identifierAllContent"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <!--xsl:message select="concat('identifierAllContent: ', $identifierAllContent)"></xsl:message-->
                    <!--xsl:for-each select="distinct-values($identifierExtracted_sequence)">
                        <xsl:message select="concat('identifierExtracted: ', .)"></xsl:message>
                    </xsl:for-each-->
                    <xsl:for-each select="distinct-values($identifierExtracted_sequence)">
                        <xsl:if test="
                            contains(., $global_baseURI) or
                            contains(., 'doi')">
                                 <xsl:variable name="identifierType" select="custom:identifierType(.)"></xsl:variable>
                                 <xsl:if test="string-length(.) > 0">
                                      <identifier type="{$identifierType}">
                                          <xsl:value-of select="."/>
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
                                <electronic type="doi" target="landingPage">
                                    <value>
                                        <xsl:value-of select="$doiOfThisPackage"/>
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
                                <xsl:value-of select="concat($global_baseURI, '/', translate(normalize-space(.), ' ', ''))"/>
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
                                <xsl:value-of select="concat($global_baseURI, '/', translate(normalize-space(.), ' ', ''))"/>
                            </key>
                            <relation type="isEnrichedBy"/>
                        </relatedObject>
                    </xsl:if>
                </xsl:for-each>
                
                <xsl:for-each select="dc:funding">
                    <xsl:if test="string-length(.) > 0">
                        <relatedObject>
                            <key>
                                <xsl:value-of select="concat($global_baseURI, '/', translate(normalize-space(.), ' ', ''))"/>
                            </key>
                            <relation type="isFundedBy"/>
                            
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
                <xsl:if test="string-length(dc:description.abstract) > 0">
                    <description type="full">
                        <xsl:value-of select="dc:description.abstract"/>
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
                                    <date type="{$type}" dateFormat="W3CDTF">
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
                    <xsl:with-param name="dcType" select="'available'"/>
                </xsl:call-template>  
                
                <xsl:call-template name="dates">
                    <xsl:with-param name="dcType" select="'created'"/>
                </xsl:call-template>  
                
                <xsl:call-template name="dates">
                    <xsl:with-param name="dcType" select="'dateAccepted'"/>
                </xsl:call-template>  
                
                <xsl:call-template name="dates">
                    <xsl:with-param name="dcType" select="'dateSubmitted'"/>
                </xsl:call-template>  
                
                <xsl:call-template name="dates">
                    <xsl:with-param name="dcType" select="'issued'"/>
                </xsl:call-template>    
                
                <xsl:call-template name="dates">
                    <xsl:with-param name="dcType" select="'valid'"/>
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
            <xsl:when test="contains(lower-case($identifier), 'doi')">
                <xsl:text>doi</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>uri</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template name="dates">
        <xsl:param name="dcType"/>
        <xsl:for-each select="*[contains(name(), $dcType)]">
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
                    <xsl:variable name="dcType" select="substring-after(name(.), 'dc:date.')"/>
                    <dates type="{$dcType}">
                        <date type="{$type}" dateFormat="W3CDTF">
                            <xsl:value-of select="."/>
                        </date>
                    </dates>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="oai_dc:dc" mode="party">
        <xsl:param name="nameIndex_sequence" as="xs:integer*"/>
        <xsl:param name="nameIdentifier_sequence" as="xs:string*"/>
        
        <xsl:for-each select="dc:creator|dc:author|dc:funding">
            <xsl:if test="string-length(normalize-space(.)) > 0"></xsl:if>
            
            <xsl:variable name="key" select="translate(normalize-space(.), ' ', '')"/>
            
            <xsl:variable name="objectType_sequence" as="xs:string*">
                <xsl:choose>
                    <xsl:when test="contains(name(), 'funding')">
                        <xsl:text>activity</xsl:text>
                        <xsl:text>grant</xsl:text>
                    </xsl:when>
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
            
            <xsl:if test="string-length($key) > 0">
                 <registryObject group="{$global_group}">
                     <key>
                         <xsl:value-of select="concat($global_baseURI, '/', $key)"/>
                     </key>
                     <originatingSource>
                         <xsl:value-of select="$global_originatingSource"/>
                     </originatingSource>
                     
                     <xsl:element name="{$object}">
                         <xsl:attribute name="type" select="$type"/>
                         <xsl:variable name="identifier_sequence" select="custom:getIdentifiersForName_sequence(normalize-space(.), $nameIndex_sequence, $nameIdentifier_sequence)"/>
                         <xsl:message select="concat('count(identifier_sequence): ', count($identifier_sequence))"/>
                         <xsl:for-each select="distinct-values($identifier_sequence)">
                             <xsl:if test="string-length(normalize-space(.)) > 0">
                                <identifier type="{custom:identifierType(.)}">
                                    <xsl:value-of select="."/>
                                    <xsl:message select="concat('identifier: ', .)"/>
                                </identifier>
                             </xsl:if>
                         </xsl:for-each>
                         <name type="primary">
                             <namePart>
                                <xsl:value-of select="."/>
                             </namePart>
                         </name>
                     </xsl:element>
                 </registryObject>
             </xsl:if>
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:function name="custom:getIdentifiersForName_sequence" as="xs:string*">
        <xsl:param name="name"/>
        <xsl:param name="nameIndex_sequence" as="xs:integer*"/>
        <xsl:param name="nameIdentifiers_sequence" as="xs:string*"/>
        
        <xsl:message select="concat('name: ', $name)"/>
         
        <xsl:variable name="formattedNameSeeking" select="custom:formatName($name)"/>
       
        <xsl:if test="string-length($formattedNameSeeking) > 0">
            <xsl:message select="concat('Seeking identifiers for: ', $formattedNameSeeking)"/>
       
            <xsl:for-each select="$nameIndex_sequence">
                <xsl:variable name="curPos" select="position()" as="xs:integer"/>
                <xsl:variable name="curNameIndex" select="." as="xs:integer"/>
                <xsl:variable name="nextNameIndex" as="xs:integer">
                    <xsl:choose>
                        <xsl:when test="count($nameIndex_sequence) > $curPos">
                            <xsl:value-of select="xs:integer($nameIndex_sequence[$curPos+1])"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="xs:integer(count($nameIdentifiers_sequence))+1"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:message select="concat('currentName ', $nameIdentifiers_sequence[$curNameIndex])"/>
                <xsl:if test="
                    (tokenize($formattedNameSeeking, ' ')[1] = tokenize($nameIdentifiers_sequence[$curNameIndex], ' ')[1]) and
                    (tokenize($formattedNameSeeking, ' ')[last()] = tokenize($nameIdentifiers_sequence[$curNameIndex], ' ')[last()])">
                    <xsl:message select="concat('Found matching currentName: ', $nameIdentifiers_sequence[$curNameIndex])"/>
                    <xsl:for-each select="$nameIdentifiers_sequence">
                        <xsl:variable name="curPos" select="position()" as="xs:integer"/>
                        <xsl:if test="($curPos &gt; $curNameIndex) and ($curPos &lt; $nextNameIndex)">
                            <xsl:copy-of select="."/>
                        </xsl:if>
                        
                    </xsl:for-each>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="custom:formatName">
        <xsl:param name="name"/>
        <xsl:if test="contains($name, ', ')">
                <xsl:choose>
                    <xsl:when test="contains($name, ', ')">
                        <xsl:value-of select="concat(substring-after($name, ', '), ' ', substring-before($name, ', '))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$name"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
    </xsl:function>
    
    <xsl:function name="custom:getNameIdentifier_sequence" as="xs:string*">
        <xsl:param name="dc" as="node()"/>
        
        <xsl:variable name="htmlAllIdentifiers">
            <xsl:for-each select="$dc/dc:identifier">
                <xsl:message select="concat('dc:identifier: ', .)"/>
                <xsl:variable name="identifierAllContent" select="."/>
                <xsl:if test="contains(., '&lt;')">
                    <xsl:value-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:message select="concat('htmlAllIdentifiers: ', $htmlAllIdentifiers)"/>
        
        <xsl:variable name="content_sequence" as="xs:string*" select="tokenize($htmlAllIdentifiers, '&gt;')"/>
        
         <xsl:message select="concat('Name count: ', count($content_sequence))"/>
         <xsl:for-each select="$content_sequence">
             <xsl:variable name="content">
                 <xsl:choose>
                     <xsl:when test="contains(., 'http')">
                         <xsl:analyze-string select="normalize-space(.)"
                             regex="(http|https):[^&quot;]*">
                             <xsl:matching-substring>
                                 <xsl:value-of select="regex-group(0)"/>
                             </xsl:matching-substring>
                         </xsl:analyze-string>
                     </xsl:when>
                     <xsl:otherwise>
                         <!-- Depending on there being a space to determine whether it's a name -->
                         <xsl:if test="contains(., ' ')"> 
                             <xsl:value-of select="normalize-space(substring-before(., '&lt;'))"/>
                         </xsl:if>
                     </xsl:otherwise>
                 </xsl:choose>
             </xsl:variable> 
             <xsl:if test="string-length($content) > 0">
                 <xsl:copy-of select="$content"/>   
             </xsl:if>
         </xsl:for-each>
    </xsl:function>
    
    <!--Return the index where a name is found within the sequence.  Items after the name
        will be the person's identifier, until there is a name again, so, for the following:
        
        Nicholas Ward
        http://orcid.org/0000-0003-1862-5685
        http://www.scopus.com/authid/detail.url?authorId=35509516000
        Annabelle Keene
        http://www.scopus.com/authid/detail.url?authorId=6701782346
        
        ... a sequence containing numbers 1 and 4 will be returned
    -->
    
    <xsl:function name="custom:getNameIndex_sequence"  as="xs:integer*">
        <xsl:param name="nameIdentifiers_sequence" as="xs:string*"/>
        
        <xsl:for-each select="distinct-values($nameIdentifiers_sequence)">
            <xsl:if test="contains(., ' ')">
                <xsl:variable name="curPos" select="position()" as="xs:integer" />
                <xsl:copy-of select="$curPos"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
   <xsl:template match="node() | text() | @*"/>

</xsl:stylesheet>
