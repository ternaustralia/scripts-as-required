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
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
            <xsl:apply-templates select="//oai:record" mode="collection"/>
        </registryObjects>
    </xsl:template>

   
    <xsl:template match="oai:record" mode="collection">
        <xsl:variable name="key" select="oai:header/oai:identifier"/>
        <xsl:variable name="class" select="'collection'"/>
        <xsl:variable name="type" select="oai:metadata/oai_dc:dc/dc:type"/>
        
        <xsl:if test="string-length($key) > 0">
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
                            <xsl:when test="$type = 'Data'">
                                <xsl:text>dataset</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$type"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
    
                    <xsl:apply-templates select="oai:metadata/oai_dc:dc" mode="collection"/>
                </xsl:element>
            </registryObject>
            
            
            <xsl:apply-templates select="oai:metadata/oai_dc:dc" mode="party"/>
            
        </xsl:if>
    </xsl:template>



    <xsl:template match="oai_dc:dc" mode="collection">
        
        <!-- identifier -->
        <xsl:for-each select="dc:identifier">
            <xsl:variable name="identifierAllContent" select="."/>
            <xsl:variable name="identifierExtracted_sequence" as="xs:string*">
                <xsl:choose>
                    <xsl:when test="contains(lower-case($identifierAllContent), 'http')">
                        <xsl:analyze-string select="normalize-space($identifierAllContent)"
                            regex="http:[^&quot;]*">
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
            <xsl:message select="concat('identifierAllContent: ', $identifierAllContent)"></xsl:message>
            <xsl:for-each select="distinct-values($identifierExtracted_sequence)">
                <xsl:message select="concat('identifierExtracted: ', .)"></xsl:message>
            </xsl:for-each>
            <xsl:for-each select="distinct-values($identifierExtracted_sequence)">
                <xsl:variable name="identifierType" select="custom:identifierType(.)"></xsl:variable>
                <xsl:if test="string-length(.) > 0">
                     <identifier type="{$identifierType}">
                         <xsl:value-of select="."/>
                     </identifier>
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
        
       <!-- subject -->
        <xsl:for-each select="dc:subject">
            <xsl:if test="string-length(.) > 0">
                <subject type="local">
                    <xsl:value-of select="."/>
                </subject>
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
        <xsl:if test="string-length(dc:rights.license) > 0">
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
        
       <!-- citationInfo -->
        <xsl:if test="string-length(dc:identifier.bibliographicCitation)">
            <citationInfo>
                <fullCitation>
                    <xsl:value-of select="dc:identifier.bibliographicCitation"/>
                </fullCitation>
            </citationInfo>
        </xsl:if>
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
                <xsl:message select="concat('Node name:', name())"/>
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
        <xsl:for-each select="dc:creator">
            <xsl:if test="string-length(normalize-space(.)) > 0"></xsl:if>
            
            <xsl:variable name="key" select="translate(normalize-space(.), ' ', '')"/>
            
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
    
    
    
    
    

    <xsl:template match="node() | text() | @*"/>

</xsl:stylesheet>
