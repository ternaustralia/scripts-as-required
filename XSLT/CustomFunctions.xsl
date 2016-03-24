<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:custom="http://custom.nowhere.yet"
    exclude-result-prefixes="custom">
    
    <xsl:function name="custom:sequenceContains" as="xs:boolean">
        <xsl:param name="sequence" as="xs:string*"/>
        <xsl:param name="str" as="xs:string"/>
        
        <xsl:variable name="true_sequence" as="xs:boolean*">
            <xsl:for-each select="distinct-values($sequence)">
                <xsl:if test="contains(lower-case(.), lower-case($str))">
                    <xsl:copy-of select="true()"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count($true_sequence) > 0">
                <xsl:copy-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="custom:originatingSource" as="xs:string">
        <xsl:param name="node" as="node()"/>
        
        <xsl:variable name="originator_sequence" as="node()*" select="
            $node/gmd:contact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'originator'] |
            $node/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'originator')] |
            $node/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'originator'] |
            $node/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'originator']"/>
        
        <xsl:variable name="author_sequence" as="node()*" select="
            $node/gmd:contact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'author'] |
            $node/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'author')] |
            $node/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'author'] |
            $node/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'author']"/>
        
        <xsl:variable name="creator_sequence" as="node()*" select="
            $node/gmd:contact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'creator'] |
            $node/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'creator')] |
            $node/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'creator'] |
            $node/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'creator']"/>
        
        <xsl:variable name="resourceProvider_sequence" as="node()*" select="
            $node/gmd:contact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'resourceprovider'] |
            $node/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'resourceprovider'] |
            $node/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'resourceprovider'] |
            $node/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'resourceprovider']"/>
        
        <xsl:variable name="owner_sequence" as="node()*" select="
            $node/gmd:contact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'owner'] |
            $node/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'owner'] |
            $node/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'owner'] |
            $node/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'owner']"/>
        
        <xsl:variable name="custodian_sequence" as="node()*" select="
            $node/gmd:contact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'custodian'] |
            $node/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'custodian'] |
            $node/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'custodian'] |
            $node/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'custodian']"/>
        
        <!-- tests for role containing 'contact', so may be just 'contact', or 'pointofcontact' -->
        <xsl:variable name="pointOfContact_sequence" as="node()*" select="
            $node/gmd:contact/gmd:CI_ResponsibleParty[contains(lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue), 'contact')] |
            $node/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[contains(lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue), 'contact')] |
            $node/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[contains(lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue), 'contact')] |
            $node/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[contains(lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue), 'contact')]"/>
        
        
        <xsl:variable name="contact_sequence" as="node()*" select="
            $node/gmd:contact/gmd:CI_ResponsibleParty"/>
        
        <xsl:choose>
            <xsl:when test="(count($originator_sequence) > 0) and string-length($originator_sequence[1]/gmd:organisationName) > 0">
                <xsl:value-of select="$originator_sequence[1]/gmd:organisationName"/>
            </xsl:when>
            <xsl:when test="(count($author_sequence) > 0) and string-length($author_sequence[1]/gmd:organisationName) > 0">
                <xsl:value-of select="$author_sequence[1]/gmd:organisationName"/>
            </xsl:when>
            <xsl:when test="(count($creator_sequence) > 0) and string-length($creator_sequence[1]/gmd:organisationName) > 0">
                <xsl:value-of select="$creator_sequence[1]/gmd:organisationName"/>
            </xsl:when>
            <xsl:when test="(count($resourceProvider_sequence) > 0) and string-length($resourceProvider_sequence[1]/gmd:organisationName) > 0">
                <xsl:value-of select="$resourceProvider_sequence[1]/gmd:organisationName"/>
            </xsl:when>
            <xsl:when test="(count($owner_sequence) > 0) and string-length($owner_sequence[1]/gmd:organisationName) > 0">
                <xsl:value-of select="$owner_sequence[1]/gmd:organisationName"/>
            </xsl:when>
            <xsl:when test="(count($custodian_sequence) > 0) and string-length($custodian_sequence[1]/gmd:organisationName) > 0">
                <xsl:value-of select="$custodian_sequence[1]/gmd:organisationName"/>
            </xsl:when>
            <xsl:when test="(count($pointOfContact_sequence) > 0) and string-length($pointOfContact_sequence[1]/gmd:organisationName) > 0">
                <xsl:value-of select="$pointOfContact_sequence[1]/gmd:organisationName"/>
            </xsl:when>
            <xsl:when test="(count($contact_sequence) > 0) and string-length($contact_sequence[1]/gmd:organisationName) > 0">
                <xsl:value-of select="$contact_sequence[1]/gmd:organisationName"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>
    </xsl:function>
        
</xsl:stylesheet>