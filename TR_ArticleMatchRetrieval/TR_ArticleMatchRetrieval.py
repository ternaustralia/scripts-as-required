import xml.dom.minidom
from xml.dom.minidom import getDOMImplementation
from urllib.request import Request
from urllib.request import urlopen
from optparse import OptionParser
import sys

# service DRCI

requestTemplate = \
    """<request xmlns='http://www.isinet.com/xrpc42' src='app.id=ANDS'>
    <fn name='LinksAMR.retrieve'>
        <list>
            <!-- WHO'S REQUESTING -->
            <map>
                <val name='username'>{0}</val>
                <val name='password'>{1}</val>
            </map>
            <!-- WHAT'S REQUESTED -->
            <map>
                <list name='{2}'>
                    <val>citingArticlesAllDBURL</val>
                    <val>uid</val>
                    <val>doi</val>
                    <val>sourceURL</val>
                    <val>timesCitedAllDB</val>
                    <val>repositoryLinkURL</val>
                </list>
            </map>
            <!-- LOOKUP DATA -->
            {3}
        </list>
    </fn>
</request>
"""

class Store(object):
    def __init__(self, *data, **kwargs):
        for dictionary in data:
            for key in dictionary:
                setattr(self, key, dictionary[key])
        for key in kwargs:
            setattr(self, key, kwargs[key])


class Article(Store):
    pass

class RequestXML(Store):

    def requestXML(self, articleList):
        print(len(articleList))
        impl = getDOMImplementation()

        mapDoc = impl.createDocument(None, 'map', None)
        mapRoot = mapDoc.documentElement

        count = 1
        objectIdTemplate = 'cite_{0}'

        for article in articleList:
            mapNode = mapDoc.createElement('map')
            mapAttr = mapDoc.createAttribute('name')
            mapAttr.value = objectIdTemplate.format(count)
            count = count + 1

            mapNode.setAttributeNode(mapAttr)
            mapRoot.appendChild(mapNode)

            for a in dir(article):
                if not a.startswith('__'):
                    print(a)
                    subNode = mapDoc.createElement('list' if a == 'authors' else 'val')
                    subAttr = mapDoc.createAttribute('name')
                    subAttr.value = a
                    subNode.setAttributeNode(subAttr)

                    mapNode.appendChild(subNode)

                    if a == 'authors':
                        itemList = getattr(article, a).split('|')
                        for item in itemList:
                            print(item)
                            itemNode = mapDoc.createElement('val')
                            itemText = mapDoc.createTextNode(item)
                            itemNode.appendChild(itemText)
                            subNode.appendChild(itemNode)
                    else:
                        subText = mapDoc.createTextNode(getattr(article, a))
                        subNode.appendChild(subText)

        print('test')
        print(mapRoot.toprettyxml())
        return requestTemplate.format(getattr(self, 'username'),
                                      getattr(self, 'pword'),
                                      getattr(self, 'service'), mapRoot.toprettyxml())

def testArticleList():
    articleList = list()

    articleList.append(Article({'uid': 'DRCI:DATA2014050004990054'}))
    articleList.append(Article({'sourceURL': 'http://hdl.handle.net/10536/DRO/DU:30046067'}))

    articleList.append(Article({'doi': '10.14264/uql.2014.80'}))

    articleList.append(Article({'atitle': 'Boron in Antarctic granulite-facies rocks: under what conditions is boron retained in the middle crust'},
                               {'year': '2003'},
                               {'authors': 'Carson, Christopher|Grew, Edward'},
                               {'doctype': 'Data set'}))

    articleList.append(Article({'atitle': 'Experimental studies into growth and ageing of krill'},
                              {'doctype': 'Data set'},
                              {'year': '2009'},
                              {'authors': 'Kawaguchi, So|Nicol, Stephen'}))

    print(len(articleList))
    return articleList


usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--username", action="store", dest="username", help="username")
parser.add_option("--password", action="store", dest="password", help="password")
parser.add_option("--service", action="store", dest="service", help="service")

(options, args) = parser.parse_args()

if not options.username:
    parser.error("Requires username.  Try --help for usage")
    sys.exit(-1)

if not options.password:
    parser.error("Requires password.  Try --help for usage")
    sys.exit(-1)

if not options.service:
    parser.error("Requires service.  Try --help for usage")
    sys.exit(-1)


try:

    gatewayURL = 'https://ws.isiknowledge.com/cps/xrpc'
    loggingTemplate = '<!-- {0} to gateway {1} shown below -->'

    requestXMLObj = RequestXML({'username': options.username}, {'pword': options.password}, {'service': options.service})

    requestXML = requestXMLObj.requestXML(testArticleList())

    print(loggingTemplate.format('Request', gatewayURL))
    print(requestXML)

    requestObj = Request(gatewayURL)
    requestObj.add_header('Content-Type', 'application/xml')
    response = urlopen(requestObj, requestXML.encode('utf-8'))

    result = response.read()
    print(loggingTemplate.format('Response', gatewayURL))
    print(result)

except Exception as e:
    print(e)


