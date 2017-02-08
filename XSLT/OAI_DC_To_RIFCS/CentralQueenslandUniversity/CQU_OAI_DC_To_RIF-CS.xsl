<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cquFunc="http://bom.nowhere.yet"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	

    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'Central Queensland University'"/>
    <xsl:param name="global_baseURI" select="'http://acquire.cqu.edu.au:8080/fedora'"/>
    <xsl:param name="global_group" select="'Central Queensland University'"/>
    <xsl:param name="global_publisherName" select="'Central Queensland University'"/>
    
    <xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/>
    

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
    
    <!-- include all sets for now, until otherwise -->
    
        <xsl:if test="(boolean(custom:sequenceContainsExact(oai:metadata/oai_dc:dc/dc:type, 'collection')) = true()) or
                    (boolean(custom:sequenceContains(oai:metadata/oai_dc:dc/dc:type, 'dataset')) = true())">
                    
             <xsl:apply-templates select="oai:metadata/oai_dc:dc" mode="collection"/>
            <!--  xsl:apply-templates select="oai:metadata/oai_dc:dc/dc:funding" mode="funding_party"/-->
            <xsl:apply-templates select="oai:metadata/oai_dc:dc" mode="party"/> 
    </xsl:if>
    </xsl:template>
    
    <xsl:template match="oai_dc:dc" mode="collection">
        <xsl:variable name="class" select="'collection'"/>
        
        <xsl:variable name="key" select="concat($global_baseURI, ':', fn:generate-id(.))"/>
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
                        <xsl:when test="boolean(custom:sequenceContains(dc:type, 'dataset')) = true()">
                            <xsl:value-of select="'dataset'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'collection'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
             
                <xsl:apply-templates select="@todo[string-length(.) > 0]" mode="collection_date_modified"/>
                
                <xsl:apply-templates select="../../oai:header/oai:datestamp" mode="collection_date_accessioned"/>
                
                <xsl:apply-templates select="dc:identifier[string-length(.) > 0]" mode="collection_identifier"/>
                
                <xsl:apply-templates select="dc:identifier[string-length(.) > 0]" mode="collection_location"/>
                
                <xsl:apply-templates select="dc:title[string-length(.) > 0]" mode="collection_name"/>
                
                <!-- xsl:apply-templates select="dc:identifier.orcid" mode="collection_relatedInfo"/ -->
                
                <xsl:apply-templates select="dc:creator[string-length(.) > 0]" mode="collection_relatedObject"/>
               
                <xsl:apply-templates select="dc:subject[string-length(.) > 0]" mode="collection_subject"/>
                
                <xsl:apply-templates select="dc:rights[string-length(.) > 0]" mode="collection_rights_rightsStatement"/>
                
                <xsl:apply-templates select="dc:description[string-length(.) > 0]" mode="collection_description_full"/>
               
                <xsl:apply-templates select="dc:date[string-length(.) > 0]" mode="collection_dates_issued"/>  
             
            </xsl:element>
        </registryObject>
    </xsl:template>
   
    
     <xsl:template match="@todo" mode="collection_date_modified">
        <xsl:attribute name="dateModified" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="oai:datestamp" mode="collection_date_accessioned">
        <xsl:attribute name="dateAccessioned" select="normalize-space(.)"/>
    </xsl:template>
       
    <xsl:template match="dc:identifier" mode="collection_identifier">
        <identifier type="{custom:getIdentifierType(.)}">
            <xsl:choose>
                <xsl:when test="starts-with(. , '10.')">
                    <xsl:value-of select="concat('http://doi.org/', .)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </identifier>    
    </xsl:template>
    
     <xsl:template match="dc:identifier" mode="collection_location">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:choose>
                            <xsl:when test="starts-with(. , '10.')">
                                <xsl:value-of select="concat('http://doi.org/', .)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="dc:title" mode="collection_name">
        <name type="primary">
            <namePart>
                <xsl:value-of select="normalize-space(.)"/>
            </namePart>
        </name>
    </xsl:template>
    
    
   <xsl:template match="dc:identifier.orcid" mode="collection_relatedInfo">
        <xsl:message select="concat('vivo:orcidId : ', .)"/>
                            
        <relatedInfo type='party'>
            <identifier type="{custom:getIdentifierType(.)}">
                <xsl:value-of select="normalize-space(.)"/>
            </identifier>
            <relation type="hasCollector"/>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="dc:creator" mode="collection_relatedObject">
            <relatedObject>
                <key>
                    <xsl:value-of select="cquFunc:formatKey(cquFunc:formatName(.))"/> 
                </key>
                <relation type="hasCollector"/>
            </relatedObject>
    </xsl:template>
    
    <xsl:template match="dc:subject" mode="collection_subject">
        <subject type="local">
            <xsl:value-of select="normalize-space(.)"/>
        </subject>
    </xsl:template>
   
    <xsl:template match="dc:rights" mode="collection_rights_rightsStatement">
        <xsl:if test="contains(lower-case(.), 'open access')">
            <rights>
                <accessRights type="open"/>
            </rights>
        </xsl:if>
        
        <xsl:variable name="currentValue" select="normalize-space(.)"/>
        
        <xsl:variable name="codeDefinition_sequence" select="$licenseCodelist/custom:CT_CodelistCatalogue/custom:codelistItem/custom:CodeListDictionary[@custom:id='LicenseCodeAustralia']/custom:codeEntry/custom:CodeDefinition[contains($currentValue, normalize-space(replace(custom:remarks, '\{n\}', '')))]" as="node()*"/>
        
        <xsl:choose>
            <xsl:when test="count($codeDefinition_sequence) > 0">
                <xsl:for-each select="$codeDefinition_sequence">
                    <xsl:if test="string-length(custom:identifier) > 0">
                        <rights>
                            <licence>
                                <xsl:attribute name="type">
                                    <xsl:value-of select="custom:identifier"/>
                                    <xsl:message select="concat('Match found for ', $currentValue, ' so using custom:identifier: ', custom:identifier)"/>
                                </xsl:attribute>
                            </licence>
                        </rights>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <rights>
                    <rightsStatement>
                        <xsl:value-of select="normalize-space(.)"/>
                    </rightsStatement>
                </rights>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="dc:description" mode="collection_description_full">
        <description type="full">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <xsl:template match="dc:date" mode="collection_dates_issued">
        <dates type="issued">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="substring-after(., 'http://openvivo.org/a/date')"/>
            </date>
        </dates>
    </xsl:template>  
             
     <xsl:template match="oai_dc:dc" mode="party">
        
        <xsl:for-each select="dc:creator">
            
            <xsl:variable name="name" select="normalize-space(.)"/>
            
            <xsl:if test="(string-length(.) > 0)">
            
                   <xsl:if test="string-length(normalize-space(.)) > 0">
                     <registryObject group="{$global_group}">
                        <key>
                            <xsl:value-of select="cquFunc:formatKey(cquFunc:formatName(.))"/> 
                        </key>
                        <originatingSource>
                             <xsl:value-of select="$global_originatingSource"/>
                        </originatingSource>
                        
                         <party>
                            <xsl:attribute name="type" select="'person'"/>
                             
                             <name type="primary">
                                 <namePart>
                                     <xsl:value-of select="cquFunc:formatName(normalize-space(.))"/>
                                 </namePart>   
                             </name>
                         </party>
                     </registryObject>
                   </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:template>
                   
    <xsl:function name="cquFunc:formatName">
        <xsl:param name="name"/>
        
        <xsl:variable name="namePart_sequence" as="xs:string*">
            <xsl:analyze-string select="$name" regex="[A-Za-z()-]+">
                <xsl:matching-substring>
                    <xsl:if test="regex-group(0) != '-'">
                        <xsl:value-of select="regex-group(0)"/>
                    </xsl:if>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count($namePart_sequence) = 0">
                <xsl:value-of select="$name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="orderedNamePart_sequence" as="xs:string*">
                    <!--  we are going to presume that we have surnames first - otherwise, it's not possible to determine by being
                            prior to a comma because we get:  "surname, firstname, 1924-" sort of thing -->
                    <!-- all names except surname -->
                    <xsl:for-each select="$namePart_sequence">
                        <xsl:if test="position() > 1">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:value-of select="$namePart_sequence[1]"/>
                </xsl:variable>
                <xsl:message select="concat('formatName returning: ', string-join(for $i in $orderedNamePart_sequence return $i, ' '))"/>
                <xsl:value-of select="string-join(for $i in $orderedNamePart_sequence return $i, ' ')"/>
    
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="cquFunc:formatKey">
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
    