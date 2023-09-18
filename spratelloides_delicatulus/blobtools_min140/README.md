## Blobtools analysis, Sde minlen140 assembly

Location of assembly and read data:
```
/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/assemblies_for_fp2min140/SPAdes_allLibs_decontam_R1R2_noIsolate/scaffolds.fasta

/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/fq_fp1_clmp_fp2min140_fqscrn_rprd
```

Make a folder for a blobtools analysis:
```
mkdir /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140
```

Copy scripts and move to blobtools directory (note - should have BUSCO and QUAST already, so just running BWA and BLAST). BR is editing file scripts to include variables for path to assembly file, read data files, and blobtools output directory.

```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140
cp /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/template_scripts/runBLAST_forblob.sb .
cp /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/template_scripts/runBWA_forblob.sb .
```

Run BLAST:
```
sbatch runBLAST_forblob.sb /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/assemblies_for_fp2min140/SPAdes_allLibs_decontam_R1R2_noIsolate/scaffolds.fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140
```

Run BWA:
```
sbatch runBWA_forblob.sb /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/assemblies_for_fp2min140/SPAdes_allLibs_decontam_R1R2_noIsolate scaffolds.fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/fq_fp1_clmp_fp2min140_fqscrn_rprd fq.gz /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140 Sde_minlen140
```

Create the Blobtools analysis directory for the assembly and add BLAST hits/BUSCO/coverage:
```
salloc --ntasks=1 --job-name=blob
enable_lmod
module load container_env/0.1
module load busco/5.0.0
module load container_env blobtoolkit
bash
export SINGULARITY_BIND=/home/e1garcia
crun blobtools create \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/assemblies_for_fp2min140/SPAdes_allLibs_decontam_R1R2_noIsolate/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140/Sde_min140_blobplot
crun blobtools add \
    --hits /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140/blastn.out  \
    --taxdump /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/taxdump \
    --taxrule bestsumorder \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140/Sde_min140_blobplot
crun blobtools add \
	--busco /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/assemblies_for_fp2min140/busco_scaffolds_results-SPAdes_allLibs_decontam_R1R2_noIsolate/run_actinopterygii_odb10/full_table.tsv \
	/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140/Sde_min140_blobplot
crun blobtools add \
	--cov /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140/Sde_minlen140_redundans.sort.filt.bam \
	/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140/Sde_min140_blobplot
```

## Filtering with Blobtools

Got the list of contaminants in my assembly from the bottom of the file bestsumorder_phylum.json

Picked everything after Chordata and no-hits. In my case this required tail of 14 and head of 12:
```
tail -n14 bestsumorder_phylum.json | head -n12 | sed -e 's/"//g' -e 's/ //g' | tr -s "\n" ","
Mollusca,Annelida,Cnidaria,Arthropoda,Echinodermata,Nematoda,Chlorophyta,Pseudomonadota,Platyhelminthes,Bacteroidota,Uroviricota,Actinomycetota,
```
Will add those as a comma-separated list to the `--param bestsumorder_phylum--Keys=` command.

Next, I will calculate the average coverage from the file `Sde_minlen140_redundans.sort.filt_read_cov.json`

if you less -SN the file, you'll see that the first two and last three lines (lines 1-2, 616866-616868)  are not numbers. Also, there are spaces and commas.
```
less -SN Sde_minlen140_redundans.sort.filt_read_cov.json
      1 {
      2  "values": [
      3   16.8083,
      4   15.365,
      5   15.9791,
      .
      .
      .
      616862   0,
      616863   0,
      616864   0,
      616865   0
      616866  ],
      616867  "keys": []
      616868 }
```
Clean and calculate average coverage:
```
cat Sde_minlen140_redundans.sort.filt_cov.json | head -n 616865 | tail -n+3 | sed -e 's/,//g' -e 's/ //g' | awk '{ total += $1 } END { print total / NR }' 
13.0001
```
This matches what I see in the blobtools plot Sde_min140_blobplot.blob.square 2.png. 
In this plot, I am looking at the distribution of no-hits and chordata and see that these reach a coverage up to ~100, and the minimum is pretty low.

I will chose 4 as minimum and 100 as maximum.

I create the script `filterAssBlobtools.sb` to run the following filter: 
```
crun blobtools filter \
	--param Sde_minlen140_redundans.sort.filt_cov--Min=4 \
	--param Sde_minlen140_redundans.sort.filt_cov--Max=100 \
	--param bestsumorder_phylum--Keys=Mollusca,Annelida,Cnidaria,Arthropoda,Echinodermata,Nematoda,Chlorophyta,Pseudomonadota,Platyhelminthes,Bacteroidota,Uroviricota,Actinomycetota \
	--output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140/Sde_filtercov_keepChordatanohit_blobplot
	--fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140/scaffolds.fasta \
	/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140/blobtools_min140
# Default name is "[input prefix].filtered.fasta"... change to more descriptive name
mv scaffolds.filtered.fasta Sde_scaffolds_filtercov_keepChordatanohit.fasta
```

After running the phylum filter, there is only no-hits and chordata at the bottom of the file
`Sde_filtercov_keepChordatanohit_blobplot/bestsumorder_phylum.json`

However, there are still many classes at the bottom of `Sde_filtercov_keepChordatanohit_blobplot/bestsumorder_class.json ` :
```
Actinopteri, no-hits, Aves, Mammalia, Cladistia, Chordata-undef, Insecta, Amphibia, Chondrichthyes, Lepidosauria, Hyperoartia, Myxini, Leptocardii, Gastropoda, Demospongiae 
```

Thus, I am running a new filter to remove all other classes other than Actinopteri or no-hits.

Running the class filter
```
#I just ran the above  script  after  adding:
--param bestsumorder_class--Keys=Aves,Mammalia,Cladistia,Chordata-undef,Insecta,Amphibia,Chondrichthyes,Lepidosauria,Hyperoartia,Myxini,Leptocardii,Gastropoda,Demospongiae \
```

This places the outdir `Sde_filtercov_keepChordatanohit_blobplot` in `Sde_min140_blobplot`. but fasta in the same dir as script.

I  should had change the name of the output. So manually changing
```
mv Sde_min140_blobplot/Sde_filtercov_keepChordatanohit_blobplot Sde_filtercov_keepChordatanohit-Actinopterinohit_blobplot
mv scaffolds.filtered.fasta Sde_scaffolds_filtercov_keepChordatanohit-Actinopterinohit.fasta
```
