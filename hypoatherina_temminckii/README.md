#New Probes for Hte

The Original probes were designed from:

individual: library

Hte-CTic_070: Hte-C_scaffolds_1R_spades_contam_R1R2ORPH_noisolate  
(files at /home/r3clark/PIRE/WG_baits/Hte/Hte-CTic_070)

yet, we discovered that

Hte-CTic_070: Hte-C_scaffolds_1R really is Aur-CRag39:NoWGA_Aur-CRag39_R_1 so probes belong to Ambassis uroteania and we don't have probes for Hte.

Luckily some of the processed libraries labelled as "Sob" are really Hte:

Sob-CKal_019_Ex2: NoWGA_Sob-CKal_NR_500     is really       Hte-CTic_093_Ex3: noWGA_Hte-Ctic_NR_500     

Sob-CKal_015_Ex3: NoWGA_Sob-CKal_NR_32      is really       Hte-CTic_077_Ex4: NoWGA_Hte-CTic_NR_32      

Sob-CKal_015_Ex3: NoWGA_Sob-CKal_R_32       is really       Hte-CTic_077_Ex4: NoWGA_Hte-CTic_R_32 

from these, we do have an assembly for the lib 500 and one combining the two 32s (the new "all"). The last one has better BUSCO/N50/etc scores. 
I did blastn a few sections of contigs from the 32s assembly and it is loosely matching Telmatherina bonti, which belongs to a family closely related to atherinids (Hte).

So I am moving forward to designing probes from the new "all" assembly which combines the two 32s libs of Sob=Hte.

---

## **C. Probe Design - Regions for Probe Development**

From the species directory: made probe directory, renamed assembly, and copied scripts.

```sh
mkdir /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/hypoatherina_temminckii
cd  /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/hypoatherina_temminckii
mkdir probe_design
cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/WGprobe_annotation.sb probe_design
cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/WGprobe_bedcreation.sb probe_design
cp /home/e1garcia/shotgun_PIRE/sob_spades/out_Hte-C_all_R1R2ORPH_decontam_noisolate_covcutoff-off_correctedIDs/scaffolds.fasta probe_design/
cd probe_design
mv scaffolds.fasta Hte_scaffolds_allLibs_32sSob-Hte_decontam_R1R2_noIsolate.fasta
```

Execute the first script
```sh
#WGprobe_annotation.sb <assembly name> 
sbatch WGprobe_annotation.sb Hte_scaffolds_allLibs_32sSob-Hte_decontam_R1R2_noIsolate.fasta 
Submitted batch job 1113391
```

Execute the second script
```sh
#WGprobe_annotation.sb <assembly base name> 
sbatch WGprobe_bedcreation.sb Hte_scaffolds_allLibs_32sSob-Hte_decontam_R1R2_noIsolate.fasta
Submitted batch job 1113684
```

