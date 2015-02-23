import sys
import os
import postgresql.driver as pg_driver
from optparse import OptionParser
import types

#Usage: RDACollectionsSubjectsReport.py [options]

#Options:
#  -h, --help           show this help message and exit
#  --database=DATABASE  name of database
#  --schema=SCHEMA      schema of database
#  --user=USER          user for database
#  --password=PASSWORD  password for database
#  --host=HOST          host for database
#  --port=PORT          port for database
#
#
def validateOption(name, value):
    if not value:
        parser.error("Requires %s.  Try --help for usage" % name)
        sys.exit(-1)
        
        
def constructCounter(limit=10000000):
    n = 0
    while n < limit:
       n+=1
       yield n

def insertIntoTblRoToAnzsrcfor(schema, ro_to_anzsrcfor_id, registry_object_key, anzsrcfor_division, anzsrcfor_value):

    assert(isinstance(ro_to_anzsrcfor_id, str))
    assert(isinstance(registry_object_key, str))
    assert(isinstance(anzsrcfor_division, str))
    assert(isinstance(anzsrcfor_value, str))
 
    int_ro_to_anzsrcfor_id = int(ro_to_anzsrcfor_id.strip())
    
    statement = ("INSERT into %s.tbl_ro_to_anzsrcfor \
    (ro_to_anzsrcfor_id, registry_object_key, anzsrcfor_value, anzsrcfor_division) \
    values (%d, \'%s\', %d, \'%s\')" % \
    (schema,
    int_ro_to_anzsrcfor_id,
    registry_object_key.strip(),
    anzsrcfor_division,
    anzsrcfor_value.strip()))
    
    print(statement)                
    result = db.prepare(statement).first()
                    
    assert(result == 1)
    
    
def isValidInt(value):
    try:
        i = int(value)
    except ValueError:
        return False

    assert(isinstance(i, int))
    return True
    
    
def divisionFromValue(value):
    if (value is None):
        return None

    if (len(value) == 0):
        return None

    if (len(value) == 1):
        if isValidInt(value[0]):
           return ('0%s' % value[0])
        
        return None
        
    if (len(value) == 2):
        return value
        
    if ((len(value) % 2) == 0):
        if ((isValidInt(value[0]) and isValidInt(value[1]))):
            return ('%s%s' % (value[0], value[1]))
            
        return None
        
    if ((len(value) % 2) == 1):
        if isValidInt(value[0]):
            return ('0%s' % value[0])
        
        return None
    
    assert(0)
  
  
def openFile(fileName, mode):
    assert(fileName is not None)
    
    print("Opening %s in mode %s" % (fileName, mode))
    try:    
        file  = open(fileName, mode)
    except Exception as e:
        print("Unable to open file %s in mode %s - %s" % (fileName, mode, e))
        sys.exit(-1)
    
    if not file:
        print("Unable to open file %s for %s" % (fileName, mode))
        sys.exit(-1)
            
    return file;


def format(value):
    return value.replace('\'', '\'\'')
   
usage = "usage: %prog [options]"
parser = OptionParser(usage=usage)
parser.add_option("--database", action="store", dest="database", help="name of database")
parser.add_option("--schema", action="store", dest="schema", help="schema of database")
parser.add_option("--user", action="store", dest="user", help="user for database")
parser.add_option("--password", action="store", dest="password", help="password for database")
parser.add_option("--host", action="store", dest="host", help="host for database")
parser.add_option("--port", action="store", dest="port", help="port for database")

(options, args) = parser.parse_args()


validateOption("database", options.database)
validateOption("schema", options.schema)
validateOption("user", options.user)
validateOption("password", options.password)
validateOption("host", options.host)
validateOption("port", options.port)

db = pg_driver.connect( \
    user = options.user, \
    password = options.password, \
    host = options.host, \
    database = options.database, \
    port = options.port \
    )
    
    
statement = "DELETE from dba.tbl_ro_to_anzsrcfor"
print(statement)
db.execute(statement)

counter = constructCounter()
unresolvedFile = openFile("Unresolved.txt", 'w')
insertSelectFile = openFile("InsertRegistryObjectDivision.txt", 'w')
insertSelectFile.write("INSERT INTO dba.tbl_ro_to_anzsrcfor (ro_to_anzsrcfor_id, registry_object_key, anzsrcfor_division, anzsrcfor_value) VALUES\n")

statement = ("SELECT registry_object_key, value from %s.vm_collections_with_anzsrc_for" % options.schema)
print(statement)
ps = db.prepare(statement)
rowList = ps()
rowCount = len(rowList)
print("rowcount: %d" % (rowCount))
currentRow = 0
for row in rowList:
    key = row[0]
    assert(key is not None)
    value = row[1]
    assert(row is not None)
    
    division = divisionFromValue(value)
    currentRow += 1
    if division is None:
        unresolvedFile.write("Key: %s, Value: %s\n" % (key, value))
        continue
        
    ID = next(counter)
    assert(division is not None)
        
    formattedKey = format(key)
    assert(formattedKey is not None)

    formattedValue = format(value)
    assert(formattedValue is not None)
    
    delimiter = (',' if currentRow < rowCount else ';')
    insertSelectFile.write("(%d, \'%s\', \'%s\', \'%s\')%s\n" % (ID, formattedKey, division, formattedValue, delimiter))
    #print("Id: %d, Key: %s, Value: %s, Division: %s" % (ID, key, value, division))


insertSelectFile.close()


insertSelectFile = openFile("InsertRegistryObjectDivision.txt", 'r')

statement = ""
for line in insertSelectFile:
    statement += line
    
    
#print(statement)
db.execute(statement)
   
insertSelectFile.close()
unresolvedFile.close()

#print(ps())

#ps = db.prepare("SELECT * from dba.tbl_ro_to_anzsrcfor")
#for row in ps:
#    print(row)
    
#insertIntoTblRoToAnzsrcfor('1', '102.100.100/4513', '12', '120102')

#ps = db.prepare("SELECT * from dba.tbl_ro_to_anzsrcfor")
#for row in ps:
#    print(row)




                    
                    
                   
