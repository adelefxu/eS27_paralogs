# pipeline part 1
#
# automates the first few stages of processing:
# - stage 0: raw Illumina FASTQ files, 1 file per lane
# - stage 1: trimmed with cutadapt
# - stage 2: demultiplexed from 1 file per sequencing lane/replicate to 1 file per sample
# stage 2 output files can be found at GSE201845
#
# configured for SLURM
#
# run "module load anaconda" before running this

import argparse
import os
import subprocess
import json
import glob

parser = argparse.ArgumentParser(description = "Run part 1 of ribosome profiling pipeline (through barcode splitting step)")
parser.add_argument("--root_dir")
parser.add_argument("--sb_name")
parser.add_argument("--sb_time", default = "12:0:0")
parser.add_argument("--sb_mem", default = "32G")
parser.add_argument("--sb_cpus", default = "4")
args = parser.parse_args()

# make log directory inside root directory
log_dir = os.path.join(args.root_dir, "logs")
os.makedirs(log_dir, exist_ok=True)

# make directories for each stage from 1 to 10 (stage0 has already been created so skip making it)
stage_dir = [os.path.join(args.root_dir, "stage"+str(i)) for i in range(0,10)]
for sd in stage_dir[1:10]:
    os.makedirs(sd, exist_ok=True)

# get lane names and prefixes from stage0 directory
stage0_fqgz = glob.glob(os.path.join(stage_dir[0], "*", "*_stage0raw.fastq.gz"))
lane_dir_short = [os.path.basename(os.path.dirname(i)) for i in stage0_fqgz]
lane_prefix=[os.path.basename(i).replace("stage0raw.fastq.gz","") for i in stage0_fqgz]
barcode_file = [i.replace("_stage0raw.fastq.gz", "_barcodes.txt") for i in stage0_fqgz]

# make lane directories in stage 1 directory
for ln in lane_dir_short:
    os.makedirs(os.path.join(stage_dir[1], ln), exist_ok=True)

stage1_fqgz = [os.path.join(stage_dir[1], lane_dir_short[i], lane_prefix[i]+"stage1trimmed.fastq.gz") for i in range(len(lane_dir_short))]
stage2_prefix = [os.path.join(stage_dir[2], lp) for lp in lane_prefix]
stage2_fq_suffix = "_stage2bcmatched.fastq"

adapter3p = "AGATCGGAAGAGCACAGTCTGAACTCCAGTCAC"

# default sbatch parameters
sb_defaults = "-e %x-%j.e -o %x-%j.o -A mbarna -p batch"

# iterate over each stage0 fastq.gz input file
for i in range(len(stage0_fqgz)):   
    
    #construct shell code
    sh_code = '\n'.join([f"#!/bin/sh -l",
                         f"date +'%D %T'",
                         f"echo",
                         f"echo '### Starting step 0: trim reads'",
                         f"echo",
                         f"module load cutadapt/2.4",
                         f"cutadapt -j 0 -u 3 -a {adapter3p} --discard-untrimmed -m 15 -o {stage1_fqgz[i]} {stage0_fqgz[i]}",
                         f"date +'%D %T'",
                         f"echo",
                         f"echo '### Starting step 1: demultiplex in-line barcodes'",
                         f"echo",
                         f"module load fastx_toolkit",
                         f"zcat {stage1_fqgz[i]} | fastx_barcode_splitter.pl --bcfile {barcode_file[i]} --eol --prefix {stage2_prefix[i]} --suffix {stage2_fq_suffix}",
                         f"echo '### DONE part 1'"])
    
    # construct sbatch command line
    sb_cmd = f"sbatch {sb_defaults} -D {log_dir} -J {lane_prefix[i]}{args.sb_name} -t {args.sb_time} --mem={args.sb_mem} -c {args.sb_cpus} <<EOF \n{sh_code}\nEOF"

    # call sbatch command line as subprocess, extract job ID
    sb_sub_msg = subprocess.check_output(sb_cmd, shell=True).decode('ascii')
    print(sb_sub_msg)
    job_id = sb_sub_msg.strip().replace("Submitted batch job ", "")

    # dump config file

    with open(os.path.join(log_dir, f"{lane_prefix[i]}{args.sb_name}_riboprof-pt1_{job_id}.config"), 'w') as config_file:
        git_version = str(subprocess.check_output(['git', 'rev-parse', 'HEAD']).strip())
        configs = {"git version": git_version, "arguments": vars(args), "sbatch command line": sb_cmd}

        json.dump(configs, config_file, indent=4)
    
