# Periopthalmus argentilineatus: SSL_assemby

Keenan Larriviere

Steps below followed preprocessing protocol on [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) under guidance of Dr. Bird

> To do: move .out files to logs dir!

## Step 1 FASTQC

Multi_FASTQC.sh in [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) was run on all raw PAR data

Files output to and results reported in multiqc_report_fq.gz.html in Multi_FASTQC dir

## Step 2 Clumpify

runCLUMPIFY_r1r2_array.bash in [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) was run on fq.gz files

Files and results output to fq_fp1_clmparray_fp2

Results reported in multiqc_report_fq.gz.html
- There were consistent abnormalities in the %GC of the 1st 15 bp when data was viewed in MultiQC

Clumpify was then run a second time, trimming the first 15 bp

Files and results output to fq_fp1_clmparray_fp2b

Results reported in 2nd_fastp_report.html

## Step 3 Screening

Moved forward with both f2p (untrimmed) and f2pb (trimmed) data for screening

runFQSCRN_6.bash in [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) was run on all f2p and f2pb files

Files output to fq_fp1_clmparray_fp2b_fqscrn for trimmed and fq_fp1_clmparray_fp2_fqscrn for untrimmed

## Step 4 Repair

runREPAIR.sbatch in [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) was run on all screened files by Dr. Bird

Files output to fq_fp1_clmparray_fp2b_fqscrn_repaired for trimmed and fq_fp1_clmparray_fp2_fqscrn_repaired for untrimmed

read_calculator_ssl.sh was then run in the Par home dir as per repo instructions
- However, this script doesn't work with our situation where we have fp2 and fp2b, so Dr. Bird suggested skipping it

## Step 5 Genome Properties

Steps below followed protocol on [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) under the guidance of Dr. Bird

- genomesize.com had no data available for Par

runJellyfish.sbatch in [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) was run on trimmed files first and then untrimmed files

Files output to fq_fp1_clmparray_fp2b_fqscrn_repaired_jfsh and fq_fp1_clmparray_fp2_fqscrn_repaired_jfsh, respectively

Uploaded fp2 and fp2b hito files to GenomeScope v1.0 and v2.0

Genome stats for Par (fp2) from Jellyfish/GenomeScope v1.0 and v2.0, k=21 for both versions
- [v1.0 link](http://genomescope.org/analysis.php?code=6ie1xZrvsS5m4MXxhSqg)
- [v2.0 link](http://genomescope.org/genomescope2.0/analysis.php?code=CkFpsIcRUMVJ3IOYxV5M)
- fp2 data not being used for SPAdes as of yet

version    |stat    |min    |max
------  |------ |------ |------
1  |Heterozygosity  |0.200501%       |0.220126%
2  |Heterozygosity  |1.34838%       |1.37913%
1  |Genome Haploid Length   |1,080,169,607 bp |1,086,129,363 bp
2  |Genome Haploid Length   |579,496,721 bp |581,452,675 bp
1  |Model Fit       |93.0612%         |95.2325%
2  |Model Fit       |81.8756%       |94.1884%

Genome stats for Par (fp2b) from Jellyfish/GenomeScope v1.0 and v2.0, k=21 for both versions
- [v1.0 link](http://genomescope.org/analysis.php?code=I9puLlREIec3rYyYvB6G)
- [v2.0 link](http://genomescope.org/genomescope2.0/analysis.php?code=LxzqHbceNr3VM8DPraVU)
- v1.0 will be used going forward for assembly since it has better model fit

version    |stat    |min    |max
------  |------ |------ |------
1  |Heterozygosity  |0.200879%       |0.218052%
2  |Heterozygosity  |1.35285%       |1.38177%
1  |Genome Haploid Length   |1,087,172,270 bp |1,092,732,992 bp
2  |Genome Haploid Length   |582,562,839 bp |584,432,399 bp
1  |Model Fit       |93.555%       |95.6701%
2  |Model Fit       |82.1948%       |94.844%

## Step 6 Genome Assembly

runSPADEShimem_R1R2_noisolate.sbatch in [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) on fq_fp1_clmparray_fp2b_fqscrn_repaired using 1.093 Bbp as size estimate
- Library 1 ran first
- Library 2 ran second
- Library 3 ran third
- All 3 libraries ran together last
