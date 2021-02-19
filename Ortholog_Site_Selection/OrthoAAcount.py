#!/usr/bin/env python3

"""
This module takes a directory of parsed site 
Returns a dataframe counting the number of conserved and relaxed sites for each ortholog.

"""

#take arguments from shell
import argparse
#os for directory navigation/access
import os   
#re for grep
import re
#import pandas for dataframes
import pandas as pd

#Make a list of all directories of interest.
def xxFileNames(path):
    #Make a list of all directories of interest.
    all_files = os.listdir(path)
    #Filter files of interest based on a pattern match
    text_files = []
    for file in all_files:
        if re.search(r"xx", file):
            text_files.append(file)
    return(text_files)

#Extract each ortholog number
def ortholog_names(xxFile):
    #Extract each ortholog number
    firstline = open(str(xxFile)).readline().rstrip()
    ortho_match = re.search(r"OG[0-9]+", firstline).group(0)
    return(ortho_match)

#Get Conserved and Relaxed aa counts
#Initialize an empty list

def count_Conserved_Relaxed_AA(xxFile):
    #Open and read file
    OpenFile = open(xxFile).readlines()

    #Initialize an empty list for each type of amino acid
    Conserved_aa = []
    Relaxed_aa = [] 

    #Compile the pattern of digits, dash, spaces, and more digits
    #Capture first and last amino acid position with ()
    dashpattern = re.compile(r'(\d+)-\s*(\d+)')
    #If not a range, capture pattern space, digits to avoid the 0.95
    alonepattern = re.compile(r'\s(\d+)')

    for line in OpenFile:
        #Find all lines that match have the conserved aa
        if "Conserved" in line:
            #Find all range of amino acids
            if "-" in line:
                #Find these within each line
                match = dashpattern.search(line)
                #Obtain the 1st number match and convert to integer
                firstnum = int(match.group(1))
                #Obtain the 2nd number match and convert to integer
                lastnum = int(match.group(2))
                #Loop through range and append each integer
                numrange = list(range(firstnum, lastnum+1))
                for num in numrange:
                    Conserved_aa.append(num)
            else:
                alonematch = alonepattern.search(line)
                num = int(alonematch.group(1))
                Conserved_aa.append(num)
        if "Relaxed" in line:
            if "-" in line:
                match = dashpattern.search(line)
                firstnum = int(match.group(1))
                lastnum = int(match.group(2))
                numrange = list(range(firstnum, lastnum+1))
                for num in numrange:
                    Relaxed_aa.append(num)
            else:
                alonematch = alonepattern.search(line)
                num = int(alonematch.group(1))
                Relaxed_aa.append(num)
    ConservedAAcount = len(Conserved_aa)
    RelaxedAAcount = len(Relaxed_aa)
    return [ConservedAAcount, RelaxedAAcount]

#Loop through all files populate a list of ortholog, conserved count, and relaxed count 

def orthologDF(xxFileNames):
    #Loop through all files populate a list of ortholog, conserved count, and relaxed count 
    ortholog = []
    conserved_count = []
    relaxed_count = []
    for file in xxFileNames:
        name = ortholog_names(file)
        ortholog.append(name)
        AAs = count_Conserved_Relaxed_AA(file)
        conserved_count.append(AAs[0])
        relaxed_count.append(AAs[1])
    #Create a dictionary with ortholog, conserved, relaxed
    orthoDict = {'Ortholog':ortholog, 'Conserved_AA_count':conserved_count, 'Relaxed_AA_count':relaxed_count}
    #Create dataframe with columns ortholog, conserved, relaxed
    orthoDF = pd.DataFrame(orthoDict)
    return orthoDF

def run(args):
    #Create a list of all directories in current path
    All_File_Names = xxFileNames(args.input)
    #Create a dataframe of ortholog and amino acid counts for conserved and relaxed sites
    orthoDF = orthologDF(All_File_Names)
    #Export csv
    orthoDF.to_csv(args.output)


def main():
    parser=argparse.ArgumentParser(description="Convert the site selection model output into a dataframe that counts the number of conserved and relaxed sites for each ortholog.")
    parser.add_argument("-in",help="path to input ortholog files" ,dest="input", type=str, required=True)
    parser.add_argument("-out",help="csv output filename" ,dest="output", type=str, required=True)
    parser.set_defaults(func=run)
    args=parser.parse_args()
    args.func(args)

if __name__=="__main__":
    main()
