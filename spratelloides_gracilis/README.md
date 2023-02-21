# Sgr Shotgun Data Processing Log -SSL data

copy and paste this into a new species dir and fill in as steps are accomplished.

---

Following the [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) roadmap 

and [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing)

## Step 1. Fastqc

Ran the [Multi_FASTQC.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/Multi_FASTQC.sh) script. [Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/spratelloides_gracilis/Multi_FASTQC/multiqc_report_fq.gz.html) (copy and paste into a text editor locally) Save and open in your browser to view

Potential issues:  
* % duplication - not bad
  * 30s-40s
* gc content - reasonable
  * 46-48%
* quality - good
  * sequence quality and per sequence qual both good
* % adapter - good and low
  * ~2s
* number of reads - good
  * ~200M



## Step 2.  1st fastp

Used [runFASTP_1st_trim.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_1st_trim.sbatch)
to generate this [report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/spratelloides_gracilis/fq_fp1/1st_fastp_report.html)

Potential issues:  
* % duplication - not bad 
  * 31-46%
* gc content - reasonable
  * ~44%
  * more variable in pos 1-72 than in 73-150 
* passing filter - good
  * ~91%
* % adapter - not too bad 
  * 6-7.5%
* number of reads - good
  * ~340-414M (per pair of r1-r2 files)

```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash ../fq_fp1 ../fq_fp1_clmparray /scratch/e1garcia 6
```

---

## Step 3. Clumpify

Ran [runCLUMPIFY_r1r2_array.bash](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runCLUMPIFY_r1r2_array.bash) in a 3 node array in Wahab
```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmparray /scratch/e1garcia 3
```

Checked the output with `checkClumpify_EG.R`
```
enable_lmod
module load container_env mapdamage2
crun R < /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R --no-save
```

*I couldn't pass the arguments from the terminal to R correcty so I commented out few lines in checkClumpify.R to bypass this*

Clumpify worked succesfully!

Out files were moved to the `logs` dir
```
mv *out logs
```


---

## Step 4. Run fastp2

Executed `runFASTP_2_ssl.sbatch` to generate this [report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/spratelloides_gracilis/fq_fp1_clmparray_fp2/2nd_fastp_report.html)
```
#runFASTP_2_ssl.sbatch <indir> <outdir> 
# do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmparray/ fq_fp1_clmparray_fp2
```

Potential issues:  
* % duplication - low
  * 8-14%
* gc content - reasonable
  * 44s 
* passing filter - good
  * 83-85%s 
* % adapter - virtually noned
  * 0.1%
* number of reads - lost alot for albatross
  * 205-213M (per pair of r1-r2 files)

---


## Step 5. Run fastq_screen

Executed `runFQSCRN_6.bash` to generate this [report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/spratelloides_gracilis/fq_fp1_clmparray_fp2_fqscrn/fastqc_screen_report.html)

```
#runFQSCRN_6.bash <indir> <outdir> <number of nodes to run simultaneously>
# do not use trailing / in paths
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 6
``

Checked output for errors
``
ls fq_fp1_clmparray_fp2_fqscrn/*tagged.fastq.gz | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*tagged_filter.fastq.gz | wc -l 
ls fq_fp1_clmparray_fp2_fqscrn/*screen.txt | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*screen.png | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*screen.html | wc -l

# all returned 6

#checked for errors in all out files at once
grep 'error' slurm-fqscrn.*out
grep 'No reads in' slurm-fqscrn.*out

# No errors!
```

However, `runFQSCRN_6.bash` was running multiqc several times generating reports with not all the files and making many outputs. I deleted all of this and re-run multiqc with `runMULTIQC.sbatch`

I modified `runFQSCRN_6.bash` by commenting out the original execution of multiqc and added the format we are running in the trims

```sh
#runMULTIQC.sbatch <INDIR> <Report name>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runMULTIQC.sbatch "fq_fp1_clmparray_fp2_fqscrn" "fqsrn_report"
```

Highlights from [report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/spratelloides_gracilis/fq_fp1_clmparray_fp2_fqscrn/fastqc_screen_report.html):
* about 90% of reads were retained


Cleanup logs
```
mkdir logs
mv *out logs
```

---

## Step 6. Repair fastq_screen paired end files

```sh
#runREPAIR.sbatch <indir> <outdir> <threads>
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmparray_fp2_fqscrn fq_fp1_clmparray_fp2_fqscrn_repaired 40
```

This went smoothly.

---


## Calculated the percent of reads lost in each step

Executed [read_calculator_ssl.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/read_calculator_ssl.sh)
to generate the [percent read loss](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/spratelloides_gracilis/preprocess_read_change/readLoss_table.tsv) and
 [percent reads remaining](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/spratelloides_gracilis/preprocess_read_change/readsRemaining_table.tsv) tables

```sh
#read_calculator_ssl.sh <Species home dir> 
# do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/read_calculator_ssl.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

Highlights:
* 25-38% of reads were duplicates and were dropped by clumpify
* fastp2 dropped 14-17% of the reads after deduplication (lower min read lenght?)
* Total accumulative read loss is 50-60%, which results in 86-94 M reads still remaining (loss seems pretty high but we still ~90M read left!)


---

### Assembly section

## Step 7. Genome properties

I could not find Sgr in the [genomesize.com](https://www.genomesize.com/) database,
 thus I estimated the genome size of Sgr using jellyfish

From species home directory: Executed runJellyfish.sbatch using decontaminated files
```sh
#runJellyfish.sbatch <Species 3-letter ID> <indir> <outdir>
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runJellyfish.sbatch "Sgr" "fq_fp1_clmparray_fp2_fqscrn_repaired" "jellyfish_decontam"
```
This jellyfish kmer-frequency [hitogram file](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/spratelloides_gracilis/jellyfish_out/Sgr_all_reads.histo) 
was uploaded into [Genomescope v1.0](http://qb.cshl.edu/genomescope/) and [Genomescope v2.0](http://qb.cshl.edu/genomescope/genomescope2.0/) to generate the 
[v1.report](http://genomescope.org/analysis.php?code=Bm6XRZmRpQ2dNxEo8fHs) and [v2.report](http://qb.cshl.edu/genomescope/genomescope2.0/analysis.php?code=Gl6gm6OeSCqMbM7Jx1SM). Highlights:

Genome stats for Sgr from Jellyfish/GenomeScope v1.0 and v2.0, k=21 for both versions

version    |stat    |min    |max    
------  |------ |------ |------ 
1  |Heterozygosity  |1.32565%       |1.34149%       
2  |Heterozygosity  |1.32975%       |1.35795%       
1  |Genome Haploid Length   |693,553,516 bp |695,211,827 bp 
2  |Genome Haploid Length   |851,426,393 bp |853,706,410 bp 
1  |Model Fit       |97.6162%       |98.7154%       
2  |Model Fit       |65.11692%       |96.0314%       

---

**Note:** the initial commands for assembly used the mid-point between min and max of Genome Scope V1, meaning that the first set of QUAST runs were feed this number.
 After these runs were completed, we decided to use Genome Scope V2 instead. Giving that the model fit for the min is usually low, I recommended using the max estimate (rounded up or down to the nearest million).

SPAdes and BUSCO do not incoorporate the genome estimate so these don't need to be re-ran. Thus, I am only rerunning QUAST with the max estimate of V2.

QUAST stat table has also been updated to include the genome scope version and "#N's per 100 kbp"

---

### Genome Size (1n bp)

Jellyfish genome size 1n: 694000000

C-value from genomesize.com 1n: not_found

GenBank chromosome-scale genome size 1n: not_found

Genome size from other sources 1n: not_found

Sources: 
1. 

---

## Step 8. Assemble the genome using [SPAdes](https://github.com/ablab/spades#sec3.2)

In our previous tests, contaminated data has produced the best assemblies for nDNA but decontaminated assemblies were better for mtDNA. The effect of using merged files remains unclear

Thus, I ran 4 assembly treatments: Contam with and without merged files and the same for Decontam. See [SPADES_Test_info](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/spratelloides_gracilis/SPADES_Test_info) for full details
```sh
CONCLUSION: Recommending running contam and decontam but skipping MRDG all together
```

***UPDATE SEE BELOW: Recommending running contam for each library independently and one run using all the libraries. Then run the decontaminated data for the best assembly only***

LOG:
Executed [runSPADEShimem_R1R2_noisolate.sbatch](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runSPADEShimem_R1R2_noisolate.sbatch). *Do this for other species*
```sh
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <contam | decontam> <genome size in bp> <species dir>
# do not use trailing / in paths. Example running contaminated data:
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "contam" "694000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "decontam" "694000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

Testing the merging reads option. *Not needed to repeat this for other spp*

Executed [runSPADEShimem_Onlymrgd_cont_noisolate.sbatch](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runSPADEShimem_Onlymrgd_cont_noisolate.sbatch)
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_Onlymrgd_cont_noisolate.sbatch "e1garcia" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pire_ssl_data_processing/blob/main/spratelloides_gracilis"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_Onlymrgd_cont_noisolate.sbatch
```

Also testing the effect of `--cov-cutoff auto`. *Do this in other species if BUSCO values are too low with `--cov-cutoff off`*
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "contam_covAUTO" "694000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "decontam_covAUTO" "694000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

Using merged files and applying `--cov-cutoff auto` did not make a big difference, see table below (merged results not shown but available at /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis)

**Running the 3 libraries independently**

I modified the SPAdes script to provide the option of running libraries together or independently up to 3 libraries <library: all | 1 | 2 | 3> given that all ssl dataset (5 spp as in August) have 3 libraries sequenced. Everything before this point was using all the libraries together. Running independently now using only the contaminated data. After determining which is the best library for assembly, I will run the decontaminated files as well.
```sh
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <library: all | 1 | 2 | 3> <contam | decontam> <genome size in bp> <species dir>
# do not use trailing / in paths.
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "1" "contam" "694000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "2" "contam" "694000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "3" "contam" "694000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

This SPAdes scripts automatically runs `QUAST` but running `BUSCO` separately 

## Step 9. Assessing the best assembly

**Executed [runBUCSO.sh](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runBUSCO.sh) on the `contigs` and `scaffolds` files**
```sh
#runBUSCO.sh <species dir> <SPAdes dir> <contigs | scaffolds>
# do not use trailing / in paths. Example using contigs:
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_contam_R1R2_noIsolate_NOmrgd" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_contam_R1R2_noIsolate_NOmrgd" "scaffolds"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_contam_R1R2_noIsolate_covAUTO" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_contam_R1R2_noIsolate_covAUTO" "scaffolds"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_decontam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_decontam_R1R2_noIsolate" "scaffolds"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_decontam_R1R2_noIsolate_covAUTO" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_decontam_R1R2_noIsolate_covAUTO" "scaffolds"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_SgC0072B_contam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_SgC0072B_contam_R1R2_noIsolate" "scaffolds"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_SgC0072C_contam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_SgC0072C_contam_R1R2_noIsolate" "scaffolds"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_SgC0072D_contam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_SgC0072D_contam_R1R2_noIsolate" "scaffolds"
```

### Summary of QUAST (using Genome Scope v.1 694000000 estimate) and BUSCO Results

Species    |Library    |DataType    |SCAFIG    |covcutoff    |genome scope v.    |No. of contigs >0    |Largest contig    |Total lenght    |% Genome size completeness    |N50    |L50    |BUSCO single copy
------  |------  |------ |------ |------ |------  |------ |------ |------ |------ |------  |------ |------ 
Sgr  |allLibs  |contam       |contigs       |off       |1       |2253577  |309779       |489995603       |70.5%       |5515       |28571       |29.9%       
Sgr  |allLibs  |contam       |scaffolds       |off       |1       |2237565  |309779       |517068774       |74.5%       |5806       |28041       |29.9%
Sgr  |allLibs  |contam       |contigs       |auto       |1       |2220821  |309779       |489827781       |70.6%       |5800       |28040       |30%
Sgr  |allLibs  |contam       |scaffolds       |auto       |1       |2204948  |309779       |516942564       |74.5%       |5800       |28041       |32.2%
Sgr  |allLibs  |decontam       |contgs       |off       |1       |2316449  |197090       |411716418       |59.3%       |5443       |24590       |27.1%
Sgr  |allLibs  |decontam       |scaffolds       |off       |1       |2295872  |197090       |440572995       |63.5%       |5751       |24463       |29.5%
Sgr  |allLibs  |decontam       |contgs       |auto       |1       |2290268  |197090       |411810888       |59.4%       |5442       |24601       |27.1%
Sgr  |allLibs  |decontam       |scaffolds       |auto       |1       |2269777  |197090       |440612739       |63.5%       |5750       |24463       |29.5%
Sgr  |SgC0072B  |contam       |contgs       |off       |1       |3375654  |68606       |441333876       |63.6%       |5405       |26613       |29.2%
Sgr  |SgC0072B  |contam       |scaffolds       |off       |1       |3358197  |68606       |460942092       |66.4%       |5587       |26490       |31.3%
Sgr  |SgC0072C  |contam       |contgs       |off       |1       |502823  |105644       |531230550       |76.5%       |6597       |24512       |37.9%
Sgr  |SgC0072C  |contam       |scaffolds       |off       |1       |496944  |105644       |536090329       |77.2%       |6662      |24355       |38.4%
Sgr  |SgC0072D  |contam       |contgs       |off       |1       |3534280  |68563       |441118097       |63.6%       |5352      |26844       |29.7%
Sgr  |SgC0072D  |contam       |scaffolds       |off       |1       |3515909  |120121       |462780087       |66.7%       |5570      |26612       |31.5%
Sgr  |SgC0072C  |contam       |contgs       |auto       |1       |13018  |29230       |5972351       |1%       |7942	|242       |0.1%
Sgr  |SgC0072C  |contam       |scaffolds       |auto	  |1       |13125  |29230	 |5849289	  |1%       |7942	  |240       |0.1%
Sgr  |SgC0072C  |decontam       |contgs       |off       |1       |502823  |105644       |531230550       |76.5%       |6597	|24512       |32.2%
Sgr  |SgC0072C  |decontam       |scaffolds       |off	  |1       |496944  |105644	 |536090329	  |77.2%       |6662	  |24355       |33.2%


### Summary of QUAST (using Genome Scope v.2 854000000 estimate) and BUSCO Results

Species    |Library    |DataType    |SCAFIG    |covcutoff    |genome scope v.    |No. of contigs    |Largest contig    |Total lenght    |% Genome size completeness    |N50    |L50    |Ns per 100 kbp    |BUSCO single copy
------  |------  |------ |------ |------ |------  |------ |------ |------ |------ |------  |------ |------ |------ 
Sgr  |SgC0072B  |contam       |contgs       |off       |2       |82681  |68606       |441333876       |51.7%       |5405       |26613       |0   |29.2%
Sgr  |SgC0072B  |contam       |scaffolds       |off       |2       |84110  |68606       |460942092       |54%       |5587       |26490       |147.59   |31.3%
Sgr  |SgC0072C  |contam       |contgs       |off       |2       |85876  |105644       |531350946       |62.2%       |6617       |24450       |0   |37.9%
Sgr  |SgC0072C  |contam       |scaffolds       |off       |2       |85997  |105644       |536156621       |62.8%       |6686      |24304       |14.73   |38.4%
Sgr  |SgC0072D  |contam       |contgs       |off       |2       |83191  |68563       |441118097       |51.7%       |5352      |26844       |0   |29.7%
Sgr  |SgC0072D  |contam       |scaffolds       |off       |2       |84615  |120121       |462780087       |54.2%       |5570      |26612       |167.75   |31.5%
Sgr  |SgC0072C  |decontam       |contgs       |off       |2       |69371  |103720       |395865756       |46.6%       |5946	|21196       |0   |32.2%
Sgr  |SgC0072C  |decontam       |scaffolds       |off	  |2       |69932  |103720	 |406306057	  |47.6%       |6080	  |21004       |42.77   |33.2%



SgC0072C contam created the best assembly. BUSCO values are somewhat low so running `--cov-cutoff auto`
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "2" "contam_covAUTO" "694000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

Running `--cov-cutoff auto` did not create a good library at all (see the table above). Moving forward and running decontaminated files for SgC0072C and `--cov-cutoff off`

```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "2" "decontam" "694000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

#### Updating the main assembly stats table with your species

Added a new record for Sgr SgC0072C contam to the [best_ssl_assembly_per_sp.tsv](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/best_ssl_assembly_per_sp.tsv)
```sh
nano ../best_ssl_assembly_per_sp.tsv
```

## Step 10. Probe design - regions for probe development

From species directory. Made probe dir, renamed assembly and copied scripts
```sh
mkdir probe_design
cp ../scripts/WGprobe_annotation.sb probe_design
cp ../scripts/WGprobe_bedcreation.sb probe_design
cp SPAdes_SgC0072C_contam_R1R2_noIsolate/scaffolds.fasta probe_design
# list the busco dirs
ls -d busco_*
# identify the busco dir of best assembly, copy the treatments (starting with the library)
# Example,the busco dir for the best assembly for Sgr is `busco_scaffolds_results-SPAdes_SgC0072C_contam_R1R2_noIsolate`
# I then provide the species 3-letter code, scaffolds, and copy and paste the parameters from the busco dir after "SPAdes_" 
cd probe_design
mv scaffolds.fasta Sgr_scaffolds_SgC0072C_contam_R1R2_noIsolate.fasta
```

Execute the first script
```sh
#WGprobe_annotation.sb <assembly name> 
sbatch WGprobe_annotation.sb "Sgr_scaffolds_SgC0072C_contam_R1R2_noIsolate.fasta"
```

Execute the second script
```sh
#WGprobe_annotation.sb <assembly base name> 
sbatch WGprobe_bedcreation.sb "Sgr_scaffolds_SgC0072C_contam_R1R2_noIsolate"
```

The longest scaffold is 105644

The upper limit used in loop is 97500

A total of 13063 regions have been identified from 10259 scaffolds


Moved out files to logs
```sh
mv *out ../logs
```

## step 11. Fetching genomes for closest relatives

```sh
nano closest_relative_genomes_Spratelloides_gracilis.txt

1.- Clupea harengus
https://www.ncbi.nlm.nih.gov/genome/15477
2.- Sardina pilchardus
https://www.ncbi.nlm.nih.gov/genome/8239
3.- Tenualosa ilisha
https://www.ncbi.nlm.nih.gov/genome/12362
4.- Coilia nasus
https://www.ncbi.nlm.nih.gov/genome/2646
5.- Denticeps clupeoides
https://www.ncbi.nlm.nih.gov/genome/7889
```

following Betancur et al. 2017 and Lavoué_etal_2007 (see the Spratelloides delicatulus slack channel for papers) 

### MitoFinder

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/run_mitofinder_ssl.sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis Sgr SPAdes_SgC0072C_contam_R1R2_noIsolate Clupeidae
```
