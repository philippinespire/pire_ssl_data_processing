#!/bin/bash

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
        subseq_len = (len - i > 300) ? 300 : len - i
        if (len - i - subseq_len < 200 && len - i - subseq_len > 0) {
            subseq_len = len - i
        }
        subseq = substr(seq, i+1, subseq_len)
        printf(">%s_%d-%d\n%s\n", header, i+1, i+subseq_len, subseq)
        i += subseq_len
    }
}
' $inFILE
