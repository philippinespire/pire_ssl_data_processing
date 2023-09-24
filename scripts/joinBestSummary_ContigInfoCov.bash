#!/bin/bash

leftFILE=$1
rightFILE=$2
outFILE=$3

header1=$(head -n 1 $leftFILE)
header2=$(head -n 1 $rightFILE)
joined_header="Composite_Key $header1 $header2"

tail -n+2 $leftFILE | \
        awk -F'\t' 'BEGIN {OFS="\t"} {print $1 "_" $2, $0}' | \
        sort -k1,1 > sorted_modified_$leftFILE

tail -n+2 $rightFILE | \
        awk -F'\t' 'BEGIN {OFS="\t"} {print $2 "_" $4, $0}' | \
        sort -k1,1 > sorted_modified_$rightFILE

cat <(echo -e "$joined_header" | tr -s " " "\t") \
        <(join -1 1 -2 1 -t $'\t' -a 1 sorted_modified_$leftFILE sorted_modified_$rightFILE) |
        awk -F'\t' 'BEGIN {OFS="\t"} {print $11, $2, $3, $15, $18, $4, $5, $6, $7, $8, $9, $10, $13, $16, $17}' > \
        $outFILE

rm sorted_modified_$leftFILE sorted_modified_$rightFILE
