import xml.dom.minidom
from xml.dom.minidom import getDOMImplementation

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


