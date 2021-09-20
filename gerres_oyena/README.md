TAMUCC-ODU
scp /work/hobi/GCL/20210829_PIRE-Goy-shotgun/* e1garcia@turing.hpc.odu.edu://RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/shotgun_raw_fq

All two sequence sets are for individual Goy-CPas_088_Ex1

RC-jwhal002

gerres_oyena directory created
cp /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/shotgun_raw_fq/*.fq.gz .

##Preprocessing##
#9/7/21#

#Multi_FASTQC.sh
Run from /home/jwhal002/shotgun_PIRE/pire_fq_gz_processing/
sbatch Multi_FASTQC.sh "fq.gz" "/home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/shotgun_raw_fq"

#runFASTP_1st_trim.sbatch
Run from /home/jwhal002/shotgun_PIRE/pire_fq_gz_processing/
sbatch runFASTP_1st_trim.sbatch /home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/shotgun_raw_fq /home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/fq_fp1
Need to mv /fq_fp1 to gerres_oyena

#9/8/21#
#runCLUMPIFY_r1r2_array.bash
Run from /home/jwhal/002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena
bash /home/jwhal002/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmparray /scratch/jwhal002 2

#9/9/21#
#checkClumpify_EG.R
crun R < /home/jwhal002/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R --no-save
"ClumpifySuccessfully worked on all samples"

#runFASTP_2_ssl.sbatch
Run from /gerres_oyena/
sbatch /home/jwhal002/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmparray fq_fp1_clmparray_fp2
report in /home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/logs

#runFQSCRN_6.bash
Run from /gerres_oyena/
bash /home/jwhal002/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 4
Error message in slurm-fqscrn.395231.0.out, and all other .out files
"ls: cannot access 'fq_fp1_clmparray_fp2/GyC0881D_CKDL210018111-1a-AK9143-AK7533_HH72GDSX2_L1_1.fq.gz': No such file or directory"
There are no *L1_1.fq.gz files in fq_fp1_clmparray_fp2/
Reran w/
bash /home/jwhal002/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash . fq_fp1_clmparray_fp2_fqscrn 4
2 .out files ended quickly, the others have been running for ~20 min
Only worked for 1 file

#9/13/21
reran from gerres_oyena/ using:
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 4
The bash script when run from my directory (jwhal002) references the sbatch script from e1garcia, so an issue was created when finding the input directory and the input files. 
The 4 output files are currently running.
Previous slurm-fqscrn.#####.#.out files were deleted.

5 files for each input *.fq.gz file for a total of 20 files.
grep 'error' slurm-fqscrn.*out
grep: No match
grep 'No reads in' slurm-fqscrn.*out
grep: No match
No files failed
mv *out logs

#Get the multiqc report
run from gerres_oyena/ using:
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runMULTIQC.sbatch "fq_fp1_clmparray_fp2_fqscrn" "fqsrn_report"
I can't find the "fqsrn_report". Is this the output file? It doesn't provide much info. 

#runREPAIR.sbatch
run from gerres_oyena/ using:
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmparray_fp2_fqscrn fq_fp1_clmparray_fp2_fqscrn_repaired 40

run from gerres_oyena/ using:
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/read_calculator_ssl.sh "/home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena"

Percent total read loss:
*D*L1_1.fq.gz 42.6037%
*D*L1_2.fq.gz 42.6037%
*E*L1_1.fq.gz 40.7463%
*E*L1_2.fq.gz 40.7463%

How much is too much data lost?


#9/14/21
###Assembly###

#genomesize.com
No Gerres oyena
Within the Genus Gerres, there are two species: Gerres subfasciatus & Gerres oblongus
Pretty sure G. subfasciatus is more closely related to G. oyena than G. oblongus (Iwatsuki et al 2006)

Gerres subfasciatus
https://www.genomesize.com/result_species.php?id=2820

C-value (pg): 0.61

Method: Feulgen Image Analysis Densitometry

Cell Type: Red blood cells

Standard Species: Betta splendens = 0.64pg, Gallus domesticus = 1.25pg, Oncorhynchus mykiss = 2.60pg, Rana pipiens = 6.70pg

References:
Hardie, D.C. and P.D.N. Hebert (2003). The nucleotypic effects of cellular DNA content in cartilaginous and ray-finned fishes. Genome 46: 683-706.

Hardie, D.C. and P.D.N. Hebert (2004). Genome-size evolution in fishes. Canadian Journal of Fisheries and Aquatic Sciences 61: 1636-1646.


Gerres oblongus
https://www.genomesize.com/result_species.php?id=2819

C-value (pg): 0.70

Chromosome Number (2n): 50

Method: Flow Cytometry

Cell Type: Red blood cells

Standard Species: Mus musculus = 3.30pg

References:
Ojima, Y. and K. Yamamoto (1990). Cellular DNA contents of fishes determined by flow cytometry. La Kromosomo II 57: 1871-1888.


#9/15/21


Genome stats for Sgr from Jellyfish/GenomeScope v1.0 k=21
stat	|min	|max	|average	
------	|------	|------	|------	
Heterozygosity	|0.869466%	|0.877487%	|0.873476%	
Genome Haploid Length	|532,667,711 bp	|533,247,245 bp	|532,957,478 bp	
Model Fit	|96.5314%	|97.1227%	|96.82705 %	

#runSPADEShimem_R1R2_noisolate.sbatch

```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jwhal002" "Goy" "1" "contam" "533000000" "/home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena"
```
Error because there were only 2 libraries and the .sbatch script assumes 3 libraries were used. This caused an error saying that one of the files was used twice, which caused the script to fail.
I editted the script in my directory and reran it using that script.

```sh
sbatch /home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jwhal002" "Goy" "1" "contam" "533000000" "/home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena"
```

Other slurm .out files were removed







Species |Library |DataType |SCAFIG |covcutoff |No. of contigs |Largest contig |Total lenght |% Genome size completeness |N50 |L50 |BUSCO single copy ------ 
|------ |------ |------ |------ |------ |------ |------ |------ |------ |------ |------
Goy |allLibs |contam |contigs |off |2253577 |309779 |489995603 |70.5% |5515 |28571 |29.9% Sgr |allLibs |contam |scaffolds |off |2237565 |309779 |517068774 
|74.5% |5806 |28041 |29.9%
Goy |allLibs |contam |contigs |auto |2220821 |309779 |489827781 |70.6% |5800 |28040 |30% Sgr |allLibs |contam |scaffolds |auto |2204948 |309779 |516942564 
|74.5% |5800 |28041 |32.2%
Goy |Gy...D |decontam |contgs |off |2316449 |197090 |411716418 |59.3% |5443 |24590 |27.1% Sgr |allLibs |decontam |scaffolds |off |2295872 |197090 |440572995 
|63.5% |5751 |24463 |29.5%
Goy |Gy...E |decontam |contgs |auto |2290268 |197090 |411810888 |59.4% |5442 |24601 |27.1% Sgr |allLibs |decontam |scaffolds |auto |2269777 |197090 |440612739 
|63.5% |5750 |24463 |29.5%
