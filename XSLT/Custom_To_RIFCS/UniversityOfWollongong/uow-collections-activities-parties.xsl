<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:gmx="http://www.isotc211.org/2005/gmx" 
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" exclude-result-prefixes="dc">
    
    <xsl:strip-space elements="*"/>
    
    <xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/>
    
    <xsl:param name="global_originatingSource" select="'University of Wollongong'"/>
    <xsl:param name="global_baseURI" select="'ro.uow.edu.au'"/>
    <xsl:param name="global_group" select="'University of Wollongong'"/>
    <xsl:param name="global_publisherName" select="'University of Wollongong'"/>

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
            <xsl:apply-templates select="//oai:record/oai:metadata/*:document-export/*:documents/*:document" mode="collection"/>
            <xsl:apply-templates select="//oai:record/oai:metadata/*:document-export/*:documents/*:document" mode="activity"/>
            <xsl:apply-templates select="//oai:record/oai:metadata/*:document-export/*:documents/*:document" mode="party"/>
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="document" mode="collection">
        
        <xsl:variable name="class" select="'collection'"/>
        <xsl:variable name="type" select="'dataset'"/>
        
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            
            <xsl:apply-templates select="fields/field[@name='uow_key']"/>
            
            <xsl:apply-templates select=".">
                <xsl:with-param name="default" select="$global_originatingSource"/>
            </xsl:apply-templates>
            
            
            <xsl:element name="{$class}">
                
                <xsl:attribute name="type" select="$type"/>
                
                <xsl:apply-templates select="fields/field[@name='persistent_identifier']/value[string-length(text()) > 0]" mode="identifier"/>
               
                <xsl:apply-templates select="fields/field[@name='doi']/value[string-length(text()) > 0]" mode="identifier"/>
                
                <xsl:choose>
                    <xsl:when test="fields/field[@name='doi']/value[string-length(text()) > 0]">
                        <xsl:apply-templates select="fields/field[@name='doi']/value[string-length(text()) > 0]" mode="location"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="fields/field[@name='persistent_identifier']/value[string-length(text()) > 0]" mode="location"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                
               <xsl:apply-templates select="title[string-length(.) > 0]"/>
                
                <xsl:apply-templates select="keywords/keyword[string-length(.) > 0]"/>
                
                <xsl:apply-templates select="disciplines/discipline[string-length(.) > 0]"/>
                
                <xsl:apply-templates select="fields/field[(@name='for')]/value[string-length(.) > 0]"/>
                
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
                        <xsl:if test="string-length(gml:remarks)">
                            <xsl:if test="contains($licenseLink, gml:remarks)">
                                <rights>
                                    <licence>
                                        <xsl:attribute name="type" select="gml:identifier"/>
                                        <xsl:attribute name="rightsUri" select="$licenseLink"/>
                                        <xsl:if test="string-length(gml:name)">
                                            <xsl:value-of select="gml:name"/>
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
   
    
   <!-- Templates -->
    
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
    
    
    <xsl:template match="document" mode="funding_party">
        
        <xsl:if test="string-length(.) > 0">
        
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
                            <xsl:value-of select="."/>
                        </namePart>
                    </name>
                </activity>
            </registryObject>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template match="document" mode="party">
        
        <xsl:for-each select="authors/author">
            
            <xsl:variable name="firstName" select="fname"/>
            <xsl:variable name="lastName" select="lname"/>
            
            <xsl:variable name="nameFormatted" select="concat($firstName, ' ', $lastName)"/>
            
            <xsl:variable name="key" select="custom:formatKey($nameFormatted)"/>
            
            <xsl:variable name="class" select="'party'"/>
            <xsl:variable name="type" select="'person'"/>
            
            <registryObject>
                <xsl:attribute name="group"><xsl:value-of select="$global_group"/></xsl:attribute>
                <key>
                    <xsl:value-of select="custom:formatKey($nameFormatted)"/>
                </key>
                <originatingSource><xsl:value-of select="$global_originatingSource"/></originatingSource>
                <xsl:element name="{$class}">
                    
                    <xsl:attribute name="type" select="$type"/>
                    
                    <xsl:variable name="htmlFormatted">
                        <xsl:variable name="html" select="../../fields/field[@name='comments']/value[contains(text(), '&lt;')]"/>
                        <xsl:if test="string-length($html)> 0">
                            <xsl:value-of select="fn:replace(fn:replace(fn:replace($html, '&lt;br /&gt;' , ''), '&lt;br/&gt;' , ''), '&amp;', '&amp;amp;')"/>
                        </xsl:if>
                    </xsl:variable>
                    
                    <xsl:if test="string-length($htmlFormatted) > 0">
                        <xsl:message select="concat('$htmlFormatted :', $htmlFormatted)"/>
                    </xsl:if>
                    
                    
                    <name type="primary">
                        <xsl:if test="string-length($firstName)> 0">
                            <namePart type="given">
                                <xsl:value-of select="$firstName"/>
                            </namePart> 
                        </xsl:if>
                        <xsl:if test="string-length($lastName)> 0">
                            <namePart type="family">
                                <xsl:value-of select="$lastName"/>
                            </namePart> 
                        </xsl:if>
                    </name>
                    
                    <xsl:if test="string-length(email)> 0">
                        <location>
                            <address>
                                <electronic type="email">
                                    <value>
                                        <xsl:value-of select="email"/>
                                    </value>
                                </electronic>
                                 </address>
                        </location>
                    </xsl:if>
                    
                    <xsl:if test="string-length(institution) > 0">
                        <xsl:variable name="institutionID_TypeValuePair" select="custom:getId_TypeValuePair(institution)"/>
                        <xsl:if test="count($institutionID_TypeValuePair) = 2">
                            <relatedInfo type="party">
                                <title><xsl:value-of select="institution"/></title>
                                <identifier type="{$institutionID_TypeValuePair[1]}">
                                    <xsl:value-of select="$institutionID_TypeValuePair[2]"/>
                                </identifier>
                                <relation type="isMemberOf"/>
                            </relatedInfo>
                        </xsl:if>
                    </xsl:if>
                </xsl:element>
            </registryObject>
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template match="fields/field[@name='uow_key']">
        <key>
            <xsl:value-of select="."/>
        </key>
    </xsl:template>
    
    <xsl:template match="document">
        <xsl:param name="default"/>
        <xsl:variable name="value">
            <xsl:choose>
                <xsl:when test="string-length(fields/field[@name='source_publication']) > 0">
                    <xsl:value-of select="fields/field[@name='source_publication']"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$default"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
       
        <originatingSource>
            <xsl:value-of select="$value"/>
        </originatingSource>
    </xsl:template>
    
    <xsl:template match="fields/field[@name='doi']/value[string-length(text()) > 0]" mode="identifier">
        <xsl:choose>
            <xsl:when test="not(contains(lower-case(.), 'doi')) and (substring(., 1) castable as xs:integer)">
                <identifier type="doi">
                    <xsl:value-of select="concat('http://doi.org/', .)"/>
                </identifier>
            </xsl:when>
            <xsl:otherwise>
                <identifier type="doi">
                    <xsl:value-of select="."/>
                </identifier>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="fields/field[@name='persistent_identifier']/value[string-length(text()) > 0]" mode="identifier">
        <xsl:analyze-string select="." regex="href=&quot;(http.+?)&quot;">
            <xsl:matching-substring>
                <xsl:variable name="identifierType" select="custom:identifierType(regex-group(1))"/>
                <identifier type="{$identifierType}">
                    <xsl:value-of select="regex-group(1)"/>
                </identifier>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="fields/field[@name='doi']/value[string-length(text()) > 0]" mode="location">
        <xsl:message select="concat('current doi: ', .)"/>
        <xsl:choose>
            <xsl:when test="not(contains(lower-case(.), 'doi')) and (substring(., 1) castable as xs:integer)">
                <location>
                    <address>
                        <electronic type='doi'>
                            <xsl:value-of select="concat('http://doi.org/', .)"/>
                        </electronic>
                    </address>
                </location> 
            </xsl:when>
            <xsl:otherwise>
                <location>
                    <address>
                        <electronic type='doi'>
                            <xsl:value-of select="."/>
                        </electronic>
                    </address>
                </location> 
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="fields/field[@name='persistent_identifier']/value[string-length(text()) > 0]" mode="location">
        <xsl:variable name="doi" select="../../field[@name='doi']/value[string-length(text()) > 0]"/>
       
        <xsl:message select="concat('current pid: ', .)"/>
        <xsl:analyze-string select="." regex="href=&quot;(http.+?)&quot;">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test="contains(regex-group(1), 'doi')">
                        <location>
                            <address>
                                <electronic type='doi'>
                                    <xsl:value-of select="regex-group(1)"/>
                                </electronic>
                            </address>
                        </location>
                    </xsl:when>
                    <xsl:when test="contains(regex-group(1), 'handle.net')">
                        <location>
                            <address>
                                <electronic type='handle'>
                                    <xsl:value-of select="regex-group(1)"/>
                                </electronic>
                            </address>
                        </location>
                    </xsl:when>
                    <xsl:when test="contains(regex-group(1), 'http')">
                        <location>
                            <address>
                                <electronic type='uri'>
                                    <xsl:value-of select="regex-group(1)"/>
                                </electronic>
                            </address>
                        </location>
                    </xsl:when>
                </xsl:choose>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="title">
        <name type="primary">
            <namePart>
                <xsl:value-of select="."/>
            </namePart>
        </name>
    </xsl:template>
    
    <xsl:template match="keyword">
        <subject type="keyword">
            <xsl:value-of select="."/>
        </subject>
    </xsl:template>
    
    <xsl:template match="discipline">
        <subject type="discipline">
            <xsl:value-of select="."/>
        </subject>
    </xsl:template>
    
    <xsl:template match="fields/field[(@name='for')]/value[string-length(.) > 0]">
        <xsl:variable name="forCode" select="tokenize(., ' ')[1]"/>
        <xsl:if test="(string-length($forCode) > 0) and ($forCode castable as xs:integer)">
            <subject type="anzsrc-for">
                <xsl:value-of select="$forCode"/>
            </subject>
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
    
    
    
    <!--xsl:function name="custom:getIdentifiersForName_sequence" as="xs:string*">
        <xsl:param name="soughtName" as="xs:string"/>
        <xsl:param name="html" as="xs:string"/>
        
        <xsl:if test="string-length($html) > 0">
            <xsl:variable name="unescapedContent" select="saxon:parse(concat('&lt;root&gt;', $html, '&lt;/root&gt;'))" as="document-node()*"/>
            <xsl:if test="count($unescapedContent) > 0">
                <xsl:message select="concat('unescapedContent ', $unescapedContent)"/>
                <xsl:variable name="namePosition_sequence" as="xs:integer*">
                    <xsl:for-each select="$unescapedContent/root/p">
                        <xsl:variable name="personPosition" select="position()" as="xs:integer"/>
                        <xsl:if test="count(strong) > 0">
                            <xsl:value-of select="$personPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                
                <xsl:for-each select="$namePosition_sequence">
                    <xsl:message select="concat('$namePosition_sequence entry: ', ., ' at position: ', position())"/>
                </xsl:for-each>
                   
                <xsl:variable name="currentPersonPositionRange_sequence" as="xs:integer*">
                     <xsl:for-each select="$unescapedContent/root/p">
                         <xsl:variable name="currentPPosition" select="position()"  as="xs:integer"/>
                         <xsl:variable name="lastPPosition" select="last()"  as="xs:integer"/>
                         <xsl:variable name="currentName" select="custom:getName(.)"/>
                         <xsl:if test="string-length($currentName) > 0">
                             <xsl:if test="string-length(.) > 0 and (contains(., ' ') or contains(., ','))">
                                 
                                 <xsl:if test="boolean(custom:nameMatch($soughtName, $currentName)) = true()">
                                     <xsl:message select="concat('Match! - ', $soughtName)"/>
                                         
                                         <xsl:copy-of select="$currentPPosition"/>
                                         <xsl:for-each select="distinct-values($namePosition_sequence)">
                                             <xsl:variable name="iterPersonPosition" select="." as="xs:integer"/>
                                             <xsl:variable name="posInt" select="position()" as="xs:integer"/>
                                             <xsl:message select="concat('iterPersonPosition: ', $iterPersonPosition)"/>
                                             <xsl:message select="concat('$posInt: ', number($posInt))"/>
                                             <xsl:if test="number($iterPersonPosition) = number($currentPPosition)">
                                                 <xsl:choose>
                                                     <xsl:when test="count($namePosition_sequence) > $posInt">
                                                         <xsl:message select="concat('Returning $namePosition_sequence[number($posInt)+1]: ', $namePosition_sequence[number($posInt)+1])"/>
                                                         <xsl:copy-of select="$namePosition_sequence[number($posInt)+1]"/>
                                                     </xsl:when>
                                                     <xsl:otherwise>
                                                         <xsl:message select="concat('Returning $lastPPosition + 1: ', $lastPPosition + 1)"/>
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
                            
                            <xsl:message select="concat('$currentPPosition: ', $currentPPosition)"/>
                            <xsl:if test="string-length(a/@href) > 0">
                                <xsl:message select="concat('a/@href: ', a/@href)"/>
                                <xsl:value-of select="a/@href"/>
                            </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
            </xsl:if>
        </xsl:if>
     </xsl:function-->
    

    <!--xsl:function name="custom:getOrganisationForName_sequence" as="xs:string*">
        <xsl:param name="soughtName" as="xs:string"/>
        <xsl:param name="html" as="node()"/>
        
        <xsl:message select="concat('html: ', $html)"/>
        
        <xsl:if test="string-length($html) > 0">
            <xsl:variable name="unescapedContent" select="saxon:parse(concat('&lt;root&gt;', $html, '&lt;/root&gt;'))" as="document-node()*"/>
            <xsl:if test="count($unescapedContent) > 0">
                <xsl:message select="concat('unescapedContent ', $unescapedContent)"/>
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
    </xsl:function-->
    
    <!--xsl:function name="custom:formatName">
        <xsl:param name="name"/>
        <xsl:choose>
            <xsl:when test="contains($name, ', ')">
                <xsl:value-of select="concat(substring-after($name, ','), ' ', substring-before($name, ','))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function-->
    
    <!--xsl:function name="custom:nameMatch" as="xs:boolean">
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
    </xsl:function-->
    
    <xsl:function name="custom:formatKey">
        <xsl:param name="input"/>
        <xsl:variable name="raw" select="translate($input, ' ', '')"/>
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
    
    <xsl:function name="custom:getId_TypeValuePair" as="xs:string*">
        <xsl:param name="name" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="lower-case($name) = 'university of wollongong'">
                <xsl:text>AU-ANL:PEAU</xsl:text>
                <xsl:text>http://nla.gov.au/nla.party-464691</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <!--xsl:function name="custom:getName">
        <xsl:param name="node" as="node()"/>
        <xsl:variable name="name_sequence" as="xs:string*">
            <xsl:for-each select="$node/strong">
                <xsl:if test="string-length(.) > 0">
                    <xsl:value-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="fn:string-join($name_sequence, ' ')"/>
    </xsl:function-->
    
   <xsl:template match="node() | text() | @*"/>

</xsl:stylesheet>
