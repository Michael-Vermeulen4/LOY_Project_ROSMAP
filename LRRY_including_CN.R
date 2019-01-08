#!/usr/bin/env Rscript

library(dplyr)
library(magrittr)

args = commandArgs(trailingOnly=TRUE)
output="/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/output/CN"

args[1] -> i
message(i)

message("loading signal files")
#list.files(path="/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/output", pattern="*.txt", full.names= TRUE) -> signal_files


#read.delim(file="",header=FALSE) -> MSY
#MSY$V1 -> par_snps


basename(i) -> base
dirname(i) -> directory
gsub(pattern = "_geno_signal.txt", replacement = "",x = base) -> s
message("loading ",s)


# read in file
read.delim(file=i,header=TRUE,sep = "\t") -> sig
message("loading complete ",s)

# filter for MSY probes
#subset(sig, grepl(x = sig$Name, pattern = "^SNP",perl = TRUE)) -> sig

# removes the -AB genotype that is produced from the previous script, into NN 

gsub(pattern = "-AB",replacement = "NN",x = sig$GType) -> x 
sig$GType <- x 


#subset(sig, sig$Name %in% par_snps) -> sig
#subset(sig, sig$Chr==chr) -> sig
#subset(sig, (sig$Position>10001 & sig$Position<2649520) | (sig$Position>59034050 & sig$Position<59363566)) -> x 

sig %>% as.data.frame() -> sig
paste0(output,"/",s,".mLRRY_with_CN_probes.txt") -> o
write.table(file = o, x = sig,quote = FALSE, sep = "\t", row.names = FALSE)
