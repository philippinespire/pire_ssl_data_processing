# Probes for Sor

Sor has a chromosome level genome already published. I will use this genome to generate probes instead of the ssl assembly

---

## **C. Probe Design - Regions for Probe Development**


From ssl dir: made specices and probe directory, download genome, prep genome, and copied scripts.

```sh
mkdir /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_orbicularis/
mkdir /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_orbicularis/probe_design
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_orbicularis/probe_design
wget https://ftp.ncbi.nlm.nih.gov/genomes/genbank/vertebrate_other/Sphaeramia_orbicularis/latest_assembly_versions/GCA_902148855.1_fSphaOr1.1/GCA_902148855.1_fSphaOr1.1_genomic.fna.gz
gunzip GCA_902148855.1_fSphaOr1.1_genomic.fna.gz  
cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/WGprobe_annotation.sb probe_design
cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/WGprobe_bedcreation.sb probe_design
```

The downloaded genome fasta file contained 24 chromosomes represented by the sequence names LR597458-LR597480. 
However, I noticed it also have several more sequences with the names CABFVO010000001-CABFVO010006896. 
After some digging, I found an [report](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/902/148/825/GCA_902148825.1_fSphaOr1.1_alternate_haplotype/GCA_902148825.1_fSphaOr1.1_alternate_haplotype_assembly_report.txt) 
of an alternate haplotype for this genome where it names these sequences  as "unplaced_scaffolds".  I am thus removing these and keeping only the chromosomes.

Removing "unplaced_scaffolds"
```
cat GCA_902148855.1_fSphaOr1.1_genomic.fna | sed '/>CABF/Q' > GCA_902148855.1_fSphaOr1.1_genomic_chrmOnly.fna
```


Execute the first script
```sh
#WGprobe_annotation.sb <assembly name> 
sbatch WGprobe_annotation.sb GCA_902148855.1_fSphaOr1.1_genomic_chrmOnly.fna
Submitted batch job 1113662
```

Script failed bc it is specifically looking for the ".fasta" extension. Renaming reference and re-running
```
mv  GCA_902148855.1_fSphaOr1.1_genomic_chrmOnly.fna GCA_902148855.1_fSphaOr1.1_genomic_chrmOnly.fasta
sbatch WGprobe_annotation.sb GCA_902148855.1_fSphaOr1.1_genomic_chrmOnly.fasta
Submitted batch job 1113712
```

Execute the second script
```sh
#WGprobe_annotation.sb <assembly base name> 
sbatch WGprobe_bedcreation.sb GCA_902148855.1_fSphaOr1.1_genomic_chrmOnly.fna
```

