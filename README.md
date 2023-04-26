# SHOTGUN DATA PROCESSING & ANALYSIS

This repo contains instructions to process data from  Shotgun Sequencing Libraries - SSL. 

---

A list of ongoing SSL projects can be found below. 

If you are working on an SSL analysis project (or if you wish to claim a project), please indicate so in the table. When data are available, priority should go to species that are higher on the CSSL priority list which will need probes in the near future.

|Species | Data availability | CSSL priority | Analysis lead | Analysis status / notes |
| --- | --- | --- | --- | --- |
|Lethrinus_variegatus | On ODU HPC | 19 | Jordan/Chris/Brendan | probe dev complete |
|Periophthalmus_argentilineatus | On ODU HPC | 17 | Keenan/Chris/Brendan | probe dev complete |
|Pomacentrus_pavo | On ODU HPC | 23 | Brendan | Assembly complete, John assigned to probe dev |
|Sphaeramia_nematoptera | On ODU HPC | 18 | Jem | Probe dev't complete |
|Pomacentrus_brachialis | On ODU HPC | 24 | Jem/Kyra | Probe dev't complete |
|Corythoichthys_haematopterus | On ODU HPC | 25 | Allison/John | Probe dev't complete - also have a Genbank genome |
|Stethojulis_interrupta | On ODU HPC | 26 |Abby/John | Probe dev't complete  |
|Ostorhinchus_chrysopomus | On ODU HPC | 28 | Eryka/Eric | Probe dev't complete  |
|Hypoatherina_temminckii | On ODU HPC | 16 | Eric | Probe development complete |
|Ambassis_buruensis | On ODU HPC | 22 | John | Probe dev't complete |
|Sphyraena obtusata | On ODU HPC | 20 | Brendan| Probe dev't complete |
|Sphaeramia_orbicularis | Needs extraction | 39 | Eric | Probe development planned using published reference |
|Dascyllus aruanus | On ODU HPC | 30 | Jem | Genome Assembly - Assembling contam best lib|
|Parupeneus barberinus | On ODU HPC | not on list | Jem | Genome Assembly - Assembling contam best lib|
|Pseudanthias squamipinnis | On ODU HPC | 37 | Jem | Genome Assembly - Assembling contam best lib|
|Tylosurus_crocodilus | On ODU HPC | not on list | Brendan | Data on HPC |
|Gerres macracanthus | On ODU HPC | 36 | ?? | Data on HPC |
|Lutjanus fulviflamma | Needs extraction | ?? | ?? | For UP Mindanao |
|Encrasicholina_pseudoheteroloba | On ODU HPC | n/a | n/a | Sequencing data weird - dropping from priority list  |
|Spratelloides delicatulus | On ODU HPC | ?? | Eric | Originally a RAD species | 

---

## Getting Started

<details><summary>Before You Start, Read This</summary>
<p>

## Before You Start, Read This
The purpose of this repo is to document the processing and analysis of `Shotgun Sequencing Libraries - SSL data` for probe development which then will be processed according to the [Capture Shotgun Sequencing Libraries- CSSL repo](https://github.com/philippinespire/pire_cssl_data_processing) or the [Low Coverage Whole Genome Sequencing - lcWGS repo](https://github.com/philippinespire/pire_lcwgs_data_processing).

SSL, CSSL and lcWGS pipelines use scripts from the [Pre-Processing PIRE Data](https://github.com/philippinespire/pire_fq_gz_processing) repo at the beginning of files processing. 

Each species will get it's own directory within this repo.  Try to avoing putting dirs inside dirs inside dirs. 

The Sgr dir will serve as the example to follow in terms of both directory structure and documentation of progress in `README.md`.

If this is your first time working on wahab/turing or want to check out some tips see the [Working on ODU's HPC repo](https://github.com/philippinespire/denovo_genome_assembly/tree/main/working_in_Turing-Wahab)

Contact Dr. Eric Garcia for questions or if you are having issues running scripts (e1garcia@odu.edu)

---

</p>
</details>


<details><summary>Clonning and Maintaining Repo with Git</summary>
<p>

	
## Use Git/GitHub to Track Progress and Clone the SSL repo

To process a species, begin by cloning this repo to your working dir. I recommend setting up a `shotgun_PIRE` sub-dir in your home dir if you have not done something similar already

Example: `/home/youruserID/shotgun_PIRE/`

Clone this repo
```
cd ~ 	# this will take you to your home dir
cd shotgun_PIRE
git clone https://github.com/philippinespire/pire_ssl_data_processing.git
```

The data will be processed and analyzed in the repo.  There is a `.gitignore` file that lists files and directories to be ignored by git.  It includes large files that git cannot handle (fq.gz, bam, etc) and other repos that might be downloaded into this repo. 
For example, the BUSCO outdir contains several large files that will cause problems for git so `busco_*/` occurs in  `.gitignore` so that it is not uploaded to github in this repo.

Because large data files will not be saved to github, they will reside in an individual's copy of the repo or somewhere on the HPC. You should provide paths (absolute/full paths are probably best) or info that make it clear where the files reside. Most of these large intermediate files should be deleted once it is confirmed that they worked. For example, we don't ultimately need the intermedate files produced by fastp, clumpify, fastq_screen. This can also be accomplished in the cleanning step at the end of this repo.

---

## Maintaining Git Repo

You must pull down the latest version of the repo everytime you sit down to work and push the changes you made everytime you walk away from the terminal.  The following order of operations when you sync the repo will minimize problems.

From your species directory, execute these commands manually or run the `runGit.sh` script (see bellow) 
```
git pull
git add --all
git commit -m "$1"
git push -u origin main
```

This code has been compiled into the script `runGIT.bash` thus you can just run this script BEFORE and AFTER you do anything in your species repo.
You will need to provide the message of your commit in the command line. Example:
```sh
bash ../runGIT.bash "initiated Sgr repo"
```
You will need to enter your git credentials multiple times each time you run this script

If you should be met with a conflict screen, you are in the archane `vim` editor.  You can look up instructions on how to interface with it. I typically do the following:

* hit escape key twice
* type the following
  `:quit!`
 
If you had to delete files for whatever reason, 
these deletions occurred in your local directory but these files will remain in the git memory if they had already enter the system.

If you are in this situation, run these git commands manually, AFTER running the runGIT.bash as describe above.

`add -u` will stage your deleled files, then you can commit and push

Run this from the directory where you deleted files:
```sh
git add -u .
git commit -m "update deletions"
git push -u origin main
```

</p>
</details>

___

## Data Processing Roadmap

<details><summary>A. PRE-PRECESSING SEQUENCES</summary>
<p>	
	
### PRE-PRECESSING SEQUENCES

---

#### 1. Set up directories and data

**Directories**

Create your `species dir` and and subdirs `logs` and `shotgun_raw_fq`

```sh
cd pire_ssl_data_processing
mkdir spratelloides_gracilis 
mkdir spratelloides_gracilis/logs
mkdir spratelloides_gracilis/shotgun_raw_fq
```

**Data**

Transfer your raw data into `shotgun_raw_fq`. Your data might be avaliable in the RC, in which case c
*(can take several hours)*
```sh
cp <source of files> spratelloides_gracilis/shotgun_raw_fq  # scp | cp | mv


Check your raw files: given that we use paired-end sequencing, you should have one pair of files (1 forward and 1 reverse) per library. This  means that you should have the same number of foward (1.fq.gz or f.fq.gz) and reverse sequence files (2.fq.gz or r.fq.gz).
 If you don't have equal numbers for foward and reverse files, check with whoever provided the data to make sure there was no issues while transferring.

You will likely get 2 or 3 libraries (4 or 6 files total). Sgr example:
```sh
ls -l /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/fq

-rwxrwx--- 1 e1garcia carpenter         248 Jul 27 12:37 README
-rwxrwx--- 1 e1garcia carpenter 15652747635 Jul 22 17:19 SgC0072B_CKDL210013395-1a-5UDI294-AK7096_HF33GDSX2_L4_1.fq.gz
-rwxrwx--- 1 e1garcia carpenter 16902243089 Jul 22 17:27 SgC0072B_CKDL210013395-1a-5UDI294-AK7096_HF33GDSX2_L4_2.fq.gz
-rwxrwx--- 1 e1garcia carpenter 13765701672 Jul 22 17:32 SgC0072C_CKDL210013395-1a-AK9146-7UDI286_HF33GDSX2_L4_1.fq.gz
-rwxrwx--- 1 e1garcia carpenter 14786676970 Jul 22 17:39 SgC0072C_CKDL210013395-1a-AK9146-7UDI286_HF33GDSX2_L4_2.fq.gz
-rwxrwx--- 1 e1garcia carpenter 16465437932 Jul 22 17:46 SgC0072D_CKDL210013395-1a-AK5577-AK7533_HF33GDSX2_L4_1.fq.gz
-rwxrwx--- 1 e1garcia carpenter 17698149145 Jul 22 17:54 SgC0072D_CKDL210013395-1a-AK5577-AK7533_HF33GDSX2_L4_2.fq.gz
```

Make a copy of your raw files in the longterm carpenter RC dir **ONLY** if one doesn't exits already (if you copied your data from the RC, a long-term copy already exists)
```sh
cd /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/
mkdir <species_name>
mkdir <species_name>/fq
cp <source of files> /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/<species_name>/fq
```
*The RC drive is only available from the login node (you won't find it after getting a working node, i.e. `salloc`)*


Now create a `README` in the `fq` dir with the full path to the original copies of the raw files and necessary decoding info to find out from which individual(s) these sequence files came from.


This information is usually provied by Sharon Magnuson in species [slack](https://app.slack.com/client/TMJJ06SH0/CMPKY5C81/thread/CQ9GAAYGY-1627263374.002300) channel

```sh
cd spratelloides_gracilis/fq
nano README.md
```

Example:
```sh
RC to e1garcia
scp <source of files> /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/fq

All 3 library sets are from the same individual: Sgr-CMvi_007_Ex1
```

*I like to update my git repo regularly, especially before and after lengthly steps. This keeps a nice record of the commits and prevents loss of data/effor. Feel free to repeat this at any step*

```sh
bash ../../runGIT.bash "README of raw data"
```

***You are ready to start processing files***

---


#### 2. Initial processing

Complete the pre-processing of your files following the [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) repo, then return here
* This includes running FASTQC, FASTP1, CLUMPIFY, FASTP2, FASTQ SCREEN, and file repair scripts from the pre-processing repo
	
</p>
</details>

___

<details><summary>B. GENOME ASSEMBLY</summary>
<p>
	
### GENOME ASSEMBLY

---

#### 1. **Genome Properties**
In this step, we look for genome size in related literature as a reference, but ultimately use Jellyfish and Genomescope to estimate genome size from our SSL data. We will use Jellyfish and GenomeScope results even if there is an available estimate as these 2 provide a more precise estimates than older methods and provide an estimate of heterozygosity.  Jellyfish estimates are also used for consistencey across species assembled in the PIRE Project and to get around potential cases where published individuals or even PIRE species may have been morphologically mis-identified.

##### 1a. Fetch the genome properties for your species from existing literature
* From the literature or other sources
	* [genomesize.com](https://www.genomesize.com/)
	* search the literature
* After searching, estimate properties with `jellyfish` and `genomescope`
	* More details [here](https://github.com/philippinespire/denovo_genome_assembly/blob/main/jellyfish/JellyfishGenomescope_procedure.md)

##### 1b. **Execute [runJellyfish.sbatch](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runJellyfish.sbatch) using decontaminated files**
```sh
#sbatch runJellyfish.sbatch <Species 3-letter ID> <indir>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Sgr" "fq_fp1_clmp_fp2_fqscrn_rprd"
```

Jellyfish will create a histogram file (.hito) with kmer frequencies. 

##### 1c. ** Download this file into your local computer and upload it in [GenomeScope v1.0](http://qb.cshl.edu/genomescope/) and [Genomescope v2.0](http://qb.cshl.edu/genomescope/genomescope2.0/)**
* Add a proper description to both of your runs. Example "Sgr_fq_fp1_clmp_fp2_fqscrn_rprd_jfsh"
* For version 1, Adjust the read lenght to that of in the Fastp2 trimming, 140 (unless you had to modify this in Fastp2)
* Leave all other parameters with default settings for both versions. 
* Submit (takes only few minutes)
 
##### 1d. **Complete the following table in your Species README. You can copy and paste this table straight into your README (no need to enclose it with quotes, i.e. a code block) and just substitute values.**
```sh
Genome stats for Sgr from Jellyfish/GenomeScope v1.0 and v2.0, k=21 for both versions

version    |stat    |min    |max
------  |------ |------ |------
1  |Heterozygosity  |1.32565%       |1.34149%
2  |Heterozygosity  |1.32975%       |1.35795%
1  |Genome Haploid Length   |693,553,516 bp |695,211,827 bp
2  |Genome Haploid Length   |851,426,393 bp |853,706,410 bp
1  |Model Fit       |97.6162%       |98.7154%
2  |Model Fit       |65.11692%       |96.0314%
```
Provide a link to both reports in your README. See other species READMEs for examples.

##### 1e. **Inspect your table and reports for red flags and choose a genome scope version.**
* In your table, check the heterozygosity (values around 1% are common) and check for good model fit (>90%) in the max values (sometimes the min value might have a low fit but th$
* In your reports, check for a tight relationship between the "observed", "full model" and "unique sequences" lines in the first graph.

If values in your table are relative similar for v1 and v2 and you found no red flags in reports, then use v2 estimates.

** Please use the "Genome Haploid Length" max value rounded up or down to the nearest million.** In the above example, this number is 853706410 for v2. Thus, 854000000 will be used in following steps

Most of the time v1-2 perform very similar. However, sometimes the two reports give contrasting values such as very different genome sizes or unrealistic estimates of heterozygosity. For example:
* In Sob, the [Sob_GenScp_v1](http://qb.cshl.edu/genomescope/analysis.php?code=zQRfOkSqbDYAGYJrs7Ee) report estimates a genome of 532 Mbp and 0.965 for H. On the other hand,  [Sob_GenScp_v2](http://qb.cshl.edu/genomescope/genomescope2.0/analysis.php?code=5vZKBtdSgiAyFvzIusxT) reports a genome size of 259 Mbp (which is small for a fish) and it actually fails to estimate heterozygosity. Thus, version 1 was used for Sob. 
* In Hte, the [Hte_GenScp_v1](http://qb.cshl.edu/genomescope/analysis.php?code=tHzBW2RjBK00gQMUSfl4) appears to have no red flags with a genome size of 846 Mbp and 0.49 for H but inspecting the first graph, you can see that the "uniqu sequence" line behaves diffently from the others. In contrast, [Hte_GenScp_v2](http://qb.cshl.edu/genomescope/genomescope2.0/analysis.php?code=8eVzhAQ8zSenObScLMGC) restores a tight relationship between lines with no red flags in estimates either (H=2.1, GenSize= 457 Mbp)

Note the source and genome size (if you found one already availble) or the Genome Scope version and rounded genome size estimate (if you had to run jellyfish) in your species README. You will use this info later

---

#### 2. Assemble the Genomes with SPAdes

Congrats! You are now ready to assemble the genome of your species!

After de novo assembler comparisons, we decided to move forward using SPADES (isolate and covcutoff flags off). 
For the most part, we obtained better assemblies using single libraries (a library consists of one forward *r1.fq.gz and reverse file *r2.fq.gz) but in few instances using all the libraries was better.
In addition, we also noted that assembling contaminated data (i.e. files in the `fq_fp1_clmp_fp2` dir)  produced better results for mtDNA (mt = mitochondrial) and decontaminated (i.e. files in the `fq_fp1_clmp_fp2_fqscrn_repaired` dir) was better for nDNA (n=nuclear). 

Thus, use the contaminated files to run one assembly for each of your libraries independently and then one combining all.
2a. **You need to be in `turing.hpc.odu.edu` for this step.** SPAdes requires high memory nodes (only avail in Turing)

```bash
#from wahab.hpc.odu.edu
exit
ssh username@turing.hpc.odu.edu
```

2b. **Get the genome size of your species, or Jellyfish estimate, in bp from the previous step**
 

We produced 3 libraries (from the same individual) for the last 5 spp with ssl data resulting in 3 sets of files. Sgr example:
```bash
ls /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/fq

SgC0072B_CKDL210013395-1a-5UDI294-AK7096_HF33GDSX2_L4_1.fq.gz
SgC0072B_CKDL210013395-1a-5UDI294-AK7096_HF33GDSX2_L4_2.fq.gz
SgC0072C_CKDL210013395-1a-AK9146-7UDI286_HF33GDSX2_L4_1.fq.gz
SgC0072C_CKDL210013395-1a-AK9146-7UDI286_HF33GDSX2_L4_2.fq.gz
SgC0072D_CKDL210013395-1a-AK5577-AK7533_HF33GDSX2_L4_1.fq.gz
SgC0072D_CKDL210013395-1a-AK5577-AK7533_HF33GDSX2_L4_2.fq.gz
```
Yet, every now and then one library can fail and you might end up with only 2 sets of files. 
Thus, the following SPAdes script is optimized to run the first 3 libraries independently and 2 or 3 libraries together for your "all" assembly.
. 
Note: If your species has 4 or more libraries, you will need to modify the script to run the 4th,5th,.. library and so on (you'll only need to add the necessary libraries to the SPAdes command)
No changes necessary for running the first, second, thrid, or all the libraries together (if you have 2 or 3 libraries only).  

**Use the decontaminated files to run one assembly for each of your libraries independently and then one combining all**

**Execute [runSPADEShimem_R1R2_noisolate.sbatch](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runSPADEShimem_R1R2_noisolate.sbatch). Example using the 1st library***

```bash
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <library: all_2libs | all_3libs | 1 | 2 | 3> <contam | decontam> <genome size in bp> <species dir> <fq data dir>
# do not use trailing / in paths. Example running contaminated data:
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "1" "decontam" "854000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "fq_fp1_clmp_fp2_fqscrn_rprd"
```

Run 2 more assemblies with the contaminated data for the second and  third library by rreplacing the "1", with "2" and  "3". 
Then, check the number of libraries you have and run a job combining all libraries together by choosing the appropiate "all_2libs" or "all_3libs" from the library options.

---

#### SPAdes **continue** option

Did your assembly failed after it was running correctly? Sometimes the assembly process will quit after sometime of running most likely due to lack of memory. One of the most useful options of SPAdes is the `continue` flag which basically recognizes where your assembly left off and restarts the process in the same spot again saving you hours or days of work. This will only help you if SPAdes was already running successfully. So if your assembly failed withing minutes, there is probably a probblem with the run and `continue` will just fail too. Check the out files first. If it failed after severl hours or days, continue might be your best friend here. 

I have already built in the continue option within the [runSPADEShimem_R1R2_noisolate.sbatch](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runSPADEShimem_R1R2_noisolate.sbatch) script. To run, first move inside the directory of the assembly that failed and then execute the same command but changing the specified library for "continue".

In the above example, I would have changed the "1" for "continue":
```
cd SPAdes_assembly_that_failed

#Execute
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "continue" "decontam" "854000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "fq_fp1_clmp_fp2_fqscrn_rprd"
```

Check that `continue` is working by watching that your jobs is running and checking that SPAdes is writing more output into your out file.

---

#### 3. Review Info on Assembly Quality from Quast Output

`QUAST` was automatically ran by the SPAdes script. Look for the `quast_results` dir and for each of your assemblies note the: 
1. Number of contigs in assembly (this is the last contig column in quast report with the name "# contigs")
2. the size of the largest contig
3. total length of assembly
4. N50
5. L50 

*Tip: you can align the columns of any .tsv for easy viewing with the comand `column` in bash. Example:
```sh
bash
cat quast-reports/quast-report_scaffolds_Sgr_spades_contam_R1R2_21-99_isolate-off.tsv | column -ts $'\t' | less -S
```

Enter your stats in the table below

---

#### 4. Run BUSCO

Those are basic assembly statistics but we still need to run BUSCO to know how many expected (i.e. highly conserved) genes were recovered by the assembly. 

**Execute [runBUCSO.sh](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runBUSCO.sh) on the `contigs` and `scaffolds` files for each assembly**

```bash
#runBUSCO.sh <species dir> <SPAdes dir> <contigs | scaffolds>
# do not use trailing / in paths. Example using contigs:
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_decontam_R1R2_noIsolate" "contigs"
```

Repeat the comand using scaffolds.

`runBUSCO.sh` will generate a new dir per run. Look for the `short_summary.txt` file and note the percentage of `Complete and single-copy BUSCOs (S)` genes

---

#### 5. Fill in this table with your QUAST and BUSCO values in your species README. 

Few notes:

* Library name can be obtained from file names
* covcutoff is "off" as a default in this pipeline. This is "on" only if you ran an extra assembly with ""contam_covAUTO" trying to improve busco values
* No. of contigs is the last contig column in quast report with the name "# contigs"
* % Genome size completeness = "Total lenght"/genome size(or rounded genome max value) *100
* **For QUAST, only report the row for the actual assembly (i.e. report "scaffolds" not "scaffolds_broken"**
* **For BUSCO, only report the "Complete and single-copy BUSCOs (S)"

```sh
Species    |Library    |DataType    |SCAFIG    |covcutoff    |genome scope v.    |No. of contigs    |Largest contig    |Total lenght    |% Genome size completeness    |N50    |L50    |Ns per 100 kbp    |BUSCO single copy
------  |------  |------ |------ |------ |------  |------ |------ |------ |------ |------  |------ |------ |------ 
Sgr  |allLibs  |contam       |contigs       |off       |1       |2253577  |309779       |489995603       |70.5%       |5515       |28571       |0       |29.9%
Sgr  |allLibs  |contam       |scaffolds       |off       |1       |2237565  |309779       |517068774       |74.5%       |5806       |28041       |147.59       |29.9%
Sgr  |SgC0072B  |contam       |contgs       |off       |2       |82681  |68606       |441333876       |51.7%       |5405       |26613       |0   |29.2%
Sgr  |SgC0072B  |contam       |scaffolds       |off       |2       |84110  |68606       |460942092       |54%       |5587       |26490       |147.59   |31.3%
Sgr  |SgC0072C  |contam       |contgs       |off       |2       |85876  |105644       |531350946       |62.2%       |6617       |24450       |0   |37.9%
Sgr  |SgC0072C  |contam       |scaffolds       |off       |2       |85997  |105644       |536156621       |62.8%       |6686      |24304       |14.73   |38.4%
Sgr  |SgC0072D  |contam       |contgs       |off       |2       |83191  |68563       |441118097       |51.7%       |5352      |26844       |0   |29.7%
Sgr  |SgC0072D  |contam       |scaffolds       |off       |2       |84615  |120121       |462780087       |54.2%       |5570      |26612       |167.75   |31.5%
Sgr  |SgC0072C  |decontam       |contgs       |off       |2       |69371  |103720       |395865756       |46.6%       |5946     |21196       |0   |32.2%
Sgr  |SgC0072C  |decontam       |scaffolds       |off     |2       |69932  |103720       |406306057       |47.6%       |6080      |21004       |42.77   |33.2%
```

---

#### 6. **Determine the best assembly**

We assess quality across multiple metrics since we don't use a golden rule/metric for determing the best assembly. 
Often, it is clear that single libray is relatively better than the others as it would have better results across metrics. Yet, sometimes this is not soo clear as different assemblies might be better in different metrics. Use the following table to help you decide:

Importance    |Metric    |Direction    |Description
------  |------  |------ |------ 
1st  |BUSCO  | Bigger is better  | % of expected genes observed in your assembly
2nd  |N50  |Bigger is better  | Lenght of the smaller contig from the set of contigs needed to reach half of your assembly
3rd  |Genome size completeness  |Bigger is better  |Lenght of assembly divided by estimated genome lenght
4th  |L50  | Smaller is better  | Number of contigs needed to reach half of your assembly
5th  |Largest contig  |Bigger is better  | Lenght of largest contig
 
If you are still undecided on which is the best assembly, post the best candidates on the species slack channel and ask for opinions

---

#### 7. Assemble contaminated data for best library 

```bash
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <library: all_2libs | all_3libs | 1 | 2 | 3> <contam | decontam> <genome size in bp> <species dir>
# do not use trailing / in paths. Example running contaminated data:
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "1" "contam" "854000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

---

#### 8. Update the main assembly stats table with your species

Add a new record for your species/assembly to the [best_ssl_assembly_per_sp.tsv](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/best_ssl_assembly_per_sp.tsv) file

Please note that you cannot paste a tab in nano as it interprets tabs as spaces. This means that you will have to manually enter each column one by one, or copy and paste multiple columns but then change the spaces by a single column to restore the tsv format.

Once done, push your changes to GitHub and confirm the that tsv format is correct by opening the [best_ssl_assembly_per_sp.tsv](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/best_ssl_assembly_per_sp.tsv) that your browser is displaying code but a nice looking table (aligned columns, etc). 

```sh
# add your info in a new row
nano ../best_ssl_assembly_per_sp.tsv
```

Next, you need to determine the best assembly to use the decontaminated data. Go on and complete step 9 (below) and come back here after.

--- 

#### **9. Evaluate then either go back to step B2 or  move onto next step**

Assuming you have completed step 9, you now know what library(ies) produced the best assembly. Compare your BUSCO values with that other species (for example, you can check the ["best assembly table"](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/best_ssl_assembly_per_sp.tsv).
If BUSCO values are too low, it might be worth trying the `covcutoff auto` (by changing the datatype variable from "contam" to "contam_covAUTO")

Example:
```bash
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "1" "contam_covAUTO" "854000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

Finally, run one more assembly using the decontaminated data from the same library(or all together) that produced the best assembly (with or without the covcutoff flag). Sgr example:
```bash
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "3" "decontam" "854000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

---

#### 10. Identifying mitochondrial genome with Mitofinder

One of the contigs in your assembled genome will probably be the mitochondrial genome (sequenced at high depth). Identifying this contig can be useful for confirming species identity.

You can run Mitofinder on the best contam assembly to find and annotate the mitochondrial genome. Use the following script, substituting particulars for your species in the arguments:

sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/run_mitofinder_ssl.sbatch [assembly dir] [species code] [SPAdes directory] [family]

Note that if you are assembling a genome for a species from a family that we have not run through SSL yet, you may have to add a mitochondrion from that family to the reference panel. An example for Parupeneus (Mullidae):

* Go to [NCBI](https://www.ncbi.nlm.nih.gov/genbank/) and search for full mitochondrial genome sequences from your species' family. For "Mullidae mitochondrion" there are multiple hits, you can just click on the first (Parupeneus indicus - close enough!) to go to the sequence record.
* Download to your local computer - in the upper right part of the screen click on "Send to", then click "Complete Record", for Choose Destination click "File", and then make sure the format "Genbank" is chosen, then click on "Create file".
* This will download to your computer as a file called "sequence.gb" - rename with the correct family ("Mullidae.gb").
* 

Check the outputs - the complete mitochondrial genome should have 15 genes and very high depth of coverage (you may have some pseudo-mitochondrial genes or genomes with fewer genes). For species identification, find the COX1 sequence and run a [BLAST](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PROGRAM=blastn&PAGE_TYPE=BlastSearch&LINK_LOC=blasthome) search. If there are no close matches it may be helpful to try [BOLD}(https://www.boldsystems.org/) or private sequence repositories.


</p>
</details>

___

<details><summary>C. PROBE DESIGN</summary>
<p>
	
### PROBE DESIGN

In this section you will identify contigs and regions within contigs to be used as candidate regions to develop the probes from.

Among other output, you will create the following 4 files:
1. *.fasta.masked: The masked fasta file 
2. *.fasta.out.gff: The gff file created from repeat masking (identifies regions of genome that were masked)
3. *_augustus.gff: The gff file created from gene prediction (identifies putative coding regions)
4. *_per10000_all.bed: The bed file with target regions (1 set of 2 probes per target region).

This instructions have been modified from Rene's [de novo assembly probe repo](https://github.com/philippinespire/denovo_genome_assembly/tree/main/WGprobe_creation) 
to best fit this repo

#### 1 Identifying regions for probe development 

From your species directory, make a new dir for the probe design
```sh
mkdir probe_design
```

Copy necessary scripts and the best assembly (i.e. scaffolds.fasta from contaminated data of best assembly) into the probe_design dir (you had already selected the best assembly previously to run the decontaminated data) 

Example:
```sh
cp ../scripts/WGprobe_annotation.sb probe_design
cp ../scripts/WGprobe_bedcreation.sb probe_design
cp SPAdes_SgC0072C_contam_R1R2_noIsolate/scaffolds.fasta probe_design
```

Rename the assembly to reflect the species and parameters used. Format to follows:

(3-letter species code)"_""scaffolds""_"(usedLibrary)"_"(cotam|decontam)"_""R1R2_noIsolate""_"(other treatments, if any).fasta

Example: Sgr_scaffolds_SgC0072C_contam_R1R2_noIsolate.fasta


NOTE: Make sure to use the .fasta extension as the script will be looking for this!

To get this info, I usually copy and paste the parameter info from the busco directory:
```sh
# list the busco dirs
ls -d busco_*
# identify the busco dir of the best assembly, copy the treatments (starting with the library)
# Example,the busco dir for the best assembly for Sgr is `busco_scaffolds_results-SPAdes_SgC0072C_contam_R1R2_noIsolate`
# I then provide the species 3-letter code, scaffolds, and copy and paste the parameters from the busco dir after "SPAdes_" 
cd probe_design
mv scaffolds.fasta Sgr_scaffolds_SgC0072C_contam_R1R2_noIsolate.fasta
```

Execute the first script. Example for Sgr:
```sh
#WGprobe_annotation.sb <assembly name> 
sbatch WGprobe_annotation.sb "Sgr_scaffolds_SgC0072C_contam_R1R2_noIsolate.fasta"
```

This will create: 
1. a repeat-masked fasta and gff file (.fasta.masked & .fasta.out.gff)
2. a gff file with predicted gene regions (augustus.gff), and 
3. a sorted fasta index file that will act as a template for the .bed file (.fasta.masked.fai)

I have modified the bed script to set the upper limit automatically. The longest scaffold and upper limit will  printed in the out file after execution.


Execute the second script. Example for Sgr:
```sh
#WGprobe_annotation.sb <assembly name> 
sbatch WGprobe_bedcreation.sb "Sgr_scaffolds_SgC0072C_contam_R1R2_noIsolate.fasta"
```

This will create a .bed file that will be sent for probe creation.
 The bed file identifies 5,000 bp regions (spaced every 10,000 bp apart) in scaffolds > 10,000 bp long.


**Check Upper Limit**

Open your out file and check that the upper limit was set correctly. Record the longest contig, uppper limit used in loop, and the number of identified regions and scaffolds  in your species README. 

The upper limit should be XX7500 (just under longest scaffold length). Ex: if longest scaffold is 88,888, then the upper limit should be 87,500; if longest scaffold is 87,499, then the upper limit should be 77,500.  

Sgr example:
```sh
cat BEDprobes-415039.out


The longest scaffold is 105644
The uppper limit used in loop is 97500
A total of 13063 regions have been identified from 10259 scaffolds
```

Move out files into your species logs dir
```sh
mv *out ../logs
```

#### 2 Closest relatives with available genomes

The last thing to do is to create a text file with links to available genomes from the 5 most closely-related species.

Most likely there won't be genomes available for your targeted species or even genus thus, the easiest way to search is probably to start with the family.
Go to the [NCBI Genome repository](https://www.ncbi.nlm.nih.gov/genome/) and search for the family of your species. If you get more than 5 genomes then search for the genus, but if  you don't, search higher classifications till you get them (i.e. order, class, etc)

Once you get at least 5 genomes, you'll need to figure out the phylogenetic relationships to lists the genomes in order from closest to farthest. 

Seach for phylogenies especific to your group. 
I have uploaded the phylogenies from Betancur et al. BMC Evolutionary Biology (2017) 17:162 for [fish phyla](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/Betancur2017_phyla.pdf)
 and [fish families](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/Betancur2017_families.pdf)
 in the scripts repo for your convenience.
These are an excellent resource for high taxonomic groups but only a few species per family are represented. 
Thus, you should also seach for phylogenies especific to your group. If these are not available, use Betancur 


Once your list is ready, create a file in your `probe_design` dir. Example for Sgr:
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

### 3 Files to Send

Share the following files with Arbor Bio to aid in probe creation:

1. The repeat-masked fasta file (.fasta.masked)
2. The gff file with repeat-masked regions (.fasta.out.gff)
3. The gff file with predicted gene regions (.augustus.gff)
4. The bed file (.bed)
5. The text file with links to available genomes from the 5 most closely-related species.

Make a dir name "files_for_ArborSci" inside your probe_design dir and move these files there:
```sh
mkdir files_for_ArborSci
mv *.fasta.masked *.fasta.out.gff *.augustus.gff *bed closest* files_for_ArborSci
```

Finally, notify Eric by email (e1garcia@odu.edu)  saying that your files are ready and post a message in the slack species channel with the probe region and scaffold info (from your BEDprobe*out file), and the full path to your files. Sgr example:
```sh
Probe Design Files Ready

A total of 13063 regions have been identified from 10259 scaffolds. The longest scaffold is 105644. 

Files for Arbor Bio:
ls /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/probe_design/files_for_ArborSci

Sgr_scaffolds_SgC0072C_contam_R1R2_noIsolate.fasta.augustus.gff
Sgr_scaffolds_SgC0072C_contam_R1R2_noIsolate.fasta.masked
Sgr_scaffolds_SgC0072C_contam_R1R2_noIsolate.fasta.out.gff
Sgr_scaffolds_SgC0072C_contam_R1R2_noIsolate_great10000_per10000_all.bed
closest_relative_genomes_Spratelloides_gracilis.txt
```

Eric will then share these with Arbor BioSciences.

#### **Finito!!!**

#### **Contrats! You have finished the ssl processing pipeline. Go ahead, give yourself a pat on the back!**

---

</p>
</details>

___

<details><summary>D. CLEANNING UP</summary>
<p>
	
## Cleaning Up

The SSL pipeline creates multiple copies of your data in the form of intermediate files. Assuming that you have finished the pipeline
 (have checked your files and send probe info to Arbor Bio), it is now time to do some cleaning up

Document the size of directories and files before cleaning up and save this to a file name <your species 3-letter ID>_ssl_beforeDeleting_IntermFiles 

From your species dir:
```sh
du -h | sort -rh > <yourspecies>_ssl_beforeDeleting_IntermFiles
# Sgr example Sgr_ssl_beforeDeleting_IntermFiles
```

#### 1 Make a copy of important files 
Before deleting files, make a copy of important files in the RC (only available in the login node):

1. raw sequence files (this should had been done already but check again)
2. "contaminated" files (fq_fp1_clmp_fp2)
3. "decontaminated" files (fq_fp1_clmp_fp2_fqscrn_repaired)
4. best assembly (probably just the contigs.fasta and scaffolds.fasta for contam and decontam of best assembly)

Example for Sgr
```sh
# check for copy of raw files
ls /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/fq

# make copy of contaminated and decontaminated files
cp -R fq_fp1_clmp_fp2 /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/<your species>/
cp -R fq_fp1_clmp_fp2_fqscrn_repaired /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/<your species>/               

# make a copy of fasta files for best assembly (SgC0072C for Sgr)
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/<your species>/SPAdes_SgC0072C_contam_R1R2_noIsolate
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/<your species>/SPAdes_SgC0072C_decontam_R1R2_noIsolate
cp SPAdes_SgC0072C_contam_R1R2_noIsolate/[cs]*.fasta /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/<your species>/SPAdes_SgC0072C_contam_R1R2_noIsolate
cp SPAdes_SgC0072C_decontam_R1R2_noIsolate/[cs]*.fasta /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/<your species>/SPAdes_SgC0072C_decontam_R1R2_noIsolate
```

#### 2 Delete unneeded files
Delete raw sequence files and other sequence files (fq.gz | fastq.gz) from intermediate processes (Fastp1, Clumpify, and Fastq Screen; steps 0, 2, and 5). Thus:

Keep files from:
* fq_fp1_clmp_fp2  
* fq_fp1_clmp_fp2_fqscrn_repaired

Delete fq.gz files from:
* shotgun_raw_fq
* fq_fp1
* fq_fp1_clmp
* fq_fp1_clmp_fp2_fqscrn

It is a good idea to keep track of the files you are deleting

An easy way to do this is to list files of your *raw* directory and direct to a new file, then append the ls of the other two directories to the same log file:
```sh
# create log file before removing
ls -ltrh *raw*/*fq.gz > deleted_files_log
ls -ltrh *fp1/*fq.gz >> deleted_files_log
ls -ltrh *clmp/*fq.gz >> deleted_files_log
ls -ltrh *fqscrn/*fq.gz >> deleted_files_log
```

Removing files
```
rm *raw*/*fq.gz
rm *fp1/*fq.gz
rm *clmp/*fq.gz
rm *fqscrn/*fq.gz
```

Finally, document the new size of your directories

From your species dir:
```sh
du -h | sort -rh > <yourspecies>_ssl_afterDeleting_IntermFiles
```

For Sgr, I deleted about 1Tb of data! (I create many treatments while making the SSL pipeline. You will likely delete less than that but still a substancial amount)


Move the cleaning files into the logs dir
```sh
mv Sgr_ssl* logs
mv deleted_files_log logs
```

</p>
</details>
