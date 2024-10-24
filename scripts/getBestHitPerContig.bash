#!/bin/bash

# This script retains 1 row per unique combination of columns 1 and 3.
# Priority: lowest E-value -> highest Bit Score -> highest Percent Identity

inFILE=$1
outFILE=$2

echo -e "Treatment\tContig_Number\tKingdom\tSpecies\tpident\tqcov\tevalue\tbitscore\tgene" > $outFILE

awk -F'\t' '{
    key = $1 "\t" $3;
    if (!(key in evalue) || $18 < evalue[key] || ($18 == evalue[key] && ($19 > bitscore[key] || ($19 == bitscore[key] && $5 > pident[key])))) {
        evalue[key] = $18;
        bitscore[key] = $19;
        pident[key] = $5;
        species[key] = $8;
        line[key] = $1 "\t" $3 "\t" $7 "\t" $8 "\t" $5 "\t" $6 "\t" $18 "\t" $19 "\t" $2;
    }
    else if ($18 == evalue[key] && $19 == bitscore[key] && $5 == pident[key]) {
        # Check for unique species
        if (index(species[key], $8) == 0) {
            species[key] = species[key] ";" $8;
            line[key] = $1 "\t" $3 "\t" $7 "\t" species[key] "\t" $5 "\t" $6 "\t" $18 "\t" $19 "\t" $2;
        }
    }
}
END {
    for (i in line) {
        print line[i];
    }
}' $inFILE | \
sort -k1,1 -k2,2n >> \
$outFILE
