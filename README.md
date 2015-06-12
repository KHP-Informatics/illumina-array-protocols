# [illumina](http://www.illumina.com/)-array-protocols
** work in progress **  

**Protocols/scripts for processing illumina SNP arrays**  

**VERSION: v0.1**  

A set of scripts and protocols that we use to processing raw Illumina SNP array data.

- BWA Mapping of probe sequences  
- Genomestudio SOP (Manual Calling & QC)    
- Standard QC (PLINK, bash...) and re-calling No-Calls using zCall  

## The Team 
**Bioinformatics** - Hamel Patel, Amos Folarin & Stephen Newhouse  @ [bluecell.io]()   
**Lab** - Charles Curtis & Team @ [The IoPPN Genomics & Biomarker Core Facility](http://www.kcl.ac.uk/ioppn/depts/mrc/research/The-IoPPN-Genomics--Biomarker-Core-Facility.aspx)  

![illuminaCSPro](./figs/CSProLogo-new-Cropped-313x105.png)

## Illumina Downloads Resource
This links takes you to Illumina's download page, which provides access to product documentation and
manifests.

- [Illumina Downloads](http://support.illumina.com/downloads.html)

## BeadChips
These are the BeadChips we have experience in processing so far....

| BeadChips |
|-------|
|[HumanOmniExpress-24 v1.0 BeadChip](http://support.illumina.com/downloads/humanomniexpress-24-v1-0-product-files.html) | 
|[HumanOmniExpress-24 v1.1 BeadChip](http://support.illumina.com/downloads/humanomniexpress-24-v1-0-product-files.html)  |
|[HumanCoreExome-24 v1.0 BeadChip](http://support.illumina.com/downloads/humancoreexome-24-v1-0-product-files.html)  |
|[HumanOmniExpressExome-8 v1.1 BeadChip](http://support.illumina.com/downloads/humanomniexpressexome-8v1-1_product_files.html)   |
|[MEGA\_Consortium](link) (Early Access...)|
|[PsychArray-B.csv](link)|
|[humanexome-12v1_a.csv](link)|

## 1. BWA Mapping of Probe Sequences

Illumina SNP arrays include a lot of probes that map to multiple (>500) sites in the Genome.  

For each array we map the probe sequences to the relevant genome build using BWA (as indicated by Illumina manifests), and
identify probes that map 100% to multiple regions (>1 hit) of the genome.

These probes are either flagged for removal before re-calling, or depending on what the data looks likes in Genomestudio,
are zeroed at the Genomestudio stage before clustering.  

Those familiar with processing Illumina Arrays, will see that a lot of the probes we identify are :- 
   
- variants that are consitently poorly clustered   
- variants not called for a lot of samples  
- variants with more than 3 clusters (not to be confused with CNV)   
- variants that are always homozygous variants (no matter the population or number of samples)  

More details soon....including a few pics...

### Illumina Array Annotations

| BeadChips | Download Link | Fasta |
|-------|---------------|------|
|MEGA\_Consortium\_15063755_B2.csv | [download](https://s3-eu-west-1.amazonaws.com/illumina-probe-mappings/mega_array_annotations.txt.gz) |[fasta]()|
|HumanCoreExome\-24v1\-0\_A.csv |[download](https://s3-eu-west-1.amazonaws.com/illumina-probe-mappings/HumanCoreExome-24v1-0_A.csv) |[fasta]()|
|HumanOmniExpressExome\-8\-v1\-1\-C.csv | [download](https://s3-eu-west-1.amazonaws.com/illumina-probe-mappings/HumanOmniExpressExome-8-v1-1-C.csv) |[fasta]()|
| PsychArray-B.csv |[download](https://s3-eu-west-1.amazonaws.com/illumina-probe-mappings/)|[fasta]()|
| humanexome-12v1_a.csv |[download](https://s3-eu-west-1.amazonaws.com/illumina-probe-mappings/)|[fasta]()|
| XXX |[download]()|[fasta]()|

All data on Amazon S3 https://s3-eu-west-1.amazonaws.com/illumina-probe-mappings/  

### BWA Mapping Results 

**Running BWA**  
Using [NGSeasy](https://github.com/KHP-Informatics/ngseasy) Docker [compbio/ngseasy-bwa](https://registry.hub.docker.com/u/compbio/ngseasy-bwa/) image.

>Program: bwa (alignment via Burrows-Wheeler transformation)  
>Version: 0.7.12-r1039  
>Contact: Heng Li <lh3@sanger.ac.uk>  

```bash
###################################
## BWA > samblaster > samtools
#

array=""
refGenome=""

docker run \
-w /home/pipeman \
-e HOME=/home/pipeman \
-e USER=pipeman \
--user pipeman \
-i \
-t compbio/ngseasy-bwa:1.0 /bin/bash -c \
"bwa mem -t 32 -V -M -a ${refGenome} ${array}.fasta | \
samblaster --addMateTags --excludeDups | \
samtools sort -@ 32 -T temp_ -O sam -o ${array}.sam && \
samtools index ${array}.sam && \
rm ${array}.sam"
```

### Probe Lists  
These lists provide data on probe mappings. We provide Illumina Probe Id's along with the
number of time it maps to the genome. 

| BeadChips | Fasta | BAM | Good probes | Bad probes |
|-------|---------------|------|----|---|
|MEGA\_Consortium\_15063755_B2.csv | [Fasta]() |[BAM]()|
|HumanCoreExome\-24v1\-0\_A.csv | [Fasta]() |[BAM]()|
|HumanOmniExpressExome\-8\-v1\-1\-C.csv | [Fasta]() |[BAM]()|
|PsychArray-B.csv |[Fasta]()|[BAM]()|
|humanexome-12v1_a.csv |[Fasta]()|[BAM]()|

#### Table 1. Number of variants after probe mapping

| BeadChips | N SNP Start |N SNP End |
|-----|-----------|-------------------------|
| MEGA\_Consortium\_15063755_B2 | 1.7m| 1.5m| 
| HumanOmniExpressExome-8 v1.1 | ?| ?| 
| HumanOmniExpress-24 v1.1 |?| ?|  
| HumanOmniExpress-24 v1.0 |?| ?|  
| HumanCoreExome-24 v1.0 |?|?|

## 2. Genomestudio 

- Manual clustering, inspection and filtering of variants in genomestudio
- ensures that the most robust data is produced
- allows iterative qc of samples and snps and ability to rescue data close to qc thresholds for exclusion
- for each array we cluster variants based on data and generate new custom egt files 
- custom egt files used for all subsequent projects

More details soon....

## 3. Quality Control and Re-Calling  

- data exported and processed using [custom scripts]()
- standard gwas qc 
   - sample & snp call rates
   - IBD 
   - het if requested
   - maf & hwe if requested
   - gender checks if requested and if gender provided
   - No PCA or MDS (this is for the data owners to do)
- No-Call Variants recalled using zCall
- Produce PLINK Files for further analysis by data owners 

More details soon....

******

### No. Genotypes and Samples Processed  

| Samples/SNPs | Total |
|-----|-----------|
| Samples | 10000 |
| SNPS | 1000000000| 

******
Copyright (C) 2015 Hamel Patel, Amos Folarin & Stephen Jeffrey Newhouse


