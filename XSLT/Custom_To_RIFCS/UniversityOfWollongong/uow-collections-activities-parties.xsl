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
    <xsl:param name="global_baseURI" select="'uow.edu.au'"/>
    <xsl:param name="global_group" select="'University of Wollongong'"/>
    <xsl:param name="global_publisherName" select="'University of Wollongong'"/>

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
            <xsl:apply-templates select="//oai:record/oai:metadata/*:document-export/*:documents/*:document" mode="collection"/>
            <xsl:apply-templates select="//oai:record/oai:metadata/*:document-export/*:documents/*:document" mode="party"/>
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="document" mode="collection">
        
        <xsl:variable name="class" select="'collection'"/>
        <xsl:variable name="type" select="'dataset'"/>
        
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            
            
            <key>
                <xsl:value-of select="custom:datasetKey(.)"/>
            </key>
            
            <xsl:apply-templates select="fields" mode="originating_source">
                <xsl:with-param name="default" select="$global_originatingSource"/>
            </xsl:apply-templates>
            
            
            <xsl:element name="{$class}">
                
                <xsl:attribute name="type" select="$type"/>
                
                <xsl:apply-templates select="fields/field[@name='persistent_identifier' and (string-length(.) > 0)]" mode="identifier"/>
               
                <xsl:apply-templates select="fields/field[@name='doi' and (string-length(.) > 0)]" mode="identifier"/>
                
                <xsl:choose>
                    <xsl:when test="fields/field[@name='doi' and (string-length(.) > 0)]">
                        <xsl:apply-templates select="fields/field[@name='doi']" mode="location"/>
                    </xsl:when>
                    <xsl:when test="fields/field[@name='persistent_identifier' and (string-length(.) > 0)]">
                        <xsl:apply-templates select="fields/field[@name='persistent_identifier']" mode="location"/>
                    </xsl:when>
                    <xsl:when test="coverpage-url[string-length(.) > 0]">
                        <xsl:apply-templates select="coverpage-url" mode="location"/>
                    </xsl:when>
                </xsl:choose>
                
                <xsl:apply-templates select="title[string-length(.) > 0]"/>
                
                <xsl:apply-templates select="authors/author"/>
                
                <xsl:apply-templates select="fields/field[(@name = 'additional_investigators') and (string-length(.) > 0)]"/>
                
                <xsl:apply-templates select="keywords/keyword[string-length(.) > 0]"/>
                
                <xsl:apply-templates select="disciplines/discipline[string-length(.) > 0]"/>
                
                <xsl:apply-templates select="fields/field[(@name='for') and (string-length(.) > 0)]"/>
                
                <xsl:apply-templates select="abstract[string-length(.) > 0]"/>
                
                <xsl:apply-templates select="fields/field[(@name='date_range') and (string-length(.) > 0)]"/>
                
                <xsl:apply-templates select="fields/field[(@name='geolocate') and (string-length(.) > 0)]"/>
                
                <xsl:apply-templates select="fields" mode="spatial_coverage"/>
                
                <xsl:apply-templates select="submission-date[string-length(.) > 0]"/>
                
                <xsl:apply-templates select="fields/field[(@name='custom_citation') and (string-length(.) > 0)]"/>
                
                <xsl:apply-templates select="fields/field[@name='grant_purl' and (string-length(.) > 0)]"/>
                
                <xsl:apply-templates select="native-url[string-length(.) > 0]"/>
                
                <xsl:apply-templates select="fields/field[(@name='distribution_license') and (string-length(.) > 0)]"/>
                
                <xsl:apply-templates select="fields/field[(@name='rights') and (string-length(.) > 0)]"/>
                
                <xsl:apply-templates select="fulltext-url[string-length(.) > 0]"/>
                
                <xsl:apply-templates select="fields/field[(@name='related_content') and (string-length(.) > 0)]"/>
                
            </xsl:element>
        </registryObject>
    </xsl:template>
   
    
   <!-- Templates -->
    
    <xsl:template match="document" mode="party">
        
        <xsl:for-each select="authors/author">
            
            <xsl:variable name="firstName" select="fname"/>
            <xsl:variable name="mname" select="mname"/>
            <xsl:variable name="lastName" select="lname"/>
            
            <xsl:variable name="nameFormatted" select="concat($firstName, ' ', $mname, ' ', $lastName)"/>
            
            <xsl:variable name="key" select="custom:formatKey($nameFormatted)"/>
            
            <xsl:variable name="class" select="'party'"/>
            <xsl:variable name="type" select="'person'"/>
            
            <registryObject>
                <xsl:attribute name="group" select="$global_group"/>
                <key>
                    <xsl:value-of select="custom:formatKey($nameFormatted)"/>
                </key>
                <originatingSource>
                    <xsl:value-of select="$global_originatingSource"/>
                </originatingSource>
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
                        <xsl:variable name="institutionID" select="custom:partyID(institution)"/>
                        <xsl:if test="string-length($institutionID) > 0">
                            <relatedInfo type="party">
                                <title>
                                    <xsl:value-of select="institution"/>
                                </title> 
                                <identifier type="{custom:identifierType($institutionID)}">
                                    <xsl:value-of select="$institutionID"/>
                                </identifier>
                                <relation type="isMemberOf"/>
                            </relatedInfo>
                        </xsl:if>
                    </xsl:if>
                    
                    <xsl:if test="string-length(custom:datasetKey(../..)) > 0">
                        <relatedObject>
                            <key>
                                <xsl:value-of select="custom:datasetKey(../..)"/>
                            </key>
                            <relation type="isCollectorOf"/>
                        </relatedObject>
                    </xsl:if>
                    
                    <xsl:if test="../../fields/field[(@name='grant_purl') and (string-length(.) > 0)]">
                        <xsl:analyze-string select="../../fields/field[@name='grant_purl']" regex="(http).+?(&quot;|&lt;|$)">
                            <xsl:matching-substring>
                                <relatedInfo type="activity">
                                    <xsl:variable name="identifierType" select="custom:identifierType(regex-group(0))"/>
                                    <identifier type="{$identifierType}">
                                        <xsl:value-of select="translate(translate(regex-group(0), '&quot;', ''), '&lt;', '')"/>
                                    </identifier>
                                    <relation type="isParticipantIn"/>
                                </relatedInfo>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:if>
                    
                </xsl:element>
            </registryObject>
        </xsl:for-each>
        
    </xsl:template>
    
   <xsl:template match="fields" mode="originating_source">
        <xsl:param name="default"/>
        <xsl:variable name="value">
            <xsl:choose>
                <xsl:when test="string-length(field[@name='source_publication']) > 0">
                    <xsl:value-of select="field[@name='source_publication']"/>
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
    
    <xsl:template match="field[@name='doi']" mode="identifier">
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
    
    <xsl:template match="field[@name='persistent_identifier']" mode="identifier">
        <xsl:for-each select="value">
            <!--xsl:analyze-string select="." regex="(http).+?(&quot;|&lt;|$)"-->
            <xsl:analyze-string select="." regex="(http).+?(&quot;|&lt;|$)">
                <xsl:matching-substring>
                    <identifier type="{custom:identifierType(regex-group(0))}">
                        <xsl:value-of select="translate(translate(regex-group(0), '&quot;', ''), '&lt;', '')"/>
                    </identifier>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="coverpage-url" mode="location">
        <xsl:if test="contains(., 'http')">
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
    </xsl:template>
    
    
    <xsl:template match="field[@name='doi']" mode="location">
        <xsl:message select="concat('current doi: ', .)"/>
        <xsl:choose>
            <!--xsl:when test="not(contains(lower-case(.), 'doi')) and (substring(., 1) castable as xs:integer)"-->
            <xsl:when test="not(contains(lower-case(.), 'doi.org'))">
                <location>
                    <address>
                        <electronic type="url" target="landingPage">
                            <value>
                                <xsl:value-of select="concat('http://doi.org/', .)"/>
                             </value>
                        </electronic>
                    </address>
                </location> 
            </xsl:when>
            <xsl:otherwise>
                <location>
                    <address>
                        <electronic type="url" target="landingPage">
                            <value>
                                <xsl:value-of select="."/>
                            </value>
                        </electronic>
                    </address>
                </location> 
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="field[@name='persistent_identifier']" mode="location">
        <xsl:for-each select="value">
            <xsl:variable name="doi" select="../../field[@name='doi' and (string-length(.) > 0)]"/>
           
            <xsl:message select="concat('current pid: ', .)"/>
            <xsl:choose>
                <xsl:when test="contains(., '&quot;')">
                    <xsl:analyze-string select="." regex="(http).+?(&quot;|&lt;|$)">
                         <xsl:matching-substring>
                             <location>
                                 <address>
                                     <electronic type="url" target="landingPage">
                                         <value>
                                             <xsl:value-of select="translate(translate(regex-group(0), '&quot;', ''), '&lt;', '')"/>
                                         </value>
                                     </electronic>
                                 </address>
                             </location>
                         </xsl:matching-substring>
                     </xsl:analyze-string>
                </xsl:when>
                <xsl:otherwise>
                    <location>
                        <address>
                             <electronic type="url" target="landingPage">
                                 <value>
                                     <xsl:value-of select="."/>
                                 </value>
                             </electronic>
                         </address>
                    </location>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="author">
            
        <xsl:variable name="firstName" select="fname"/>
        <xsl:variable name="mname" select="mname"/>
        <xsl:variable name="lastName" select="lname"/>
        
        <xsl:variable name="nameFormatted" select="concat($firstName, ' ', $mname, ' ', $lastName)"/>
        
        <xsl:variable name="key" select="custom:formatKey($nameFormatted)"/>
        
        <xsl:if test="string-length($key) > 0">
            <relatedObject>
                <key>
                    <xsl:value-of select="custom:formatKey($nameFormatted)"/>
                </key>
                <relation type="hasCollector"/>
            </relatedObject>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template match="field[@name='additional_investigators']">
        <xsl:for-each select="value">
            <description type="notes">
                <xsl:text>Additional Investigators:&lt;br&gt;</xsl:text>
                <xsl:value-of select="."/>
            </description>
        </xsl:for-each>
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
    
    <xsl:template match="field[(@name='for')]">
        <xsl:for-each select="value">
            <xsl:variable name="forCode" select="tokenize(., ' ')[1]"/>
             <xsl:if test="(string-length($forCode) > 0) and ($forCode castable as xs:integer)">
                 <subject type="anzsrc-for">
                     <xsl:value-of select="$forCode"/>
                 </subject>
             </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="abstract">
        <description type="full">
            <xsl:value-of select="."/>
        </description>
    </xsl:template>
    
    <xsl:template match="fields/field[@name='date_range']">
        <xsl:for-each select="value">
            <coverage>
                <temporal>
                    <text>
                        <xsl:value-of select="."/>
                    </text>
                </temporal>
            </coverage>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="field[@name='geolocate']">
        <xsl:for-each select="value">
            <coverage>
                <spatial type="text">
                    <xsl:value-of select="."/>
                </spatial>
            </coverage>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="fields" mode="spatial_coverage">
        <xsl:if test="
            (string-length(field[@name='latitude']) > 0) and
            (string-length(field[@name='longitude']) > 0)">
            <location>
                <spatial type="kmlPolyCoords">
                    <xsl:value-of select="concat(field[@name='longitude'], ',',field[@name='latitude'])"/>
                </spatial>
            </location>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="submission-date">
        <dates type="submitted">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="."/>
            </date>
        </dates>
    </xsl:template>
    
    <xsl:template match="field[@name='custom_citation']">
        <xsl:for-each select="value">
            <citationInfo>
                <fullCitation>
                    <xsl:value-of select="."/>
                </fullCitation>
            </citationInfo>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="field[@name='grant_purl']">
        <xsl:for-each select="value">
            <xsl:analyze-string select="." regex="(http).+?(&quot;|&lt;|$)">
              <xsl:matching-substring>
                  <relatedInfo type="activity">
                      <xsl:variable name="identifierType" select="custom:identifierType(regex-group(0))"/>
                      <identifier type="{$identifierType}">
                          <xsl:value-of select="translate(translate(regex-group(0), '&quot;', ''), '&lt;', '')"/>
                      </identifier>
                      <relation type="isOutputOf"/>
                  </relatedInfo>
              </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="native-url">
        <xsl:for-each select="value">
            <xsl:if test="contains(., 'viewcontent')">
                <rights>
                    <accessRights type="open"/>
                </rights>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="field[@name='rights']">
        <xsl:for-each select="value">
            <rights>
                <rightsStatement>
                    <xsl:value-of select="."/>
                </rightsStatement>
            </rights>
            <xsl:if test="contains(lower-case(.), 'open access')">
                <rights>
                    <accessRights type="open"/>
                </rights>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="field[@name='distribution_license']">
        <xsl:for-each select="value">
            <rights>
                <licence>
                    <xsl:choose>
                        <xsl:when test="contains(., 'http')">
                            <xsl:attribute name="rightsUri">
                                <xsl:value-of select="."/>
                            </xsl:attribute>
                            <xsl:if test="contains(., 'creativecommons')">
                                <xsl:message select="concat('creativecommons: ', .)"/>
                                <xsl:analyze-string select="." regex="(http://creativecommons.org/licenses/)(.*)(/\d)">
                                    <xsl:matching-substring>
                                        <xsl:if test="string-length(regex-group(2)) > 0">
                                            <xsl:attribute name="type">
                                                <xsl:value-of select="upper-case(concat('cc-', regex-group(2)))"/>
                                            </xsl:attribute>
                                        </xsl:if>
                                    </xsl:matching-substring>
                                </xsl:analyze-string>
                            </xsl:if>
                        </xsl:when>
                    </xsl:choose>
                </licence>
            </rights>
        </xsl:for-each>
    </xsl:template>
    
    
    <xsl:template match="fulltext-url">
        <xsl:if test="contains(., 'viewcontent')">
            <rights>
                <accessRights type="open"/>
            </rights>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="field[@name='related_content']">
        <xsl:for-each select="value">
            <xsl:analyze-string select="." regex="(http).+?(&quot;|&lt;|$)">
                <xsl:matching-substring>
                    <relatedInfo>
                         <xsl:variable name="identifierType" select="custom:identifierType(regex-group(0))"/>
                         <identifier type="{$identifierType}">
                             <xsl:value-of select="translate(translate(regex-group(0), '&quot;', ''), '&lt;', '')"/>
                         </identifier>
                        <relation type="hasAssociationWith"/>
                    </relatedInfo>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Functions -->
    
    <xsl:function name="custom:datasetKey" as="xs:string">
        <xsl:param name="document" as="node()"/>
        <xsl:choose>
            <xsl:when test="$document/fields/field[(@name='uow_key') and (string-length(.) > 0)]">
                <xsl:value-of select="$document/fields/field[@name='uow_key']"/>
            </xsl:when>
            <xsl:when test="$document/submission-path[string-length(.) > 0]">
                <xsl:value-of select="custom:formatKey($document/submission-path)"/>
            </xsl:when>
            <xsl:when test="$document/articleid[string-length(.) > 0]">
                <xsl:value-of select="custom:formatKey($document/articleid)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="custom:identifierType" as="xs:string">
        <xsl:param name="identifier" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="contains(lower-case($identifier), 'nla.party')">
                <xsl:text>AU-ANL:PEAU</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'scopus')">
                <xsl:text>scopus</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'orcid')">
                <xsl:text>orcid</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'doi')">
                <xsl:text>doi</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'handle')">
                <xsl:text>handle</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>uri</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <xsl:function name="custom:formatKey">
        <xsl:param name="input"/>
        <xsl:variable name="raw" select="translate(translate($input, ' ', ''), '.', '')"/>
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
    
    <xsl:function name="custom:partyID" as="xs:string">
        <xsl:param name="name" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="lower-case($name) = 'university of wollongong'">
                <xsl:text>http://nla.gov.au/nla.party-464691</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text/>
            </xsl:otherwise>
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
