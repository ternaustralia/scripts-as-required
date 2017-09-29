import urllib2
import sys
import re

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
                <ogc:Filter xmlns="http://http://www.opengis.net/ogc" xmlns:gmd="http://www.isotc211.org/2005/gmd">{1}</ogc:Filter>
            </Constraint>
        </csw:Query>
    </csw:GetRecords>
    '''

queryPropertyTemplate = '''
    <ogc:{0}><ogc:PropertyIsLike wildCard="*" singleChar="_" escapeChar="\">
    <ogc:PropertyName>{1}</ogc:PropertyName>
    <ogc:Literal>{2}</ogc:Literal>
    </ogc:PropertyIsLike></ogc:{3}>
    '''


def constructQuery(allEntries):

    query = ""

    for entry in allEntries:
        query += str.format(queryPropertyTemplate, entry["condition"], entry["key"], entry["value"], entry["condition"])

    return query


def dictFormatted(allEntries):

    formatted = ""

    for entry in allEntries:
        formatted += str.format('{0}_{1}_{2}_', entry["condition"], entry["key"], entry["value"])

    return formatted


def callCSW(cswUrl, allEntries):

    startPosition = '1'
    fullQuery = None
    fileName = ""

    if (allEntries != None):

        query = constructQuery(allEntries)
        if(query == None):
            print "Unable to construct query"
            return

        fullQuery = queryTemplate.format(startPosition, query)
        print fullQuery
        okForFileName = re.sub('[/:]', '_', dictFormatted(allEntries))
        fileName = str.format('{0}{1}', okForFileName, 'records.xml')
        print(fileName)

    else:
        fullQuery = noConstraints.format(startPosition)
        fileName = "all_records.xml"

    print str(fileName)

    request = urllib2.Request(url=cswUrl, data=fullQuery, headers={"Content-type": "application/xml"})

    response = urllib2.urlopen(request)


    with open(str(fileName), 'w') as f:
        for line in response.read():
            f.write(line),

    print 'done'




def main():

    assert(len(sys.argv) == 2)
    assert(sys.argv[1] != None)

    print(sys.argv[1])

    url = sys.argv[1]


    entry = dict({"condition" : "And", "key" : "ResourceIdentifier", "value" : "rr4"})
    print len(entry)

    allEntries = list()

    allEntries.append(entry)

    entry = dict({"condition" : "Or", "key" : "ResourceIdentifier", "value" : "rr6"})
    print len(entry)

    allEntries.append(entry)

    print len(allEntries)


    callCSW(url, allEntries)

    #dictKeyValue = {'ResourceIdentifier', 'rr6'}
    #callCSW(url, dictKeyValue)

    #dictKeyValue = {'ResourceIdentifier', 'rr7'}
    #callCSW(url, dictKeyValue)

    #dictKeyValue = {'Identifier', 'f8510_1385_3021_0891'}
    #callCSW(url, 'Identifier', 'f8510_1385_3021_0891')

    #callCSW(url, None, None)
    #callCSW(url, 'AnyText', 'rr4')
    #callCSW(url, 'AnyText', 'rr6')
    #callCSW(url, 'AnyText', 'rr7')


if __name__ == "__main__":
    main()