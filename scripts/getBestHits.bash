#!/bin/bash

# This script retains 1 row per query seq.
# Priority: lowest E-value -> highest Bit Score -> highest Percent Identity

inFILE=$1

grep -vi "environmental" $inFILE | \
awk -F'\t' '{
    if (!($1 in evalue) || $15 < evalue[$1] || ($15 == evalue[$1] && ($16 > bitscore[$1] || ($16 == bitscore[$1] && $2 > pident[$1])))) {
        evalue[$1] = $15;
        bitscore[$1] = $16;
        pident[$1] = $2;
        line[$1] = $0;
    }
}
END {
    for (i in line) {
        print line[i];
    }
}' | \
sed -e 's/_contig/\tcontig/' -e 's/\(contig_[0-9][0-9]*\)_/\1\t/' -e 's/@/\t/' | \
sort -k1,1 -k3,3 -k2,2 -k4,4n
