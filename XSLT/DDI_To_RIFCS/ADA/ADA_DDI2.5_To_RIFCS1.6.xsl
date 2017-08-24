<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:ddi="http://www.icpsr.umich.edu/DDI" 
    xmlns:oai_ddi="https://dataverse-test.ada.edu.au/oai"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:localFunc="http://www.localfunc.net"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:local="http://local.to.here"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    exclude-result-prefixes="saxon local xs oai ddi oai_ddi custom fn localFunc">
    
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'Australian Data Archive'"/>
    <xsl:param name="global_baseURI" select="'www.ada.edu.au'"/>
    <xsl:param name="global_group" select="'Australian Data Archive'"/>
    <xsl:param name="global_publisherName" select="'Australian Data Archive'"/>
    <xsl:param name="global_baseURL" select="'https://www.ada.edu.au/ada/'"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="/">
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="//*:codeBook" mode="collection"/>
            <!--xsl:apply-templates select="." mode="activity"/-->
            <xsl:apply-templates select="//*:codeBook/*:stdyDscr/*:citation/*:rspStmt/*:AuthEnty[(string-length(.) > 0)]" mode="party_author"/>
            <xsl:apply-templates select="//*:codeBook/*:docDscr/*:citation/*:prodStmt/*:producer[(string-length(.) > 0)]" mode="party_producer"/>
            <xsl:apply-templates select="//*:codeBook/*:stdyDscr/*:citation/*:rspStmt/*:AuthEnty/@affiliation[(string-length(.) > 0)]" mode="party_organisation"/>
                
        </registryObjects>
    </xsl:template>
    
   <xsl:template match="*:codeBook" mode="collection">
        <xsl:message select="concat('match', 'codeBook')"/>
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <key>
                <xsl:value-of select="custom:registryObjectKeyFromString(*:stdyDscr/*:citation/*:titlStmt/*:IDNo)"/>
            </key>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource> 
                
            <collection>
                <xsl:attribute name="type" select="'dataset'"/>
                <xsl:attribute name="dateAccessioned" select="*:stdyDscr/*:citation/*:distStmt/*:depDate/@date[(string-length(.) > 0)]"/>
                <xsl:apply-templates select="*:stdyDscr/*:citation/*:titlStmt/*:IDNo[(string-length(.) > 0)]" mode="registryObject_identifier"/>
                <xsl:apply-templates select="*:stdyDscr/*:citation/*:titlStmt/*:titl[(string-length(.) > 0)]" mode="registryObject_name"/>
                <xsl:apply-templates select="*:stdyDscr/*:citation/*:titlStmt/*:IDNo[(string-length(.) > 0)]" mode="registryObject_location"/>
                <xsl:apply-templates select="*:stdyDscr/*:stdyInfo/*:subject/*:keyword[(string-length(.) > 0)]" mode="registryObject_subject"/>
                <xsl:apply-templates select="*:stdyDscr/*:stdyInfo/*:abstract[(string-length(.) > 0)]" mode="registryObject_description"/>
                <xsl:apply-templates select="*:stdyDscr/*:stdyInfo/*:sumDscr" mode="registryObject_coverage"/>
                <xsl:apply-templates select="*:stdyDscr/*:othrStdyMat/*:relPubl" mode="registryObject_relatedInfo"/>
                <xsl:apply-templates select="*:stdyDscr/*:citation/*:rspStmt/*:AuthEnty[(string-length(.) > 0)]" mode="registryObject_relatedObject"/>
                <xsl:apply-templates select="*:docDscr/*:citation/*:prodStmt/*:producer[(string-length(.) > 0)]" mode="registryObject_relatedObject"/>
                <xsl:apply-templates select="*:stdyDscr/*:citation/*:titlStmt/*:altTitl[(string-length(.) > 0)]" mode="registryObject_altname"/>
                <xsl:apply-templates select="*:stdyDscr/*:citation/*:prodStmt/*:copyright" mode="registryObject_rights_statement"/>
                <xsl:apply-templates select="*:stdyDscr/*:dataAccs/*:useStmt" mode="registryObject_rights_access"/>
                
                <xsl:apply-templates select="." mode="registryObject_citationInfo"/>
                
                <xsl:apply-templates select="*:stdyDscr/*:citation/*:distStmt/*:depDate/@date[(string-length(.) > 0)]" mode="registryObject_dates_accepted"/>
                <xsl:apply-templates select="*:stdyDscr/*:citation/*:distStmt/*:distDate/@date[(string-length(.) > 0)]" mode="registryObject_dates_available"/>
            </collection>
        </registryObject>
    </xsl:template>
    
    <xsl:template match="*:codeBook" mode="activity">
    </xsl:template>
    
    <xsl:template match="*:codeBook" mode="party">
    </xsl:template>
    
    <xsl:template match="*:IDNo" mode="registryObject_location">
        <location>
            <address>
                 <electronic type="url">
                    <value>
                        <xsl:choose>
                            <xsl:when test="contains(., 'au.edu.anu.ada.ddi.')">
                                <xsl:value-of select="concat($global_baseURL, substring-after(normalize-space(.), 'au.edu.anu.ada.ddi.'))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="contains(lower-case(.), 'doi:')">
                                        <xsl:value-of select="concat('http://doi.org/', substring-after(., 'doi:'))"/>
                                     </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </xsl:otherwise>
                                  </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </value> 
                </electronic>
            </address>
        </location>
     </xsl:template>
    
   <xsl:template match="*:keyword" mode="registryObject_subject">
        <subject>
            <xsl:choose>
                <xsl:when test="string-length(@vocab) > 0">
                    <xsl:attribute name="type" select="@vocab"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="type" select="'local'"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <xsl:if test="string-length(@vocabURI) > 0">
                <xsl:attribute name="termIdentifier" select="@vocabURI"/>
            </xsl:if>
            <xsl:value-of select="normalize-space(.)"/>
        </subject>
    </xsl:template>
    
    <xsl:template match="*:abstract" mode="registryObject_description">
        <description type="full">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <xsl:template match="*:sumDscr" mode="registryObject_coverage">
        <coverage>
            <!--xsl:apply-templates select="*:timePrd[(@event = 'start') and (string-length(@date) > 0)]" mode="registryObject_coverage_temporal_start"/-->
            <!--xsl:apply-templates select="*:timePrd[(@event = 'single') and (string-length(@date) > 0)]" mode="registryObject_coverage_temporal_single"/-->
            <xsl:apply-templates select="*:collDate[(@event = 'start') and (string-length(@date) > 0)]" mode="registryObject_coverage_temporal_start"/>
            <xsl:apply-templates select="*:collDate[(@event = 'single') and (string-length(@date) > 0)]" mode="registryObject_coverage_temporal_single"/>
            <xsl:apply-templates select="*:nation[string-length(.) > 0]" mode="registryObject_coverage_spatial"/>
            <xsl:apply-templates select="*:geogCover[string-length(.) > 0]" mode="registryObject_coverage_spatial"/>
            <xsl:apply-templates select="*:geogUnit[string-length(.) > 0]" mode="registryObject_coverage_spatial"/>
        </coverage>
    </xsl:template>
    
    <xsl:template match="*:relPubl" mode="registryObject_relatedInfo">
        <relatedInfo type="publication">
            <identifier type="uri">
                <xsl:value-of select="normalize-space(*:citation/*:holdings/@URI)"/>
            </identifier> 
            <title>
                <xsl:value-of select="normalize-space(*:citation/*:titlStmt/*:titl)"/>
            </title> 
            <relation type="isCitedBy"/>
            <notes>
                <xsl:value-of select="normalize-space(.)"/>
            </notes>
        </relatedInfo>
    </xsl:template>
    
    <!--xsl:template match="*:timePrd" mode="registryObject_coverage_temporal_start">
        <temporal>
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="normalize-space(@date)"/>
            </date>
            
            <xsl:if test="following-sibling::*:timePrd[@event = 'end'][1]/@date[string-length(.) > 0]">
                <date type="dateTo" dateFormat="W3CDTF">
                    <xsl:value-of select="normalize-space(following-sibling::*:timePrd[@event = 'end'][1]/@date)"/>
                </date>
            </xsl:if>
        </temporal>
    </xsl:template-->
    
    <!--xsl:template match="*:timePrd" mode="registryObject_coverage_temporal_single">
        <temporal>
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="normalize-space(@date)"/>
            </date>
            </temporal>
    </xsl:template-->
    
    <xsl:template match="*:collDate" mode="registryObject_coverage_temporal_start">
        <temporal>
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="normalize-space(@date)"/>
            </date>
            <xsl:if test="following-sibling::*:collDate[@event = 'end'][1]/@date[string-length(.) > 0]">
               <date type="dateTo" dateFormat="W3CDTF">
                   <xsl:value-of select="normalize-space(following-sibling::*:collDate[@event = 'end'][1]/@date)"/>
               </date>
            </xsl:if>
        </temporal>
    </xsl:template>
    
    <xsl:template match="*:collDate" mode="registryObject_coverage_temporal_single">
        <temporal>
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="normalize-space(@date)"/>
            </date>
          </temporal>
    </xsl:template>
    
    <xsl:template match="*:nation" mode="registryObject_coverage_spatial">
        <spatial type="text">
            <xsl:value-of select="normalize-space(.)"/>
        </spatial>
    </xsl:template>
    
    <xsl:template match="*:geogCover" mode="registryObject_coverage_spatial">
        <spatial type="text">
            <xsl:value-of select="normalize-space(.)"/>
        </spatial>
    </xsl:template>
    
    <xsl:template match="*:geogUnit" mode="registryObject_coverage_spatial">
        <spatial type="text">
            <xsl:value-of select="normalize-space(.)"/>
        </spatial>
    </xsl:template>
    
    
    <date type="dateTo" dateFormat="W3CDTF">2004-03-12T09:14:10.00Z</date>
    
    
    
    <xsl:template match="*:IDNo" mode="registryObject_identifier">
        <identifier type="{custom:getIdentifierType(.)}">
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="*:titl" mode="registryObject_name">
        <name type="primary">
            <namePart>
                <xsl:value-of select="normalize-space(.)"/>
            </namePart>
        </name>
    </xsl:template>
    
    <xsl:template match="*:AuthEnty" mode="registryObject_relatedObject">
        <xsl:message select="concat('AuthEnty for relatedObject: ', .)"/>
        <xsl:if test="string-length(.) > 0">
            <relatedObject>
                <key>
                   <xsl:value-of select="local:formatKey(.)"/> 
                </key>
                <relation type="hasCollector"/>
            </relatedObject>
        </xsl:if>   
    </xsl:template>
    
    <xsl:template match="*:producer" mode="registryObject_relatedObject">
        <xsl:message select="concat('producer for relatedObject: ', .)"/>
        <xsl:if test="string-length(.) > 0">
            <relatedObject>
                <key>
                   <xsl:value-of select="local:formatKey(.)"/> 
                </key>
                <relation type="isOwnedBy"/>
            </relatedObject>
        </xsl:if>   
    </xsl:template>
    
    <xsl:template match="*:titl" mode="registryObject_altname">
        <name type="alternative">
            <namePart>
                <xsl:value-of select="normalize-space(.)"/>
            </namePart>
        </name>
    </xsl:template>
    
    <xsl:template match="*:copyright" mode="registryObject_rights_statement">
        <rights>
            <rightsStatement>
                <xsl:value-of select="normalize-space(.)"/>
            </rightsStatement>
        </rights>
    </xsl:template>
    
    <xsl:template match="*:useStmt" mode="registryObject_rights_access">
        
        <!--xsl:variable name="accessType">
            <xsl:choose>
                <xsl:when test="*:specPerm/@required = 'yes'">
                    <xsl:text>restricted</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>open</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable-->
        
        <xsl:variable name="accessType" select="'restricted'"/>
        
        <rights>
            <xsl:if test="lower-case(normalize-space(*:confDec/@required)) = 'yes'">
                <accessRights type="{$accessType}">
                    <xsl:text>Confidentiality Declaration Required</xsl:text>
                </accessRights>
            </xsl:if>
            <xsl:if test="lower-case(normalize-space(*:specPerm/@required)) = 'no'">
                <accessRights type="{$accessType}">
                    <xsl:text>General Access Application Required</xsl:text>
                </accessRights>
            </xsl:if>
            <xsl:if test="lower-case(normalize-space(*:specPerm/@required)) = 'yes'">
                <accessRights type="{$accessType}">
                    <xsl:text>Restricted Application and Access Approval Required</xsl:text>
                </accessRights>
            </xsl:if>
           
        </rights>
    </xsl:template>
    
    <xsl:template match="@date" mode="registryObject_dates_accepted">
        <dates type="dateAccepted">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="normalize-space(.)"/>
            </date>
        </dates>
    </xsl:template>
    
    <xsl:template match="@date" mode="registryObject_dates_available">
        <dates type="available">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="normalize-space(.)"/>
            </date>
        </dates>
    </xsl:template>
    
    <xsl:template match="*:codeBook" mode="registryObject_citationInfo">
      
       
        <xsl:apply-templates select="*:stdyDscr/*:citation/*:biblCit[(string-length(.) > 0)]" mode="registryObject_citation_full"/>
        
        <citationInfo>
            <citationMetadata>
                <xsl:apply-templates select="*:stdyDscr/*:citation/*:titlStmt/*:IDNo[(string-length(.) > 0)]" mode="registryObject_citation_identifier"/>
                <xsl:apply-templates select="*:stdyDscr/*:citation/*:rspStmt/*:AuthEnty[(string-length(.) > 0)]" mode="registryObject_citation_contributor"/>
                <xsl:apply-templates select="*:docDscr/*:citation/*:prodStmt/*:producer[(string-length(.) > 0)]" mode="registryObject_citation_publisher"/>
                <xsl:apply-templates select="*:stdyDscr/*:citation/*:titlStmt/*:titl[(string-length(.) > 0)]" mode="registryObject_citation_title"/>
                <xsl:apply-templates select="*:stdyDscr/*:citation/*:verStmt/*:version[(string-length(.) > 0)]" mode="registryObject_citation_version"/>
                <xsl:apply-templates select="*:stdyDscr/*:citation/*:distStmt/*:distDate/@date[(string-length(.) > 3)]" mode="registryObject_citation_date_published"/>
                <!--xsl:apply-templates select="*:stdyDscr/*:citation/*:titlStmt/*:IDNo[(string-length(.) > 0)]" mode="registryObject_citation_url"/-->
                
            </citationMetadata>
        </citationInfo>
    </xsl:template>
    
    <xsl:template match="*:biblCit" mode="registryObject_citation_full">
        <citationInfo>
          <fullCitation>
              <xsl:value-of select="normalize-space(.)"/>
          </fullCitation>
        </citationInfo>
    </xsl:template>
    
    
    <xsl:template match="*:IDNo" mode="registryObject_citation_identifier">
        <identifier type="{custom:getIdentifierType(.)}">
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="*:AuthEnty" mode="registryObject_citation_contributor">
        <contributor>
            <namePart>
                <xsl:value-of select="normalize-space(.)"/>
            </namePart>
        </contributor>
    </xsl:template>
    
    <xsl:template match="*:titl" mode="registryObject_citation_title">
        <title>
            <xsl:value-of select="normalize-space(.)"/>
        </title>
    </xsl:template>
    
    <xsl:template match="*:version" mode="registryObject_citation_version">
        <version>
            <xsl:value-of select="normalize-space(.)"/>
        </version>
    </xsl:template>
    
    <xsl:template match="@date" mode="registryObject_citation_date_published">
        <date type="publicationDate">
            <xsl:value-of select="normalize-space(substring(., 1, 4))"/>
        </date>
    </xsl:template>
    
    <xsl:template match="*:producer" mode="registryObject_citation_publisher">
        <publisher>
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:if test="string-length(@affiliation) > 0">
                <xsl:value-of select="concat(', ', @affiliation)"/>
            </xsl:if>
        </publisher>
    </xsl:template>
    
    <!--xsl:template match="*:IDNo" mode="registryObject_citation_url">
        <url>
            <xsl:choose>
                <xsl:when test="contains(., 'au.edu.anu.ada.ddi.')">
                    <xsl:value-of select="concat($global_baseURL, substring-after(normalize-space(.), 'au.edu.anu.ada.ddi.'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </url>
    </xsl:template-->
    
    
    <xsl:template match="*:AuthEnty" mode="party_author">
        <xsl:variable name="personName" select="."/>
            <xsl:message select="concat('personName for party_producer: ', $personName    )"/>
        
            <xsl:if test="(string-length($personName) > 0)">
            
                     <registryObject group="{$global_group}">
                        <key>
                           <xsl:value-of select="local:formatKey($personName)"/> 
                        </key>       
                        <originatingSource>
                             <xsl:value-of select="$global_originatingSource"/>
                        </originatingSource>
                        
                         <party>
                            <xsl:attribute name="type" select="'person'"/>
                             
                              <name type="primary">
                                 <namePart>
                                    <xsl:value-of select="normalize-space(.)"/>
                                 </namePart>    
                             </name>
                             
                             <xsl:if test="string-length(@affiliation) > 0">
                                <relatedObject>
                                    <key>
                                        <xsl:value-of select="local:formatKey(@affiliation)"/>
                                    </key>
                                    <relation type="isMemberOf"/>
                                </relatedObject>
                             
                             </xsl:if>
                             
                         </party>
                     </registryObject>
                </xsl:if>
        </xsl:template>
    
    <xsl:template match="*:producer" mode="party_producer">
        <xsl:variable name="personName" select="."/>
            <xsl:message select="concat('personName for party_producer: ', $personName    )"/>
        
            <xsl:if test="(string-length($personName) > 0)">
            
                     <registryObject group="{$global_group}">
                        <key>
                           <xsl:value-of select="local:formatKey($personName)"/> 
                        </key>       
                        <originatingSource>
                             <xsl:value-of select="$global_originatingSource"/>
                        </originatingSource>
                        
                         <party>
                            <xsl:attribute name="type" select="'person'"/>
                             
                              <name type="primary">
                                 <namePart>
                                    <xsl:value-of select="normalize-space(.)"/>
                                 </namePart>    
                             </name>
                         </party>
                     </registryObject>
                </xsl:if>
        </xsl:template>
        
     <xsl:template match="@affiliation" mode="party_organisation">
        <xsl:variable name="orgName" select="."/>
            <xsl:message select="concat('orgName for party_organisation: ', $orgName )"/>
        
            <xsl:if test="(string-length($orgName) > 0)">
            
                     <registryObject group="{$global_group}">
                        <key>
                           <xsl:value-of select="local:formatKey($orgName)"/> 
                        </key>       
                        <originatingSource>
                             <xsl:value-of select="$global_originatingSource"/>
                        </originatingSource>
                        
                         <party>
                            <xsl:attribute name="type" select="'group'"/>
                             
                              <name type="primary">
                                 <namePart>
                                    <xsl:value-of select="normalize-space(.)"/>
                                 </namePart>    
                             </name>
                         </party>
                     </registryObject>
                </xsl:if>
        </xsl:template>
  
            
    
    <xsl:function name="local:formatKey">
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
    
</xsl:stylesheet>
