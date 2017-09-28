import urllib2
import sys

#working
noConstraints = '''
    <csw:GetRecords 
        service="CSW"
        version="2.0.2"
        maxRecords="100"
        startPosition="1"
        resultType="results"
        outputFormat="application/xml"
        outputSchema="http://www.isotc211.org/2005/gmd"
        xmlns="http://www.opengis.net/cat/csw/2.0.2"
        xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
        xmlns:ogc="http://www.opengis.net/ogc"
        xmlns:ows="http://www.opengis.net/ows"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns:dct="http://purl.org/dc/terms/"
        xmlns:gml="http://www.opengis.net/gml"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.opengis.net/cat/csw/2.0.2">
        <csw:Query typeNames="csw:Record">
            <ElementSetName typeNames="csw:Record">full</ElementSetName>
        </csw:Query>
    </csw:GetRecords>
    '''

queryTemplate = '''
    <csw:GetRecords 
        service="CSW"
        version="2.0.2"
        maxRecords="100"
        startPosition="{0}"
        resultType="results"
        outputFormat="application/xml"
        outputSchema="http://www.isotc211.org/2005/gmd"
        xmlns="http://www.opengis.net/cat/csw/2.0.2"
        xmlns:gmd="http://www.isotc211.org/2005/gmd" 
        xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
        xmlns:ogc="http://www.opengis.net/ogc"
        xmlns:ows="http://www.opengis.net/ows"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns:dct="http://purl.org/dc/terms/"
        xmlns:gml="http://www.opengis.net/gml"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.opengis.net/cat/csw/2.0.2">
        <csw:Query typeNames="csw:Record">
            <ElementSetName typeNames="csw:Record">full</ElementSetName>
            <Constraint version="1.1.0">
                <ogc:Filter xmlns="http://http://www.opengis.net/ogc" xmlns:gmd="http://www.isotc211.org/2005/gmd">
                    <ogc:PropertyIsLike wildCard="*" singleChar="_" escapeChar="\">
                        <ogc:PropertyName>{1}</ogc:PropertyName>
                        <ogc:Literal>{2}</ogc:Literal>
                    </ogc:PropertyIsLike>
                </ogc:Filter>
            </Constraint>
        </csw:Query>
    </csw:GetRecords>
    '''


def callCSW(cswUrl, propertyName, literal):

    startPosition = '1'
    queryToUse = None
    fileName = None

    if literal != None:
        queryToUse = queryTemplate.format(startPosition, propertyName, literal)
        fileName = literal+"_records.xml"
    else:
        queryToUse = noConstraints.format(startPosition)
        fileName = "all_records.xml"

    print queryToUse

    # call(allDatasetsQuery, 'all_records.xml')
    # call(rr4Query, 'rr4_records.xml')

    request = urllib2.Request(url=cswUrl, data=queryToUse, headers={"Content-type": "application/xml"})

    response = urllib2.urlopen(request)


    with open(fileName, 'w') as f:
        for line in response.read():
            f.write(line),

    print 'done'


#callCSW(None)

def main():

    assert(len(sys.argv) == 2)
    assert(sys.argv[1] != None)

    print(sys.argv[1])

    url = sys.argv[1]

    callCSW(url, 'AnyText', 'rr4')
    callCSW(url, 'AnyText', 'rr6')
    callCSW(url, 'AnyText', 'rr7')


if __name__ == "__main__":
    main()