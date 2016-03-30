<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:ro="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:nesp="https://intranet.ands.org.au/display/TEAM/NESP+-+National+Environmental+Science+Program"
    version="2.0" >
        
    <xsl:output method="xml"/>
    
 <!-- set NESP program -->
    <xsl:variable name="parent-program-purl">http://purl.org/au-research/grants/doe/nesp</xsl:variable>

 <!-- set DOE as funder -->
    <xsl:variable name="funder">http://dx.doi.org/10.13039/501100003531</xsl:variable>
           
    <xsl:template match="/root">
        <xsl:text>&#xA;</xsl:text>
        <xsl:element name="registryObjects" xmlns="http://ands.org.au/standards/rif-cs/registryObjects">
            <xsl:attribute name="xsi:schemaLocation">http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:attribute>             
            <xsl:apply-templates select="row[*//string-length(text()) > 0]"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="row">
        
        <xsl:if test="Project_ID != ''">
  <!-- set purl for parent program from Program column -->
            <xsl:variable name="program_purl"><xsl:value-of select="concat($parent-program-purl,'/',lower-case(normalize-space(Program)))"/></xsl:variable>
            
  <!-- set Project ID -->
            <xsl:variable name="project"><xsl:value-of select="lower-case(normalize-space(Project_ID))"/></xsl:variable>
            
  <!-- registry object -->
            <xsl:element name="registryObject" xmlns="http://ands.org.au/standards/rif-cs/registryObjects">
                <xsl:attribute name="group">Department of the Environment</xsl:attribute>
            <xsl:text>&#xA;</xsl:text>
            <xsl:variable name="key"><xsl:value-of select="concat($program_purl,'/',$project)"/></xsl:variable>
            <xsl:element name="key"><xsl:value-of select="$key"/></xsl:element>
            <xsl:text>&#xA;</xsl:text>
                <xsl:element name="originatingSource">Scraped from the Web</xsl:element>
            <xsl:text>&#xA;</xsl:text>
            
  <!-- activity -->
                <xsl:element name="activity">
                    <xsl:attribute name="type">grant</xsl:attribute>

                    <!-- title -->
                    <xsl:element name="name">
                        <xsl:attribute name="type">primary</xsl:attribute>
                        <xsl:element name="namePart">
                            <xsl:value-of select="Project_Title"/>
                        </xsl:element>
                    </xsl:element>

                    <!-- identifiers -->
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:element name="identifier">
                        <xsl:attribute name="type">purl</xsl:attribute>
                        <xsl:value-of select="$key"/>
                    </xsl:element>


                    <!-- parent program  -->
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:element name="relatedObject">
                        <xsl:element name="key">
                            <xsl:value-of select="$program_purl"/>
                        </xsl:element>
                        <xsl:element name="relation">
                            <xsl:attribute name="type">isPartOf</xsl:attribute>
                        </xsl:element>
                    </xsl:element>

                    <!-- funder -->

                    <xsl:text>&#xA;</xsl:text>
                    <xsl:element name="relatedInfo">
                        <xsl:attribute name="type" select="'party'"/>
                        <xsl:element name="identifier">
                            <xsl:attribute name="type" select="nesp:identifierType($funder)"/>
                            <xsl:value-of select="$funder"/>
                        </xsl:element>
                        <xsl:element name="relation">
                            <xsl:attribute name="type">isFundedBy</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="title">
                            <xsl:text>Department of the Environment</xsl:text>
                        </xsl:element>
                    </xsl:element>

                    <!-- administering institution -->
                    <xsl:if test="normalize-space(Managing_Institution) != ''">
                        <xsl:for-each select="tokenize(Managing_Institution,';')">
                            <xsl:text>&#xA;</xsl:text>
                            <xsl:variable name="managerID" select="normalize-space(substring-after(.,'|'))"/>
                            <xsl:variable name="managerName">
                                <xsl:choose>
                                    <xsl:when test="contains(., '|')">
                                        <xsl:value-of select="normalize-space(substring-before(.,'|'))"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$managerID != ''">
                                    <xsl:element name="relatedInfo">
                                        <xsl:attribute name="type" select="'party'"/>
                                        <xsl:element name="identifier">
                                            <xsl:attribute name="type" select="nesp:identifierType($managerID)"/>
                                            <xsl:value-of select="$managerID"/>
                                        </xsl:element>
                                        <xsl:element name="relation">
                                            <xsl:attribute name="type">hasManager</xsl:attribute>
                                        </xsl:element>
                                        <xsl:if test="string-length($managerName) > 0">
                                            <xsl:element name="title">
                                                <xsl:value-of select="$managerName"/>
                                            </xsl:element>
                                        </xsl:if>
                                    </xsl:element>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="string-length($managerID) = 0">
                                        <xsl:if test="string-length($managerName) > 0">
                                            <xsl:element name="description">
                                                <xsl:attribute name="type">managers</xsl:attribute>
                                                <xsl:value-of select="$managerName"/>
                                            </xsl:element>
                                        </xsl:if>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:if>
                    

                    <xsl:if test="normalize-space(Partner_Institution) != ''">
                        <xsl:for-each select="tokenize(Partner_Institution,';')">
                            <xsl:text>&#xA;</xsl:text>
                            <xsl:variable name="partnerID" select="normalize-space(substring-after(.,'|'))"/>
                            <xsl:variable name="partnerName">
                                <xsl:choose>
                                    <xsl:when test="contains(., '|')">
                                        <xsl:value-of select="normalize-space(substring-before(.,'|'))"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$partnerID != ''">
                                    <xsl:element name="relatedInfo">
                                        <xsl:attribute name="type" select="'party'"/>
                                        <xsl:element name="identifier">
                                            <xsl:attribute name="type" select="nesp:identifierType($partnerID)"/>
                                            <xsl:value-of select="$partnerID"/>
                                        </xsl:element>
                                        <xsl:element name="relation">
                                            <xsl:attribute name="type">hasParticipant</xsl:attribute>
                                        </xsl:element>
                                        <xsl:if test="string-length($partnerName) > 0">
                                            <xsl:element name="title">
                                                <xsl:value-of select="$partnerName"/>
                                            </xsl:element>
                                        </xsl:if>
                                    </xsl:element>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="string-length($partnerID) = 0">
                                        <xsl:if test="string-length($partnerName) > 0">
                                            <xsl:element name="description">
                                                <xsl:attribute name="type">partners</xsl:attribute>
                                                <xsl:value-of select="$partnerName"/>
                                            </xsl:element>
                                        </xsl:if>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:if>
                    



                    <!-- Descriptions -->
                    <!-- brief -->
                    <xsl:if test="Description != ''">
                        <xsl:text>&#xA;</xsl:text>
                        <xsl:element name="description">
                            <xsl:attribute name="type">brief</xsl:attribute>
                            <xsl:for-each select="tokenize(Description,'&#10;')">
                                <xsl:variable name="para" select="normalize-space(.)"/>
                                <xsl:if test="normalize-space($para) != ''">
                                    <xsl:text>&amp;lt;p&amp;gt;</xsl:text>
                                    <xsl:value-of select="$para"/>
                                    <xsl:text>&#xA;</xsl:text>
                                    <xsl:text>&amp;lt;/p&amp;gt;</xsl:text>

                                </xsl:if>
                            </xsl:for-each>
                        </xsl:element>

                    </xsl:if>


                    <!-- Notes -->
                    <xsl:if test="normalize-space(Funding_Note) != ''">
                        <xsl:text>&#xA;</xsl:text>
                        <xsl:element name="description">
                            <xsl:attribute name="type">note</xsl:attribute>
                            <xsl:value-of select="Funding_Note"/>
                        </xsl:element>
                    </xsl:if>

                    <!-- Subjects -->
                    <xsl:if test="normalize-space(Project_Keywords) != ' '">
                        <xsl:for-each select="tokenize(Project_Keywords,';')">
                            <xsl:variable name="subject" select="normalize-space(.)"/>
                            <xsl:text>&#xA;</xsl:text>
                            <xsl:if test="$subject != ''">
                                <xsl:element name="subject">
                                    <xsl:attribute name="type">local</xsl:attribute>
                                    <xsl:value-of select="$subject"/>
                                </xsl:element>
                            </xsl:if>
                        </xsl:for-each>

                    </xsl:if>

                    <!-- Lead Investigator -->
                    <xsl:if test="normalize-space(Lead_Researcher) != ''">
                        <xsl:for-each select="tokenize(Lead_Researcher,';')">
                            <xsl:text>&#xA;</xsl:text>
                            <xsl:variable name="leadResearcherID" select="normalize-space(substring-after(.,'|'))"/>
                            <xsl:variable name="leadResearcherName">
                                <xsl:choose>
                                    <xsl:when test="contains(., '|')">
                                        <xsl:value-of select="normalize-space(substring-before(.,'|'))"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$leadResearcherID != ''">
                                 <xsl:element name="relatedInfo">
                                     <xsl:attribute name="type" select="'party'"/>
                                     <xsl:element name="identifier">
                                         <xsl:attribute name="type" select="nesp:identifierType($leadResearcherID)"/>
                                         <xsl:value-of select="$leadResearcherID"/>
                                     </xsl:element>
                                     <xsl:element name="relation">
                                         <xsl:attribute name="type">hasPrincipalInvestigator</xsl:attribute>
                                     </xsl:element>
                                     <xsl:if test="string-length($leadResearcherName) > 0">
                                         <xsl:element name="title">
                                             <xsl:value-of select="$leadResearcherName"/>
                                         </xsl:element>
                                     </xsl:if>
                                 </xsl:element>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="string-length($leadResearcherID) = 0">
                                        <xsl:if test="string-length($leadResearcherName) > 0">
                                            <xsl:element name="description">
                                                <xsl:attribute name="type">researchers</xsl:attribute>
                                                <xsl:value-of select="$leadResearcherName"/>
                                            </xsl:element>
                                        </xsl:if>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:if>
                    
                    <xsl:if test="normalize-space(Other_Researcher) != ''">
                        <xsl:for-each select="tokenize(Other_Researcher,';')">
                            <xsl:text>&#xA;</xsl:text>
                            <xsl:variable name="otherResearcherID" select="normalize-space(substring-after(.,'|'))"/>
                            <xsl:variable name="otherResearcherName">
                                <xsl:choose>
                                    <xsl:when test="contains(., '|')">
                                        <xsl:value-of select="normalize-space(substring-before(.,'|'))"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$otherResearcherID != ''">
                                    <xsl:element name="relatedInfo">
                                        <xsl:attribute name="type" select="'party'"/>
                                        <xsl:element name="identifier">
                                            <xsl:attribute name="type" select="nesp:identifierType($otherResearcherID)"/>
                                            <xsl:value-of select="$otherResearcherID"/>
                                        </xsl:element>
                                        <xsl:element name="relation">
                                            <xsl:attribute name="type">hasParticipant</xsl:attribute>
                                        </xsl:element>
                                        <xsl:if test="string-length($otherResearcherName) > 0">
                                            <xsl:element name="title">
                                                <xsl:value-of select="$otherResearcherName"/>
                                            </xsl:element>
                                        </xsl:if>
                                    </xsl:element>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="string-length($otherResearcherID) = 0">
                                        <xsl:if test="string-length($otherResearcherName) > 0">
                                            <xsl:element name="description">
                                                <xsl:attribute name="type">researchers</xsl:attribute>
                                                <xsl:value-of select="$otherResearcherName"/>
                                            </xsl:element>
                                        </xsl:if>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:if>
                    
                  
                    <!-- web page about project -->
                    <xsl:if test="Description_URL != ''">
                        <xsl:text>&#xA;</xsl:text>
                        <xsl:element name="relatedInfo">
                            <xsl:attribute name="type">website</xsl:attribute>
                            <xsl:element name="identifier">
                                <xsl:attribute name="type">uri</xsl:attribute>
                                <xsl:value-of select="Description_URL"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>

                    <!-- Existence Dates -->

                    <xsl:variable name="startdate" select="normalize-space(Start)"/>
                    <xsl:variable name="enddate" select="normalize-space(End)"/>
                    <xsl:if test="$startdate != '' or $enddate != ''">
                        <xsl:element name="existenceDates">
                            <xsl:if test="$startdate !=''">
                                <xsl:element name="startDate">
                                    <xsl:attribute name="dateFormat">W3CDTF</xsl:attribute>
                                    <xsl:choose>
                                        <xsl:when test="contains($startdate, 'T00:00:00')">
                                            <xsl:value-of
                                                select="substring-before($startdate, 'T00:00:00')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$startdate"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:element>
                            </xsl:if>
                            <xsl:if test="$enddate !=''">
                                <xsl:element name="endDate">
                                    <xsl:attribute name="dateFormat">W3CDTF</xsl:attribute>
                                    <xsl:choose>
                                        <xsl:when test="contains($enddate, 'T00:00:00')">
                                            <xsl:value-of
                                                select="substring-before($enddate, 'T00:00:00')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$enddate"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:element>
                            </xsl:if>
                        </xsl:element>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                </xsl:element> <!-- activity -->
                <xsl:text>&#xA;</xsl:text>
            </xsl:element> <!-- registryObject -->
        </xsl:if>

    </xsl:template> 
    
    <xsl:function name="nesp:identifierType">
        <xsl:param name="identifier"/>
        
        <xsl:choose>
            <xsl:when test="contains($identifier,'nla.party')">
                <xsl:text>AU-ANL:PEAU</xsl:text>
            </xsl:when>
            <xsl:when test="contains($identifier,'orcid')">
                <xsl:text>orcid</xsl:text>
            </xsl:when>
            <xsl:when test="contains($identifier,'doi.org')">
                <xsl:text>doi</xsl:text>
            </xsl:when>
            <xsl:when test="contains($identifier,'http')">
                <xsl:text>uri</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>global</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!--xsl:template match="*"/-->

</xsl:stylesheet>
