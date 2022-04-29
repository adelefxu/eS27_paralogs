Input: raw Illumina FASTQ files, 1 file per lane
Output: read counts for 5' UTR, CDS, and 3' UTR per transcript, per sample

Order of execution:

1. riboprof_pt1.py
2. riboprof_pt2.py
3. parse_start_distance_wrapper_slurm.py, which calls parse_start_distance.sh, which calls bowtieSAM_parse_start_position.py and distanceFromStartStop_size.py
4. Run plot_start_distances.R on the *_distance.txt files produced by the previous step. 
5. Examine the resulting plots (only look at UTR plots) and identify the mode value of read start positions for each read length. The offset between this mode value and the start codon (position 0) reflects the distance between the start of the footprint and the A site. Edit bowtieSAM_parse_A_position_Ribo_template.py accordingly to reflect the offset for calculating the A position for each read length (in the example below, all the mode values were 9-13 nt upstream of the 0 position

if read_length<=26:
            A_position = start + 4 + 9
elif read_length==27:
            A_position = start + 4 + 9
elif read_length==28:
            A_position = start + 4 + 9
elif read_length==29:
            A_position = start + 4 + 10
elif read_length==30:
            A_position = start + 4 + 10
elif read_length==31:
            A_position = start + 4 + 12
elif read_length==32:
            A_position = start + 4 + 12
elif read_length==33:
            A_position = start + 4 + 12
elif read_length>=34:
            A_position = start + 4 + 13

6. Execute bowtieSAM_parse_A_position_Ribo_template.py by running the wrapper script, bowtieSAM_parse_A_position_Ribo_wrapper_slurm.py

7. Run UTR_CDS_reads_count_wrapper_slurm.py, which calls UTR_CDS_reads_count_submit.sh, which calls UTR_CDS_reads_count.py
