#!/bin/bash

# A script to sort ortholog files from the ete3 amino acid site selection model

#Always add a stop to the script if there is a failure at anypoint
set -e

#Check to make sure there are at least 1 argument is passed
if [ $# -ne 1 ]; then
        echo Did not input 1 argument
        echo Need to input ortholog file
        exit 1
fi 

FILE=$1
NUMQUERIES=$(grep -c 'Processing' $FILE)

echo file is $FILE and number of files is $NUMQUERIES
echo file is $FILE and number of files - 1 is $[NUMQUERIES - 1]

csplit -n 4 $FILE '/^Processing/' '{'$[NUMQUERIES - 2]'}'
