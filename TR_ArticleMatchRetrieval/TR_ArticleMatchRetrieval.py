from classes import RequestXML, Article
from urllib.request import Request
from urllib.request import urlopen
from optparse import OptionParser
import sys

def testArticleList():
    articleList = list()

    #articleList.append(Article({'uid': 'DRCI:DATA2014050004990054'}))
    #articleList.append(Article({'ut': 'http://hdl.handle.net/10536/DRO/DU:30046067'}))
    #articleList.append(Article({'sourceURL': 'http://hdl.handle.net/10536/DRO/DU:30046067'}))

    #articleList.append(Article({'doi': '10.14264/uql.2014.80'}))

    articleList.append(Article({'atitle': 'Boron in Antarctic granulite-facies rocks: under what conditions is boron retained in the middle crust'},
                               {'year': '2003'},
                               {'authors': 'Carson, Christopher|Grew, Edward'},
                               {'doctype': 'Data set'}))

    '''
    articleList.append(Article({'atitle': 'Experimental studies into growth and ageing of krill'},
                              {'doctype': 'Data set'},
                              {'year': '2009'},
                              {'authors': 'Kawaguchi, So|Nicol, Stephen'}))

    '''
    print(len(articleList))
    return articleList


usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--username", action="store", dest="username", help="username")
parser.add_option("--password", action="store", dest="password", help="password")

(options, args) = parser.parse_args()

if not options.username:
    parser.error("Requires username.  Try --help for usage")
    sys.exit(-1)

if not options.password:
    parser.error("Requires password.  Try --help for usage")
    sys.exit(-1)


try:

    gatewayURL = 'https://ws.isiknowledge.com/cps/xrpc'
    loggingTemplate = '<!-- {0} to gateway {1} shown below -->'

    requestXMLObj = RequestXML({'username': options.username}, {'pword': options.password}, {'service': 'DRCI'})

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


