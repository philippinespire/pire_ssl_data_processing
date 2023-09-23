#!/bin/bash

# this script queries the mitofinder dirs and determines which libraries yielded mtDNA contigs, and which did not

MitoFinderDIR=$1

ls -lhtr $MitoFinderDIR | \
        grep "^d" | \
        sed -e 's/  / /g' | \
        cut -d " " -f 9 | \
        grep -v "mitofinder_refpanel" | \
        grep -v "logs" | \
        sort > $MitoFinderDIR/all_mitofinder.txt

#ls -lhtr $MitoFinderDIR/*/*.scafSeq | \
#        cut -d "/" -f 2 | \
#        sed -e 's/  / /g' | \
#        cut -d " " -f 9 | \
#        sort > $MitoFinderDIR/successful_mitofinder.txt

ls $MitoFinderDIR/*/*Final_Results/*_contig_*genes_NT.fasta | \
        sed 's/\/.*//' | \
        uniq > \
        $MitoFinderDIR/successful_mitofinder.txt

comm -23 $MitoFinderDIR/all_mitofinder.txt $MitoFinderDIR/successful_mitofinder.txt > $MitoFinderDIR/failed_mitofinder.txt

