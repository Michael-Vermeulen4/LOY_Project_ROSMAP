#!/bin/bash

## DOWNSAMPLE CHROMOSOME IN BAM

## GOAL: SCRIPT SHOULD INPUT A BAM FILE (WGS) AND OUTPUT THE SAME BAM
##       WITH A DOWNSAMPLED CHROMOSOME OF CHOICE.
##
##       THIS WILL BE USED TO SIMULATE ANEUPLOIDY AND WILL BE USED WITH MADSEQ
##       TO OBSERVE HOW THE MADSEQ ALGORITHM DEALS WITH NULLSOMY Y.

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "downsample_chr.sh | input_bam | chr_to_downsample | output_dir | filename_output | picard_jar_path"
    exit
fi

bam=$1
chr=$2
output=$3
filename=$4
picard=$5


out=${output}/${filename}
log=${output}/chr${chr}.downsample.log
# extract the chrom of choice using samtools view

touch ${output}/tmp.bam

echo "BEGINNING PROCESS" | tee $log
echo "EXTRACTING chr${chr}" | tee $log 
samtools view -b $bam $chr > ${output}/tmp.bam || { echo 'samtools view failed' | tee -a $log ; exit 1; } 

echo "INDEXING chr${chr} bam" | tee $log
samtools index ${output}/tmp.bam

echo "DOWNSAMPLING chr${chr} to 0.97" | tee $log
# downsample the extracted chrom
samtools view -b -s 0.97 ${output}/tmp.bam > ${output}/chr${chr}.97.bam || { echo 'samtools view downsample failed' | tee -a $log ; exit 1; }

echo "DOWNSAMPLING chr${chr} to 0.95" | tee $log
# downsample the extracted chrom
samtools view -b -s 0.95 ${output}/tmp.bam > ${output}/chr${chr}.95.bam || { echo 'samtools view downsample failed' | tee -a $log ; exit 1; }

echo "DOWNSAMPLING chr${chr} to 0.90" | tee $log
# downsample the extracted chrom
samtools view -b -s 0.90 ${output}/tmp.bam > ${output}/chr${chr}.90.bam || { echo 'samtools view downsample failed' | tee -a $log ; exit 1; }

echo "DOWNSAMPLING chr${chr} to 0.75" | tee $log
# downsample the extracted chrom
samtools view -b -s 0.75 ${output}/tmp.bam > ${output}/chr${chr}.75.bam || { echo 'samtools view downsample failed' | tee -a $log ; exit 1; } 

echo "DOWNSAMPLING chr${chr} to 0.50" | tee $log
samtools view -b -s 0.5 ${output}/tmp.bam > ${output}/chr${chr}.50.bam || { echo 'samtools view downsample failed' | tee -a $log ; exit 1; } 

echo "DOWNSAMPLING chr${chr} to 0.25" | tee $log
samtools view -b -s 0.25 ${output}/tmp.bam > ${output}/chr${chr}.25.bam || { echo 'samtools view downsample failed' | tee -a $log ; exit 1; } 

echo "DOWNSAMPLING chr${chr} to 0.1" | tee $log
samtools view -b -s 0.10 ${output}/tmp.bam > ${output}/chr${chr}.10.bam || { echo 'samtools view downsample failed' | tee -a $log ; exit 1; } 

# extract the remaining chromosomes from the BAM file (except the downsampled one)
CHROM=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y)
DELETE=($chr)

CHROM=( "${CHROM[@]/$DELETE}" )
rem="${CHROM[@]}"

echo "EXTRACTING THE REMAINING CHROMOSOMES" | tee $log
samtools view -b $bam $rem > ${output}/everything_but.bam || { echo 'samtools view #2 failed' | tee -a $log ; exit 1; }

# merge bam files (VALIDATION_STRINGENCY=LENIENT)

picard=~/../bin/picard.jar
filename=NA18519
output=/zfs/scratch/saram_lab/1K_Genomes/b37_bam/LOY_tmp/
chr=Y
log=${output}/chr${chr}.downsample.log

echo "MERGING FILES" | tee $log
java -Xmx30g -jar $picard MergeSamFiles I=${output}/everything_but.bam VALIDATION_STRINGENCY=LENIENT \
I=${output}/chr${chr}.97.bam USE_THREADING=TRUE O=${output}/${filename}.${chr}.97.bam || { echo 'Merge Sam 1 failed' | tee -a $log ; exit 1; }

echo "MERGING FILES" | tee $log
java -Xmx30g -jar $picard MergeSamFiles I=${output}/everything_but.bam VALIDATION_STRINGENCY=LENIENT \
I=${output}/chr${chr}.95.bam USE_THREADING=TRUE O=${output}/${filename}.${chr}.95.bam || { echo 'Merge Sam 2 failed' | tee -a $log ; exit 1; }

echo "MERGING FILES" | tee $log
java -Xmx30g -jar $picard MergeSamFiles I=${output}/everything_but.bam VALIDATION_STRINGENCY=LENIENT \
I=${output}/chr${chr}.90.bam USE_THREADING=TRUE O=${output}/${filename}.${chr}.90.bam || { echo 'Merge Sam 3 failed' | tee -a $log ; exit 1; }

echo "MERGING FILES" | tee $log
java -Xmx30g -jar $picard MergeSamFiles I=${output}/everything_but.bam VALIDATION_STRINGENCY=LENIENT \
I=${output}/chr${chr}.75.bam USE_THREADING=TRUE O=${output}/${filename}.${chr}.75.bam || { echo 'Merge Sam 4 failed' | tee -a $log ; exit 1; }

echo "MERGING FILES" | tee $log
java -Xmx30g -jar $picard MergeSamFiles I=${output}/everything_but.bam VALIDATION_STRINGENCY=LENIENT \
I=${output}/chr${chr}.50.bam USE_THREADING=TRUE O=${output}/${filename}.${chr}.50.bam || { echo 'Merge Sam 5 failed' | tee -a $log ; exit 1; }

echo "MERGING FILES" | tee $log
java -Xmx30g -jar $picard MergeSamFiles I=${output}/everything_but.bam VALIDATION_STRINGENCY=LENIENT \
I=${output}/chr${chr}.25.bam USE_THREADING=TRUE O=${output}/${filename}.${chr}.25.bam || { echo 'Merge Sam 6 failed' | tee -a $log ; exit 1; }
 
 echo "MERGING FILES" | tee $log
java -Xmx30g -jar $picard MergeSamFiles I=${output}/everything_but.bam VALIDATION_STRINGENCY=LENIENT \
I=${output}/chr${chr}.10.bam USE_THREADING=TRUE O=${output}/${filename}.${chr}.10.bam || { echo 'Merge Sam 7 failed' | tee -a $log ; exit 1; }

# clean
echo "CLEANUP" | tee $log
rm -f ${output}/tmp.bam
rm -f ${output}/chr${chr}.97.bam
rm -f ${output}/chr${chr}.95.bam
rm -f ${output}/chr${chr}.90.bam
rm -f ${output}/chr${chr}.75.bam
rm -f ${output}/chr${chr}.50.bam
rm -f ${output}/chr${chr}.25.bam
rm -f ${output}/chr${chr}.10.bam
rm -f ${output}/everything_but.bam

echo "COMPLETE" | tee $log
# run quality metrics 