#!/bin/bash

# this script queries the mitofinder dirs and determines which libraries yielded mtDNA contigs, and which did not

MitoFinderDIR=$1

ls -lhtr $MitoFinderDIR | \
        grep "^d" | \
        sed -e 's/  / /g' | \
        cut -d " " -f 9 | \
        grep -v "mitofinder_refpanel" | \
        grep -v "logs" | \
        sort > \
        $MitoFinderDIR/all_mitofinder_libs.txt

find "$MitoFinderDIR" -type f -name "*MitoFinder.log" -exec grep -H "MitoFinder.*found.*contig" {} \; | \
        tr ":" "\t" | \
        sort -k1,1 > \
        $MitoFinderDIR/results_summary_mitofinder.tsv

cat $MitoFinderDIR/results_summary_mitofinder.tsv | \
        grep "MitoFinder di[dt] not" | \
        sed 's/_MitoFinder\.log.*$//' | \
        sed 's/^.*\///g' | \
        sort > \
        $MitoFinderDIR/noMTDNAfound_mitofinder_libs.txt

cat $MitoFinderDIR/results_summary_mitofinder.tsv | \
        grep "MitoFinder found" | \
        sed 's/_MitoFinder\.log.*$//' | \
        sed 's/^.*\///g' | \
        sort > \
        $MitoFinderDIR/MTDNAfound_mitofinder_libs.txt

ls $MitoFinderDIR/*/*Final_Results/*_contig_*genes_NT.fasta | \
        sed 's/^[^/]*\///' | \
        sed 's/\/.*//' | \
        uniq | \
        sort > \
        $MitoFinderDIR/successfulFASTA_mitofinder_libs.txt

comm -23 $MitoFinderDIR/all_mitofinder_libs.txt $MitoFinderDIR/successfulFASTA_mitofinder_libs.txt > \
        $MitoFinderDIR/failedFASTA_mitofinder_libs.txt

comm -23 $MitoFinderDIR/all_mitofinder_libs.txt \
        <(cat $MitoFinderDIR/noMTDNAfound_mitofinder_libs.txt \
              $MitoFinderDIR/MTDNAfound_mitofinder_libs.txt | \
              sort) > \
        $MitoFinderDIR/RunInterrupted_mitofinder_libs.txt

