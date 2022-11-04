<b>Allison's Readme</b>
---

Notes:

/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Allison

rsync afink007@wahab.hpc.odu.edu:/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Allison/corythoichthys_haematopterus/shotgun_raw_fq/fastqc_report.html .
---

07/08/2022

	First introduction draft completed

07/11/2022

	Readme created

	<i>Corythoichthys haematopterus</i> raw fq.qz files
	renamed prior to running species through pipeline.
	
	renameFQGZ.bash run, renamed to Cha-CPnd, outputs:
	
	Cha-CPnd_001_Ex1-1A_L4_1.fq.gz  Cha-CPnd_001_Ex1-2G_L4_1.fq.gz
	Cha-CPnd_001_Ex1-1A_L4_2.fq.gz  Cha-CPnd_001_Ex1-2G_L4_2.fq.gz
	Cha-CPnd_001_Ex1-1H_L4_1.fq.gz  stdin_fastqc.html
	Cha-CPnd_001_Ex1-1H_L4_2.fq.gz  stdin_fastqc.zip

	Git push permission error

	attempted to run Multi_FastQC.sh, permission error

07/12/2022

	Still have permission error for pushing

	Got MultiQC to run

	/home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Allison/corythoichthys_haematopterus/shotgun_raw_fq" "fq.gz"
	
	Ran Fastqp

        Multi_FastQC.sh successfuly run, html file copied to personal computer
        
		/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Allison/corythoichthys_haematopterus/shotgun_raw_fq/fastqc_report.html   

07/18/2022

	Getting over jetlag. Checked on jobs set before leaving the Philippines. No jobs were still running on wahab or turing.

	Recorded data from quast output for all libs

	Running BUSCO failed. Sent message to slack about it.

07/19/2022

	Re-ran SPAdes for 1, 2 and 3

	Recorded quast report for all libs
	
	Worked on paper- found sources that contradict hypothesis, took notes on them
	
	Got BUSCO to run for all individual libraries

07/20/2022
	
	SPAdes for 2 and 3 ran successfuly- marked as B/C
	
	Scaffolds and contigs results from BUSCO for all libs exist, Brendan ran contigs as test. Recorded info in readme
	
	Updating readme files (took down notes on computer while permission issues were not letting me save in readme)
	
	Organized Cha directory
	
	Rsync'd all quast reports onto personal desktop

	Added quast results to step 4 table in Cha readme

	Submitted contigs for B (batch job 775394) and scaffolds for B (batch job 775404)
	
	Submitted contigs for C (batch job 775407) and scaffolds for C (batch job 775408)

	Need to re-run SPAdes for 1st library (A), code:

	sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "afink007" "Cha" "1" "decontam" 
"342000000" "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Allison/corythoichthys_haematopterus/" "fq_fp1_clmp_fp2_fqscrn_repaired" 


07/25/2022

	getting back to Cha

	Something went wrong with running SPADES for A, re-running

07/26/2022

	Busco is done for all now, filling out table
	Updated table with QUAST info

	Species    	Library    	DataType    	SCAFIG    	covcutoff    	genome scope v.    	No. of contigs    	Largest contig    	Total length 	% Genome size completeness    	N50    	L50    	Ns per 100 kbp    	BUSCO single copy	
	------  	------  	------ 	------ 	------ 	------  	------ 	------ 	------ 	------ 	------  	------ 	------ 	------ 	
	Cha	allLibs  	decontam     	contigs       	off       		74819	282571	364837995	41.16	4799	25780	0.00	798	
	Cha	allLibs  	decontam     	scaffolds       	off       		76635	282571	378208088	41.15	4860	26123	51.41	811	
	Cha	CPnd-A	decontam     	contgs       	off       		8516	116066	45376391	46.86	4852	2278	0.00	406	
	Cha	CPnd-A	decontam     	scaffolds       	off       		9451	198527	198527	46.76	4773	2534	104.89	421	
	Cha	CPnd-B	decontam     	contgs       	off       		12295	176474	56786073	45.54	4260	4145	0.00	479	
	Cha	CPnd-B	decontam     	scaffolds       	off       		14138	269079	65369174	45.28	4268	4762	150.71	491	
	Cha	CPnd-C	decontam     	contgs       	off       		6572	153476	36962939	46.19	5041	1498	0.00	369	
	Cha	CPnd-C	decontam     	scaffolds       	off       		7408	182426	40835802	45.98	4851	1756	84.64	389

	Used excel custom sort to find best library: AllLibs
	Running contam for All Libs

	sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "afink007" "Cha" "all_libs" "contam" "342000000" "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Allison/corythoichthys_haematopterus/" "fq_fp1_clmp_fp2"
	Scripts:

	/home/e1garcia/shotgun_PIRE/REUs/2022_REU/<yourname>/<speciesname>_PSMC/data/mkBAM/<speciescode>_denovoSSL_20k_PSMC
	cp /home/e1garcia/shotgun_PIRE/REUs/2022_REU/<yourname>/<speciesname>_PSMC/scripts/dDocentHPC_ODU.sbatch /home/e1garcia/shotgun_PIRE/REUs/2022_REU/<yourname>/<speciesname>_PSMC/data/mkBAM/<speciescode>_denovoSSL_20k_PSMC


07/27/2022

	Checked in on Cha, job from yesterday is still running
	Job finished (AllLibs contam)
	Running Busco for allLibs contam

07/28/2022

	Busco ran for contam contigs
	filling out table for species
	confirmed that contam beats decontam
	best assembly to use contaminated data is still allLibs
	the BUSCO is the best we are going to get, even though it is low (23%)

	copied scaffolds.fasta into main directory, starting PSMC now
	copied scripts
	made data/mkBAM
	renamed fasta file
	removed smalls
	658 scaffolds
	length of filtered assembly: 35226418
	Changed names to numerals
	dDocent cloned
	Cha_denovoSSL_20k_PSMC created
	moved over dDocent, scripts and .fa file
	copied fqgz to corect folder
	copied in fasta
	copied in scripts
	submitted mkBAM job 824952
	failed, missing bash file, added it in... re-run mkBAM 830273

07/29/2022

	mkBAM successful
	running fltrBAM job
	fltrBAM worked
	mergebam ran successfully
	depth 70.2281 range: 23.4093666667 - 140.4562
	copied mpileup.sbatch
	sbatch --array=1-658 mpileup.sbatch Allison corythoichthys_haematopterus Cha 23 140 0
	sbatch --array=1-658 psmcfa.sbatch Allison corythoichthys_haematopterus Cha 0

	psmcfa worked correctly

	sbatch psmc.sbatch Allison corythoichthys_haematopterus Cha 2.60822892
	psmc job  883848
	psmc successful

07/30/2022

	gentime is 2.60822892
	psmcbootplot job 885581
	***CHA DONE IN TERMINAL***
	
	



