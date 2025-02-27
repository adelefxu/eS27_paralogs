# adapted from a script originally written by Gerald Tiu

# install.packages("ggplot2")
# install.packages("reshape2")
# install.packages("knitr")
# install.packages("devtools")
# install_github("ggbiplot", "vqv")
# install.packages('ggfortify')
# install.packages("tidyverse")
# source("https://bioconductor.org/biocLite.R")
# biocLite("edgeR")
# install.packages("RColorBrewer")
# install.packages("gplots")

require("ggplot2")
require("reshape2")
require("knitr")
require("devtools")
require("ggbiplot")
library("ggfortify")
require("dplyr")
require("edgeR")
require("RColorBrewer")
require("gplots")

# Change directory to appropriate directory
directory <- "/Users/adelexu/Box Sync/Adele's Externally Shareable Files/Sync/ribosome_profiling/191217_start_distance/"
files <- list.files(path=directory, pattern="*_distance.txt", full.names=T, recursive=FALSE)

for(file in files){
  base <- basename(file)
  name <- tools::file_path_sans_ext(base)
  output <- paste(name, "plot", sep="_")
  
  distance_df <- read.table(file, sep="\t", stringsAsFactor=FALSE, header=FALSE, quote="", comment.char="")
  colnames(distance_df) <- c("read_length", "position", "UTR_col", "UTR_readcount", "CDS_col", "CDS_readcount")
  
  distance_df_UTR <- distance_df[c("read_length", "position", "UTR_readcount")]
  distance_df_CDS <- distance_df[c("read_length", "position", "CDS_readcount")]
  
  for(i in 25:38){
    df_UTR_temp <- distance_df_UTR[distance_df_UTR$read_length==i,]
    output_temp = paste(output, "UTR", i, sep="_")
    
    p <- ggplot(df_UTR_temp, aes(x=position, y=UTR_readcount))
    p <- p + geom_bar(stat="identity")
    p <- p + theme_bw()
    p <- p + ggtitle(output_temp) + theme(plot.title = element_text(size=6.5))
    output_path <- paste(directory, output_temp, sep="/")
    filename_full <- paste(output_path, "jpeg", sep=".")
    ggsave(filename_full, plot=p, device="jpeg")
    
    df_CDS_temp <- distance_df_CDS[distance_df_CDS$read_length==i,]
    output_temp = paste(output, "CDS", i, sep="_")
    
    p <- ggplot(df_CDS_temp, aes(x=position, y=CDS_readcount))
    p <- p + geom_bar(stat="identity")
    p <- p + theme_bw()
    p <- p + ggtitle(output_temp) + theme(plot.title = element_text(size=6.5))
    output_path <- paste(directory, output_temp, sep="/")
    filename_full <- paste(output_path, "jpeg", sep=".")
    ggsave(filename_full, plot=p, device="jpeg")
    
  }
}






