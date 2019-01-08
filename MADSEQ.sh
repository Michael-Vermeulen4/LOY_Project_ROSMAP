#!/bin/bash

### Script to run MADSEQ analyses using 1KG data
### Goal is to successful run the program and time
### how long the process takes for a high coverage bam
### and a low coverage sequenced bam

output=hg19.basic.500k.interval_list
gatk-launch PreprocessIntervals -R ~/data/ref/hg19_basic.fa --bin-length 500000 --interval-merging-rule OVERLAPPING_ONLY -O $output
t=$(cat ${output}  | grep '@' | wc -l)
p=$((t + 1))
tail -n +$p $output > ${output}.bed
SECONDS=0
#log=${output}







duration=$SECONDS >> $log

















