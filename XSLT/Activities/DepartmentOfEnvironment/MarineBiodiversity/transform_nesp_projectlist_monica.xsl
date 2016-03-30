<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:ro="http://ands.org.au/standards/rif-cs/registryObjects" 
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
            <xsl:apply-templates/>
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
                        <xsl:element name="key"><xsl:value-of select="$program_purl"/></xsl:element>
                        <xsl:element name="relation"><xsl:attribute name="type">isPartOf</xsl:attribute></xsl:element>
                    </xsl:element>             
                
<!-- funder -->
                    
                <xsl:text>&#xA;</xsl:text>
                <xsl:element name="relatedObject">
                    <xsl:element name="key"><xsl:value-of select="$funder"/></xsl:element>
                    <xsl:element name="relation"><xsl:attribute name="type">isFundedBy</xsl:attribute></xsl:element>
                </xsl:element> 
                
<!-- administering institution -->              

                <xsl:if test="Managing_Institution_ID">
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:element name="relatedObject">
                        <xsl:element name="key"><xsl:value-of select="Managing_Institution_ID"/></xsl:element>
                        <xsl:element name="relation"><xsl:attribute name="type">isManagedBy</xsl:attribute></xsl:element>
                    </xsl:element>       
                </xsl:if>
                
<!-- partner institutions -->
                <xsl:if test="normalize-space(Partner_Institution_ID) != ''">
                    <xsl:for-each select="tokenize(Partner_Institution_ID,';')">
                        <xsl:variable name="partner"><xsl:value-of select="normalize-space(.)"/></xsl:variable>
                        <xsl:text>&#xA;</xsl:text>
                        <xsl:if test="$partner!=''">
                         <xsl:element name="relatedObject">
                            <xsl:element name="key"><xsl:value-of select="$partner"/></xsl:element>
                            <xsl:element name="relation"><xsl:attribute name="type">hasParticipant</xsl:attribute></xsl:element>
                         </xsl:element> 
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
                
 

<!-- Descriptions -->
    <!-- brief -->
                <xsl:if test="Description != ''"> 
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:element name="description">
                      <xsl:attribute name="type">brief</xsl:attribute>
                        <xsl:for-each select="tokenize(Description,'&#10;')">
                            <xsl:variable name="para" select="normalize-space(.)"></xsl:variable>
                            <xsl:if test="$para!=' '">
                                <xsl:text>&amp;lt;p&amp;gt;</xsl:text>
                                <xsl:value-of select="$para"></xsl:value-of>
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
                <xsl:if test="Project_Keywords != ' '">
                    <xsl:for-each select="tokenize(Project_Keywords,';')">
                        <xsl:variable name="subject"><xsl:value-of select="normalize-space(.)"/></xsl:variable>
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
                <xsl:if test="normalize-space(Lead_Researcher_ID) != ''">
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:element name="relatedInfo">
                        <xsl:attribute name="type">party</xsl:attribute>
                        <xsl:element name="identifier">
                            <xsl:attribute name="type">
                                <xsl:choose>
                                    <xsl:when test="contains(Lead_Researcher_ID,'nla.party')">
                                        <xsl:text>AU-ANL:PEAU</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(Lead_Researcher_ID,'orcid')">
                                        <xsl:text>AU-YORCID</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>URI</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:value-of select="Lead_Researcher_ID"/></xsl:element>
                        <xsl:element name="relation"><xsl:attribute name="type">hasPrincipalInvestigator</xsl:attribute></xsl:element>
                    </xsl:element>    
                </xsl:if>
                
                <xsl:if test="normalize-space(Lead_Researcher_ID) = ''">
                    <xsl:if test="normalize-space(Lead_Researcher_Name) != ''">
                        <xsl:text>&#xA;</xsl:text>
                        <xsl:element name="description">
                            <xsl:attribute name="type">researchers</xsl:attribute>
                            <xsl:value-of select="Lead_Researcher_Name"/>
                        </xsl:element>
                    </xsl:if>  
                    
                </xsl:if>
                
 <!-- Other Researcher -->
                <xsl:if test="normalize-space(Other_Researcher_ID) != ''">
                    <xsl:for-each select="tokenize(Other_Researcher_ID,';')">
                        <xsl:variable name="researcher"><xsl:value-of select="normalize-space(.)"/></xsl:variable>
                        <xsl:text>&#xA;</xsl:text>
                        <xsl:element name="relatedInfo">
                            <xsl:attribute name="type">party</xsl:attribute>
                            <xsl:element name="identifier">
                                <xsl:attribute name="type">
                                    <xsl:choose>
                                        <xsl:when test="contains($researcher,'nla.party')">
                                            <xsl:text>AU-ANL:PEAU</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains($researcher,'orcid')">
                                            <xsl:text>AU-YORCID</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>URI</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:value-of select="$researcher"/>
                            </xsl:element>
                            <xsl:element name="relation"><xsl:attribute name="type">hasParticipant</xsl:attribute></xsl:element>
                        </xsl:element>  
                    </xsl:for-each>
                </xsl:if>
                
                <xsl:if test="normalize-space(Other_Researcher_ID) = ''">
                    <xsl:if test="normalize-space(Other_Researcher_Name) != ''">
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:element name="description">
                        <xsl:attribute name="type">researchers</xsl:attribute>
                        <xsl:value-of select="Other_Researcher_Name"/>
                    </xsl:element>
                    </xsl:if>
                </xsl:if>
  

        <!-- web page about project -->
                <xsl:if test="Description_URL!=''">
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
                <xsl:if test="$startdate != '' or $enddate !=''">
                    <xsl:element name="existenceDates">
                        <xsl:if test="$startdate !=''">     
                            <xsl:element name="startDate">
                                <xsl:attribute name="dateFormat">W3CDTF</xsl:attribute>
                                <xsl:value-of select="$startdate"/>
                            </xsl:element>
                        </xsl:if>
                        <xsl:if test="$enddate !=''"> 
                            <xsl:element name="endDate">
                                <xsl:attribute name="dateFormat">W3CDTF</xsl:attribute>
                                <xsl:value-of select="$enddate"/>
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

    
   <xsl:template match="*"/>

</xsl:stylesheet>
