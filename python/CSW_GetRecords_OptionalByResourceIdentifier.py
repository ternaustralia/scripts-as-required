import urllib
import sys
import re
import Test_OGC_CSW_Functions


# Call like so for example, querying by certain ResourceIdentifier:
# http://test.domain.org/csw_endpoint identifier1,identifier2,identifier3

def main():

    print(len(sys.argv))
    assert(sys.argv[1] != None)

    print(sys.argv[1])

    url = sys.argv[1]

    paramList = list()

    conditionDict = None;

    if (len(sys.argv) > 2):
        print(sys.argv[2])

        identifierList = sys.argv[2].split(',')

        assert((identifierList.__class__.__name__) == 'list')


        for identifier in identifierList:
            print(identifier)

            paramDict = dict({"name" : "ResourceIdentifier", "value" : identifier})
            print("type(paramDict)")
            print(type(paramDict))

            for key, value in paramDict.items():
                print(key)
                print(value)

            paramList.append(paramDict)

        conditionDict = dict({"Or" : paramList})

    Test_OGC_CSW_Functions.callCSW(url, conditionDict)


if __name__ == "__main__":
    main()

