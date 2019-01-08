#!/usr/bin/env Rscript

library(dplyr)
library(magrittr)
library(rlist)
#args = commandArgs(trailingOnly=TRUE)
input="/zfs3/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/output"

#args[1] -> input
#args[2] -> chr
list.files(path = input,full.names = TRUE, pattern = "*.txt") -> files

#files <- files[c(1,2)]
#message("loading bdev files")


#f_mean <- as.data.frame(matrix(nrow=length(files),ncol = 2))
#bdev_mean <- as.data.frame(matrix(nrow=length(files),ncol = 2))

vector() -> a
vector() -> b
vector() -> sample
list() -> sum



for(i in files) {
  
  basename(i) -> base
  dirname(i) -> directory
  gsub(pattern = "_geno_signal.txt", replacement = "",x = base) -> s
  message("loading ",s)
  
  read.delim(file=i, header = TRUE) -> f
  list() -> v 
  list() -> tables
  for(j in c(1:22,"X","Y")){
    paste0("chr",j) -> name
    subset(f, f$Chr==j) -> tmp
    message(name)
    #assign(name, paste0("chr",j)) -> x 
    list.append(tables, tmp) -> tables
   
  }
  names(tables) <- c(1:22,"X","Y")
  
  vector() -> logr
  for(k in names(tables)){
    f <- tables[[k]]
    median(f$Log.R.Ratio) -> Log.R.Ratio
    logr <- c(logr,Log.R.Ratio)
  }
  #median(f$Log.R.Ratio) -> Log.R.Ratio
  #a <- c(a,Log.R.Ratio)
  #
  #median(f$B.Allele.Freq) -> B.Allele.Freq
  #b <- c(b,B.Allele.Freq)
  #
  lapply(c(1:22,"X","Y"), function(x){paste0("chr",x)}) -> chrs
  unlist(chrs) -> chrs
  names(logr) <- chrs
  
  list.append(sum, logr) -> sum
  
  sample <- c(sample,s)
}

names(sum) <- sample
do.call(rbind, sum) -> output
output %>% as.data.frame() -> output



#summary <- sample
#summary %>% as.data.frame() -> summary
#summary$Log.R.Ratio <- a 
#summary$B.Allele.Freq <- b
#names(summary)[1] <- "sample"
 
  
  
write.table(file="/zfs3/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/MLRRY_including_CN.txt", x = output, quote=FALSE, row.names=TRUE, sep="\t")
  
