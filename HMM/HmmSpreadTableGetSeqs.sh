#!/bin/bash

#Always add a stop to the script if there is a failure at anypoint
set -e 

#First input = name of hmm
#Second input = R script
#Third Input = Table folder also used as file extension

#Check to make sure there are at least 3 arguments passed
if [ $# -lt 3 ]; then
        echo Did not input 3 arguments
        echo HMM for 1st
        echo Rscript for 2nd
        echo Folder for 3rd
        exit 1
fi

read -p "Is the 1st input HMM, 2nd input RSCRIPT, and 3rd input FOLDER? Type y to continue. " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

FILES=$(ls | grep 'pep$') 
HMM=$1
RSCRIPT=$2
TABLE=$3

mkdir $TABLE
mkdir HMMSequenceMatches

for i in $FILES
do
        hmmsearch --tblout $i.tbl $HMM $i
        Rscript $RSCRIPT $i.tbl $i.tbl
        for seq in $(cut -f1 $i.tbl | tail -n +2)
        do
        	grep -A 1 $seq $i >> $i.hmmhits
        done
        mv $i.tbl $TABLE
        mv $i.hmmhits HMMSequenceMatches
done