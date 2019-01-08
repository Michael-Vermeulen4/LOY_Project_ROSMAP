suppressMessages(library("MADSEQ"))

d="/zfs/users/michael.vermeulen/michael.vermeulen/LOY_projct/output/OCT29"

Y10_bam = "/zfs/scratch/saram_lab/1K_Genomes/b37_bam/LOY_tmp/NA18519.Y.10.bam"
Y25_bam = "/zfs/scratch/saram_lab/1K_Genomes/b37_bam/LOY_tmp/NA18519.Y.25.bam"
Y50_bam = "/zfs/scratch/saram_lab/1K_Genomes/b37_bam/LOY_tmp/NA18519.Y.50.bam"
Y75_bam = "/zfs/scratch/saram_lab/1K_Genomes/b37_bam/LOY_tmp/NA18519.Y.75.bam"
Y90_bam = "/zfs/scratch/saram_lab/1K_Genomes/b37_bam/LOY_tmp/NA18519.Y.10.bam"
Y95_bam = "/zfs/scratch/saram_lab/1K_Genomes/b37_bam/LOY_tmp/NA18519.Y.10.bam"
Y97_bam = "/zfs/scratch/saram_lab/1K_Genomes/b37_bam/LOY_tmp/NA18519.Y.10.bam"
normal_bam = "/zfs/scratch/saram_lab/1K_Genomes/b37_bam/NA18519.mapped.ILLUMINA.bwa.YRI.low_coverage.20130415.bam"

target = "/zfs/users/michael.vermeulen/michael.vermeulen/LOY_projct/data/hs37d5.500k.interval_list.20.21.22.X.Y.bed"

Y10_cov = prepareCoverageGC(target_bed=target, bam=Y10_bam, "hs37d5")
Y25_cov = prepareCoverageGC(target_bed=target, bam=Y25_bam, "hs37d5")
Y50_cov = prepareCoverageGC(target_bed=target, bam=Y50_bam, "hs37d5")
Y75_cov = prepareCoverageGC(target_bed=target, bam=Y75_bam, "hs37d5")
Y90_cov = prepareCoverageGC(target_bed=target, bam=Y90_bam, "hs37d5")
Y95_cov = prepareCoverageGC(target_bed=target, bam=Y95_bam, "hs37d5")
Y97_cov = prepareCoverageGC(target_bed=target, bam=Y97_bam, "hs37d5")
normal_cov = prepareCoverageGC(target_bed=target, bam=normal_bam, "hs37d5")



normalizeCoverage(Y10_cov,Y25_cov,Y50_cov,Y75_cov,Y90_cov,Y95_cov,Y97_cov,control=normal_cov,writeToFile=TRUE, destination=d,plot=TRUE)

Y50_vcf = "/zfs/scratch/michael.vermeulen/tmp/OCT29_EDIT_AF/OCT29_test2/artificially_downsample_chrY_PAR1.50.vcf.gz"
Y75_vcf = "/zfs/scratch/michael.vermeulen/tmp/OCT29_EDIT_AF/OCT29_test2/artificially_downsample_chrY_PAR1.70.vcf.gz"
Y25_vcf = ""
normal_vcf = ""
Y90_vcf = ""
Y95_vcf = ""
Y97_vcf = ""


prepareHetero(Y50_vcf, target, genome="hs37d5", writeToFile=TRUE, destination=d,plot = TRUE)
prepareHetero(Y75_vcf, target, genome="hs37d5", writeToFile=TRUE, destination=d,plot = TRUE)
prepareHetero(Y25_vcf, target, genome="hs37d5", writeToFile=TRUE, destination=d,plot = TRUE)
prepareHetero(normal_vcf, target, genome="hs37d5", writeToFile=TRUE, destination=d,plot = TRUE)
prepareHetero(Y90_vcf, target, genome="hs37d5", writeToFile=TRUE, destination=d,plot = TRUE)
prepareHetero(Y95_vcf, target, genome="hs37d5", writeToFile=TRUE, destination=d,plot = TRUE)
prepareHetero(Y97_vcf, target, genome="hs37d5", writeToFile=TRUE, destination=d,plot = TRUE)

PAR_Y70 = runMadSeq(hetero=Y75_vcf, coverage=Y75_cov, target_chr="X", nChain=1, nStep=1000, thinSteps=1, adapt=100, burnin=200)




