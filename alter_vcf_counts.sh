# in bash 

bcftools view /zfs/scratch/michael.vermeulen/tmp/NA18519.Y.50.filtered.vcf.gz X:60001-2699271 | grep 'PASS' | cut -f1,2,3,4,5,6,7,8,9,10 | grep -P '\t0/1' | cut -f1,2,3,4,5,6,7,8,9 > template.txt
bcftools view /zfs/scratch/michael.vermeulen/tmp/NA18519.Y.50.filtered.vcf.gz X:60001-2699271 | grep 'PASS' | cut -f10 | grep -P '^0/1' > gt.txt
bcftools view -h NA18519.Y.75.filtered.vcf.gz > header.txt

## in R
# set file.p to gt.txt

source("/zfs/scratch/michael.vermeulen/tmp/OCT29_EDIT_AF/edit_genotypes.R")

file.p="gt.txt"



for(i in c(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,0.95,0.97,1)){
  o <- paste("Y",i,".txt",sep="")
  mutate_GT(file.p,i,o)
  
}

## produces vectors containing updated, mutated (downsampled) AD and AP fields
## in bash

paste -d"\t" template.txt Y1.txt > NA18519.PAR1.Y100.filtered.vcf
paste -d"\t" template.txt Y0.97.txt > NA18519.PAR1.Y97.filtered.vcf
paste -d"\t" template.txt Y0.95.txt > NA18519.PAR1.Y95.filtered.vcf
paste -d"\t" template.txt Y0.9.txt > NA18519.PAR1.Y90.filtered.vcf
paste -d"\t" template.txt Y0.8.txt > NA18519.PAR1.Y80.filtered.vcf
paste -d"\t" template.txt Y0.7.txt > NA18519.PAR1.Y70.filtered.vcf
paste -d"\t" template.txt Y0.6.txt > NA18519.PAR1.Y60.filtered.vcf
paste -d"\t" template.txt Y0.5.txt > NA18519.PAR1.Y50.filtered.vcf
paste -d"\t" template.txt Y0.4.txt > NA18519.PAR1.Y40.filtered.vcf
paste -d"\t" template.txt Y0.3.txt > NA18519.PAR1.Y30.filtered.vcf
paste -d"\t" template.txt Y0.2.txt > NA18519.PAR1.Y20.filtered.vcf
paste -d"\t" template.txt Y0.1.txt > NA18519.PAR1.Y10.filtered.vcf

for i in 100 97 95 90 80 70 60 50 40 30 20 10; do
    cat header.txt NA18519.PAR1.Y${i}.filtered.vcf | bgzip > NA18519.PAR1.Y${i}.filtered.vcf.gz
    tabix -p vcf NA18519.PAR1.Y${i}.filtered.vcf.gz
done


## NOW EXTRACT THE PAR1 FROM THE FULL VCF
## bcftools concat

bcftools view /zfs/scratch/michael.vermeulen/tmp/NA18519.Y.50.filtered.vcf.gz X:1-60001,X:2699271-155259521 | grep 'PASS'  > nonPAR_chrX.vcf
cat header.txt nonPAR_chrX.vcf | bgzip > nonPAR_chrX.vcf.gz 
tabix -p vcf nonPAR_chrX.vcf.gz 

bcftools view /zfs/scratch/michael.vermeulen/tmp/NA18519.Y.50.filtered.vcf.gz 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 Y | grep 'PASS' > everything_else.vcf
cat header.txt everything_else.vcf | bgzip > everything_else.vcf.gz
tabix -p vcf everything_else.vcf.gz

bcftools concat -d "none" -a NA18519.PAR1.Y50.filtered.vcf.gz everything_else.vcf.gz nonPAR_chrX.vcf.gz | bgzip > artificially_downsample_chrY_PAR1.50.vcf.gz









