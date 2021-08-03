#!/bin/bash -l

ls shotgun_raw_fq/*gz | parallel --no-notice -kj6 "echo -n {}',' && zgrep '^@' {} | wc -l" > fsqc.temp
ls fq_fp1/*gz | parallel --no-notice -kj6 "zgrep '^@' {} | wc -l" > fp1.temp
ls fq_fp1_clmparray/*gz | parallel --no-notice -kj6 "zgrep '^@' {} | wc -l" > clm.temp
ls fq_fp1_clmparray_fp2/*gz | parallel --no-notice -kj6 "zgrep '^@' {} | wc -l" > fp2.temp

#paste <(ls shotgun_raw_fq/*gz | parallel --no-notice -kj6 "echo -n {}',' && zgrep '^@' {} | wc -l") \
#	<(ls fq_fp1/*gz | parallel --no-notice -kj6 "zgrep '^@' {} | wc -l") \
#	<(ls fq_fp1_clmparray/*gz | parallel --no-notice -kj6 "zgrep '^@' {} | wc -l") \
#	<(ls fq_fp1_clmparray_fp2/*gz | parallel --no-notice -kj6 "zgrep '^@' {} | wc -l") > tempcount.tsv
