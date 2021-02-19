#!/bin/bash

#Always add a stop to the script if there is a failure at anypoint
set -e 

#First input = blast query

#Check to make sure there are at least 3 arguments passed
if [ $# -ne 1 ]; then
        echo Did not input 1 argument
        echo Need to input query sequence
        exit 1
fi

read -p "Is the input the query sequence? Type y to continue. " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

FILES=$(ls | grep 'pep$') 
QUERY=$1

mkdir BlastResults
mkdir BlastResults/Reports
mkdir BlastResults/Hits

for i in $FILES
do
    NAME=$(echo $i | cut -f1 -d'.')
    #Create Blast database for each peptide sequence
    makeblastdb -in $i -dbtype prot
    #Query target against each database
    blastp -query $QUERY -db $i -out ${NAME}.blast -max_hsps 1 -outfmt 6
    #Filter report of bit scores > 200
    awk '$12 > 200' ${NAME}.blast > BlastResults/Reports/${NAME}.blastreport
    #Create list of sequence names
    awk '$12 > 200' ${NAME}.blast | cut -f2 > seq.list
    #Get matches sequences from database
    seqtk subseq $i seq.list > BlastResults/Hits/${NAME}.FAS.pep
    rm ${NAME}.blast
    rm ${i}.phr
    rm ${i}.pin
    rm ${i}.psq
    rm seq.list
done