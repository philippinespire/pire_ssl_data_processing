#!/bin/bash

# this script harvests mtDNA contig info output by mitofinder and makes it tidy

# inPATH="*/*Final_Results/*infos"
inPATH=$1

################################
# echo "Input Path: $inPATH"
################################

grep -B10 "^Circular" $inPATH | \
sed -e 's/^.*Initial contig name:/Initial_contig_name/' \
    -e 's/^.*Length:/Contig_length/' \
    -e 's/.*Statistics for/Contig_number/' \
    -e 's/final sequence:/contig_0/' \
    -e 's/\(contig\) \([1-9][0-9]*\):/\1_\2/' \
    -e 's/^.*GC content:/GC_content/' \
    -e 's/\%//' \
    -e 's/^.*Circularization:/Circularization/' \
    -e 's/Not found/Not_found/' \
    -e 's/\(^.*\)\/.*\-$/Treatment \1/' \
    -e 's/\/.*$//' | \
awk 'BEGIN {
    OFS="\t";
    print "Assembler", "Treatment", "Initial_Contig_Name", "Contig_Number", "Length", "GC_Content", "Circularization"
}
/--/ {
    print assembler, treatment, initial_contig_name, contig_number, contig_length, gc_content, circularization;
    assembler = treatment = initial_contig_name = contig_number = contig_length = gc_content = circularization = "";
    next;
}
{
    if ($0 ~ /Initial_contig_name/) {
        initial_contig_name = $2;
        if ($0 ~ /_cov_/) {
            assembler = "metaspades"
        } else if ($0 ~ / k[1-9][0-9]*_/) {
            assembler = "megahit"
        } else {
            assembler = "unk_assembler"
        }
    } else if ($0 ~ /Contig_number/) {
        contig_number = $2;
    } else if ($0 ~ /Contig_length/) {
        contig_length = $2;
    } else if ($0 ~ /GC_content/) {
        gc_content = $2;
    } else if ($0 ~ /Circularization/) {
        circularization = $2;
    } else if ($0 ~ /Treatment/) {
        treatment = $2;
    }
}
END {
    print assembler, treatment, initial_contig_name, contig_number, contig_length, gc_content, circularization;
}
'
