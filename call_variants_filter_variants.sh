#!/bin/bash

## FIND VARIANTS AND FILTER FROM BAM 

## GOAL: INPUT BAM FILE, OUTPUT FILTERED VARIANT LIST
##

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "call_variants_filter_variants.sh | input_bam | output_dir | reference_genome_path | dbsnp_file_path"
    exit
fi

bam=$1
output=$2
ref=$3
dbsnp=$4

tmp=${bam##*/}
sample=${tmp%.*}
rm -f tmp

log=${output}/${sample}.log
touch $log
##
## bam = bam file (indexed and sorted by coordinates)
## output = output dir for final vcfs
## reference = reference genome
## dbsnp = vcf from dbsnp detailing SNPS (eg. common_all_20180418.vcf.gz)

### 1. CALLING VARIANTS

gatk-launch HaplotypeCaller -R $ref \
    -I $bam \
    --dbsnp $dbsnp \
    -O ${output}/${sample}.raw.vcf \
    --output-mode EMIT_ALL_CONFIDENT_SITES | tee -a $log || { echo 'HaplotypeCaller failed' | tee -a $log ; exit 1; }

raw=${output}/${sample}.raw.vcf


### 2. FILTER FOR SNPS 

gatk-launch SelectVariants -R $ref \
  -V $raw \
  -select-type SNP \
  -O ${raw}.SNPS.vcf | tee -a $log  || { echo 'SelectVariants failed' | tee -a $log ; exit 1; }


### 3. HARD FILTER SNPS BASED ON 6 CRITERIA

gatk-launch VariantFiltration -R $ref \
  -V ${raw}.SNPS.vcf \
  --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" \
  --filter-name "my_snp_filter" \
  -O ${output}/${sample}.filtered.vcf | tee -a $log  || { echo 'VariantFiltration failed' | tee -a $log ; exit 1; }

bgzip -@ 4 ${output}/${sample}.filtered.vcf
tabix -p vcf ${output}/${sample}.filtered.vcf.gz

## CLEAN UP

rm -vf ${output}/${sample}.raw.vcf
rm -vf ${raw}.SNPS.vcf













