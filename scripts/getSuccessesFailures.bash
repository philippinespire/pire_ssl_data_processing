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
        $MitoFinderDIR/mitofinder_libs_all.txt

find "$MitoFinderDIR" -type f -name "*MitoFinder.log" -exec grep -H "MitoFinder.*found.*contig" {} \; | \
        tr ":" "\t" | \
        sort -k1,1 > \
        $MitoFinderDIR/mitofinder_results_summary.tsv

cat $MitoFinderDIR/mitofinder_results_summary.tsv | \
        grep "MitoFinder di[dt] not" | \
        sed 's/_MitoFinder\.log.*$//' | \
        sed 's/^.*\///g' | \
        sort > \
        $MitoFinderDIR/mitofinder_libs_NoMTDNAfound.txt

cat $MitoFinderDIR/mitofinder_results_summary.tsv | \
        grep "MitoFinder found" | \
        sed 's/_MitoFinder\.log.*$//' | \
        sed 's/^.*\///g' | \
        sort > \
        $MitoFinderDIR/mitofinder_libs_MTDNAfound.txt

ls $MitoFinderDIR/*/*Final_Results/*_contig_*genes_NT.fasta | \
        sed 's/^[^/]*\///' | \
        sed 's/\/.*//' | \
        uniq | \
        sort > \
        $MitoFinderDIR/mitofinder_libs_successfulFASTA.txt

comm -23 $MitoFinderDIR/mitofinder_libs_all.txt $MitoFinderDIR/mitofinder_libs_successfulFASTA.txt > \
        $MitoFinderDIR/mitofinder_libs_failedFASTA.txt

comm -23 $MitoFinderDIR/all_mitofinder_libs.txt \
        <(cat $MitoFinderDIR/mitofinder_libs_NoMTDNAfound.txt \
              $MitoFinderDIR/mitofinder_libs_MTDNAfound.txt | \
              sort) > \
        $MitoFinderDIR/mitofinder_libs_RunInterrupted.txt

