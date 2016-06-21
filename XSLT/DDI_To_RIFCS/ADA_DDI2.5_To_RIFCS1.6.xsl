<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:ddi="http://www.icpsr.umich.edu/DDI" 
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:localFunc="http://www.localfunc.net"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
    
    <xsl:param name="global_originatingSource" select="'Australian Data Archive'"/>
    <xsl:param name="global_baseURI" select="'www.ada.edu.au'"/>
    <xsl:param name="global_group" select="'Australian Data Archive'"/>
    <xsl:param name="global_publisherName" select="'Australian Data Archive'"/>
    <xsl:param name="global_baseURL" select="'https://www.ada.edu.au/ada/'"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:message select="concat('name:', name(ddi:codeBook))"/>
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
            <xsl:apply-templates select="ddi:codeBook" mode="collection"/>
            <!--xsl:apply-templates select="." mode="activity"/-->
            <!--xsl:apply-templates select="." mode="party"/-->
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="ddi:codeBook" mode="collection">
        <xsl:message select="concat('match', 'codeBook')"/>
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <key>
                <xsl:value-of select="normalize-space(@ID)"/>
            </key>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource> 
                
            <collection>
                <xsl:attribute name="type" select="'dataset'"/>
                <xsl:attribute name="dateAccessioned" select="ddi:stdyDscr/ddi:citation/ddi:distStmt/ddi:depDate/@date[(string-length(.) > 0)]"/>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:citation/ddi:titlStmt/ddi:IDNo[(string-length(.) > 0)]" mode="registryObject_identifier"/>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:citation/ddi:titlStmt/ddi:titl[(string-length(.) > 0)]" mode="registryObject_name"/>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:citation/ddi:titlStmt/ddi:IDNo[(string-length(.) > 0)]" mode="registryObject_location"/>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:stdyInfo/ddi:subject/ddi:keyword[(string-length(.) > 0)]" mode="registryObject_subject"/>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:stdyInfo/ddi:abstract[(string-length(.) > 0)]" mode="registryObject_description"/>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:stdyInfo/ddi:sumDscr" mode="registryObject_coverage"/>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:othrStdyMat/ddi:relPubl" mode="registryObject_relatedInfo"/>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:citation/ddi:titlStmt/ddi:altTitl[(string-length(.) > 0)]" mode="registryObject_altname"/>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:citation/ddi:prodStmt/ddi:copyright" mode="registryObject_rights_statement"/>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:dataAccs/ddi:useStmt" mode="registryObject_rights_access"/>
                
                <xsl:apply-templates select="." mode="registryObject_citationInfo"/>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:citation/ddi:distStmt/ddi:depDate/@date[(string-length(.) > 0)]" mode="registryObject_dates_submitted"/>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:citation/ddi:distStmt/ddi:distDate/@date[(string-length(.) > 0)]" mode="registryObject_dates_available"/>
            </collection>
        </registryObject>
    </xsl:template>
    
    <xsl:template match="ddi:codeBook" mode="activity">
    </xsl:template>
    
    <xsl:template match="ddi:codeBook" mode="party">
    </xsl:template>
    
    <xsl:template match="ddi:IDNo" mode="registryObject_location">
        <location>
            <address>
                 <electronic type="url">
                    <value>
                        <xsl:value-of select="concat($global_baseURL, substring-after(normalize-space(.), 'au.edu.anu.ada.ddi.'))"/>
                    </value> 
                </electronic>
            </address>
        </location>
     </xsl:template>
    
   <xsl:template match="ddi:keyword" mode="registryObject_subject">
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
    
    <xsl:template match="ddi:abstract" mode="registryObject_description">
        <description type="full">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <xsl:template match="ddi:sumDscr" mode="registryObject_coverage">
        <coverage>
            <xsl:apply-templates select="ddi:timePrd[(@event = 'start') and (string-length(@date) > 0)]" mode="registryObject_coverage_temporal_start"/>
            <xsl:apply-templates select="ddi:timePrd[(@event = 'single') and (string-length(@date) > 0)]" mode="registryObject_coverage_temporal_single"/>
            <xsl:apply-templates select="ddi:collDate[(@event = 'start') and (string-length(@date) > 0)]" mode="registryObject_coverage_temporal_start"/>
            <xsl:apply-templates select="ddi:collDate[(@event = 'single') and (string-length(@date) > 0)]" mode="registryObject_coverage_temporal_single"/>
            <xsl:apply-templates select="ddi:nation[string-length(.) > 0]" mode="registryObject_coverage_spatial"/>
            <xsl:apply-templates select="ddi:geogCover[string-length(.) > 0]" mode="registryObject_coverage_spatial"/>
            <xsl:apply-templates select="ddi:geogUnit[string-length(.) > 0]" mode="registryObject_coverage_spatial"/>
        </coverage>
    </xsl:template>
    
    <xsl:template match="ddi:relPubl" mode="registryObject_relatedInfo">
        <relatedInfo type="publication">
            <identifier type="uri">
                <xsl:value-of select="normalize-space(ddi:citation/ddi:holdings/@URI)"/>
            </identifier> 
            <title>
                <xsl:value-of select="normalize-space(ddi:citation/ddi:titlStmt/ddi:titl)"/>
            </title> 
            <relation type="isCitedBy"/>
            <notes>
                <xsl:value-of select="normalize-space(.)"/>
            </notes>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="ddi:timePrd" mode="registryObject_coverage_temporal_start">
        <temporal>
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="normalize-space(@date)"/>
            </date>
            <text>
                <xsl:value-of select="normalize-space(@cycle)"/>
            </text>
            
            <xsl:if test="following-sibling::ddi:timePrd[@event = 'end'][1]/@date[string-length(.) > 0]">
                <date type="dateTo" dateFormat="W3CDTF">
                    <xsl:value-of select="normalize-space(following-sibling::ddi:timePrd[@event = 'end'][1]/@date)"/>
                </date>
                <text>
                    <xsl:value-of select="normalize-space(@cycle)"/>
                </text>
            </xsl:if>
        </temporal>
    </xsl:template>
    
    <xsl:template match="ddi:timePrd" mode="registryObject_coverage_temporal_single">
        <temporal>
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="normalize-space(@date)"/>
            </date>
            <text>
                <xsl:value-of select="normalize-space(@cycle)"/>
            </text>
        </temporal>
    </xsl:template>
    
    <xsl:template match="ddi:collDate" mode="registryObject_coverage_temporal_start">
        <temporal>
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="normalize-space(@date)"/>
            </date>
            <text>
                <xsl:value-of select="normalize-space(@cycle)"/>
            </text>
           
           <xsl:if test="following-sibling::ddi:collDate[@event = 'end'][1]/@date[string-length(.) > 0]">
               <date type="dateTo" dateFormat="W3CDTF">
                   <xsl:value-of select="normalize-space(following-sibling::ddi:collDate[@event = 'end'][1]/@date)"/>
               </date>
               <text>
                   <xsl:value-of select="normalize-space(@cycle)"/>
               </text>
           </xsl:if>
        </temporal>
    </xsl:template>
    
    <xsl:template match="ddi:collDate" mode="registryObject_coverage_temporal_single">
        <temporal>
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="normalize-space(@date)"/>
            </date>
            <text>
                <xsl:value-of select="normalize-space(@cycle)"/>
            </text>
        </temporal>
    </xsl:template>
    
    <xsl:template match="ddi:nation" mode="registryObject_coverage_spatial">
        <spatial type="text">
            <xsl:value-of select="normalize-space(.)"/>
        </spatial>
    </xsl:template>
    
    <xsl:template match="ddi:geogCover" mode="registryObject_coverage_spatial">
        <spatial type="text">
            <xsl:value-of select="normalize-space(.)"/>
        </spatial>
    </xsl:template>
    
    <xsl:template match="ddi:geogUnit" mode="registryObject_coverage_spatial">
        <spatial type="text">
            <xsl:value-of select="normalize-space(.)"/>
        </spatial>
    </xsl:template>
    
    
    <date type="dateTo" dateFormat="W3CDTF">2004-03-12T09:14:10.00Z</date>
    
    
    
    <xsl:template match="ddi:IDNo" mode="registryObject_identifier">
        <identifier type="{localFunc:getIdentifierType(.)}">
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="ddi:titl" mode="registryObject_name">
        <name type="primary">
            <namePart>
                <xsl:value-of select="normalize-space(.)"/>
            </namePart>
        </name>
    </xsl:template>
    
    <xsl:template match="ddi:titl" mode="registryObject_altname">
        <name type="alternative">
            <namePart>
                <xsl:value-of select="normalize-space(.)"/>
            </namePart>
        </name>
    </xsl:template>
    
    <xsl:template match="ddi:copyright" mode="registryObject_rights_statement">
        <rights>
            <rightsStatement>
                <xsl:value-of select="normalize-space(.)"/>
            </rightsStatement>
        </rights>
    </xsl:template>
    
    <xsl:template match="ddi:useStmt" mode="registryObject_rights_access">
        
        <xsl:variable name="accessType">
            <xsl:choose>
                <xsl:when test="ddi:specPerm/@required = 'yes'">
                    <xsl:text>restricted</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>open</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <rights>
            <xsl:if test="string-length(normalize-space(ddi:confDec))">
                <accessRights type="{$accessType}">
                    <xsl:value-of select="normalize-space(ddi:confDec)"/>
                </accessRights>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(ddi:restrctn))">
                <accessRights type="{$accessType}">
                    <xsl:value-of select="normalize-space(ddi:restrctn)"/>
                </accessRights>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(ddi:conditions))">
                <accessRights type="{$accessType}">
                    <xsl:value-of select="normalize-space(ddi:conditions)"/>
                </accessRights>
            </xsl:if>
        </rights>
    </xsl:template>
    
    <xsl:template match="@date" mode="registryObject_dates_submitted">
        <dates type="dateSubmitted">
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
    
    <xsl:template match="ddi:codeBook" mode="registryObject_citationInfo">
        
        <citationInfo>
            <citationMetadata>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:citation/ddi:titlStmt/ddi:IDNo[(string-length(.) > 0)]" mode="registryObject_citation_identifier"/>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:citation/ddi:rspStmt/ddi:AuthEnty[(string-length(.) > 0)]" mode="registryObject_citation_contributor"/>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:citation/ddi:prodStmt/ddi:producer[@role='Data Collectors' and (string-length(.) > 0)]" mode="registryObject_citation_publisher"/>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:citation/ddi:titlStmt/ddi:titl[(string-length(.) > 0)]" mode="registryObject_citation_title"/>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:citation/ddi:verStmt/ddi:version[(string-length(.) > 0)]" mode="registryObject_citation_version"/>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:citation/ddi:distStmt/ddi:depDate/@date[(string-length(.) > 0)]" mode="registryObject_citation_date_submitted"/>
                <xsl:apply-templates select="ddi:stdyDscr/ddi:citation/ddi:distStmt/ddi:distDate/@date[(string-length(.) > 0)]" mode="registryObject_citation_date_published"/>
            </citationMetadata>
        </citationInfo>
    </xsl:template>
    
    
    <xsl:template match="ddi:IDNo" mode="registryObject_citation_identifier">
        <identifier type="{localFunc:getIdentifierType(.)}">
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="ddi:AuthEnty" mode="registryObject_citation_contributor">
        <contributor>
            <namePart>
                <xsl:value-of select="normalize-space(.)"/>
            </namePart>
        </contributor>
    </xsl:template>
    
    <xsl:template match="ddi:titl" mode="registryObject_citation_title">
        <title>
            <xsl:value-of select="normalize-space(.)"/>
        </title>
    </xsl:template>
    
    <xsl:template match="ddi:version" mode="registryObject_citation_version">
        <version>
            <xsl:value-of select="normalize-space(.)"/>
        </version>
    </xsl:template>
    
    <xsl:template match="@date" mode="registryObject_citation_date_submitted">
        <date type="dateSubmitted">
            <xsl:value-of select="normalize-space(.)"/>
        </date>
    </xsl:template>
    
    <xsl:template match="@date" mode="registryObject_citation_date_published">
        <date type="publicationDate">
            <xsl:value-of select="normalize-space(.)"/>
        </date>
    </xsl:template>
    
    <xsl:template match="ddi:producer" mode="registryObject_citation_publisher">
        <publisher>
            <xsl:value-of select="normalize-space(.)"/>
        </publisher>
    </xsl:template>
    
    
    
    
    <xsl:function name="localFunc:getIdentifierType" as="xs:string">
        <xsl:param name="identifier"/>
         <xsl:choose>
            <xsl:when test="contains(lower-case($identifier), 'orcid')">
                <xsl:text>orcid</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'purl.org')">
                <xsl:text>purl</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'doi.org')">
                <xsl:text>doi</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'scopus')">
                <xsl:text>scopus</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'handle.net')">
                <xsl:text>handle</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'nla.gov.au')">
                <xsl:text>AU-ANL:PEAU</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'fundref')">
                <xsl:text>fundref</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'http')">
                <xsl:text>uri</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>global</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>