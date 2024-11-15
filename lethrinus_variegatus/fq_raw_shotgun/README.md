*Lethrinus variegatus*

Transfer completed from TAMUCC to ODU

```
scp /work/hobi/GCL/20220318_PIRE-Lva-shotgun/* e1garcia@turing.hpc.odu.edu:/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing//lethrinus_variegatus/shotgun_raw_fq
```

Raw *.fq.gz files were not present in `/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus/fq_raw_shotgun/` so they were transferred from `/RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus/fq_raw_shotgun/`. 
```
rsync -a /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus/fq_raw_shotgun/*.fq.gz /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus/fq_raw_shotgun/ &
```
All three sequence sets are from individual Lva-CPnd_006_Ex1

The `old_new_filenames.log` was not created when renaming, so one was manually created from the `newFileNames.txt` and the `origFileNames.txt`.
```
cat old_new_filenames.log

LvaC00610A_CKDL220006132-1a-AK6260-7UDI214_HK52YDSX3_L3_1.fq.gz Lva-CPnd_006A_L3_1.fq.gz
LvaC0069G_CKDL220006132-1a-AK6881-GC12_HK52YDSX3_L3_1.fq.gz     Lva-CPnd_006G_L3_1.fq.gz
LvaC0069H_CKDL220006132-1a-AK6881-7UDI246_HK52YDSX3_L3_1.fq.gz  Lva-CPnd_006H_L3_1.fq.gz
LvaC00610A_CKDL220006132-1a-AK6260-7UDI214_HK52YDSX3_L3_2.fq.gz Lva-CPnd_006A_L3_2.fq.gz
LvaC0069G_CKDL220006132-1a-AK6881-GC12_HK52YDSX3_L3_2.fq.gz     Lva-CPnd_006G_L3_2.fq.gz
LvaC0069H_CKDL220006132-1a-AK6881-7UDI246_HK52YDSX3_L3_2.fq.gz  Lva-CPnd_006H_L3_2.fq.gz
```
Unusual naming format for the SSL Lva files. It looks like the well ID and the individual ID were combined. It also looks like the extraction ID is missing from the new file names (Ex1). The file names will not be corrected at this point (11/7/24).
```
cd /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus/fq_raw_shotgun/

ls Lva*.fq.gz

Lva-CPnd_006A_L3_1.fq.gz
Lva-CPnd_006A_L3_2.fq.gz
Lva-CPnd_006G_L3_1.fq.gz
Lva-CPnd_006G_L3_2.fq.gz
Lva-CPnd_006H_L3_1.fq.gz
Lva-CPnd_006H_L3_2.fq.gz

less Lva_ssl_decode.tsv

Sequence_Name   Extraction_ID
LvaC00610A      Lva-CPnd_006A
LvaC0069G       Lva-CPnd_006G
LvaC0069H       Lva-CPnd_006H

less origFileNames.txt

LvaC00610A_CKDL220006132-1a-AK6260-7UDI214_HK52YDSX3_L3_
LvaC0069G_CKDL220006132-1a-AK6881-GC12_HK52YDSX3_L3_
LvaC0069H_CKDL220006132-1a-AK6881-7UDI246_HK52YDSX3_L3_

less newFileNames.txt

Lva-CPnd_006A_L3_
Lva-CPnd_006G_L3_
Lva-CPnd_006H_L3_
```
Actual file names:

Lva-CPnd_006A_L3_1.fq.gz

Lva-CPnd_006A_L3_2.fq.gz

Lva-CPnd_006G_L3_1.fq.gz

Lva-CPnd_006G_L3_2.fq.gz

Lva-CPnd_006H_L3_1.fq.gz

Lva-CPnd_006H_L3_2.fq.gz

Correct file name:

Lva-CPnd_006_10A_L3_1.fq.gz

Lva-CPnd_006_10A_L3_2.fq.gz

Lva-CPnd_006_9G_L3_1.fq.gz

Lva-CPnd_006_9G_L3_2.fq.gz
