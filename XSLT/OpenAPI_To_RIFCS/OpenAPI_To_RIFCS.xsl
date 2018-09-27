<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:fn = "http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:custom="http://custom.nowhere.yet"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="xsl xsi fn xs custom">
    <!-- stylesheet to convert data.gov.au xml (transformed from json with python script) to RIF-CS -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <!-- =========================================== -->
    <!-- dataset (datasets) Template             -->
    <!-- =========================================== -->

    <xsl:template match="/">
        <xsl:message select="'Process'"/>
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
        
            <xsl:apply-templates select="root" mode="service"/>
            
        </registryObjects>
            
    </xsl:template>
    
    <!-- ====================================== -->
    <!-- Service RegistryObject - Template -->
    <!-- ====================================== -->

    <!-- Service Registry Object -->
    <xsl:template match="root" mode="service">
        <xsl:message select="'Process service'"/>
        
          <xsl:variable name="organizationDescription"
            select="normalize-space(organization/description)"/>
             <xsl:if test="string-length($serviceURI)">

                <registryObject group="{$global_group}">

                    <key>
                        <xsl:value-of select="substring(string-join(for $n in fn:string-to-codepoints(reverse(*:stdyDscr/*:citation/*:titlStmt/*:IDNo)) return string($n), ''), 0, 500)"/>
                    </key>

                    <originatingSource>
                        <xsl:value-of select="$global_originatingSource"/>
                    </originatingSource>

                    <service type="webservice">

                        <identifier type="uri">
                            <xsl:value-of select="$serviceURI"/>
                        </identifier>

                        <xsl:variable name="serviceName" select="custom:getServiceName($serviceURI)"/>

                        <name type="primary">
                            <namePart>
                                <xsl:choose>
                                    <xsl:when test="string-length($serviceName)">
                                        <xsl:value-of
                                            select="concat($serviceName, ' for access to ', $organizationTitle, ' data')"
                                        />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
                                            select="concat('Service for access to ', $organizationTitle, ' data')"
                                        />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </namePart>
                        </name>

                        <xsl:if test="string-length($organizationDescription)">
                            <description>
                                <xsl:attribute name="type">
                                    <xsl:text>brief</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of
                                    select="concat('Service for access to ', $organizationTitle, ' data - ',  $organizationDescription)"
                                />
                            </description>
                        </xsl:if>


                        <location>
                            <address>
                                <electronic>
                                    <xsl:attribute name="type">
                                        <xsl:text>url</xsl:text>
                                    </xsl:attribute>
                                    <value>
                                        <xsl:value-of select="$serviceURI"/>
                                    </value>
                                </electronic>
                            </address>
                        </location>

                       
                    </service>
                </registryObject>
            </xsl:if>
    </xsl:template>

   
</xsl:stylesheet>
