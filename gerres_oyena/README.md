# Gerres oyena - Shotgun Data Processing Log - SSL Data

---

### Transfer data from TAMUCC to ODU
```sh
scp /work/hobi/GCL/20210829_PIRE-Goy-shotgun/* e1garcia@turing.hpc.odu.edu://RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/shotgun_raw_fq
```
All two sequence sets are for individual Goy-CPas_088_Ex1

```sh
cp /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/shotgun_raw_fq/*.fq.gz .
```

## PREPROCESSING

## Step 1. Fastqc
Run from /home/jwhal002/shotgun_PIRE/pire_fq_gz_processing/
```sh
sbatch Multi_FASTQC.sh "fq.gz" "/home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/shotgun_raw_fq"
```

Potential issues:
* % duplication: 
 * 27.3% - 30.4%
* gc content: 
 * 49% - 53%
* quality: good
 * sequence quality and per sequence qual both good
* % adapter: slightly elevated
 * 5.23% - 7.3% 
* number of reads: 
 *105.7M - 129.5M

## Step 2. 1st fastp

Run runFASTP_1st_trim.sbatch to generate this report
```sh
sbatch runFASTP_1st_trim.sbatch /home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/shotgun_raw_fq /home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/fq_fp1
```
Need to mv /fq_fp1 to gerres_oyena

Potential issues:
* % duplication:
  * 10.9% - 12.2%
* gc content:
  * 43.1% - 43.2%
* passing filter:
  * 81.5% - 82.1%
* % adapter:
  * 15.0% - 17.5%
* number of reads:
  * 173M - 211M (per pair of r1-r2 files)

## Step 3. Clumpify

Ran runCLUMPIFY_r1r2_array.bash in a 2 node array on Wahab.
bash /home/jwhal002/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmparray /scratch/jwhal002 2

Checked the output with checkClumpify_EG.R

```sh
enable_lmod
module load container_env mapdamage2
crun R < /home/jwhal002/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R --no-save
"ClumpifySuccessfully worked on all samples"
```

## Step 4. fastp2

Ran runFASTP_2_ssl.sbatch to generate this [report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/gerres_oyena/fq_fp1_clmparray_fp2/2nd_fastp_report.html)
```sh
sbatch /home/jwhal002/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmparray fq_fp1_clmparray_fp2
```
report in /home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/logs

Potential issues:

* % duplication: low
  * 2.7% - 2.9%
* gc content: reasonable
  * 42.9% - 43.1%
* passing filter: good
  * 82.8% - 85.4%
* % adapter: virtually none
  * 0.3% - 0.4%
* number of reads:
  * 132M - 157M (per pair of r1-r2 files)

## Step 5. fastq_screen
Ran from runFQSCRN_6.bash/gerres_oyena/ to generate this [report]()
```sh
bash /home/jwhal002/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 4
```
Error message in slurm-fqscrn.395231.0.out, and all other .out files
```sh
ls: cannot access 'fq_fp1_clmparray_fp2/GyC0881D_CKDL210018111-1a-AK9143-AK7533_HH72GDSX2_L1_1.fq.gz': No such file or directory
```
There are no *L1_1.fq.gz files in fq_fp1_clmparray_fp2/

Reran w/
```sh
bash /home/jwhal002/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash . fq_fp1_clmparray_fp2_fqscrn 4
```
Only worked for 1 file

Reran w/
```sh
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 4
```
The bash script when run from my directory (jwhal002) references the sbatch script from e1garcia, so an issue was created when finding the input directory and the input files. 
The 4 output files are currently running.
Previous slurm-fqscrn.#####.#.out files were deleted.

5 files for each input *.fq.gz file for a total of 20 files.
```sh
grep 'error' slurm-fqscrn.*out
grep: No match
grep 'No reads in' slurm-fqscrn.*out
grep: No match
No files failed
mv *out logs
```

Ran runMULTIQC.sbatch
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runMULTIQC.sbatch "fq_fp1_clmparray_fp2_fqscrn" "fqsrn_report"
```
I can't find the "fqsrn_report". Is this the output file? It doesn't provide much info. 

Highlights from [report]():

## Step 6. Repair fastq_screen paired end files
Ran runREPAIR.sbatch
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmparray_fp2_fqscrn fq_fp1_clmparray_fp2_fqscrn_repaired 40
```
run from gerres_oyena/ using:
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/read_calculator_ssl.sh "/home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena"
```

Percent total read loss:

GyC0881D*L1_1.fq.gz: 42.6037%
GyC0881D*L1_2.fq.gz: 42.6037%
GyC0881E*L1_1.fq.gz: 40.7463%
GyC0881E*L1_2.fq.gz: 40.7463%

How much is too much data lost?

---

## ASSEMBLY

## Step 7. Genome properties
I couldn't find Goy in www.genomesize.com
I did find two species within the Genus *Gerres*: *Gerres subfasciatus* & *Gerres oblongus*
Pretty sure *G. subfasciatus* is more closely related to *G. oyena* than *G. oblongus* (Iwatsuki et al 2006)

__*Gerres subfasciatus*__

https://www.genomesize.com/result_species.php?id=2820

C-value (pg): 0.61

Method: Feulgen Image Analysis Densitometry

Cell Type: Red blood cells

Standard Species: Betta splendens = 0.64pg, Gallus domesticus = 1.25pg, Oncorhynchus mykiss = 2.60pg, Rana pipiens = 6.70pg

References:

Hardie, D.C. and P.D.N. Hebert (2003). The nucleotypic effects of cellular DNA content in cartilaginous and ray-finned fishes. Genome 46: 683-706.

Hardie, D.C. and P.D.N. Hebert (2004). Genome-size evolution in fishes. Canadian Journal of Fisheries and Aquatic Sciences 61: 1636-1646.

__*Gerres oblongus*__

https://www.genomesize.com/result_species.php?id=2819

C-value (pg): 0.70

Chromosome Number (2n): 50

Method: Flow Cytometry

Cell Type: Red blood cells

Standard Species: Mus musculus = 3.30pg

References:

Ojima, Y. and K. Yamamoto (1990). Cellular DNA contents of fishes determined by flow cytometry. La Kromosomo II 57: 1871-1888.

Genome stats for Goy from Jellyfish/GenomeScope v1.0 k=21
stat	|min	|max	|average	
------	|------	|------	|------	
Heterozygosity	|0.869466%	|0.877487%	|0.873476%	
Genome Haploid Length	|532,667,711 bp	|533,247,245 bp	|532,957,478 bp	
Model Fit	|96.5314%	|97.1227%	|96.82705 %	

## Step 8. Assemble the genome using SPAdes
Ran runSPADEShimem_R1R2_noisolate.sbatch
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jwhal002" "Goy" "1" "contam" "533000000" "/home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena"
```
Error because there were only 2 libraries and the .sbatch script assumes 3 libraries were used. This caused an error saying that one of the files was used twice, which caused the script to fail.

I editted the script in my directory and reran it using that script.
```sh
sbatch /home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jwhal002" "Goy" "1" "contam" "533000000" "/home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena"
```

Other slurm .out files were removed

Assemblies made for GyC0881D (#"1"), GyC00881E (#"2"), allLibs w/ covcutoff = off

Assemblies made for GyC0881D w/ covcutoff = auto

### Summary of QUAST and BUSCO Results
Species |Library |DataType |SCAFIG |covcutoff |No. of contigs |Largest contig |Total length |% Genome size completeness |N50 |L50 |BUSCO single copy
------ |------ |------ |------ |------ |------ |------ |------ |------ |------ |------ |------
Goy |allLibs |contam |contigs |off |56139 |99979 |428433255 |80.4% |8873 |14304 | 48.8%
Goy |allLibs |contam |scaffolds |off |25822 |364333 |504055061 |94.6% |33151 |4188 | 74.9%
Goy |GyC0881D |contam |contigs |off |55401 |111112 |456566152 |85.7% |9976 |13705 | 54.6%
Goy |GyC0881D |contam |scaffolds |off |25665 |383347 |518735835 |97.3% |33953 |4182 | 79.1%
Goy |GyC0881E |contam |contigs |off |52039 |118096 |484528224 |90.9% |11778 |12108 | 58.2%
Goy |GyC0881E |contam |scaffolds |off |24249 |397418 |531155459 |99.7% |37754 |3908 | 80.2%
Goy |GyC0881D |contam |contigs |auto |55459 |111115 |456736917 |85.7% |9969 |13728 | 54.5%
Goy |GyC0881D |contam |scaffolds |auto |25707 |383347 |518852621 |97.4% |33957 |4183 | 79.1%
Goy |GyC0881E |decontam |contigs |off |52425 |113391 |488426273 |91.6% |11751 |12369 | 60.4%
Goy |GyC0881E |decontam |scaffolds |off |30872 |259628 |528159939 |99.1% |26350 |5731 | 78.7%


## Step 9. Assessing the best assembly
Ran runBUSCO.sh on the contigs and scaffolds files
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena" "SPAdes_GyC0881D_contam_R1R2_noIsolate" "contigs"
```
BUSCO done

GoyC0881E(Library #"2") contam scaffolds determined to be the best assembly

Will use the data that produced this assembly for creating a decontaminated assembly

```sh
sbatch /home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jwhal002" "Goy" "2" "decontam" "533000000" "/home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena"
```

BUSCO for decontam file:
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena" "SPAdes_GyC0881E_decontam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena" "SPAdes_GyC0881E_decontam_R1R2_noIsolate" "scaffolds"
```

## Step 10. Probe Design - regions for probe development
From species directory: made probe_design directory, renamed assembly, and copied scripts
```sh
mkdir probe_design
cp SPAdes_GyC0881E_contam_R1R2_noIsolate/scaffolds.fasta probe_design/
mv scaffolds.fasta Goy_scaffolds_GyC0881E_contam_R1R2_noIsolate.fasta
```
Execute the first script
```sh
sbatch WGprobe_annotation.sb "Goy_scaffolds_GyC0881E_contam_R1R2_noIsolate.fasta"
```
Execute the second script
```sh
sbatch WGprobe_bedcreation.sb "Goy_scaffolds_GyC0881E_contam_R1R2_noIsolate"
```

The longest scaffold is 397418

The uppper limit used in loop is 387500

A total of 43671 regions have been identified from 14263 scaffolds

## Step 11. Fetching genomes for closest relatives
Betancur 2017

Series: Eupercaria

Order: Gerreiformes (Incertae sedis in Eupercaria)

No Gerreiformes, Haemulidae, Uranoscopiformes

Used the phylogeny of CAS & others to determine closest relatives

Lutjanidae: 1

Sparidae: 4

1. Lutjanus erythropterus
https://www.ncbi.nlm.nih.gov/genome/?term=lutnajus+erythropterus
2. Diplodus sargus
https://www.ncbi.nlm.nih.gov/genome/92100
3. Spondyliosoma cantharus
https://www.ncbi.nlm.nih.gov/genome/69439
4. Sparus aurata
https://www.ncbi.nlm.nih.gov/genome/11609
5. Acanthopagrus latus
https://www.ncbi.nlm.nih.gov/genome/8551

