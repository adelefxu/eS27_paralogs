#!/bin/bash

module load anaconda
source activate riboprof

input_file=$1
output_file=$2

python /home/adelexu/research/riboprof/riboprof/scripts/UTR_CDS_reads_count.py $input_file $output_file

