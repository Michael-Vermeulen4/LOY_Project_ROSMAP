## ---- echo = FALSE-------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")

## ----eval=FALSE----------------------------------------------------------
#  system.file("extdata","aneuploidy.bam",package="MADSEQ")
#  system.file("extdata","aneuploidy.vcf.gz",package="MADSEQ")

## ------------------------------------------------------------------------
## load the package
suppressMessages(library("MADSEQ"))

## get path to the location of example data
aneuploidy_bam = system.file("extdata","aneuploidy.bam",package="MADSEQ")
normal_bam = system.file("extdata","normal.bam",package="MADSEQ")
target = system.file("extdata","target.bed",package="MADSEQ")

## Note: for your own data, just specify the path to the location 
## of your file using character.

## prepare coverage and GC content for each targeted region
# aneuploidy sample
aneuploidy_cov = prepareCoverageGC(target_bed=target, 
                                    bam=aneuploidy_bam, 
                                    "hg19")

# normal sample
normal_cov = prepareCoverageGC(target_bed=target, 
                                bam=normal_bam, 
                                "hg19")

## view the first two rows of prepared coverage data (A GRanges Object)
aneuploidy_cov[1:2]

normal_cov[1:2]

## ------------------------------------------------------------------------
## normalize coverage data
## set plot=FALSE here because similar plot will show in the following example
normalizeCoverage(aneuploidy_cov,writeToFile=TRUE, destination=".",plot=FALSE)

## ------------------------------------------------------------------------
## normalize coverage data
aneuploidy_normed = normalizeCoverage(aneuploidy_cov,writeToFile=FALSE,
                                      plot=FALSE)

## a GRangesList object will be produced by the function, look at it by
names(aneuploidy_normed)
aneuploidy_normed[["aneuploidy_cov"]]

## ------------------------------------------------------------------------
## normalize coverage data
normalizeCoverage(aneuploidy_cov, normal_cov,
                  writeToFile =TRUE, destination = ".", plot=FALSE)

## ----fig.height=6, fig.width=6,fig.align='center'------------------------
## normalize coverage data
normed_without_control = normalizeCoverage(aneuploidy_cov, normal_cov, 
                                           writeToFile=FALSE, plot=TRUE)

## a GRangesList object will be produced by the function
length(normed_without_control)
names(normed_without_control)

## subsetting
normed_without_control[["aneuploidy_cov"]]
normed_without_control[["normal_cov"]]

## ------------------------------------------------------------------------
## normalize coverage data, normal_cov is the control sample
normalizeCoverage(aneuploidy_cov, control=normal_cov,
                  writeToFile=TRUE, destination = ".",plot=FALSE)

## ------------------------------------------------------------------------
normed_with_control = normalizeCoverage(aneuploidy_cov, control=normal_cov, 
                                        writeToFile =FALSE, plot=FALSE)

## a GRangesList object will be produced by the function
length(normed_without_control)
names(normed_with_control)

## ------------------------------------------------------------------------
## specify the path to vcf.gz file
aneuploidy_vcf = system.file("extdata","aneuploidy.vcf.gz",package="MADSEQ")

## target bed file specified before

## If you choose to write the output to file (recommended)
prepareHetero(aneuploidy_vcf, target, genome="hg19", 
              writeToFile=TRUE, destination=".",plot = FALSE)

## If you don't want to write output to file
aneuploidy_hetero = prepareHetero(aneuploidy_vcf, target,
                                  genome="hg19", writeToFile=FALSE,plot = FALSE)


## ----fig.height=4, fig.width=6,fig.align='center'------------------------
## specify the path to processed files
aneuploidy_hetero = "./aneuploidy.vcf.gz_filtered_heterozygous.txt"
aneuploidy_normed_cov = "./aneuploidy_cov_normed_depth.txt"

## run the model
aneuploidy_chr18 = runMadSeq(hetero=aneuploidy_hetero, 
                             coverage=aneuploidy_normed_cov, 
                             target_chr="chr18",
                             nChain=1, nStep=1000, thinSteps=1,
                             adapt=100,burnin=200)

## An MadSeq object will be returned
aneuploidy_chr18

## ----eval=FALSE----------------------------------------------------------
#  ## subset normalized coverage for aneuploidy sample from the GRangesList
#  ## returned by normalizeCoverage function
#  aneuploidy_normed_cov = normed_with_control[["aneuploidy_cov"]]
#  
#  ## run the model
#  aneuploidy_chr18 = runMadSeq(hetero=aneuploidy_hetero,
#                               coverage=aneuploidy_normed_cov,
#                               target_chr="chr18")
#  
#  ## An MadSeq object will be returned
#  aneuploidy_chr18

## ----echo=FALSE,warning=FALSE--------------------------------------------
BIC = c("[0,10]","(10,20]",">20")
evidence = c("Probably noisy data","Could be positive",
             "High confidence")
table = data.frame(BIC,evidence)
library(knitr)
kable(table,col.names =c("deltaBIC","Evidence against higher BIC") ,align="c")

## ---- fig.height=4, fig.width=6,fig.align='center'-----------------------
## plot the posterior distribution for all the parameters in selected model
plotMadSeq(aneuploidy_chr18)

## ---- fig.height=4, fig.width=4,fig.align='center'-----------------------
## plot the histogram for the estimated fraction of aneuploidy
plotFraction(aneuploidy_chr18, prob=0.95)

## ---- fig.height=4, fig.width=5,fig.align='center'-----------------------
## plot the distribution of AAF as estimated by the model
plotMixture(aneuploidy_chr18)

## ----echo=FALSE,warning=FALSE--------------------------------------------
parameters = c("f","m","mu[1]","mu[2]","mu[3] (LOH model)",
               "mu[3] (meiotic trisomy model)","mu[4]","kappa","p[1]","p[2]",
               "p[3]","p[4]","p[5]","m_cov","p_cov","r_cov")
explains = c("Fraction of mosaic aneuploidy",
             "The midpoint of the alternative allele frequency (AAF) for all heterozygous sites",
             "Mean AAF of mixture 1: the AAFs of this mixture shifted from midpoint to some higher values", 
             "Mean AAF of mixture 2: the AAFs of this mixture shifted from midpoint to some lower values",
             "Mean AAF of mixture 3: In LOH model, mu[3] indicates normal sites without loss of heterozygosity",
             "Mean AAF of mixture 3: In meiotic model, the AAFs of this mixture shifted from 0 to some higher value",
             "Mean AAF of mixture 4: the AAFs of this mixture shifted from 1 to some lower value (only in meiotic model)",
             "Indicate variance of the AAF mixtures: larger kappa means smaller variance",
             "Weight of mixture 1: indicate the proportion of heterozygous sites in the mixture 1",
             "Weight of mixture 2: indicate the proportion of heterozygous sites in the mixture 2",
             "Weight of mixture 3: indicate the proportion of heterozygous sites in the mixture 3 (only in LOH and meiotic model)",
             "Weight of mixture 4: indicate the proportion of heterozygous sites in the mixture 4 (only in meiotic model)",
             "Weight of outlier component: the AAF of 1% sites might not well behaved, so these sites are treated as noise.",
             "Mean coverage of all the sites from the chromosome, estimated from a negative binomial distribution",
             "Prob of the negative binomial distribution for the coverage",
             "Another parameter (r) for the negative binomial disbribution of the coverage, small r means large variance")
table = data.frame(parameters,explains)
kable(table,col.names =c("parameters","description") ,align="c")

