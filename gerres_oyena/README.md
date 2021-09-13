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

