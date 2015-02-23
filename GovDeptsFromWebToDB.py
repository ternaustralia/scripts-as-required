# Utility which scrapes directory.gov.au for Australian Government Departments and Agencies and 
# populates mysql Australian_government database with each department found.
#  - Scrapes the following sites in particular for Government Departments and Agencies:
#       http://www.directory.gov.au/quicklinks.php?agency&sect1
#       http://www.directory.gov.au/quicklinks.php?agency&sect2
#       http://www.directory.gov.au/quicklinks.php?agency&sect3
#       http://www.directory.gov.au/quicklinks.php?agency&sect4
#   Departments and agencies are stored with a type '1' in the department table (from department_type)
#  - Scrapes the following sites in particular for Councils, Committees & Boards:
#       http://www.directory.gov.au/quicklinks.php?council&sect1
#       http://www.directory.gov.au/quicklinks.php?council&sect2
#       http://www.directory.gov.au/quicklinks.php?council&sect3
#       http://www.directory.gov.au/quicklinks.php?council&sect4
#   Councils, Committees and Boards are stored with a type '2' in the department table (from department_type)  

#   Output:     After populating Australian_government database, a CSV file of departments is constructed
# and copied to the MySQLDataDirectory.  Because I don't know how to get this path via the MySQLDB API yet,
# there is no attempt to delete the file before creating it, so if you run this script subsequently, be sure
# to delete the file first.  To find out where it is..
#   1 - open MySQL Administrator
#   2 - select 'Startup Variable' from the tree on the left
#   3 - select the 'General Parameters' tab and have a look in the Directories section for the value in 'Data directory'

import _mysql
from lxml.html import parse, open_in_browser
from lxml import etree
from lxml import html
import StringIO
import os

deptId = 0
deptType_Id = 1 # department/agency or other, e.g. board/committee, etc
peopleId = 0
addressId = 0

db=_mysql.connect(host="localhost",user="admin", passwd="admin",db="AustralianGovernment",port=3306)

#db.query("""SELECT * FROM department where DT_Id = 1""")
#r=db.store_result()
#print(r.fetch_row(0,0))


FILE_parsed = open("parsed.xml","w")

def writeDBRefreshCommands():
    db.query("""delete from contact""")
    db.query("""alter table contact AUTO_INCREMENT=1""")
    db.query("""delete from contact_type""")
    db.query("""alter table contact_type AUTO_INCREMENT=1""")
    db.query("""delete from address""")
    db.query("""alter table address AUTO_INCREMENT=1""")
    db.query("""delete from address_type""")
    db.query("""alter table address_type AUTO_INCREMENT=1""")
    db.query("""delete from people""")
    db.query("""alter table people AUTO_INCREMENT=1""")
    db.query("""delete from department""")
    db.query("""alter table department AUTO_INCREMENT=1""")
    db.query("""delete from department_type""")
    db.query("""alter table department_type AUTO_INCREMENT=1""")
    db.query("""insert into department_type(name)\nvalues (\'dept\'),(\'other\')""")
    db.query("""insert into address_type(name)\nvalues (\'postal\'),(\'actual\')""")
    db.query("""insert into contact_type(name)\nvalues (\'email\'),(\'phone\'),(\'fax\'),(\'website\')""")

def getDepartmentWebSite(internalWebsite):
    docRoot = rootFromHtml(internalWebsite)
    xmlOutFile = "internalWebsite.xml"
    file = open(xmlOutFile,"w")
    file.write(html.tostring(docRoot, method='xml'))
    element = docRoot.findtext("Website Link")
    
    links = list(docRoot.iter("a"))   # Returns list of all links
    for link in links:
        website = link.get("href")
        text = link.text_content()
        if text.find('Website Link') > -1: 
            # Found department website
            print("Website Link: %s" % website)       
            return website
    
        
    return ''

def writeDBUpdateCommands(deptList):

    # IDs for row indexes
    ctId_email = 1
    ctId_phone = 2
    ctId_website = 4
    atId_postal = 1

    numListItems = 0

    #lastObjectLetter = chr(ord('A')-1)
    
    if len(deptList) < 5:
        assert(0)

    for deptObject in deptList:
        numListItems = numListItems + 1;
        global peopleId
        peopleId = peopleId + 1
        global addressId
        addressId= addressId + 1
        
        if hasattr(deptObject, 'name'):
            #Test the validity of name.  If dodgy, go to next deptObject
            name = getattr(deptObject, 'name')
            name.rstrip('');
            FILE_parsed.write("hasattr 'name' on deptObject[%d], value: %s\n" % (numListItems-1, name))   
            if len(name) == 1:
                if name != ' ':
                    # we have found the alphabet indicator.  Update our stored value
                    # so that we know which letter we are up to for validating

                    # validate it - it ought to be the next in the alphabet (next ascii value)
                    #if ord(name[0]) > (ord(lastObjectLetter)):
                    #    lastObjectLetter = name[0]
                        print("Processing departments beginning with %s" % name[0])

                continue # If we only have a one character name
                
            if len(name) <= 1: 
                continue

            if name.find("http") > -1: 
                continue
            
            #if name[0] != lastObjectLetter: 
            #    continue
                # the name does not start with the letter that we are expecting, so let it go - it's probably some random html stuff
                
            global deptId
            global deptType_Id
            deptId = deptId + 1
            
            db.query("insert into department (D_Id, Name, DT_Id) values (%d, \'%s\', %d);\n" % (deptId, (getattr(deptObject, 'name')), deptType_Id))
            db.query("insert into people (P_Id, FirstName, Surname, D_Id) values (%d, \'General\', \'Enquiries\', %d);\n" % (peopleId, deptId))
        
        if hasattr(deptObject, 'phone'):
            FILE_parsed.write("hasattr 'phone' on deptObject[%d], value: %s\n" % (numListItems-1, getattr(deptObject, 'phone')))
            db.query("insert into contact (Name, P_Id, CT_Id) values (\'%s\', %d, %d);\n" % (getattr(deptObject, 'phone'), peopleId, ctId_phone));
        
        if hasattr(deptObject, 'email'):
            FILE_parsed.write("hasattr 'email' on deptObject[%d], value: %s\n" % (numListItems-1, getattr(deptObject, 'email')))   
            db.query("insert into contact (Name, P_Id, CT_Id) values (\'%s\', %d, %d);\n" % (getattr(deptObject, 'email'), peopleId, ctId_email));
            
        if hasattr(deptObject, 'website'):
            FILE_parsed.write("hasattr 'website' on deptObject[%d], value: %s\n" % (numListItems-1, getattr(deptObject, 'website'))) 
            db.query("insert into contact (Name, P_Id, CT_Id) values (\'%s\', %d, %d);\n" % (getattr(deptObject, 'website'), peopleId, ctId_website));
                
        if hasattr(deptObject, 'address'):
            FILE_parsed.write("hasattr 'address' on deptObject[%d], value: %s\n" % (numListItems-1, getattr(deptObject, 'address')))
            state = ''
            if hasattr(deptObject, 'state'):
                state = getattr(deptObject, 'state')
            db.query("insert into address (A_Id, Name, State, P_Id, AT_Id) values (%d, \'%s\', \'%s\', %d, %d);\n" % (addressId, getattr(deptObject, 'address'), state, peopleId, atId_postal));
            
    print("%d departments found" % numListItems)

def writeDBSelectToCSV():

    db.query("Select d.D_Id D_Id, d.Name DeptName, c.Name Contact, a.Name, a.State INTO OUTFILE 'AustralianGovernmentDepartmentContacts.csv' \
                FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\\n' \
                FROM department d left join people p on d.D_Id=p.D_Id left join contact c on p.P_Id=c.P_Id left join address a on p.P_Id=a.P_Id \
                where c.CT_Id = 4 \
                and d.DT_Id = 1") # website
    
def populateDepartmentURLList(urlList):
    del urlList[0:len(urlList)-1]
    number = 1
    while number < 5:
        urlList.append("http://www.directory.gov.au/quicklinks.php?agency&sect"+str(number))
        number = number + 1
        
        
def populateOtherURLList(urlList):
    del urlList[0:len(urlList)-1]
    number = 1
    while number < 5:
        urlList.append("http://directory.gov.au/quicklinks.php?council&sect"+str(number))
        number = number + 1

        
def rootFromHtml(url):
    docTree = parse(url)
    docRoot = docTree.getroot() #HTMLElement
    docRoot.make_links_absolute()
    #open_in_browser(docRoot)
    return docRoot

stateList = ['ACT', 'NSW', 'QLD', 'VIC', 'SA', 'TAS', 'NT', 'WA'] 
    
def populateDepartmentList(urlList):
    pageCount = 1
    deptList = list() # empty list
    for url in urlList:
        docRoot = rootFromHtml(url)
        
        #iterate through xml, populating departments
        qlp_table = docRoot.get_element_by_id("qlp_table")
        if len(qlp_table) > 0:
            print("Found!")
            
        headingSkipped = 0
        for department in qlp_table.iter(tag="tr"):
            if headingSkipped == 0:
                headingSkipped = 1 
                continue
            
            fields = department.getchildren()
            
            # Department Name in field[0]
            if len(fields) < 1:
                continue
                
            deptObject = DeptObject()
            FILE_parsed.write("Object created\n")
                
            index = 0
            for field in fields:
                text = field.text_content()
                if len(text) < 1:
                    continue
            
                links = list(field.iter("a"))   # Returns list of all links
                text = text.split( '\n', 1 )[0]
                text = text.replace("'", "''")        
                text = text.rstrip('\n')        
                
                
                if index == 0: 
                    if len(text) < 2:
                        continue
                        
                    FILE_parsed.write("setattr name: %s\n" % text.encode('ascii', 'ignore'))        
                    setattr(deptObject, 'name', text.encode('ascii', 'ignore'))
                    
                    for link in links:
                        internalWebsite = link.get("href")
                        website = getDepartmentWebSite(internalWebsite)
                        FILE_parsed.write("setattr  website: %s\n" % website.encode('ascii', 'ignore'))        
                        setattr(deptObject, 'website', website.encode('ascii', 'ignore'))
                    
                    index = index + 1
                    continue
                
                # email?
                if text.upper().find("@") > -1:
                    for link in links:
                        email = link.get("href")
                        if email.find('mailto:') == 0:
                            emailStripped = email.split( ':', 1 )[1]
                            if len(emailStripped) > 0:
                                FILE_parsed.write("setattr  email: %s\n" % emailStripped.encode('ascii', 'ignore'))        
                                setattr(deptObject, 'email', emailStripped.encode('ascii', 'ignore'))
                    continue
                    
                # address?
                phonePerhaps = 1
                for state in stateList:
                    if state not in text.upper():
                        continue
                        
                    FILE_parsed.write("setattr  address: %s\n" % text.encode('ascii', 'ignore'))        
                    setattr(deptObject, 'address', text.encode('ascii', 'ignore'))
                    FILE_parsed.write("setattr  state: %s\n" % state.encode('ascii', 'ignore'))        
                    setattr(deptObject, 'state', state.encode('ascii', 'ignore'))
                    phonePerhaps = 0
                    
                
                # phone?
                if phonePerhaps == 1:
                    # it may be address if it has GPO, even though it didn't contain a state...
                    if len(text) > 0:
                        if text.find('GPO') > -1:
                            FILE_parsed.write("setattr  address: %s\n" % text.encode('ascii', 'ignore'))        
                            setattr(deptObject, 'address', text.encode('ascii', 'ignore'))
                        else:
                            FILE_parsed.write("setattr  phone: %s\n" % text.encode('ascii', 'ignore'))        
                            setattr(deptObject, 'phone', text.encode('ascii', 'ignore'))
                    
            
            deptList.append(deptObject)
    
    return deptList
        
            
        
class DeptObject:
    def displayDeptObject(self):
        print("Name : ", self.name,  ", email: ", self.email,  ", address: ", self.address,  ", phone: ", self.phone,  ", website: ", self.website)
  

deptUrlList = list() # empty list
populateDepartmentURLList(deptUrlList)  

otherUrlList = list() # empty list
populateOtherURLList(otherUrlList)
  
deptList = populateDepartmentList(deptUrlList)
otherList = populateDepartmentList(otherUrlList) # goverment councils, committes and boards

writeDBRefreshCommands()
writeDBUpdateCommands(deptList)
deptType_Id = 2
writeDBUpdateCommands(otherList)
writeDBSelectToCSV()
FILE_parsed.close()
db.commit()
db.close()





