#!/usr/bin/env Rscript

library(dplyr)
library(magrittr)
args = commandArgs(trailingOnly=TRUE)
input="/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/output"


args[1] -> chr
list.files(path = input,full.names = TRUE, pattern = "*.txt") -> files

#message("loading bdev files")


#f_mean <- as.data.frame(matrix(nrow=length(files),ncol = 2))
#bdev_mean <- as.data.frame(matrix(nrow=length(files),ncol = 2))

vector() -> a
vector() -> b
vector() -> sample



for(i in files) {
  
  basename(i) -> base
  dirname(i) -> directory
  gsub(pattern = ".mLRRY_with_CN_probes.txt", replacement = "",x = base) -> s
  message("loading ",s)
  
  read.delim(file=i, header = TRUE) -> f
  subset(f, f$Chr==chr) -> f 
  median(f$Log.R.Ratio) -> Log.R.Ratio
  a <- c(a,Log.R.Ratio)
  
  median(f$B.Allele.Freq) -> B.Allele.Freq
  b <- c(b,B.Allele.Freq)
  
  sample <- c(sample,s)
}

summary <- sample
summary %>% as.data.frame() -> summary
summary$Log.R.Ratio <- a 
summary$B.Allele.Freq <- b
names(summary)[1] <- "sample"
 
  
  
write.table(file="/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/MLRRY_including_CN_chr",chr,".txt", x = summary, quote=FALSE, row.names=FALSE, sep="\t")
  
