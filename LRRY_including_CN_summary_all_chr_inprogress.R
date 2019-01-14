#!/usr/bin/env Rscript

library(dplyr)
library(magrittr)
library(rlist)
library(data.table)

#args = commandArgs(trailingOnly=TRUE)
input <- "/zfs3/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/output"
par_snps <- "/zfs3/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/PAR_snp_ids"
cn_probes_in_par_ids <- "/zfs3/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/cn_probes_in_par_ids"

read.delim(file=par_snps,header=FALSE) -> par_snps
read.delim(file=cn_probes_in_par_ids,header=FALSE) -> cn_probes_in_par_ids

#args[1] -> input
#args[2] -> chr
list.files(path = input,full.names = TRUE, pattern = "*.txt") -> files

#files <- files[c(1,2,3,4)]
#message("loading bdev files")


#f_mean <- as.data.frame(matrix(nrow=length(files),ncol = 2))
#bdev_mean <- as.data.frame(matrix(nrow=length(files),ncol = 2))

vector() -> a
vector() -> b
vector() -> sample
list() -> sum




for(i in files) {
  
  tables <- list()
  basename(i) -> base
  dirname(i) -> directory
  gsub(pattern = "_geno_signal.txt", replacement = "",x = base) -> s
  message("loading ",s)
  fread(file=i, header = TRUE) -> f
  
  # remove cn probes that fall in PAR1 of Y 
  subset(f, !(f$Name %in% cn_probes_in_par_ids$V1)) -> f 
  
  subset(f, grepl(pattern="SNP",x=f$Name,perl=TRUE)) -> snps
  subset(f, grepl(pattern="^CN",x=f$Name,perl=TRUE)) -> cn
  
  subset(f, f$Name %in% par_snps$V1) -> par
  
  # DONT NEED THIS CODE CHUNK RIGHT NOW BECAUSE I REMOVE THE PAR SNPS IN THE LOOP BELOW
  # remove par probes from the snps and cn data sets
  # the f dataframe includes both cn and snp probes 
  #subset(snps, !(snps$Name %in% par_snps$V1)) -> snps
  #subset(cn, !(cn$Name %in% par_snps$V1)) -> cn
  #subset(f, !(f$Name %in% par_snps$V1)) -> f 
  
  # Y is effectively MSY as there are no probes located in the PAR region that are labelled Y 
  
  # will produce 4 matrices
  # snps - only snp probe mLRR for autosomes, X (no par), Y, PAR
  # cn - only cn probe mLRR for autosomes, X (no par), Y, PAR
  # f - both cn and snp mLRR for autosomes, X (no par), Y, PAR
  # par - mLRR for PAR snps only

    for(j in c(1:22,"X","Y","PAR")){
      if(j=="PAR"){
        paste0(j," region") -> name
        subset(f, f$Name %in% par_snps$V1) -> tmp
        message(name)
        list.append(tables, tmp) -> tables
        next
      } # end of if 
      
      # code chunk removes the PAR snps from the X 
      if(j=="X"){
        paste0("chr",j) -> name
        message(name)
        subset(f, f$Chr==j) -> tmp
        subset(tmp, !(tmp$Name %in% par_snps$V1)) -> tmp
        list.append(tables, tmp) -> tables
        next
      } # end of if 
      
      paste0("chr",j) -> name
      subset(f, f$Chr==j) -> tmp
      message(name)
      #assign(name, paste0("chr",j)) -> x 
      list.append(tables, tmp) -> tables
    } # end of for 
    
    paste("hey")
    names(tables) <- c(1:22,"X","Y","PAR")
    
    
    vector() -> logr
    for(k in names(tables)){
      f <- tables[[k]]
      median(f$Log.R.Ratio) -> Log.R.Ratio
      logr <- c(logr,Log.R.Ratio)
    } # end of for

    #median(f$Log.R.Ratio) -> Log.R.Ratio
    #a <- c(a,Log.R.Ratio)
    #
    #median(f$B.Allele.Freq) -> B.Allele.Freq
    #b <- c(b,B.Allele.Freq)
    #
    lapply(c(1:22,"X","Y","PAR"), function(x){paste0("chr",x)}) -> chrs
    unlist(chrs) -> chrs
    names(logr) <- chrs
    
    list.append(sum, logr) -> sum
    
    sample <- c(sample,s)
  
} # end of for 

  
names(sum) <- sample
do.call(rbind, sum) -> output
output %>% as.data.frame() -> output

write.table(file="/zfs3/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/mLRR_CN_SNP_JAN9.txt", x = output, quote=FALSE, row.names=TRUE, sep="\t")


#summary <- sample
#summary %>% as.data.frame() -> summary
#summary$Log.R.Ratio <- a 
#summary$B.Allele.Freq <- b
#names(summary)[1] <- "sample"
 

  
  

  
