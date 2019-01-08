#!/usr/bin/env Rscript


library(dplyr)
library(magrittr)
args = commandArgs(trailingOnly=TRUE)
output="/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/output"


args[1] -> i
message(i)g 
# cat birdseed.call.txt | grep -Pv '^#' > t; mv t birdseed.call.txt 
# read in birdseed.calls 
message("loading birdseed calls")
#read.delim(file="birdseed.calls.txt",header=TRUE) -> calls
readRDS(file="/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/bird.RDS") -> calls
message("loading birdseed calls: complete")
names(calls) -> calls_samples
gsub(pattern=".cel",replacement="",x=calls_samples) -> t 
names(calls) <- t 
calls %>% as.data.frame() -> calls



# read in signal files for each sample 

#list.files(path="/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/kcolumn", pattern="gw6.*", full.names= TRUE) -> signal_files


  basename(i) -> base
  dirname(i) -> directory
  gsub(pattern = "gw6.", replacement = "",x = base) -> s
  message("loading ",s)
  read.delim(file=i, header=TRUE, sep="\t") -> signal
  message("loading complete!")
  
  message("merging signal and genotype files.")
  names(calls) -> samples
  grep(pattern = s, x = samples) -> index
  genotypes <- calls[,c(1,index)]
  
  cbind(genotypes[match(signal$Name,genotypes$probeset_id),],signal) -> t
  t[,c(-1)] -> t 
  t[,c(2:ncol(t),1)] -> t 
  names(t)[6] <- "GT"
  gsub(pattern="0",replacement="AA",t$GT) -> k
  gsub(pattern="1",replacement="AB",k) -> k
  gsub(pattern="2",replacement="BB",k) -> k
  gsub(pattern="-1",replacement="NN",k) -> k
  gsub(pattern="-AB",replacement="NN",k) -> t$GT
  names(t) <- c("Name","Chr","Position","Log.R.Ratio","B.Allele.Freq","GType")
  
  
  write.table(x = t, file = paste(output,"/",s,"_geno_signal.txt",sep = ""),quote = FALSE,row.names=FALSE,sep="\t")
  message(s, " complete")
  
