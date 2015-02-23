# Reads datasets from an excel file of Government Departments and Agencies and adds them to a pre-existing database.
# input:  xls of Government Departments and Agencies (Gov dept/agency per worksheet)
#           - e.g. AustralianGovernmentDepartmentsAToD.xls which is the output of WriteCSVMultiTabExcel.py
#           - e.g. AustralianGovernmentDepartmentsEToZ.xls which is the output of WriteCSVMultiTabExcel.py
# ouputs:  
#           Adds datasets per department to the Australian_government database
import _mysql
import string
import sys
import getopt
import re
import os
import os.path
import csv
from types import *
import xlrd

from optparse import OptionParser

FILE_out = open("out.txt","w")

usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("-i", "--input", dest="excel_file", help="path to the multi-sheet excel file of Australian Government Departments/Agencies - e.g. output from WriteCSVMultiTabExcel.py")

(options, args) = parser.parse_args()
#print(len(args))
#if len(args) != 1:
#    parser.error("Incorrect number of arguments. Try --help for usage.")

FILE_out.write("Opening: %s" % options.excel_file)

db=_mysql.connect(host="localhost",user="root", passwd="root",db="Australian_government")

if len(options.excel_file) < 1:
    parser.error("Invalid file name.  Try --help for usage")
    
if (options.excel_file).find(".xls") < 0:
    parser.error("An .xls file is required: e.g. output from WriteCSVMultiTabExcel.py. Try --help for usage")
    
class DataSet:
    def displayDataSet(self):
        print("DeptId : ", self.DeptId,  ", Name: ", self.Name,  ", SubDepartment: ", self.SubDepartment,  ", ContactName: ", self.ContactName,  ", JiraReference: ", self.JiraReference,  ", ProjectId: ", self.ProjectId,  ", ProjectName: ", self.ProjectName,  ", Other: ", self.Other)
        
def attributeName(col):
    if col == 0:
        return "DataSet"
    
    if col == 1:
        return "SubDepartment"
        
    if col == 2:
        return "ContactName"
    
    if col == 3:
        return "ContactNumber"
        
    if col == 4:
        return "JiraReference"
        
    if col == 5:
        return "ProjectId"
    
    if col == 6:
        return "ProjectName"
        
    if col == 7:
        return "Other"
        
    assert(0)
    
def attrFromObject(dataSet, attrName):
    if hasattr(dataSet, attrName):
        return getattr(dataSet, attrName)
        
    return ""
    
def attrForMatching(list):
    list.append("JiraReference")
    list.append("ProjectId")
    list.append("ProjectName")
    list.append("DataSet")
    return list

    
def updateExisting(dataSet):
    # is there already a dataset for this department that has the same jirareference?
    if not hasattr(dataSet, "DeptId"):
        assert(0)
    
    deptID = getattr(dataSet, "DeptId")
    attributes = list()
    attrForMatching(attributes)
    for attribute in attributes:
        if valueMatch(dataSet, deptID, attribute):
            FILE_out.write("Matched on attribute: %s\n" % attribute)
            return update(dataSet, attribute)
    
    return 0;
    
def update(dataSet, matchedAttribute):
    sql = ("update dataset d set \
    d.DataSet = '%s', \
    d.SubDepartment = '%s', \
    d.ContactName = '%s', \
    d.ContactNumber = '%s', \
    d.JiraReference = '%s', \
    d.ProjectId = '%s', \
    d.ProjectName = '%s', \
    d.Other = '%s' \
    where D_Id = '%s' and %s = '%s'" %    
    (attrFromObject(dataSet, 'DataSet'), \
    attrFromObject(dataSet, 'SubDepartment'), \
    attrFromObject(dataSet, 'ContactName'), \
    attrFromObject(dataSet, 'ContactNumber'), \
    attrFromObject(dataSet, 'JiraReference'), \
    attrFromObject(dataSet, 'ProjectId'), \
    attrFromObject(dataSet, 'ProjectName'), \
    attrFromObject(dataSet, 'Other'), \
    attrFromObject(dataSet, 'DeptId'), \
    matchedAttribute, \
    attrFromObject(dataSet, matchedAttribute)))
    FILE_out.write("%s\n" % sql)
    db.query(sql)
    return 1
        
def valueMatch(dataSet, deptID, attribute):
    if hasattr(dataSet, attribute):
        value = getattr(dataSet, attribute)
        if len(value) > 0:
            sql = "select * from dataset where D_Id = '%s' and %s = '%s'" % (deptID, attribute, value)
            db.query(sql)
            FILE_out.write("%s\n" % sql)
            result=db.store_result()
            if result.num_rows() > 0:
                FILE_out.write("Rows returned: %d\n" % result.num_rows())
                return 1
            
        FILE_out.write("No matching data sets found\n")
        
    return 0

def insert(dataSet):
    # add each dataset to the database
    sql = ("insert into dataset (D_Id, DataSet, SubDepartment, ContactName, ContactNumber, JiraReference, ProjectId, ProjectName, Other) \
    values (\'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\')\n" % \
    ((attrFromObject(dataSet, 'DeptId')), \
    (attrFromObject(dataSet, 'DataSet')),
    (attrFromObject(dataSet, 'SubDepartment')),
    (attrFromObject(dataSet, 'ContactName')),
    (attrFromObject(dataSet, 'ContactNumber')),
    (attrFromObject(dataSet, 'JiraReference')),
    (attrFromObject(dataSet, 'ProjectId')),
    (attrFromObject(dataSet, 'ProjectName')),
    (attrFromObject(dataSet, 'Other'))))
    
    FILE_out.write("%s\n" % sql)
    db.query(sql);
                
book = xlrd.open_workbook(options.excel_file)
#FILE_out.write("The number of worksheets is %d\n" % book.nsheets)
FILE_out.write("Worksheet name(s): %s\n" % book.sheet_names())

dataSets = list() # empty list for datasets

for sheetIndex in range(1, book.nsheets-1):
    # grab sheet for current department and associated department id 
    sh = book.sheet_by_index(sheetIndex)
    deptId = sh.cell_value(0, 0).encode('ascii', 'ignore')
    FILE_out.write("Name: %s, rows: %d, cols: %d\n" % (sh.name, sh.nrows, sh.ncols))
    for row in range(8, sh.nrows):
        # create a DataSet object per row (set the current department Id)
        FILE_out.write("New dataset for deptId: %s - " % deptId)
        dataSet = DataSet()
        setattr(dataSet, "DeptId", deptId)
        for col in range(0, sh.ncols):
            FILE_out.write("col: %d " % col)
            cellVal = sh.cell_value(row, col).encode('ascii', 'ignore')
            attrName = attributeName(col)
            setattr(dataSet, attrName, cellVal)
            FILE_out.write("%s: %s, " % (attrName, cellVal))
        FILE_out.write("\n")
        dataSets.append(dataSet) # add dataset to our list of datasets
      

FILE_out.write("%d DataSets found\n" % len(dataSets)) 

for dataSet in dataSets:
    # is there a dataset in the database that has a matching value for this department?
    if not updateExisting(dataSet):
        insert(dataSet)
    
    
db.commit()
db.close()
