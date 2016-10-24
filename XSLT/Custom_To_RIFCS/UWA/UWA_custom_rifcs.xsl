<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  
    xmlns:todo="http://yettodo" 
    xmlns:local="http://local.to.here"
    xmlns:dataset="http://atira.dk/schemas/pure4/wsdl/template/dataset/current" 
    xmlns:core="http://atira.dk/schemas/pure4/model/core/current" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:organisation-template="http://atira.dk/schemas/pure4/model/template/abstractorganisation/current" 
    xmlns:person-template="http://atira.dk/schemas/pure4/model/template/abstractperson/current"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"> 
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'University of Western Australia'"/>
    <xsl:param name="global_baseURI" select="'research-repository.uwa.edu.au'"/>
    <xsl:param name="global_group" select="'University of Western Australia (PURE)'"/>
    <xsl:param name="global_publisherName" select="'University of Western Australia'"/>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects 
            http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
          
            <xsl:apply-templates select="//core:result/core:content"/>
            
        </registryObjects>
    </xsl:template>
   
    <xsl:template match="core:content">
        <xsl:message select="concat('name(.): ', name(.))"/>
        
        <!-- include dataset for now -->
        
        <xsl:if test="core:type = 'dk.atira.pure.modules.datasets.external.model.dataset.DataSet'">
                <xsl:apply-templates select="." mode="collection">
                    <xsl:with-param name="type" select="'dataset'"/>
                </xsl:apply-templates>
                <xsl:apply-templates select="." mode="party"/>
        </xsl:if>
    </xsl:template>
    
<xsl:template match="core:content" mode="collection">
        <xsl:param name="type" as="xs:string"/>
        <xsl:variable name="class" select="'collection'"/>
        
        <xsl:message select="concat('mapped type: ', $type)"/>
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
                
                <xsl:attribute name="type" select="$type"/>
             
                <xsl:apply-templates select="core:modified[string-length(.) > 0]" mode="collection_date_modified"/>
                
                <xsl:apply-templates select="core:created[string-length(.) > 0]" mode="collection_date_created"/>
                
                <xsl:apply-templates select="@uuid[string-length(.) > 0]" mode="collection_identifier"/>
                
                <xsl:apply-templates select="*/todo:doi[string-length(.) > 0]" mode="collection_identifier"/>
                
                <xsl:apply-templates select="*/todo:doi[string-length(.) > 0]" mode="collection_location"/>
                
                <xsl:if test="string-length(*/todo:doi) = 0">
                    <xsl:apply-templates select="*[1]/@todo:about[(string-length(.) > 0)]" mode="collection_location"/>
                </xsl:if>
                
                <xsl:apply-templates select="*:title[string-length(.) > 0]" mode="collection_name"/>
                
                <!-- xsl:apply-templates select="*:managedBy" mode="collection_relatedInfo"/-->
                
                <xsl:apply-templates select="*:managedBy" mode="collection_relatedObject"/>
                
                <!-- xsl:apply-templates select="*:persons/*:dataSetPersonAssociation" mode="collection_relatedInfo"/-->
                
                <xsl:apply-templates select="*:persons/*:dataSetPersonAssociation" mode="collection_relatedObject"/>
                
                <xsl:apply-templates select="*/todo:freetextKeyword[string-length(.) > 0]" mode="collection_subject"/>
                
                <xsl:apply-templates select="todo:todo" mode="collection_subject"/>
               
                <xsl:apply-templates select="*/todo:todo[string-length(.) > 0]" mode="collection_description_full"/>
               
                <xsl:apply-templates select="." mode="collection_dates"/>  
                 
            </xsl:element>
        </registryObject>
    </xsl:template>
   
    <xsl:template match="core:modified" mode="collection_date_modified">
        <xsl:attribute name="dateModified" select="."/>
    </xsl:template>
   
    <xsl:template match="core:created" mode="collection_date_created">
        <xsl:attribute name="dateAccessioned" select="."/>
    </xsl:template>
    
    <xsl:template match="@uuid" mode="collection_identifier">
        <identifier type="global">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="todo:doi" mode="collection_identifier">
        <identifier type="doi">
            <xsl:choose>
                <xsl:when test="starts-with(. , '10.')">
                    <xsl:value-of select="concat('http://doi.org/', .)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </identifier>    
    </xsl:template>
    
     <xsl:template match="todo:doi" mode="collection_location">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:choose>
                            <xsl:when test="starts-with(. , '10.')">
                                <xsl:value-of select="concat('http://doi.org/', .)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="*:title" mode="collection_name">
        <name type="primary">
            <namePart>
                <xsl:value-of select="normalize-space(.)"/>
            </namePart>
        </name>
    </xsl:template>
    
    
    <xsl:template match="@todo:about" mode="collection_location">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="."/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="*:managedBy" mode="collection_relatedInfo">
        <xsl:message select="concat('@uuid : ', @uuid)"/>
                            
        <xsl:if test="(string-length(@uuid) > 0)">
            <relatedInfo type="party">
                <identifier type="{custom:getIdentifierType(@uuid)}">
                    <xsl:value-of select="@uuid"/>
                </identifier>
                <xsl:if test="string-length(organisation-template:name) > 0">   
                    <title>
                        <xsl:value-of select="normalize-space(organisation-template:name)"/>
                    </title>
                </xsl:if>
                <relation type="isManagedBy"/>
            </relatedInfo>
        </xsl:if>
    </xsl:template>
    
     <xsl:template match="*:dataSetPersonAssociation" mode="collection_relatedInfo">
        <xsl:message select="concat('person-template:person/@uuid : ', person-template:person/@uuid)"/>
                            
        <xsl:if test="(string-length(person-template:person/@uuid) > 0)">
            <relatedInfo type="party">
                <identifier type="{custom:getIdentifierType(person-template:person/@uuid)}">
                    <xsl:value-of select="person-template:person/@uuid"/>
                </identifier>
                <xsl:variable name="personName" select="normalize-space(concat(person-template:person/person-template:name/core:firstName, ' ', person-template:person/person-template:name/core:lastName))"/>
                <xsl:if test="string-length($personName) > 0">   
                    <title>
                        <xsl:value-of select="$personName"/>
                    </title>
                </xsl:if>
                <xsl:apply-templates select="person-template:personRole" mode="relation"/>
             </relatedInfo>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="person-template:personRole" mode="relation">
        <xsl:variable name="uriValue_sequence" select="tokenize(core:uri, '/')" as="xs:string*"/>
        <xsl:if test="count($uriValue_sequence) > 0">
            <xsl:variable name="role" select="$uriValue_sequence[count($uriValue_sequence)]"/>
                <relation>
                    <xsl:attribute name="type">
                        <xsl:choose>
                            <xsl:when test="contains(lower-case($role), 'creator')">
                                <xsl:text>hasCollector</xsl:text>
                            </xsl:when>
                             <xsl:when test="contains(lower-case($role), 'rightsholder')">
                                <xsl:text>isOwnedBy</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(lower-case($role), 'collector')">
                                <xsl:text>hasCollector</xsl:text>
                            </xsl:when>
                             <xsl:otherwise>
                                <xsl:value-of select="$role"/>
                            </xsl:otherwise>      
                        </xsl:choose>
                    </xsl:attribute>
                </relation>
       </xsl:if>
    </xsl:template>
       
    
    <xsl:template match="*:dataSetPersonAssociation" mode="collection_relatedObject">
        <xsl:variable name="personName" select="normalize-space(concat(person-template:person/person-template:name/core:firstName, ' ', person-template:person/person-template:name/core:lastName))"/>
        <xsl:message select="concat('personName for relatedObject: ', $personName)"/>
        <xsl:if test="string-length($personName) > 0">
            <relatedObject>
                <key>
                   <xsl:value-of select="local:formatKey($personName)"/> 
                </key>
                <xsl:apply-templates select="person-template:personRole" mode="relation"/>
            </relatedObject>
        </xsl:if>   
    </xsl:template>
    
    
    <xsl:template match="*:managedBy" mode="collection_relatedObject">
        <xsl:if test="string-length(organisation-template:name) > 0">
            <relatedObject>
                <key>
                   <xsl:value-of select="local:formatKey(organisation-template:name)"/> 
                </key>
                <relation type="isManagedBy"/>
            </relatedObject>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="todo:freetextKeyword" mode="collection_subject">
        <subject type="local">
            <xsl:value-of select="."/>
        </subject>
    </xsl:template>
    
    <xsl:template match="todo:todo" mode="collection_subject">
        <subject type="local">
            <xsl:value-of select="."/>
        </subject>
    </xsl:template>
    
    <xsl:template match="todo:todo" mode="collection_description_full">
        <description type="full">
            <xsl:value-of select="."/>
        </description>
    </xsl:template>
    
    <xsl:template match="core:content" mode="collection_dates">
        <dates type="issued">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="local:formatDate(*:dateMadeAvailable)"/>
            </date>
        </dates>
        
        <dates type="created">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="local:formatDate(*:dateOfDataProduction)"/>
            </date>
            <date type="dateTo" dateFormat="W3CDTF">
                <xsl:value-of select="local:formatDate(*:endDateOfDataProduction)"/>
            </date>
        </dates>
        
    </xsl:template>  
    
    <xsl:template match="core:content" mode="party">
    
        <xsl:apply-templates select="*:managedBy" mode="party_managing_organisation"/>
        <xsl:apply-templates select="*:persons/*:dataSetPersonAssociation" mode="party_people"/>
    
    </xsl:template>
    
     <xsl:template match="*:dataSetPersonAssociation" mode="party_people">
           
            <xsl:variable name="personName" select="normalize-space(concat(person-template:person/person-template:name/core:firstName, ' ', person-template:person/person-template:name/core:lastName))"/>
            <xsl:message select="concat('personName : ', $personName    )"/>
        
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
                             
                            <xsl:if test="string-length(person-template:person/@uuid) > 0">
                                <identifier type="global">
                                    <xsl:value-of select="person-template:person/@uuid"/>
                                </identifier>
                            </xsl:if>
                             <name type="primary">
                                 <namePart type="given">
                                    <xsl:value-of select="normalize-space(person-template:person/person-template:name/core:firstName)"/>
                                 </namePart>    
                                 <namePart type="family">
                                    <xsl:value-of select="normalize-space(person-template:person/person-template:name/core:lastName)"/>
                                 </namePart>    
                             </name>
                         </party>
                     </registryObject>
                   
                </xsl:if>
            
        </xsl:template>
        
    <xsl:template match="*:managedBy" mode="party_managing_organisation">
           
            <xsl:if test="(string-length(organisation-template:name) > 0)">
            
                     <registryObject group="{$global_group}">
                        <key>
                           <xsl:value-of select="local:formatKey(organisation-template:name)"/> 
                        </key>       
                        <originatingSource>
                             <xsl:value-of select="$global_originatingSource"/>
                        </originatingSource>
                        
                         <party>
                            <xsl:attribute name="type" select="'group'"/>
                             
                            <xsl:if test="string-length(@uuid) > 0">
                                <identifier type="global">
                                    <xsl:value-of select="@uuid"/>
                                </identifier>
                            </xsl:if>
                             <name type="primary">
                                 <namePart>
                                    <xsl:value-of select="normalize-space(organisation-template:name)"/>
                                 </namePart>    
                             </name>
                         </party>
                     </registryObject>
                   
                </xsl:if>
            
        </xsl:template>
             
     <xsl:function name="local:formatDate">
        <xsl:param name="currentNode" as="node()"/>
        
        <xsl:variable name="datePart_sequence" as="xs:string*">
            <xsl:copy-of select="$currentNode/*:year"/>
            <xsl:copy-of select="$currentNode/*:month"/>
            <xsl:copy-of select="$currentNode/*:day"/>
        </xsl:variable>
        <xsl:value-of  select="string-join($datePart_sequence, '-')"/>   
    </xsl:function>
 
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