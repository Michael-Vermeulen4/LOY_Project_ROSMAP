#!/usr/bin/env Rscript

library(dplyr)
library(magrittr)

args = commandArgs(trailingOnly=TRUE)
output="/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/mosaic/chr1"

args[1] -> i
message(i)

message("loading signal files")
#list.files(path="/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/output", pattern="*.txt", full.names= TRUE) -> signal_files


read.delim(file="/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib/CD_GenomeWideSNP_6_rev3/Full/GenomeWideSNP_6/LibFiles/GenomeWideSNP_6.Full.specialSNPs_PAR",header=FALSE) -> PAR
PAR$V1 -> par_snps


  basename(i) -> base
  dirname(i) -> directory
  gsub(pattern = "_geno_signal.txt", replacement = "",x = base) -> s
  message("loading ",s)
  
  
  # read in file
  read.delim(file=i,header=TRUE,sep = "\t") -> sig
  message("loading complete ",s)
  
  # remove CN probes 
  subset(sig, grepl(x = sig$Name, pattern = "^SNP",perl = TRUE)) -> sig
  
  # removes the -AB genotype that is produced from the previous script, into NN 
  
  gsub(pattern = "-AB",replacement = "NN",x = sig$GType) -> x 
  sig$GType <- x 
  
  # MAD algorithm calculations 
  
  subset(sig, sig$GType=="AA") -> AA
  subset(sig, sig$GType=="AB") -> AB
  subset(sig, sig$GType=="BB") -> BB
  subset(sig, sig$GType=="NN") -> NN
  
  # BDev homo = min(BAF,1-BAF)
  # BDev het = abs(BAF-0.5)
  # fraction = 2Bdev/(0.5+Bdev)
  
  min_abs <- function(a) {
    min(a,1-a) -> x 
    return(x)
  }
  
  Bdev_het <- function(a) {
    abs(a-0.5) -> x 
    return(x)
  }

  lapply(AA$B.Allele.Freq,function(x) min_abs(x)) -> k
  unlist(k) -> k
  AA$Bdev <- k
  
  lapply(BB$B.Allele.Freq,function(x) min_abs(x)) -> k
  unlist(k) -> k
  BB$Bdev <- k
  
  lapply(AB$B.Allele.Freq,function(x) Bdev_het(x)) -> k
  unlist(k) -> k
  AB$Bdev <- k
  
  lapply(NN$B.Allele.Freq,function(x) min_abs(x)) -> k
  unlist(k) -> k
  NN$Bdev <- k
  
  rbind(AA,BB,AB,NN) -> sig
  
  #subset(sig, sig$Name %in% par_snps) -> sig
  subset(sig, sig$Chr==1) -> sig
  #subset(sig, (sig$Position>10001 & sig$Position<2649520) | (sig$Position>59034050 & sig$Position<59363566)) -> x 
  
  fraction <- function(a) {
  (2*a)/(0.5+a) -> xq
    return(x)
  }
  
  
  
  lapply(sig$Bdev,function(x) fraction(x)) -> k
  unlist(k) -> k
  sig$fraction <- k
  sig %>% as.data.frame() -> sig
  paste0(output,"/",s,".Bdev.txt") -> o
  write.table(file = o, x = sig,quote = FALSE, sep = "\t", row.names = FALSE)
