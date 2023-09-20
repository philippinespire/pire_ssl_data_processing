#!/bin/bash

# this script retains 1 row per query seq, the row with the highest pident

inFILE=$1

awk -F'\t' '{
    if (!($1 in max) || $2 > max[$1]) {
        max[$1] = $2;
        line[$1] = $0;
    }
}
END {
    for (i in line) {
        print line[i];
    }
}' $inFILE | \
sed -e 's/_contig/\tcontig/' -e 's/\(contig_[1-9][0-9]*\)_/\1\t/' | \
sort -k2,2 -k1,1 -k3,3n
