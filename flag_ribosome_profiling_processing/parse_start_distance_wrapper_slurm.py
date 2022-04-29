# adapted from a script originally written by Gerald Tiu
# configured for SLURM

import glob, os, subprocess, argparse

# Parse arguments
parser = argparse.ArgumentParser()
parser.add_argument('--sam_dir') # directory containing outputs of stage 9
parser.add_argument('--log_dir') # log directory
parser.add_argument('--script_path') # path to parse_start_distance.sh
parser.add_argument('--utrcdslengthpath') # path to file containing 4 tab-delimited columns:
# - transcript ID
# - length in nt of 5' UTR
# - length in nt of CDS
# - length in nt of 3' UTR
args = parser.parse_args()

stage9_suffix = '_stage9resort.sam'

for file in glob.glob(os.path.join(args.sam_dir, '*', f'*{stage9_suffix}')):
    
    print(file)
    
    samp_name_short = os.path.basename(file).replace(stage9_suffix, '')
    
    jobname = f'{samp_name_short}_startdist'
    
    sb_cmd = f"sbatch -J {jobname} -t 6:00:00 --mem=8000 -D {args.log_dir} -e %x-%j.e -o %x-%j.o -A mbarna -p batch {args.script_path} {file} {args.utrcdslengthpath}"     
    
    subprocess.call(sb_cmd, shell = True)
