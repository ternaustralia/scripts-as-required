<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd" 
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:toDataCite="http://nowhere.yet"
    exclude-result-prefixes="gmd oai gml gco">
    
    <xsl:output omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="oai:responseDate"/>
    <xsl:template match="oai:request"/>
    <xsl:template match="oai:GetRecord/oai:record/oai:header/oai:identifier"/>
    <xsl:template match="oai:GetRecord/oai:record/oai:header/oai:datestamp"/>
    <xsl:template match="oai:GetRecord/oai:record/oai:header/oai:setSpec"/>
    
    <xsl:param name="global_publisherName" select="'Default Publisher'"/>
    
    <xsl:template match="/">
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="//gmd:MD_Metadata"/>
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="node()"/>
    
    <xsl:template match="gmd:MD_Metadata">
        
        <resource xmlns="http://datacite.org/schema/kernel-2.2"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://datacite.org/schema/kernel-2.2
            http://schema.datacite.org/meta/kernel-2.2/metadata.xsd">    
            
            <identifier identifierType="">
                
            </identifier>
            
           
            <xsl:variable name="creatorName_sequence" as="xs:string*">
                <!-- Each individual name with appropriate role -->
                <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[string-length(normalize-space(gmd:individualName)) > 0]">
                    <xsl:if test="toDataCite:isCreator(gmd:role/gmd:CI_RoleCode/@codeListValue)">
                        <xsl:value-of select="normalize-space(gmd:individualName)"/> 
                    </xsl:if>
                </xsl:for-each>
                <!-- Each organisation name - where there isn't an individual name - with appropriate role -->
                <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[
                    (string-length(normalize-space(gmd:individualName)) = 0) and (string-length(normalize-space(gmd:organisationName)) > 0)]">
                    <xsl:if test="toDataCite:isCreator(gmd:role/gmd:CI_RoleCode/@codeListValue)">
                        <xsl:value-of select="normalize-space(gmd:organisationName)"/> 
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <xsl:for-each select="distinct-values($creatorName_sequence)">
                <creators>
                    <creator>
                        <creatorName>
                            <xsl:value-of select="."/>
                        </creatorName>
                    </creator>
                </creators>
            </xsl:for-each>
            
            <titles>
                <title>
                    <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title"/>
                </title>
            </titles>
            
            
            <xsl:variable name="publisherName_sequence" as="xs:string*">
                <!-- Each organisation name - where there isn't an individual name - with appropriate role -->
                <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[
                    (string-length(normalize-space(gmd:individualName)) = 0) and (string-length(normalize-space(gmd:organisationName)) > 0)]">
                    <xsl:if test="toDataCite:isPublisher(gmd:role/gmd:CI_RoleCode/@codeListValue)">
                        <xsl:value-of select="normalize-space(gmd:organisationName)"/> 
                    </xsl:if>
                </xsl:for-each>
                <!-- Each individual name with appropriate role -->
                <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[string-length(normalize-space(gmd:individualName)) > 0]">
                    <xsl:if test="toDataCite:isPublisher(gmd:role/gmd:CI_RoleCode/@codeListValue)">
                        <xsl:value-of select="normalize-space(gmd:individualName)"/> 
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            
            <!-- Take the first publisher - we need one only -->
            <xsl:if test="count($publisherName_sequence) > 0">
                 <publisher>
                     <xsl:value-of select="$publisherName_sequence[1]"/>
                 </publisher>
            </xsl:if>
            
            <xsl:variable name="publishDate_sequence">
                <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date">
                    <xsl:if test="contains(lower-case(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue), 'publication')">
                        <xsl:value-of select="normalize-space(gmd:date/gco:Date)"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            
            <!-- Take the first publish date - we need one only -->
            <xsl:if test="count($publishDate_sequence) > 0">
                <publicationYear>
                    <xsl:value-of select="$publishDate_sequence[1]"/>
                </publicationYear>
            </xsl:if>
            
          <xsl:variable name="subject_sequence" as="xs:string*">
                 <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory/gmd:MD_TopicCategoryCode">
                    <xsl:for-each select="tokenize(.,',')">
                       <xsl:value-of select='.'/>
                    </xsl:for-each>
                 </xsl:for-each>
                
                <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword">
                    <xsl:for-each select="tokenize(.,',')">
                        <xsl:value-of select='.'/>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:variable>
            
            <xsl:for-each select="distinct-values($subject_sequence)">
                <xsl:if test="string-length(normalize-space(.)) > 0">
                    <subject><xsl:value-of select="normalize-space(.)"/></subject>
                </xsl:if>
            </xsl:for-each>
            
            <xsl:variable name="contributorNameType_sequence" as="xs:string*">
                <!-- Each individual name with appropriate role -->
                <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[string-length(normalize-space(gmd:individualName)) > 0]">
                    <xsl:if test="toDataCite:isContributor(gmd:role/gmd:CI_RoleCode/@codeListValue)">
                        <xsl:value-of select="concat(normalize-space(gmd:individualName), '|', normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue))"/> 
                    </xsl:if>
                </xsl:for-each>
                <!-- Each individual name with appropriate role -->
                <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty[string-length(normalize-space(gmd:individualName)) > 0]">
                    <xsl:if test="toDataCite:isCreator(gmd:role/gmd:CI_RoleCode/@codeListValue)">
                        <xsl:value-of select="concat(normalize-space(gmd:individualName), '|', normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue))"/> 
                    </xsl:if>
                </xsl:for-each>
                <!-- Each organisation name - where there isn't an individual name - with appropriate role -->
                <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[
                    (string-length(normalize-space(gmd:individualName)) = 0) and (string-length(normalize-space(gmd:organisationName)) > 0)]">
                    <xsl:if test="toDataCite:isContributor(gmd:role/gmd:CI_RoleCode/@codeListValue)">
                        <xsl:message select="'isContributor - returned true'"/>
                        <xsl:value-of select="concat(normalize-space(gmd:organisationName), '|', normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue))"/> 
                    </xsl:if>
                </xsl:for-each>
                <!-- Each organisation name - where there isn't an individual name - with appropriate role -->
                <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty[
                    (string-length(normalize-space(gmd:individualName)) = 0) and (string-length(normalize-space(gmd:organisationName)) > 0)]">
                    <xsl:if test="toDataCite:isContributor(gmd:role/gmd:CI_RoleCode/@codeListValue)">
                        <xsl:message select="'isContributor - returned true'"/>
                        <xsl:value-of select="concat(normalize-space(gmd:organisationName), '|', normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue))"/> 
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <xsl:for-each select="distinct-values($contributorNameType_sequence)">
                <xsl:variable name="contributorType_pair" as="xs:string*" select="tokenize(normalize-space(.),'\|')"/>
                <xsl:if test="count($contributorType_pair) = 2">
                    <contributors>
                        <contributor>
                            <contributorName contributorType="{toDataCite:transformContributorType($contributorType_pair[2])}">
                                <xsl:value-of select="$contributorType_pair[1]"/>
                            </contributorName>
                        </contributor>
                    </contributors>
                </xsl:if>
            </xsl:for-each>
        </resource>
    </xsl:template>
    
    <xsl:function name="toDataCite:isCreator" as="xs:boolean">
        <xsl:param name="role"/>
        <xsl:message select="concat('isCreator - role: ', $role)"/>
        <xsl:choose>
            <xsl:when test="
                $role = 'author' or
                $role = 'originator' or
                $role = 'principalInvestigator'">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'isCreator - returning false()'"/>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="toDataCite:isContributor" as="xs:boolean">
        <xsl:param name="role"/>
        <xsl:message select="concat('isContributor - role: ', $role)"/>
        <xsl:choose>
           <xsl:when test="
               $role != 'author' and
               $role != 'principalInvestigator' and
               $role != 'originator' and
               $role != 'publisher'">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'isContributor - returning false()'"/>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="toDataCite:isPublisher" as="xs:boolean">
        <xsl:param name="role"/>
        <xsl:message select="concat('isPublisher - role: ', $role)"/>
        <xsl:choose>
            <xsl:when test="$role = 'publisher'">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'isPublisher - returning false()'"/>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Datacite MetadataSchema 3.0 - Contributor Types
        
        ContactPerson 
        DataCollector 
        DataManager 
        Distributor 
        Editor 
        Funder 
        HostingInstitution 
        Producer 
        ProjectLeader 
        ProjectManager 
        ProjectMember 
        RegistrationAgency 
        RegistrationAuthority 
        RelatedPerson 
        Researcher 
        ResearchGroup 
        RightsHolder 
        Sponsor 
        Supervisor 
        WorkPackageLeader 
        Other
        -->
    
    <xsl:function name="toDataCite:transformContributorType">
        <xsl:param name="contributorType"/>
        <xsl:choose>
            <xsl:when test="contains($contributorType, 'resourceProvider')">
                <xsl:text></xsl:text>
            </xsl:when>
        </xsl:choose>

    </xsl:function>
    
       
</xsl:stylesheet>