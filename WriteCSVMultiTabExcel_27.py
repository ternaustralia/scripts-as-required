# input:  csv of Government Departments and Agencies (e.g. AustralianGovernmentContacts.csv which is the output of GovDeptsFromWebToDB.py)
# ouputs:  
#       AustralianGovernmentDepartmentsAToZ.xls which contains one tab listing all Government Departments and Agencies
#       AustralianGovernmentDepartmentsAToD.xls which contains:
#           - one tab listing all Government Departments and Agencies with names starting with letters between and including A to D
#           - a tab per Government Department/Agencies identified on the first tab
#       AustralianGovernmentDepartmentsEToZ.xls which contains as above but for letters between E and Z

import string
import sys
import getopt
import re
import os
import os.path
import csv
from pyExcelerator import *

from optparse import OptionParser

usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("-i", "--input", dest="csv_file", help="path to the csv file of Australian Government Departments/Agencies - e.g. output from GovDeptsFromWebToDB.py")

(options, args) = parser.parse_args()
#print(len(args))
#if len(args) != 1:
    #parser.error("Incorrect number of arguments. Try --help for usage.")

print(options.csv_file)

if len(options.csv_file) < 1:
    parser.error("Invalid file name.  Try --help for usage")
    
if (options.csv_file).find(".csv") < 0:
    parser.error("A .csv file is required: e.g. output from GovDeptsFromWebToDB.py. Try --help for usage")

    
def openExcelSheet(sheetName, workbook):
  print("Creating sheet %s\n" % sheetName)
  """ Opens a reference to an Excel WorkBook and Worksheet objects """
  worksheet = workbook.add_sheet(sheetName)
  return workbook, worksheet
  
def writeExcelRowPerField(worksheet, columns):
  """ Write a non-header row into the worksheet """
  cno = 0
  lno = 0
  for column in columns:
    worksheet.write(lno, cno, column)
    lno = lno + 1
   
def writeExcelRowPerLine(firstLetter, lastLetter, worksheet, lno, columns):
  """ Write a non-header row into the worksheet """
  cno = 0
  deptLetter = columns[1][0];
  if len(deptLetter) != 1:
    assert(0)
    return 0
    
  print("Name: %s, ord: %d" %(deptLetter, ord(deptLetter)))
  if ord(deptLetter) > ord(lastLetter):
    return 0
    
  if ord(deptLetter) < ord(firstLetter):
    return 0
  
  for column in columns:
    #print("write: %s, lno:%d, colunm:%d" % (column, lno, cno))
    worksheet.write(lno, cno, column)
    cno = cno + 1   
    
  return 1
    
def closeExcelSheet(workbook, outputFileName):
  """ Saves the in-memory WorkBook object into the specified file """
  workbook.save(outputFileName+'.xls')
  
def fillFirstSheet(firstLetter, lastLetter, inputFileName, sepChar, workbook, worksheet):
    inputFile = open(inputFileName, 'r')
    reader = csv.reader(inputFile, delimiter=sepChar)
    lno = 0
    for line in reader:
        if writeExcelRowPerLine(firstLetter, lastLetter, worksheet, lno, line) > 0:
            lno = lno + 1
    closeExcelSheet(workbook, outputFileName+firstLetter+'To'+lastLetter)
    inputFile.close()
    
def appendSheetPerLine(firstLetter, lastLetter, inputFileName, sepChar, workbook, worksheet):
    inputFile = open(inputFileName, 'r')
    reader = csv.reader(inputFile, delimiter=sepChar)
    titlePresent = False
    linesPerFile = 1
    fno = 0
    lno = 0
    titleCols = []
    for line in reader:
        deptName = getSheetName(line)
        if len(deptName) < 1:
            continue;
        deptLetter = deptName[0]
        if ord(deptLetter) < ord(firstLetter):
            continue;
        if ord(deptLetter) > ord(lastLetter):
            continue;
        workbook, worksheet = openExcelSheet(deptName, workbook)
        if (lno == 0 and titlePresent):
          if (len(titleCols) == 0):
            titleCols = line
          writeExcelHeader(worksheet, titleCols)
        else:
          writeExcelRowPerField(worksheet, line)
        lno = lno + 1
        if (linesPerFile != -1 and lno >= linesPerFile):
          closeExcelSheet(workbook, outputFileName+firstLetter+'To'+lastLetter)
          fno = fno + 1
          lno = 0
          
        #write placeholder for DataSet SubDepartment
        worksheet.write(7, 0, "DataSet")
        worksheet.write(7, 1, "SubDepartment")
        worksheet.write(7, 2, "ContactName")
        worksheet.write(7, 3, "ContactNumber")
        worksheet.write(7, 4, "JiraReference")
        worksheet.write(7, 5, "ProjectId")
    
    #closeExcelSheet(workbook, outputFileName+firstLetter+'To'+lastLetter)
    inputFile.close()    
          

def getSheetName(columns):
    cno = 0
    for column in columns:
        if cno == 1:
            return column; # return the value of column 1 to be the name of the sheet
        cno = cno + 1
    
    
outputFileName = "AustralianGovernmentDepartments"
sepChar = ","

firstLetter = "A"
lastLetter = "Z"
workbook = Workbook()
workbook, worksheet = openExcelSheet("AToZ", workbook)
fillFirstSheet(firstLetter, lastLetter, options.csv_file, sepChar, workbook, worksheet)

firstLetter = "A"
lastLetter = "D"
workbook = Workbook()
workbook, worksheet = openExcelSheet("AToD", workbook)
fillFirstSheet(firstLetter, lastLetter, options.csv_file, sepChar, workbook, worksheet)
appendSheetPerLine(firstLetter, lastLetter, options.csv_file, sepChar, workbook, worksheet)

firstLetter = "E"
lastLetter = "Z"
workbook = Workbook()
workbook, worksheet = openExcelSheet("EToZ", workbook)
fillFirstSheet(firstLetter, lastLetter, options.csv_file, sepChar, workbook, worksheet)
appendSheetPerLine(firstLetter, lastLetter, options.csv_file, sepChar, workbook, worksheet)


