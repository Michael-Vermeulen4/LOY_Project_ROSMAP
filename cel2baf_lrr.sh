#mkdir /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/
#mkdir /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib
#mkdir /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt
#mkdir /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/mkdir 
#mkdir /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt

### QC first 

## use the celfiles that passed QC to run the apt-geno-probeset

## remove the following CEL files 
# CANTYG06
# BROOSA05
# BEERYF05
# BROOSH01
# CANTYB08
# ENSKYF04
# TRETSD02
# CANTYB05
# TRETSD05
# CLANSG03
# SEINED03

/zfs/users/michael.vermeulen/programs/apt-2.10.2-x86_64-intel-linux/bin/apt-geno-qc \
-c /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib/CD_GenomeWideSNP_6_rev3/Full/GenomeWideSNP_6/LibFiles/GenomeWideSNP_6.Full.cdf \
-a /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib/CD_GenomeWideSNP_6_rev3/Full/GenomeWideSNP_6/LibFiles/GenomeWideSNP_6.r2.qca \
-q /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib/CD_GenomeWideSNP_6_rev3/Full/GenomeWideSNP_6/LibFiles/GenomeWideSNP_6.r2.qcc \
--chrX-probes /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib/CD_GenomeWideSNP_6_rev3/Full/GenomeWideSNP_6/LibFiles/GenomeWideSNP_6.chrXprobes \
--chrY-probes /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib/CD_GenomeWideSNP_6_rev3/Full/GenomeWideSNP_6/LibFiles/GenomeWideSNP_6.chrYprobes \
--cel-files /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/Broad/CEL_FILES_NOV21.txt \
-out-file /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/QC_results.txt 


# Step 1. Generate the signal intensity data based on raw CEL files

# full paths of all cel files in the BROAD directory were piped into /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/Broad/CEL_FILES_NOV21.txt
## substep 1.1-Generate genotyping calls from CEL files

/zfs/users/michael.vermeulen/programs/apt-2.10.2-x86_64-intel-linux/bin/apt-probeset-genotype \
-c /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib/CD_GenomeWideSNP_6_rev3/Full/GenomeWideSNP_6/LibFiles/GenomeWideSNP_6.Full.cdf \
-a birdseed \
--read-models-birdseed /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib/CD_GenomeWideSNP_6_rev3/Full/GenomeWideSNP_6/LibFiles/GenomeWideSNP_6.birdseed.models \
--special-snps /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib/CD_GenomeWideSNP_6_rev3/Full/GenomeWideSNP_6/LibFiles/GenomeWideSNP_6.Full.specialSNPs \
--chrX-probes /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib/CD_GenomeWideSNP_6_rev3/Full/GenomeWideSNP_6/LibFiles/GenomeWideSNP_6.chrXprobes \
--chrY-probes /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib/CD_GenomeWideSNP_6_rev3/Full/GenomeWideSNP_6/LibFiles/GenomeWideSNP_6.chrYprobes \
--summaries \
--write-models \
--cel-files /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/Broad/CEL_FILES_NOV21.txt \
--out-dir /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt


## substep 1.2 - Allele-specific signal extraction from CEL files

/zfs/users/michael.vermeulen/programs/apt-2.10.2-x86_64-intel-linux/bin/apt-probeset-summarize \
--cdf-file /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib/CD_GenomeWideSNP_6_rev3/Full/GenomeWideSNP_6/LibFiles/GenomeWideSNP_6.Full.cdf \
--analysis quant-norm.sketch=50000,pm-only,med-polish,expr.genotype=true \
--target-sketch /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib/hapmap.quant-norm.normalization-target.txt \
--out-dir /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt \
--cel-files /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/Broad/CEL_FILES_NOV21.txt

# using ROSMAP metadata to create a file with each ID [tab] sex(0-1)
# msex column from phenotypes.mat was used and projIDs were mapped to celIDS into the file /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/LOY_CEL_SEX.txt

## substep 1.3 Generate canonical genotype clustering file

/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/bin/generate_affy_geno_cluster.pl \
/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/birdseed.calls.txt \
/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/birdseed.confidences.txt \
/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/quant-norm.pm-only.med-polish.expr.summary.txt \
--confidence 0.05 \
-locfile /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib/affygw6.hg19.pfb \
-sexfile /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC5_apt/LOY_CEL_SEX.txt \
-out /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/conf_0.05/gw6.genocluster


#/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/bin/generate_affy_geno_cluster.pl \
#/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/birdseed.calls.txt \
#/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/birdseed.confidences.txt \
#/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/quant-norm.pm-o~nly.med-polish.expr.summary.txt \
#-locfile /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib/affygw6.hg19.pfb \
#-sexfile /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib/file_sex \
#-out /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/gw6.genocluster

## substep 1.4 LRR and BAF calculation

/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/bin/normalize_affy_geno_cluster.pl \
/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/gw6.genocluster \
/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/quant-norm.pm-only.med-polish.expr.summary.txt \
-locfile /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib/affygw6.hg19.pfb \
-out /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/gw6.lrr_baf.txt

## split files 
# Name | Chr | Position | Log R Ratio | B Allele Freq

/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/lib/penncnv/kcolumn.pl \
/zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/gw6.lrr_baf.txt \
split 2 -tab -head 3 -name -out /zfs/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/kcolumn/gw6 \


## convert birdseed calls into PLINK 

# wget http://www.bioinf.wits.ac.za/h3a/scripts/phase1-apt/pedfilemaker.pl

# 1. make the ped file for PLINK 



perl ~/tut/plink/pedfilemaker.pl -affy_calls /zfs3/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/birdseed.calls.txt \
-report /zfs3/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/birdseed.report.txt \
-annot /zfs3/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/GenomeWideSNP_6.na35.annot.csv \
-o /zfs3/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt

cut -f1-4 /zfs3/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/mapfile.map > /zfs3/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/h3data.map

cp /zfs3/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/pedfile.ped /zfs3/scratch/saram_lab/ROSMAP_CEL/ROSMAP_Cel/gw6/apt/DEC6_apt/h3data.ped


####################### QC ##############################
## download https://github.com/MareesAT/GWA_tutorial/blob/master/1_QC_GWAS.zip

# 1. sex determination check 
plink --file h3data --check-sex --out sexcheck --noweb

# generate plots to visualize the sex-check results 
Rscript --no-save gender_check.R

## CLANSA08 CANTYE12 TROCKE07       PROBLEM WITH SEX 
## make remove file of columns 1 and 2 in sexcheck.sexcheck called remove.txt

plink --file h3data \
--remove remove.txt \
--make-bed \
--out h3data_clean

# generate plots to visualize the missingness results
plink --bfile h3data_clean --missing
Rscript --no-save hist_miss.R

# remove subjects with more than 2% missing genotypes 
plink --bfile h3data_clean --mind 0.02 --make-bed --out h3data_clean

# remove SNPs with high rate of missing genotype calls 
plink --bfile h3data_clean --geno 0.05 --make-bed --out h3data_clean


# remove files deviating from HWE
plink --bfile h3data_clean --hardy
awk '{ if ($9 <0.0001) print $0 }' plink.hwe>plinkzoomhwe.hwe
Rscript --no-save hwe.R
plink --bfile h3data_clean --hwe 0.001 include-nonctrl --out h3data_clean

# setting minor allele frequency 
awk '{ if ($1 >= 1 && $1 <= 22) print $2 }' h3data_clean.bim > snp_1_22.txt
awk '{ if ($1 >= 23 && $1 <= 26) print $2 }' h3data_clean.bim > snpXY.txt
plink --bfile h3data_clean --extract snp_1_22.txt --make-bed --out h3data_clean_1_22
plink --bfile h3data_clean --extract snpXY.txt --make-bed --out h3data_clean_XY

plink --bfile h3data_clean_1_22 --freq --out MAF_check
Rscript --no-save MAF_check.R

plink --bfile h3data_clean_1_22 --maf 0.01 --make-bed --out h3data_clean_1_22
plink --bfile h3data_clean_1_22 --bmerge h3data_clean_XY --make-bed --out h3data_clean

plink --bfile h3data_clean_1_22 --exclude h3data_clean-merge.missnp --make-bed --out h3data_clean_1_22
plink --bfile h3data_clean_XY --exclude h3data_clean-merge.missnp --make-bed --out h3data_clean_XY

plink --bfile h3data_clean_1_22 --bmerge h3data_clean_XY --make-bed --out h3data_clean


# misshap test 
plink --bfile h3data_clean --test-mishap
awk '{ if ($8 < 1E-9) print $1 }' plink.missing.hap > exclude.misshap.txt

plink --bfile h3data_clean --exclude exclude.misshap.txt --make-bed --out h3data_clean


