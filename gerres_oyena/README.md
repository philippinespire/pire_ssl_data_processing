TAMUCC-ODU
scp /work/hobi/GCL/20210829_PIRE-Goy-shotgun/* e1garcia@turing.hpc.odu.edu://RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/shotgun_raw_fq

All two sequence sets are for individual Goy-CPas_088_Ex1

RC-jwhal002

gerres_oyena directory created
cp /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/shotgun_raw_fq/*.fq.gz .

##Preprocessing##
#9/7/21#

Run from /home/jwhal002/shotgun_PIRE/pire_fq_gz_processing/
sbatch Multi_FASTQC.sh "fq.gz" "/home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/shotgun_raw_fq"
