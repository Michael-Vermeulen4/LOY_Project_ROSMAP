#!/usr/bin/env Rscript

library(dplyr)
library(magrittr)

input="/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/mosaic/chr1"

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
  gsub(pattern = ".Bdev.txt", replacement = "",x = base) -> s
  message("loading ",s)
  
  read.delim(file=i, header = TRUE) -> f
  
  mean(f$fraction) -> frac_mean
  a <- c(a,frac_mean)
  
  mean(f$Bdev) -> bdev
  b <- c(b,bdev)
  
  sample <- c(sample,s)
}

summary <- sample
summary %>% as.data.frame() -> summary
summary$frac_mean <- a 
summary$Bdev <- b 
 
  
  
write.table(file="/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/Bdev_summary_table_chr1.txt", x = summary, quote=FALSE, row.names=FALSE, sep="\t")
  
