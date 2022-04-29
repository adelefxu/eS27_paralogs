# Rscript command line: Rscript subset_dge.R <path to ensembl file> <path to input DGE file>
# Output DGE file is automatically given the same prefix as input DGE file.

# Un-comment next 3 lines if running from Rscript command line

args <- commandArgs(trailingOnly=TRUE)
input_ensembl_file <- args[1]
input_dge_file <- args[2]

# Un-comment next 2 lines if running in RStudio
# input_ensembl_file <- "/Users/Adele/Google Drive/Barna/MCA/edited_t123_ensembl.tsv"
# input_dge_file <- "/Users/Adele/Google Drive/Barna/MCA/rmbatch_dge/PeripheralBlood4_rm.batch_dge.txt"

print("Input ensembl file:")
input_ensembl_file
print("Input DGE file:")
input_dge_file

# Read inputs
print("Reading in ensembl file...")
input_ensembl <- read.table(file=input_ensembl_file, sep='\t', header=TRUE)
print("Reading in DGE file...")
Sys.time()
input_dge <- read.table(file=input_dge_file, header=TRUE, row.names=1, quote="")
print("Done reading DGE file...")
Sys.time()
input_genes <- unique(input_ensembl$gene.name)

print("Number of input genes:")
length(input_genes)
print("Rows & columns of input DGE:")
dim(input_dge)

# Trim rowname & colname formatting: remove quotes in rownames and get rid of X. in colnames (X. was added because my colnames originally had quotes around them, which aren't allowed as colnames)
rownames(input_dge) <- gsub(pattern="\"", replacement="", rownames(input_dge))
colnames(input_dge) <- gsub(pattern="^X.", replacement="", colnames(input_dge))
colnames(input_dge) <- gsub(pattern=".$", replacement="", colnames(input_dge))

print("Rows & columns 1:5 of DGE:")
input_dge[1:5, 1:5]

print(paste("Of", length(input_genes), "input genes,", sum(input_genes %in% rownames(input_dge)), "are in the DGE.",sep=" "))
print("Not found in DGE:")
not_in_dge <- input_genes[!(input_genes %in% rownames(input_dge))]
not_in_dge

not_in_dge_ensembl <- input_ensembl[input_ensembl$gene.name %in% not_in_dge,c("gene.id", "gene.name", "gene.status", "t1.name", "is.t1", "is.t2", "is.t3")]
print(paste(nrow(not_in_dge_ensembl), "entries and", length(unique(not_in_dge_ensembl$gene.name)), "unique genes not found in DGE", sep=" "))
print("Entries not found in DGE, counted by tier 1, 2, and 3:")
print(paste(sum(not_in_dge_ensembl$is.t1), sum(not_in_dge_ensembl$is.t2), sum(not_in_dge_ensembl$is.t3), sep=" "))

print("Writing subsetted DGE to file")

# Make output DGE. Include rows for genes that are not found in DGE, to keep things consistent between samples
output_dge <- matrix(0, ncol = ncol(input_dge), nrow = length(input_genes))
colnames(output_dge) <- colnames(input_dge)
rownames(output_dge) <- input_genes

in_dge <- rownames(output_dge) %in% rownames(input_dge)
output_dge[in_dge,] <- as.matrix(input_dge[rownames(output_dge)[in_dge],])

input_dge_file_split <- strsplit(input_dge_file, "/")[[1]]
input_dge_file_name <- input_dge_file_split[length(input_dge_file_split)]
input_dge_file_prefix <- sub(".txt$", "", input_dge_file_name)

write.table(output_dge, file=paste(input_dge_file_prefix, "_subset.txt", sep=""), quote=FALSE, sep='\t', row.names=TRUE, col.names=TRUE)
