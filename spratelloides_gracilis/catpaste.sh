#!/bin/bash -l
	
cat <(echo "file	#reads_raw	#reads_fp1	#reads_clmp	#reads_fp2	#reads_fqscrn	#reads_repr	#reads_remaining") <(\
	paste raw.temp fp1.temp clm.temp fp2.temp) > 1_Catpaste
