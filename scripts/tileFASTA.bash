#!/bin/bash

# Check if the input file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 input.fasta"
    exit 1
fi

input_file="$1"

awk '
# Function to process each sequence
function process_sequence(seq_name, sequence) {
    len = length(sequence)

    if (len < 300) {
        print ">" seq_name "_1-" len
        print sequence
        return
    }

    last_start = 1

    for(start = 1; start + 299 <= len; start += 50) {
        end = start + 299
        print ">" seq_name "_" start "-" end
        print substr(sequence, start, 300)
	last_start = start
    }

    if (end < len) {
	final_start = last_start + 50
#	if (final_start + 299 > len) {
#		final_start = len - 299
#	}
	final_end = len
	print ">" seq_name "_" final_start "-" final_end
	print substr(sequence, final_start, final_end - final_start + 1)
    }
}

# Main script starts here
BEGIN {
    sequence = ""
    seq_name = ""
}

# If the line starts with ">", it"s a sequence identifier
/^>/ {
    # Process the previous sequence if any
    if(seq_name != "") {
        process_sequence(seq_name, sequence)
    }

    # Reset sequence and name for the next sequence
    seq_name = substr($0, 2)
    sequence = ""
    next
}

# If we reach this point, the line is part of a sequence
{
    sequence = sequence $0
}

# Process the last sequence
END {
    if(seq_name != "") {
        process_sequence(seq_name, sequence)
    }
}
' "$input_file"
