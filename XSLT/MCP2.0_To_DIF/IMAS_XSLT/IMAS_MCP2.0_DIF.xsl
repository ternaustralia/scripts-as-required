<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:gml="http://www.opengis.net/gml" 
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:local="http://local.function" 
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xsi:schemaLocation="http://schemas.aodn.org.au/mcp-2.0 http://schemas.aodn.org.au/mcp-2.0/schema.xsd http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20060504/srv/srv.xsd"
    exclude-result-prefixes="xsi gmd srv gml gco xs">
   
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="//*:MD_Metadata" mode="DIF"/>
    </xsl:template>
    
    <!-- Conversion from Marine Community Profile 2.0 XML to DIF 9.9.3 XML -->
    <!-- Applies mapping rules provided by Emma Flukes emma.flukes@utas.edu.au -->
    
    <xsl:template match="*:MD_Metadata" mode="DIF">
        
        <DIF xmlns="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/" xmlns:dif="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/ https://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/dif_v9.9.3.xsd">
            
            <xsl:apply-templates select="gmd:fileIdentifier" mode="DIF_Entry_ID"/>
            
            <xsl:apply-templates select="gmd:identificationInfo/*:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title" mode="DIF_Entry_Title"/>
            
            <xsl:apply-templates select="gmd:identificationInfo/*:MD_DataIdentification" mode="DIF_Data_Set_Citation"/>
            
            <xsl:apply-templates select="gmd:identificationInfo/*:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty" mode="DIF_Personnel"/>
            
            <xsl:apply-templates select="gmd:identificationInfo/*:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords[contains(lower-case(gmd:thesaurusName/gmd:CI_Citation/gmd:title), 'gcmd')]/gmd:keyword" mode="DIF_Parameters"/>
            
            <xsl:apply-templates select="gmd:identificationInfo/*:MD_DataIdentification/gmd:topicCategory/gmd:MD_TopicCategoryCode" mode="DIF_ISO_Topic_Category"/>
            
            <xsl:apply-templates select="gmd:identificationInfo/*:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords[not (contains(lower-case(gmd:thesaurusName/gmd:CI_Citation/gmd:title), 'gcmd'))]/gmd:keyword" mode="DIF_Keyword"/>
            
            <xsl:apply-templates select="gmd:identificationInfo/*:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/*:EX_TemporalExtent/gmd:extent/gml:TimePeriod" mode="DIF_Temporal_Coverage"/>
            
            <xsl:apply-templates select="gmd:identificationInfo/*:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/*:EX_TemporalExtent/gmd:extent/gml:TimeInstant/gml:timePosition" mode="DIF_Temporal_Coverage"/>
            
            <xsl:apply-templates select="gmd:identificationInfo/*:MD_DataIdentification/gmd:status/gmd:MD_ProgressCode" mode="DIF_Data_Set_Progress"/>
            
            <xsl:apply-templates select="gmd:identificationInfo/*:MD_DataIdentification/gmd:extent/gmd:EX_Extent" mode="DIF_Spatial_Coverage"/>
            
            <xsl:apply-templates select="gmd:identificationInfo/*:MD_DataIdentification/gmd:resourceConstraints/*:MD_Commons/*:otherConstraints" mode="DIF_Access_Constraints"/>
            
            <xsl:apply-templates select="gmd:language" mode="DIF_Data_Set_Language"/>
            
            <xsl:apply-templates select="gmd:contact/gmd:CI_ResponsibleParty[contains(lower-case(gmd:positionName), 'data manager')]" mode="DIF_Data_Centre"/>
            
            <xsl:apply-templates select="gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format" mode="DIF_Distribution"/>
            
            <xsl:apply-templates select="gmd:identificationInfo/*:MD_DataIdentification/gmd:credit" mode="DIF_Reference"/>
    
            <Summary>
                <xsl:apply-templates select="gmd:identificationInfo/*:MD_DataIdentification/gmd:abstract" mode="DIF_Summary_Abstract"/>
                <xsl:apply-templates select="gmd:identificationInfo/*:MD_DataIdentification/gmd:purpose" mode="DIF_Summary_Purpose"/>
            </Summary>
            
            <xsl:apply-templates select="gmd:distributionInfo/gmd:MD_Distribution" mode="DIF_Related_URL"/>
            
            <xsl:apply-templates select="gmd:parentIdentifier" mode="DIF_Parent_DIF"/>
            
            <Originating_Metadata_Node>GCMD</Originating_Metadata_Node>
            <Metadata_Name>CEOS IDN DIF</Metadata_Name>
            <Metadata_Version>VERSION 9.9.3</Metadata_Version>
            
            <xsl:apply-templates select="gmd:identificationInfo/*:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date[contains(lower-case(gmd:dateType/gmd:CI_DateTypeCode), 'creation')]/gmd:date/gco:DateTime" mode="DIF_Creation_Date"/>
            
            <xsl:apply-templates select="*:revisionDate" mode="DIF_Last_DIF_Revision_Date"/>
        </DIF>
    </xsl:template>
        
    <xsl:template match="gmd:fileIdentifier" mode="DIF_Entry_ID">
        <Entry_ID><xsl:value-of select="."/></Entry_ID>
    </xsl:template>
    
    <xsl:template match="gmd:title" mode="DIF_Entry_Title">
        <Entry_Title><xsl:value-of select="."/></Entry_Title>
    </xsl:template>
    
    <xsl:template match="*:MD_DataIdentification" mode="DIF_Data_Set_Citation">
        
        <xsl:variable name="citedResponsiblePartyIndividualNames_NoTitle_sequence" as="xs:string*">
            <xsl:for-each select="distinct-values(gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:individualName)">
                <xsl:variable name="individualNamesOnly_sequence" select="local:individualNamesOnly_sequence(.)"/>
                <xsl:for-each select="$individualNamesOnly_sequence">
                    <xsl:if test="count($individualNamesOnly_sequence) &gt; position()">
                        <xsl:copy-of select="."/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        
        <Data_Set_Citation>
            <Dataset_Creator>
                <xsl:value-of select="string-join($citedResponsiblePartyIndividualNames_NoTitle_sequence, ', ')"/>
            </Dataset_Creator>
            <Dataset_Title>
                <xsl:value-of select="gmd:citation/gmd:CI_Citation/gmd:title"/>
            </Dataset_Title>
            <Dataset_Release_Date>
                <xsl:value-of select="gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:authority/gmd:CI_Citation/gmd:date/gmd:CI_Date[contains(lower-case(gmd:dateType/gmd:CI_DateTypeCode), 'publication')]/gmd:date/gco:DateTime"/>
            </Dataset_Release_Date>
            
            <xsl:variable name="citedResponsiblePartyOrganisationNames_sequence"
                select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName">
            </xsl:variable>
            <Dataset_Publisher>
                <xsl:if test="count($citedResponsiblePartyOrganisationNames_sequence) > 0">
                    <xsl:value-of select="$citedResponsiblePartyOrganisationNames_sequence[1]"/>
                </xsl:if>
            </Dataset_Publisher>
            <Dataset_DOI>
                <xsl:variable name="doi" select="gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code[contains(., 'doi') or contains(., '10.')]"/>
                <xsl:choose>
                    <xsl:when test="contains($doi, 'doi:')">
                        <xsl:value-of select="substring-after($doi, 'doi:')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$doi"/>
                    </xsl:otherwise>
                </xsl:choose>
                
            </Dataset_DOI>
        </Data_Set_Citation>
    </xsl:template>
    
    <xsl:template match="gmd:CI_ResponsibleParty" mode="DIF_Personnel">
        
        <xsl:variable name="namePart_sequence" select="local:individualNamesOnly_sequence(gmd:individualName)" as="xs:string*"/>
         
        <Personnel>
            <Role><xsl:value-of select="local:mapRole_ISO_DIF(gmd:role/gmd:CI_RoleCode)"/></Role>
            <First_Name>
                <xsl:if test="count($namePart_sequence) > 1">
                    <xsl:value-of select="$namePart_sequence[2]"/>
                </xsl:if>
            </First_Name>
            <Last_Name>
                <xsl:if test="count($namePart_sequence) > 0">
                    <xsl:value-of select="$namePart_sequence[1]"/>
                </xsl:if>
            </Last_Name>
            
            <xsl:apply-templates select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address" mode="DIF_Personnel_Address"/>
        </Personnel>
        
    </xsl:template>
       
    <xsl:template match="gmd:CI_Address" mode="DIF_Personnel_Address">
            <Email>
                <xsl:value-of select="gmd:electronicMailAddress"/>
            </Email>
            <Contact_Address>
                <xsl:for-each select="gmd:deliveryPoint">
                    <Address>
                        <xsl:value-of select="."/>
                    </Address>
                </xsl:for-each>    
                <City>
                    <xsl:value-of select="gmd:city"></xsl:value-of>
                </City>
                <Province_or_State>
                    <xsl:value-of select="gmd:administrativeArea"></xsl:value-of>
                </Province_or_State>
                <Postal_Code>
                    <xsl:value-of select="gmd:postalCode"></xsl:value-of>
                </Postal_Code>
                <Country>
                        <xsl:value-of select="gmd:country"></xsl:value-of>
                </Country>
            </Contact_Address>
    </xsl:template>


    <xsl:template match="gmd:keyword" mode="DIF_Parameters">
        
        <xsl:variable name="parameter_sequence" select="tokenize(., '\|')"/>
        
        <Parameters>
            
        <xsl:if test="count($parameter_sequence) > 0">
        
                <Category>
                    <xsl:if test="count($parameter_sequence) > 0">
                        <xsl:value-of select="$parameter_sequence[1]"/>
                    </xsl:if>
                </Category>
                <Topic>
                    <xsl:if test="count($parameter_sequence) > 1">
                        <xsl:value-of select="$parameter_sequence[2]"/>
                    </xsl:if>
                </Topic>
                <Term>
                    <xsl:if test="count($parameter_sequence) > 2">
                        <xsl:value-of select="$parameter_sequence[3]"/>
                    </xsl:if>
                </Term>
                <Variable_Level_1>
                    <xsl:if test="count($parameter_sequence) > 3">
                       <xsl:value-of select="$parameter_sequence[4]"/>
                    </xsl:if>
                </Variable_Level_1>
                
            <Variable_Level_2>
                <xsl:if test="count($parameter_sequence) > 4">
                    <xsl:value-of select="$parameter_sequence[5]"/>
                </xsl:if>
            </Variable_Level_2>
            
            </xsl:if>
        </Parameters>
    </xsl:template>
    
    <xsl:template match="gmd:MD_TopicCategoryCode" mode="DIF_ISO_Topic_Category">
        <ISO_Topic_Category>
            <xsl:value-of select="."/>
        </ISO_Topic_Category>
    </xsl:template>
    
    <xsl:template match="gmd:keyword" mode="DIF_Keyword">
        <Keyword>
            <xsl:value-of select="."/>
        </Keyword>
    </xsl:template>
    
    <xsl:template match="gml:TimePeriod" mode="DIF_Temporal_Coverage">
    
        <Temporal_Coverage>
            <Start_Date>
                <xsl:value-of select="local:truncDate(gml:beginPosition)"/>
            </Start_Date>
            <Stop_Date>
                <xsl:value-of select="local:truncDate(gml:endPosition)"/>
            </Stop_Date>
        </Temporal_Coverage>
        
    </xsl:template>
    
    <xsl:template match="gml:timePosition" mode="DIF_Temporal_Coverage">
        
        <Temporal_Coverage>
            <Start_Date>
                <xsl:value-of select="local:truncDate(.)"/>
            </Start_Date>
        </Temporal_Coverage>
    </xsl:template>
    

    <xsl:template match="gmd:MD_ProgressCode" mode="DIF_Data_Set_Progress">
        <Data_Set_Progress>
            <xsl:choose>
                <xsl:when test="contains(lower-case(.), 'ongoing')">
                    <xsl:text>IN WORK</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(.), 'completed')">
                    <xsl:text>COMPLETE</xsl:text>
                </xsl:when>
            </xsl:choose>
        </Data_Set_Progress>
    </xsl:template>
    
    <xsl:template match="gmd:EX_Extent" mode="DIF_Spatial_Coverage">
    
        <Spatial_Coverage>
            <Southernmost_Latitude>
                <xsl:value-of select="gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude"/>
            </Southernmost_Latitude>
            <Northernmost_Latitude>
                <xsl:value-of select="gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude"/>
            </Northernmost_Latitude>
            <Westernmost_Longitude>
                <xsl:value-of select="gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude"/>
            </Westernmost_Longitude>
            <Easternmost_Longitude>
                <xsl:value-of select="gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude"/>
            </Easternmost_Longitude>
            <Minimum_Depth>
                <xsl:value-of select="gmd:verticalElement/gmd:EX_VerticalExtent/gmd:minimumValue"/>
            </Minimum_Depth>
            <Maximum_Depth>
                <xsl:value-of select="gmd:verticalElement/gmd:EX_VerticalExtent/gmd:maximumValue"/>
            </Maximum_Depth>
        </Spatial_Coverage>
        
    </xsl:template>
    
    <xsl:template match="*:otherConstraints" mode="DIF_Access_Constraints">
        <Access_Constraints>
           <xsl:value-of select="."/>
        </Access_Constraints>
    </xsl:template>
    
    <xsl:template match="gmd:language" mode="DIF_Data_Set_Language">
        <Data_Set_Language>
            <xsl:if test="contains(lower-case(.), 'eng')">
                <xsl:text>English</xsl:text>
            </xsl:if>
        </Data_Set_Language>
    </xsl:template>
    
   
    <xsl:template match="gmd:CI_ResponsibleParty" mode="DIF_Data_Centre">
        <Data_Center>
            <Data_Center_Name>
                <Short_Name>
                    <xsl:if test="contains(lower-case(gmd:organisationName), 'aims') or contains(lower-case(gmd:organisationName), 'institute for marine and antarctic studies')">
                        <xsl:text>AU/IMAS</xsl:text>
                    </xsl:if>
                </Short_Name>
                <Long_Name>
                    <xsl:choose>
                        <xsl:when test="contains(gmd:organisationName, ',')">
                            <xsl:value-of select="substring-before(gmd:organisationName, ',')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="gmd:organisationName"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </Long_Name>
            </Data_Center_Name>
            <Personnel>
                <Role>DATA CENTER CONTACT</Role>
                <First_Name>
                    <xsl:choose>
                        <xsl:when test="contains(gmd:organisationName, ',')">
                            <xsl:value-of select="substring-before(gmd:organisationName, ',')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="gmd:organisationName"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </First_Name>
                <Middle_Name/>
                <Last_Name/>
                <Email>
                    <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress"/>
                </Email>
            </Personnel>
        </Data_Center>
    </xsl:template>
    
    <xsl:template match="gmd:MD_Format" mode="DIF_Distribution">
        <Distribution>
            <Distribution_Media>FTP</Distribution_Media>
            <Distribution_Format>
                <xsl:value-of select="gmd:name"/>
             </Distribution_Format>
        </Distribution>
        
    </xsl:template>
    
    <xsl:template match="gmd:credit" mode="DIF_Reference">
        <Reference>
           <xsl:value-of select="."/>
        </Reference>
    </xsl:template>
   
    <xsl:template match="gmd:abstract" mode="DIF_Summary_Abstract">
        <Abstract>
            <xsl:value-of select="."/>
        </Abstract>
    </xsl:template>
    
    <xsl:template match="gmd:purpose" mode="DIF_Summary_Purpose">
        <Purpose>
            <xsl:value-of select="."/>
        </Purpose>
    </xsl:template>
    
    <xsl:template match="gmd:MD_Distribution" mode="DIF_Related_URL">
        <Related_URL>
        </Related_URL>
    </xsl:template>
        
        
        <xsl:template match="gmd:parentIdentifier" mode="DIF_Parent_DIF">
            <Parent_DIF>
                <xsl:value-of select="."/>
            </Parent_DIF>
        </xsl:template>
        
        <xsl:template match="gco:DateTime" mode="DIF_Creation_Date">
            <DIF_Creation_Date>
                <xsl:value-of select="local:truncDate(.)"/>
             </DIF_Creation_Date>
        </xsl:template>
        
        <xsl:template match="*:revisionDate" mode="DIF_Last_DIF_Revision_Date">
            <Last_DIF_Revision_Date>
                <xsl:value-of select="local:truncDate(.)"/>
            </Last_DIF_Revision_Date>
        </xsl:template>


    <xsl:function name="local:mapRole_ISO_DIF">
        <xsl:param name="role"></xsl:param>
        <xsl:choose>
            <xsl:when test="contains(lower-case($role), 'principalinvestigator')">
                <xsl:text>INVESTIGATOR</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($role), 'pointofcontact')">
                <xsl:text>TECHNICAL CONTACT</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:individualNamesOnly_sequence" as="xs:string*">
        <xsl:param name="individualName"/>
        
        <!-- Filter out each name and title, so allow a '/' as in 'Assoc/Prof', and include '.' as after an initial-->
       <xsl:analyze-string select="$individualName" regex="(\?=^|\w)[A-z/.]+">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(0)"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
  
    </xsl:function>
    
    <xsl:function name="local:truncDate">
        <xsl:param name="dateIn"></xsl:param>
        <xsl:choose>
            <xsl:when test="contains($dateIn, 'T')">
                <xsl:value-of select="substring-before($dateIn, 'T')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$dateIn"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    
</xsl:stylesheet>
