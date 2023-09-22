#!/bin/bash

# this script takes sequences in a fasta file and makes shorter sequences tiled across the larger sequence
# tiles are between 200 and 300 bp and a new tile starts every 100 bp

inFILE=$1

awk '
BEGIN { RS = ">" ; FS = "\n" ; ORS = "" }
NR > 1 {
    header = $1
    seq = ""
    for (i=2; i<=NF; i++) {
        seq = seq $i
    }
    len = length(seq)
    i = 0
    while (i < len) {
        if (len - i < 200) {
            subseq_len = len - i
        } else {
            subseq_len = 300
            if (len - i - 300 < 200 && len - i - 300 > 0) {
                subseq_len = len - i - 100
            }
        }
        subseq = substr(seq, i+1, subseq_len)
        printf(">%s_%d-%d\n%s\n", header, i+1, i+subseq_len, subseq)
        i += (subseq_len == len - i) ? subseq_len : 100  # Move 100 bp downstream for the next tile, unless it's the last tile
    }
}
' $inFILE


