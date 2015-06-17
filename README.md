# [illumina](http://www.illumina.com/)-array-protocols
** *work in progress..some links dont work and data and scripts to be added asap* **  

****

# Protocols for processing illumina SNP arrays 
 
**VERSION: v0.1**  
**Date: June 2015**  
**Authors: Stephen Newhouse, Hamel Patel, Amos Folarin, Charles Curtis**

## Table of Contents
[toc]

## Quick Overview
A set of scripts and protocols that we use to processing raw Illumina SNP array data.

- Links to information about Illumina BeadChips
- BWA Mapping of probe sequences  
- Genomestudio SOP (Manual Calling & QC)    
- Standard QC (PLINK, sh...) and re-calling No-Calls using zCall  
- Some reading...

## The Team 
**Bioinformatics** - Hamel Patel, Amos Folarin & Stephen Newhouse  @ [bluecell.io]()   

**Lab** - Charles Curtis & Team @ [The IoPPN Genomics & Biomarker Core Facility](http://www.kcl.ac.uk/ioppn/depts/mrc/research/The-IoPPN-Genomics--Biomarker-Core-Facility.aspx)  

![illuminaCSPro](./figs/CSProLogo-new-Cropped-313x105.png)

## The WorkFlow

*WORK FLOW PIC...*

1. Sample DNA + Sample Info > Lab > Raw Data (iDats)  
2. Raw Data (iDats) + Sample Info > Bioinformaticians > Genomestudio  
3. Genomestudio > zCall > Quality Control > PLINK + QC Report  

## Illumina BeadArray Microarray Technology 

### [BeadArray Microarray Technology](http://www.illumina.com/technology/beadarray-technology.html) 

> "BeadArray microarray technology represents a fundamentally different approach to high-density array"  
>     - *http://www.illumina.com/technology/beadarray-technology.html*

### [Infinium HD Assay](http://www.illumina.com/technology/beadarray-technology/infinium-hd-assay.html)

>The Infinium HD Assay leverages proven chemistry and a robust BeadChip array platform to produce unrivaled data quality, superior call rates, and the most consistent reproducibility. From customized studies on targeted regions to large-scale genome-wide association studies, the flexible Infinium HD design offers a powerful solution for virtually any genetic analysis application

**Discover the technology: [View Infinium Array animation video](http://www.youtube.com/embed/lVG04dAAyvY?iframe&rel=0&autoplay=1)**

**Some more videos**   
- [Illumina Vids 1](https://www.google.co.uk/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=illumina+beadchip+technology&safe=off&tbm=vid)  
- [Illumina Vids 2](https://www.google.co.uk/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#safe=off&tbm=vid&q=illumina+beadchip)  

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

## Illumina Downloads Resource
We provide links out to Illumina product data, as these are often not easliy found by the web/tech/google naive.  

This links takes you to Illumina's download page, which provides access to product documentation and
manifests.

- [Illumina Downloads](http://support.illumina.com/downloads.html)

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
ftp://webdata:webdata@ussd-ftp.illumina.com/Downloads/ProductFiles/HumanCoreExome-24/Product_Files/  

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

## No. Genotypes and Samples Processed  

| Samples/SNPs | Total |
|-----|-----------|
| Samples | 10000 |
| SNPS | 1000000000| 

******
Copyright (C) 2015 Hamel Patel, Amos Folarin & Stephen Jeffrey Newhouse

********

# Scratch (Steve's Lab Book)
> Dr Stephen Newhouse <stephen.j.newhouse@gmail.com>  
> Lab Book and messing around - this will change and/or be removed soon  
> Code examples will be added to `./bin`
> 

**Getting product data**  
All at <ftp://webdata:webdata@ussd-ftp.illumina.com/Downloads/ProductFiles/>

**A snap shot of whats in there**  

```
bpmFiles/		10/15/13, 12:00:00 AM
HumanCore/		5/4/15, 3:10:00 PM
HumanCore-24/		9/25/14, 12:00:00 AM
HumanCoreExome/		2/19/15, 10:48:00 AM
HumanCoreExome-24/		2/17/15, 10:44:00 AM
HumanCVD/		10/15/13, 12:00:00 AM
HumanExome/		7/9/14, 12:00:00 AM
HumanGenotypingArrays/		7/15/14, 12:00:00 AM
HumanMethylation27/		10/15/13, 12:00:00 AM
HumanMethylation450/		10/15/13, 12:00:00 AM
HumanOmni1-Quad/		10/15/13, 12:00:00 AM
HumanOmni2-5Exome-8/		2/19/15, 5:44:00 PM
HumanOmni5-Quad/		3/4/15, 2:25:00 PM
HumanOmni5Exome/		1/29/15, 5:12:00 PM
HumanOmni5MExome/		10/15/13, 12:00:00 AM
HumanOmni25/		2/17/15, 10:15:00 AM
HumanOmniExpress/		7/10/14, 12:00:00 AM
HumanOmniExpress-24/		2/17/15, 10:56:00 AM
HumanOmniExpressExome/		7/11/14, 12:00:00 AM
HumanOmniZhongHua-8/		2/23/15, 6:05:00 PM
PsychArray/		5/28/15, 10:13:00 AM
```

All processed on Rosalind image  

getting the data ... 

```sh
wget -r -c -b ftp://webdata:webdata@ussd-ftp.illumina.com/Downloads/ProductFiles/;
```

## Illumina CSV format

**Header** `HumanCoreExome-24v1-0_A.csv`

- skip 7  
- remove tail -24



```sh
head HumanCoreExome-24v1-0_A.csv
```

```
Illumina
[Heading]
Descriptor File Name,HumanCoreExome-24v1-0_A.bpm
Assay Format,Infinium HTS
Date Manufactured,4/10/2014
Loci Count ,547644
[Assay]
IlmnID,Name,IlmnStrand,SNP,AddressA_ID,AlleleA_ProbeSeq,AddressB_ID,AlleleB_ProbeSeq,GenomeBuild,Chr,MapInfo,Ploidy,Species,Source,SourceVersion,SourceStrand,SourceSeq,TopGenomicSeq,BeadSetID,Exp_Clusters,RefStrand
401070-0_B_F_1853042904,401070,BOT,[G/C],0037685961,ATCCAGTAATATGCATCATGGAATGAACTGATTTCAAAATGTAATCCAAG,0037805256,ATCCAGTAATATGCATCATGGAATGAACTGATTTCAAAATGTAATCCAAC,37,4,100333846,diploid,Homo sapiens,ILLUMINA,0,TOP,AAACTATTATTTTTTAGATTTGAATATAAATGTATTTTTTAAACACTTGTTATGAGTTAA[C/G]TTGGATTACATTTTGAAATCAGTTCATTCCATGATGCATATTACTGGATTAGATTAAGAA,AAACTATTATTTTTTAGATTTGAATATAAATGTATTTTTTAAACACTTGTTATGAGTTAA[C/G]TTGGATTACATTTTGAAATCAGTTCATTCCATGATGCATATTACTGGATTAGATTAAGAA,837,3,+
1KG_1_100177980-0_M_R_2255313133,1KG_1_100177980,MINUS,[D/I],0088747340,TTTGGCAGTTCTTCAGCCTCTTCTGGCAGTCTTCAGGCCACCTTTACATG,,,37,1,100177980,diploid,Homo sapiens,unknown,0,PLUS,TaaaaTGCaaaattttTCCATTTGaaaaCAGATTAGTTTGCCAACTAATGatatCTACATTAagagAGCATTtataTAGAAAGGctctAAGTACCTTGGGT[-/C]CATGTAAAGGTGGCCTGAAGACTGCCagaagaGGCTgaagaaCTGCCAAAGtcatcaCtataCAGCCGAGGTATGggtggtAACCTGCATGCTAAACAAA,TaaaaTGCaaaattttTCCATTTGaaaaCAGATTAGTTTGCCAACTAATGatatCTACATTAagagAGCATTtataTAGAAAGGctctAAGTACCTTGGGT[-/C]CATGTAAAGGTGGCCTGAAGACTGCCagaagaGGCTgaagaaCTGCCAAAGtcatcaCtataCAGCCGAGGTATGggtggtAACCTGCATGCTAAACAAA,837,3,-
```

**Tail** `HumanCoreExome-24v1-0_A.csv`

```sh
tail -24 HumanCoreExome-24v1-0_A.csv
```

```
[Controls]
0027630314:0027630314:0027630314:0027630314,Staining,Red,DNP (High)
0029619375:0029619375:0029619375:0029619375,Staining,Purple,DNP (Bgnd)
0041666334:0041666334:0041666334:0041666334,Staining,Green,Biotin (High)
0034648333:0034648333:0034648333:0034648333,Staining,Blue,Biotin (Bgnd)
0017616306:0017616306:0017616306:0017616306,Extension,Red,Extension (A)
0014607337:0014607337:0014607337:0014607337,Extension,Purple,Extension (T)
0012613307:0012613307:0012613307:0012613307,Extension,Green,Extension (C)
0011603365:0011603365:0011603365:0011603365,Extension,Blue,Extension (G)
0031623323:0031623323:0031623323:0031623323,Target Removal,Green,Target Removal
0019612319:0019612319:0019612319:0019612319,Hybridization,Green,Hyb (High)
0020636378:0020636378:0020636378:0020636378,Hybridization,Blue,Hyb (Medium)
0023617335:0023617335:0023617335:0023617335,Hybridization,Black,Hyb (Low)
0032629312:0032629312:0032629312:0032629312,Stringency,Red,String (PM)
0033668307:0033668307:0033668307:0033668307,Stringency,Purple,String (MM)
0026619332:0026619332:0026619332:0026619332,Non-Specific Binding,Red,NSB (Bgnd)
0027624356:0027624356:0027624356:0027624356,Non-Specific Binding,Purple,NSB (Bgnd)
0025617343:0025617343:0025617343:0025617343,Non-Specific Binding,Blue,NSB (Bgnd)
0024616350:0024616350:0024616350:0024616350,Non-Specific Binding,Green,NSB (Bgnd)
0034633358:0034633358:0034633358:0034633358,Non-Polymorphic,Red,NP (A)
0016648324:0016648324:0016648324:0016648324,Non-Polymorphic,Purple,NP (T)
0043641328:0043641328:0043641328:0043641328,Non-Polymorphic,Green,NP (C)
0013642359:0013642359:0013642359:0013642359,Non-Polymorphic,Blue,NP (G)
0028637363:0028637363:0028637363:0028637363,Restoration,Green,Restore
```
## Get Variant Information and Make Fasta Files

Header:-  

```
IlmnID,Name,IlmnStrand,SNP,AddressA_ID,AlleleA_ProbeSeq,AddressB_ID,AlleleB_ProbeSeq,GenomeBuild,Chr,MapInfo,Ploidy,Species,Source,SourceVersion,SourceStrand,SourceSeq,TopGenomicSeq,BeadSetID
```

Get minimal info `IlmnID,Name,AlleleA_ProbeSeq,AlleleB_ProbeSeq`

`bin/make-fasta-from-annotation-csv.sh`

```sh
#!/usr/bin/env sh
set -o errexit
set -o nounset

###########################################################################################
# Program: make-fasta-from-annotation-csv.sh
# Version 0.1
# Author: Stephen Newhouse (stephen.j.newhouse@gmail.com);
###########################################################################################

## USAGE: make-fasta-from-annotation-csv.sh HumanCoreExome-24v1-0_A.csv

## input
MY_FILE=${1}

echo -e "\n>>>>START [make-fasta-from-annotation-csv.sh ${1}]\n"
sleep 1s

## beadChip name 
BEADCHIP=`basename ${MY_FILE} .csv`

## remove header and tails and add new name for look-ups
echo -e "....Make new annotation file: remove header and ending guff and add new name for look-ups > [${BEADCHIP}.txt]"

    awk -F "," 'NR > 7 {print $0}' ${BEADCHIP}.csv | grep -v ^00 | grep -v "Controls" | \
        awk -F "," '{print $1"xSEQIDx"$2","$0}' > ${BEADCHIP}.txt

## Get Probe A Only Variants fasta
echo -e "....Make Fasta File for Variants with single probe sequence (A) only > [${BEADCHIP}.single.probe.A.fasta]"

    cat ${BEADCHIP}.txt  | sed '1d' | tr ',' '\t' | awk ' $9 !~ /[ATCG]/ ' | \
        awk '{print ">"$1"\n"$7}' > ${BEADCHIP}.single.probe.A.fasta

## Get Probe A & B Variants fasta
echo -e "....Make Fasta File for Variants with mulitiple probe sequences (A & B) > [${BEADCHIP}.multi.probe.A.and.B.fasta]"

    cat ${BEADCHIP}.txt  | sed '1d' | tr ',' '\t' | awk -F "\t" ' $9 ~ /[ATCG]/ ' | \
        awk '{print ">"$1"_PobeA""\n"$7"\n"">"$1"_PobeB""\n"$9}' >  ${BEADCHIP}.multi.probe.A.and.B.fasta

## Combine fasta files for mapping
echo -e "....Make Fasta File for All Variants: single and mulitiple probe sequences (A & B) > [${BEADCHIP}.fasta]"

    cat ${BEADCHIP}.single.probe.A.fasta ${BEADCHIP}.multi.probe.A.and.B.fasta > ${BEADCHIP}.fasta

## END    
echo -e "\n>>>>DONE [make-fasta-from-annotation-csv.sh ${1}]\n"
sleep 1s
```

**testing `make-fasta-from-annotation-csv.sh`**

```sh
time make-fasta-from-annotation-csv.sh HumanCoreExome-24v1-0_A.csv
```


```
>>>> START [make-fasta-from-annotation-csv.sh HumanCoreExome-24v1-0_A.csv]

.... Make new annotation file: remove header and ending guff and add new name for look-ups > [HumanCoreExome-24v1-0_A.txt]
.... Make Fasta File for Variants with single probe sequence (A) only > [HumanCoreExome-24v1-0_A.single.probe.A.fasta]
.... Make Fasta File for Variants with mulitiple probe sequences (A & B) > [HumanCoreExome-24v1-0_A.multi.probe.A.and.B.fasta]
.... Make Fasta File for All Variants: single and mulitiple probe sequences (A & B) > [HumanCoreExome-24v1-0_A.fasta]

>>>> DONE [make-fasta-from-annotation-csv.sh HumanCoreExome-24v1-0_A.csv]

real    0m5.014s
user    0m5.431s
sys     0m3.007s
```

## BWA mapping

BWA & Indexed Genomes provided as part of [NGSeasy](https://github.com/KHP-Informatics/ngseasy)  

Assume `make-fasta-from-annotation-csv.sh HumanCoreExome-24v1-0_A.csv` already run

### The pipeline so far.....

- make fasta > bwa map  

```bash
## Genome (GATK Resources)
GENOME="/media/Data/ngs_resources/reference_genomes_b37/human_g1k_v37.fasta"  

## BeadArray Annotation .csv
ARRAY_CSV="HumanCoreExome-24v1-0_A.csv"

## Makes Fasta Files
time make-fasta-from-annotation-csv.sh ${ARRAY_CSV}

## Run BWA
time aln-fasta-bwa-docker.sh ${ARRAY_CSV} ${GENOME} 32
```

```
>>>> START [aln-fasta-bwa-docker.sh   ]

ubuntu@ngseasy-sjn:/media/Data/mega_array$
ubuntu@ngseasy-sjn:/media/Data/mega_array$ time illumina-array-protocols/bin/aln-fasta-bwa-docker.sh ${ARRAY_CSV} ${GENOME} 32

>>>> START [aln-fasta-bwa-docker.sh HumanCoreExome-24v1-0_A.csv /media/Data/ngs_resources/reference_genomes_b37/human_g1k_v37.fasta 32]

.... Running [bwa mem -t 32 -V -M -a /media/Data/ngs_resources/reference_genomes_b37/human_g1k_v37.fasta HumanCoreExome-24v1-0_A.fasta | samblaster --addMateTags --excludeDups | samtools sort -@ 32 -T temp_ -O sam -o HumanCoreExome-24v1-0_A.sam && samtools index HumanCoreExome-24v1-0_A.sam]

samblaster: Version 0.1.21
samblaster: Inputting from stdin
samblaster: Outputting to stdout
[M::bwa_idx_load_from_disk] read 0 ALT contigs
[M::process] read 577420 sequences (28871000 bp)...
[M::mem_process_seqs] Processed 577420 reads in 45.554 CPU sec, 4.102 real sec
samblaster: Loaded 84 header sequence entries.
samblaster: Marked 35105 of 577420 (6.08%) read ids as duplicates using 14776k memory in 0.326S CPU seconds and 8S wall time.
[main] Version: 0.7.12-r1039
[main] CMD: bwa mem -t 32 -V -M -a /media/Data/ngs_resources/reference_genomes_b37/human_g1k_v37.fasta HumanCoreExome-24v1-0_A.fasta
[main] Real time: 7.523 sec; CPU: 47.991 sec

>>>> END [aln-fasta-bwa-docker.sh HumanCoreExome-24v1-0_A.csv /media/Data/ngs_resources/reference_genomes_b37/human_g1k_v37.fasta 32]


real    0m8.949s
user    0m45.335s
sys     0m4.926s
```

Inside `bin/make-fasta-from-annotation-csv.sh`

```sh
#!/usr/bin/env bash
set -o errexit
set -o nounset

###########################################################################################
# Program: aln-fasta-bwa-docker.sh
# Version 0.1
# Author: Stephen Newhouse (stephen.j.newhouse@gmail.com);
###########################################################################################

## USAGE: aln-fasta-bwa-docker.sh HumanCoreExome-24v1-0_A.csv ref.fasta 32

MY_FILE=${1}
BEADCHIP=`basename ${MY_FILE} .csv`
REF_GENOME=${2}
NCPU=${3}

echo -e "\n>>>> START [aln-fasta-bwa-docker.sh ${1} ${2} ${3}]\n"

echo -e ".... Running [bwa mem -t ${NCPU} -V -M -a ${REF_GENOME} ${BEADCHIP}.fasta | \
samblaster --addMateTags --excludeDups | \
samtools sort -@ ${NCPU} -T temp_ -O sam -o ${BEADCHIP}.sam && \
samtools index ${BEADCHIP}.sam]\n"

## Run BWA 
bwa mem -t ${NCPU} -V -M -a ${REF_GENOME} ${BEADCHIP}.fasta | \
samblaster --addMateTags --excludeDups | \
samtools sort -@ ${NCPU} -T temp_ -O sam -o ${BEADCHIP}.sam && \
samtools index ${BEADCHIP}.sam
wait

echo -e "\n>>>> END [aln-fasta-bwa-docker.sh ${1} ${2} ${3}]\n"
```

```
## intsalled locally
/usr/local/bin/samblaster  
/usr/local/bin/bwa  
/usr/local/bin/samtools  
```

**make table of results**

`touch bin/make-beadchip-sam-bwa-table.sh`

```bash
#!/usr/bin/env bash
set -o errexit
set -o nounset

echo -e "\n>>>>START [make-beadchip-sam-bwa-table.sh ${1}]\n"   

## Assume awscli installed and set up properly
## This is set up specifically for our usage
S3BUCKET="illumina-probe-mappings"
BUCKET_URL="https://s3-eu-west-1.amazonaws.com/${S3BUCKET}"

## set names and get information
#SAM=${1}
SAM="HumanCoreExome-24v1-0_A.sam"
SAMMD5=`md5sum ${SAM} | awk '{print $1}'`
SAM_SIZE=`du -h ${SAM} | awk '{print $1}'`

## make beadchip-sam-bwa-table.md
if [[ ! -e "beadchip-sam-bwa-table.md" ]]; then
    touch beadchip-sam-bwa-table.md
    echo -e "| SAM File | Size | MD5 |" >> beadchip-sam-bwa-table.md
    echo -e "|----------|------|-----|" >> beadchip-sam-bwa-table.md
fi

## add to table 
echo -e ".... Updating [beadchip-sam-bwa-table.md]"

    echo -e "| [${SAM}](${BUCKET_URL}/${SAM}) | ${SAM_SIZE} | ${SAMMD5}|" >> beadchip-sam-bwa-table.md

## copy to amazon s3 http://docs.aws.amazon.com/cli/latest/reference/s3/cp.html
echo -e "\n.... Copying [${SAM}] to amazon s3 : [aws s3 cp ${SAM} s3://${S3BUCKET} --acl public-read]\n"

   aws s3 cp ${SAM} s3://${S3BUCKET} --acl public-read 

echo -e "\n>>>>DONE [make-beadchip-sam-bwa-table.sh ${1}]\n"   
```

******

### Chips : Status 

**Date** `Mon Jun 15 09:57:10 UTC 2015`  
This is what we have so far..  

```
HumanCNV370
HumanCore
HumanCore-24
HumanCoreExome
HumanCoreExome-24
HumanCVD
HumanExome
HumanGenotypingArrays
HumanMethylation27
HumanMethylation450
HumanOmni1-Quad
HumanOmni25
HumanOmni2-5Exome-8
HumanOmni5Exome
HumanOmni5MExome
HumanOmni5-Quad
HumanOmniExpress
HumanOmniExpress-24
HumanOmniExpressExome
```

Not all chips have csv annotaions with sequences.  
Not all .bpm files have sequence  

**Moving csvs to project dirs** 

```bash

## Dirs on Rosalind Image

## ILM Data 
ILMDR="/media/Data/mega_array/iProductFiles/ussd-ftp.illumina.com/Downloads/ProductFiles"

## Where we will stick em all
MAPPING_DIR="/media/Data/mega_array/illumina-probe-mappings"

## CHIPs 
# HumanCNV370 : bpm only not copied
# HumanCore : cp
# HumanCore-24 : cp 
# HumanCoreExome : cp
# HumanCoreExome-24 : cp
# HumanCVD : bpm only copied
# HumanExome : cp
# HumanMethylation27 : skipped
# HumanMethylation450 : skipped
# HumanOmni1-Quad : bpm only copied
# HumanOmni25 : cp csv and bpm
# HumanOmni2-5Exome-8 : cp csv and bpm
# HumanOmni5Exome : cp
# HumanOmni5MExome : egt and sample sheets only
# HumanOmni5-Quad : cp 
# HumanOmniExpress : cp
# HumanOmniExpressExome : cp
# HumanOmniZhongHua-8 : CHINESE VARIANTS

BEADARRAY="HumanCore-24"

ls ${ILMDR}/${BEADARRAY} | grep .csv$

cp -v ${ILMDR}/${BEADARRAY}/HumanCore-12-v1-0-B.csv ${MAPPING_DIR}

```

Illumia are a bit lazy with docs and consitency, so a lot of the copying was
done interactivley. 

**Mon Jun 15 11:51:06 UTC 2015**

`/media/Data/mega_array/illumina-probe-mappings`

```
./
├── bin
│   ├── bwa
│   ├── samblaster
│   └── samtools
├── illumina_manifest_csv
│   ├── HumanCore-12-v1-0-B.csv
│   ├── humancore-24-v1-0-manifest-file-a.csv
│   ├── HumanCoreExome-12-v1-0-D.csv
│   ├── HumanCoreExome-12v1-1_B.csv
│   ├── HumanCoreExome-12-v1-1-C.csv
│   ├── HumanCoreExome-24v1-0_A.csv
│   ├── HumanExome-12-v1-0-B.csv
│   ├── HumanExome-12-v1-1-B.csv
│   ├── HumanExome-12v1-2_A.csv
│   ├── HumanExome-12-v1-2-B.csv
│   ├── HumanOmni2-5-8-v1-0-D.csv
│   ├── HumanOmni2-5-8-v1-1-C.csv
│   ├── HumanOmni25-8v1-2_A1.csv
│   ├── HumanOmni2-5Exome-8-v1-0-B.csv
│   ├── HumanOmni2-5Exome-8-v1-1-A.csv
│   ├── HumanOmni5-4-v1-0-D.csv
│   ├── HumanOmni5-4v1-1_A.csv
│   ├── HumanOmni5Exome-4-v1-0-B.csv
│   ├── HumanOmni5Exome-4v1-1_A.csv
│   ├── HumanOmni5Exome-4-v1-1-B.csv
│   ├── HumanOmni5Exome-4v1-2_A.csv
│   ├── HumanOmniExpress-12-v1-0-K.csv
│   ├── HumanOmniExpress-12-v1-1-C.csv
│   └── MEGA_Consortium_15063755_B2.csv
├── ref_genome
│   ├── human_g1k_v37.fasta
│   ├── human_g1k_v37.fasta.amb
│   ├── human_g1k_v37.fasta.ann
│   ├── human_g1k_v37.fasta.bwt
│   ├── human_g1k_v37.fasta.fai
│   ├── human_g1k_v37.fasta.pac
│   └── human_g1k_v37.fasta.sa
└── scratch
    ├── cvdsnp55v1_a.bpm
    ├── humanomni1-quad_v1-0_h.bpm
    └── humanomni25Exome-8v1_a.bpmpm

``` 

## Make fasta, create update allele file and run bwa

**Mon 15 Jun 2015 15:52:55 BST**  

```bash


## where me scripts are
SRC="/media/Data/mega_array/illumina-probe-mappings/illumina-array-protocols/bin"

## where the manifests are
ILM="/media/Data/mega_array/illumina-probe-mappings/illumina_manifest_csv"

## list files
FILES=`ls ${ILM}`

## make fasta files
for i in ${FILES}
do
	${SRC}/make-fasta-from-annotation-csv.sh ${i}
done	

## make update alleles file
for i in ${FILES}
do
	${SRC}/create_update_allele_file.sh ${i}
done
```

set to run...home time!  


```bash
#!/usr/bin/env bash
set -o errexit
set -o nounset

SRC="/media/Data/mega_array/illumina-probe-mappings/illumina-array-protocols/bin"

## where the manifests are
ILM="/media/Data/mega_array/illumina-probe-mappings/illumina_manifest_csv"

## list files
FILES=`ls ${ILM} ## this was silly - it read ALL bloody files!
`

## run bwa

# ${SRC}/aln-fasta-bwa.sh HumanCore-12-v1-0-B.csv ../ref_genome/human_g1k_v37.fasta 32

for i in ${FILES}
do
	${SRC}/aln-fasta-bwa.sh ${i} ../ref_genome/human_g1k_v37.fasta 32
done
```

saved as `run-bwa-15-june-2015.sh` and run as:-  


```bash
nohup ./run-bwa-15-june-2015.sh &
```


*********

Fasta IDs sep  `sep = "-ilmprb-"`  

```
>1KG_1_100177980-0_M_R_2115812812-ilmprb-1KG_1_100177980
TTTGGCAGTTCTTCAGCCTCTTCTGGCAGTCTTCAGGCCACCTTTACATG
>1KG_1_108681808-0_P_F_2115829838-ilmprb-1KG_1_108681808
CCAGCAACACCATGACTCCAGGGTTTACAGAATCTTTTGCAAAATTATCC
>1KG_1_109440678-0_M_R_2115829847-ilmprb-1KG_1_109440678
CTCACTCATAAAAATCCACGGCTGCCTGCAGAGCATCTCTCACTTCTTCT
>1KG_1_109479801-0_M_R_2115829849-ilmprb-1KG_1_109479801
CCTTATGCCAAAACGTATGAGGGTAGAAGAGAGATTTTGAGAGAGAGAGA
>1KG_1_110655430-0_M_R_2115812891-ilmprb-1KG_1_110655430
CTTGGCATCCTGTGGTTCAAAGTGTTTAGCTAGGACCAGTCCCAGCTGGT
```

**To Do:-**  

Filter SAM  
Make List of Multi Mapping Probes  

`cat ${FILE} | sed -e 's/-ilmprb-/"\t"/g'`

## Tue 16 Jun 2015 10:10:17 BST

All files donwloaded from illumina.  

#### List of Illumina Downloads 

```bash
cd /media/Data/mega_array/iProductFiles
tree -d
```

```
##ubuntu@ngseasy-sjn:/media/Data/mega_array/iProductFiles$ tree -d
.
└── ussd-ftp.illumina.com
    └── Downloads
        └── ProductFiles
            ├── BovineHD
            ├── BovineLD
            │   ├── BovineLDv1-1
            │   └── v2-0
            ├── BovineSNP50
            │   └── BovineSNP50v2ProductFiles
            ├── bpmFiles
            ├── CanineHD
            ├── CanineSNP20
            ├── CRCArray
            ├── CytoSNP
            ├── CytoSNP12-FFPE
            │   └── HmanHap300
            ├── CytoSNP-850K
            │   ├── Rev_B_Product_Files
            │   └── v1-0
            ├── HumanCNV370
            │   └── HumanCNV370-Duo
            ├── HumanCore
            ├── HumanCore-24
            │   └── v1-0
            │       └── humancore-24-v1-0-demo-12-a
            │           ├── CNV
            │           └── Data
            ├── HumanCoreExome
            │   ├── HumanCoreExome-12v1-1
            │   ├── v1-0
            │   └── v1-1
            ├── HumanCoreExome-24
            │   ├── Product_Files
            │   ├── Product_Support_Files
            │   └── v1-0
            ├── HumanCVD
            ├── HumanExome
            │   ├── ProductFiles
            │   ├── ProductSupportFiles
            │   ├── v1-0
            │   ├── v1-1
            │   └── v1-2
            ├── HumanGenotypingArrays
            ├── HumanMethylation27
            ├── HumanMethylation450
            ├── HumanOmni1-Quad
            ├── HumanOmni25
            │   ├── v1-0
            │   ├── v1-1
            │   └── v1-2
            ├── HumanOmni2-5Exome-8
            │   ├── Product_Files_v1-1
            │   ├── Product_Support_Files_v1-1
            │   ├── v1-0
            │   └── v1-1
            ├── HumanOmni5Exome
            │   ├── v1-0
            │   ├── v1-1
            │   └── v1-2
            ├── HumanOmni5MExome
            ├── HumanOmni5-Quad
            │   ├── v1-0
            │   └── v1-1
            ├── HumanOmniExpress
            │   ├── v1-0
            │   └── v1-1
            ├── HumanOmniExpress-24
            │   ├── v1-0
            │   └── v1-1
            │       ├── HumanOmniExpress-24v1-1_A_Demo_12
            │       │   ├── CNV
            │       │   └── Data
            │       └── PopulationReports
            ├── HumanOmniExpressExome
            │   ├── ProductFiles
            │   ├── ProductSupportFiles
            │   │   └── v1-0
            │   ├── v1-0
            │   ├── v1-1
            │   └── v1-2
            ├── HumanOmniZhongHua-8
            │   ├── v1-0
            │   ├── v1-1
            │   └── v1-2
            ├── MaizeSNP50
            ├── OncoArray-500K
            │   └── v1-0
            ├── OvineSNP50
            ├── PorcineSNP60
            │   ├── PorcineSNP60_v1ProductFiles
            │   └── PorcineSNP60_v2ProductFiles
            └── PsychArray
                └── v1-0
```

### BWA aln of outstanding data sets

These are what are left to do for Human BeadArray products, where csv are available.
```
PsychArray
HumanOmniZhongHua-8
```

copy csv to `/media/Data/mega_array/illumina-probe-mappings/illumina_manifest_csv` 

List **`PsychArray `**

```bash
## PsychArray
cd /media/Data/mega_array/iProductFiles/ussd-ftp.illumina.com/Downloads/ProductFiles/PsychArray
tree 
```

```
.
├── infinium-hts-automated-sample-sheet.csv
├── infinium-hts-manual-adjustable-spacer-pipette-sample-sheet.csv
├── infinium-hts-manual-single-channel-pipette-sample-sheet.csv
├── PsychArray_A_annotated.txt
├── PsychArray_A.bed
├── PsychArray_A.bpm
├── PsychArray_A_ClusterFile.egt
├── PsychArray_A.csv
├── PsychArray_A_Demo_12.zip
├── PsychArray_A_LocusReport.txt
├── PsychArray_A_Reproducibility and Heritability Report.csv
├── PsychArray_A_ReproducibilityandHeritabilityReport.csv
├── PsychArray_A_SampleSheet_Demo_12.csv
├── psycharray-population-reports-full.zip
├── psycharray-population-reports-maf-copy-numbers.zip
└── v1-0
    ├── PsychArray-B.bpm
    ├── PsychArray-B.csv
    ├── PsychArray-B-mapping-comments.txt
    ├── PsychArray-B-mapping-comments.zip
    ├── PsychArray-B-prior-product-modifications.txt
    ├── PsychArray-B-prior-product-modifications.zip
    ├── psycharray-demo-sample-sheet-a-12-samples.zip
    ├── psycharray-loci-name-to-rsid-conversion.txt
    └── psycharray-loci-name-to-rsid-conversion.zip
```

copy **`PsychArray`** to **`illumina_manifest_csv`**

```bash
## PsychArray
cd /media/Data/mega_array/iProductFiles/ussd-ftp.illumina.com/Downloads/ProductFiles/PsychArray
ILM="/media/Data/mega_array/illumina-probe-mappings/illumina_manifest_csv"
cp -v PsychArray_A.csv ${ILM}
cp -v v1-0/PsychArray-B.csv ${ILM}
```

List **`HumanOmniZhongHua-8`**

```bash
## HumanOmniZhongHua-8
cd /media/Data/mega_array/iProductFiles/ussd-ftp.illumina.com/Downloads/ProductFiles/HumanOmniZhongHua-8
tree .
```

```
.
├── v1-0
│   ├── HumanOmniZhongHua-8-v1-0-C-auxiliary-file.txt
│   ├── HumanOmniZhongHua-8-v1-0-C-auxiliary-file.zip
│   ├── HumanOmniZhongHua-8-v1-0-C.bpm
│   ├── HumanOmniZhongHua-8-v1-0-C.csv
│   ├── HumanOmniZhongHua-8-v1-0-C-mapping-comments.txt
│   ├── HumanOmniZhongHua-8-v1-0-C-mapping-comments.zip
│   ├── HumanOmniZhongHua-8-v1-0-C-prior-product-modifications.txt
│   └── HumanOmniZhongHua-8-v1-0-C-prior-product-modifications.zip
├── v1-1
│   ├── HumanOmniZhongHua-8-v1-1-B-auxiliary-file.txt
│   ├── HumanOmniZhongHua-8-v1-1-B-auxiliary-file.zip
│   ├── HumanOmniZhongHua-8-v1-1-B.bpm
│   ├── HumanOmniZhongHua-8-v1-1-B.csv
│   ├── HumanOmniZhongHua-8-v1-1-B-mapping-comments.txt
│   ├── HumanOmniZhongHua-8-v1-1-B-mapping-comments.zip
│   ├── HumanOmniZhongHua-8-v1-1-B-prior-product-modifications.txt
│   ├── HumanOmniZhongHua-8-v1-1-B-prior-product-modifications.zip
│   ├── humanomnizhonghua-8-v1-1-cluster-file.zip
│   └── humanomnizhonghua-8-v1-1-lims-product-descriptor-file-15045826-a.zip
└── v1-2
    ├── humanomnizhonghua-8-v1-2-a-manifest-file-bpm.zip
    ├── humanomnizhonghua-8-v1-2-a-manifest-file-csv.zip
    ├── humanomnizhonghua-8-v1-2-cluster-file.zip
    ├── humanomnizhonghua-8-v1-2-demo-data-12-samples.zip
    ├── humanomnizhonghua-8-v1-2-demo-sample-sheet-12-samples.zip
    ├── humanomnizhonghua-8-v1-2-file-for-ucsc-browser-bed.zip
    ├── humanomnizhonghua-8-v1-2-gene-annotation.zip
    ├── humanomnizhonghua-8-v1-2-lims-product-descriptor-15053792-a.zip
    ├── humanomnizhonghua-8-v1-2-loci-name-to-rsid-conversion.zip
    ├── humanomnizhonghua-8-v1-2-locus-report.zip
    ├── humanomnizhonghua-8-v1-2-mapping-comments.zip
    ├── humanomnizhonghua-8-v1-2-population-reports-full.zip
    ├── humanomnizhonghua-8-v1-2-population-reports-maf-copy-numbers.zip
    ├── humanomnizhonghua-8-v1-2-reproducibility-and-heritability-report.zip
    ├── humanomnizhonghua-8-v1-2-strand-report-fdt.zip
    ├── humanomnizhonghua-v1-2-vs-v1-1-legacy-overlap.zip
    └── humanomnizhonghua-v1-2-vs-v1-1-missing-legacy-snps.zip

```   

copy **`HumanOmniZhongHua-8`** to **`illumina_manifest_csv`**

```bash
## HumanOmniZhongHua-8
cd /media/Data/mega_array/iProductFiles/ussd-ftp.illumina.com/Downloads/ProductFiles/HumanOmniZhongHua-8
ILM="/media/Data/mega_array/illumina-probe-mappings/illumina_manifest_csv"
cp -v v1-0/HumanOmniZhongHua-8-v1-0-C.csv ${ILM}
cp -v v1-1/HumanOmniZhongHua-8-v1-1-B.csv ${ILM}
cp -v v1-2/humanomnizhonghua-8-v1-2-a-manifest-file-csv.zip ${ILM} && \
unzip ${ILM}/humanomnizhonghua-8-v1-2-a-manifest-file-csv.zip && \
rm ${ILM}/humanomnizhonghua-8-v1-2-a-manifest-file-csv.zip

```

Now move to `${ILM}` and run make fasta....bwa etc

I effed up and deleted a bunch of stuff...so running the whole thing again...

```bash
## where me scripts are
SRC="/media/Data/mega_array/illumina-probe-mappings/illumina-array-protocols/bin"

## where the manifests are
ILM="/media/Data/mega_array/illumina-probe-mappings/illumina_manifest_csv"

## make sure we are in the right dir
cd ${ILM}

## list files
FILES=`ls | grep .csv$`

## Do it all one time...
for i in ${FILES}
do

## make fasta files
echo -e "\n\n>>>>>>>>>> Make Fasta >>>>>>>>>>\n\n"

	time ${SRC}/make-fasta-from-annotation-csv.sh ${i} && mv -v *probe* ../fasta
	
## make update alleles file
echo -e "\n\n>>>>>>>>>> Make Update Alleles >>>>>>>>>>\n\n"

	time ${SRC}/create_update_allele_file.sh ${i} && mv -v *update* ../update_alleles_files
		
## bwa aln
echo -e "\n\n>>>>>>>>>> BWA Aligning Sh!t >>>>>>>>>>\n\n"

	time ${SRC}/aln-fasta-bwa.sh ${i} ../ref_genome/human_g1k_v37.fasta 32

done 
```

count N lines in .txt annotation files 

```bash
wc -l *txt | awk '{print $1-1"\t"$2}' | sort -grk1 
```

#### Number of Varians (Lines) for Each BeadArray processed

```bash
## make md table
echo -e "| Number of Variants (Lines) | BeadArray File |" >> table_n_lines_annotations.md;

echo -e "|----------|---------|" >> table_n_lines_annotations.md;

wc -l *txt | awk '{print $1-1"\t"$2}' | sort -grk1 | \
awk '{print "|",$1,"|"$2,"|"}' >> table_n_lines_annotations.md;
```



| Number of Variants (Lines) | BeadArray File |
|----------|---------|
| 4641218 |HumanOmni5Exome-4-v1-1-B.txt |
| 4641218 |HumanOmni5Exome-4v1-1_A.txt |
| 4548474 |HumanOmni5Exome-4v1-2_A.txt |
| 4511703 |HumanOmni5Exome-4-v1-0-B.txt |
| 4301332 |HumanOmni5-4-v1-0-D.txt |
| 4284426 |HumanOmni5-4v1-1_A.txt |
| 2583651 |HumanOmni2-5Exome-8-v1-1-A.txt |
| 2567845 |HumanOmni2-5Exome-8-v1-0-B.txt |
| 2391739 |HumanOmni2-5-8-v1-1-C.txt |
| 2379855 |HumanOmni2-5-8-v1-0-D.txt |
| 2338671 |HumanOmni25-8v1-2_A1.txt |
| 1705969 |MEGA\_Consortium\_15063755_B2.txt |
| 964193 |HumanOmniExpressExome-8-v1-2-B.txt |
| 964193 |HumanOmniExpressExome-8v1-2_A.txt |
| 958178 |HumanOmniExpressExome-8-v1-1-C.txt |
| 951117 |HumanOmniExpressExome-8-v1-0-B.txt |
| 900015 |HumanOmniZhongHua-8-v1-0-C.txt |
| 894517 |HumanOmniZhongHua-8-v1-1-B.txt |
| 730525 |HumanOmniExpress-12-v1-0-K.txt |
| 719665 |HumanOmniExpress-12-v1-1-C.txt |
| 571054 |PsychArray-B.txt |
| 571054 |PsychArray_A.txt |
| 547644 |HumanCoreExome-24v1-0_A.txt |
| 542585 |HumanCoreExome-12-v1-1-C.txt |
| 542585 |HumanCoreExome-12v1-1_B.txt |
| 538448 |HumanCoreExome-12-v1-0-D.txt |
| 306670 |humancore-24-v1-0-manifest-file-a.txt |
| 298930 |HumanCore-12-v1-0-B.txt |
| 247870 |HumanExome-12-v1-0-B.txt |
| 244770 |HumanExome-12-v1-2-B.txt |
| 244770 |HumanExome-12v1-2_A.txt |
| 242901 |HumanExome-12-v1-1-B.txt |

## Samtools flagstat

Testing...

```bash
samtools flagstat HumanOmni5Exome-4-v1-1-B.sam
```

```
5131847 + 0 in total (QC-passed reads + QC-failed reads)
314599 + 0 secondary
0 + 0 supplementary
310100 + 0 duplicates
5131477 + 0 mapped (99.99%:-nan%)
0 + 0 paired in sequencing
0 + 0 read1
0 + 0 read2
0 + 0 properly paired (-nan%:-nan%)
0 + 0 with itself and mate mapped
0 + 0 singletons (-nan%:-nan%)
0 + 0 with mate mapped to a different chr
0 + 0 with mate mapped to a different chr (mapQ>=5)
```

Note secondary and duplicate hits...

We will now generate these stats for all files..

```bash
SAM=`ls | grep .sam$`

for i in ${SAM}
do
	samtools flagstat ${i} > ${i}.flagstat
done	
```

## Multi-mapping Probes

Focus on MEGA Array

```bash
more MEGA_Consortium_15063755_B2.sam.flagstat
```

```
2657065 + 0 in total (QC-passed reads + QC-failed reads)
768483 + 0 secondary
0 + 0 supplementary
253125 + 0 duplicates
2657048 + 0 mapped (100.00%:-nan%)
0 + 0 paired in sequencing
0 + 0 read1
0 + 0 read2
0 + 0 properly paired (-nan%:-nan%)
0 + 0 with itself and mate mapped
0 + 0 singletons (-nan%:-nan%)
0 + 0 with mate mapped to a different chr
0 + 0 with mate mapped to a different chr (mapQ>=5)
```

```bash
## go to dir
cd /media/Data/mega_array/illumina-probe-mappings/illumina_manifest_csv

## List MEGA* files
ls | grep MEGA
```

```
MEGA_Consortium_15063755_B2.csv ## annotation from Illumina
MEGA_Consortium_15063755_B2.fasta ## probe fasta seqs
MEGA_Consortium_15063755_B2.sam ## BWA SAM File
MEGA_Consortium_15063755_B2.sam.flagstat ## Flagstats 
MEGA_Consortium_15063755_B2.txt ## Annotation File (remove Illumina header and tail)
```

Focus **`ARRAY="MEGA_Consortium_15063755_B2"`**

```bash
## Array Name
ARRAY="MEGA_Consortium_15063755_B2"

## count CIGAR top 20
awk '{print $6}' ${ARRAY}.sam | sort | uniq -c | sort -grk1 | head -20
```

```
2460169 50M
   6528 45M5H
   6492 5H45M
   5794 4H46M
   5786 46M4H
   4764 3H47M
   4760 10H40M
   4742 40M10H
   4651 47M3H
   4321 41M9H
   4257 9H41M
   4063 8H42M
   4029 42M8H
   3939 48M2H
   3860 2H48M
   3560 20H30M
   3534 30M20H
   3492 7H43M
   3435 14H36M
   3430 15H35M
```

Note hard clipping (H) 

```bash
grep -w "45M5H" ${ARRAY}.sam | head
```

```
JHU_7.128268062-1_T_R_2236780463-ilmprb-JHU_7.128268062 256     1       157146  0       45M5H   *       0       0       *       *       NM:i:1  MD:Z:27G17      AS:i:40 XR:Z:dna:chromosome chromosome:GRCh37:1:1:249250621:1
JHU_15.102428433-1_B_F_2226976652-ilmprb-JHU_15.102428433       256     1       379890  0       45M5H   *       0       0       *       *       NM:i:0  MD:Z:45 AS:i:45 XR:Z:dna:chromosome chromosome:GRCh37:1:1:249250621:1
JHU_7.128268062-1_T_R_2236780463-ilmprb-JHU_7.128268062 256     1       692832  0       45M5H   *       0       0       *       *       NM:i:1  MD:Z:27G17      AS:i:40 XR:Z:dna:chromosome chromosome:GRCh37:1:1:249250621:1
JHU_6.151966-1_B_F_2232450143-ilmprb-JHU_6.151966       256     1       803082  0       45M5H   *       0       0       *       *       NM:i:2  MD:Z:11G7G25    AS:i:35 XR:Z:dna:chromosome chromosome:GRCh37:1:1:249250621:1
rs676417-131_T_F_1891380557-ilmprb-rs676417     256     1       1043230 0       45M5H   *       0       0       *       *       NM:i:2  MD:Z:0G38A5     AS:i:39 XR:Z:dna:chromosome chromosome:GRCh37:1:1:249250621:1
JHU_1.1161742-1_T_F_2245137316-ilmprb-JHU_1.1161742     256     1       1161756 0       45M5H
```

Grep CIGAR string **`50M`**

```bash
grep -w "50M" ${ARRAY}.sam | head
```

```
HU_12.92809-1_B_F_2243580166-ilmprb-JHU_12.92809       272     1       12804   0       50M     *       0       0       *       *       NM:i:2  MD:Z:3C30T15    AS:i:41 XR:Z:dna:chromosome chromosome:GRCh37:1:1:249250621:1
JHU_12.92723-1_T_F_2243580162-ilmprb-JHU_12.92723_PobeA 272     1       12889   0       50M     *       0       0       *       *       NM:i:1  MD:Z:21G28      AS:i:45 XR:Z:dna:chromosome chromosome:GRCh37:1:1:249250621:1
JHU_12.92723-1_T_F_2243580162-ilmprb-JHU_12.92723_PobeB 1296    1       12889   0       50M     *       0       0       *       *       NM:i:2  MD:Z:0G20G28    AS:i:44 XR:Z:dna:chromosome chromosome:GRCh37:1:1:249250621:1
JHU_12.92436-1_B_R_2243580153-ilmprb-JHU_12.92436       256     1       13126   0       50M     *       0       0       *       *       NM:i:3  MD:Z:12T19G1A15 AS:i:35 XR:Z:dna:chromosome chromosome:GRCh37:1:1:249250621:1
JHU_2.114357511-1_T_R_2227997727-ilmprb-JHU_2.114357511 256     1       13454   0       50M     *       0       0       *       *       NM:i:2  MD:Z:5C13T30    AS:i:40 XR:Z:dna:chromosome chromosome:GRCh37:1:1:249250621:1
JHU_12.91677-1_B_F_2243580132-ilmprb-JHU_12.91677       272     1       13936   0       50M     *       0       0       *       *       NM:i:3  MD:Z:10G25C7T5  AS:i:35 XR:Z:dna:chromosome chromosome:GRCh37:1:1:249250621:1
JHU_15.102514230-1_B_F_2226977142-ilmprb-JHU_15.102514230_PobeA 272     1       16932   0       50M     *       0       0       *       *       NM:i:2  MD:Z:13G22C13   AS:i:40 XR:Z:dna:chromosome chromosome:GRCh37:1:1:249250621:1
JHU_15.102514230-1_B_F_2226977142-ilmprb-JHU_15.102514230_PobeB 1296    1       16932   0       50M     *       0       0       *       *       NM:i:3  MD:Z:0C12G22C13 AS:i:39 XR:Z:dna:chromosome chromosome:GRCh37:1:1:249250621:1
9:17124-GA-0_T_F_2299865180-ilmprb-9:17124-GA   256     1       16963   0       50M     *       0       0       *       *       NM:i:2  MD:Z:41C0A7     AS:i:41 XR:Z:dna:chromosome chromosome:GRCh37:1:1:249250621:1
9:17085-CT-0_T_R_2299865177-ilmprb-9:17085-CT   272     1       16975   0       50M     *       0       0       *       *       NM:i:2  MD:Z:29C0A19    AS:i:40 XR:Z:dna:chromosome chromosome:GRCh37:1:1:249250621:1

```

Note, many have no sequence and are not primary mapping


Grep CIGAR string **`50M`** and QUAL `>0`

```bash
grep -w "50M" ${ARRAY}.sam | awk '$5>0' | wc -l 

## 1. Full length of Probes maps to genome CIGAR 50M
grep -w "50M" ${ARRAY}.sam | \
awk 'BEGIN{OFS="\t";} {print $1, $3, $4, $6, $10}' | \
sed -e 's/-ilmprb-/\t/g' | \
awk '{print $1}' | sort | uniq -c | sort -grk1 | head -20
```

Probes hit > 1000 Times

```
   1055 rs4413915-138_T_F_2304127707
   1044 rs183751916-138_B_F_2304123777
   1040 5:74635225-G-C-0_B_R_2304214204
   1012 rs7336004-138_T_F_2295997788
   1010 rs184037461-138_B_R_2304123844
   1010 rs141419953-138_B_F_2304118828
   1008 1:205656202-C-G-0_B_F_2304167124
   1007 rs149787424-138_B_R_2304121996
   1006 6:142745735-T-A-0_B_R_2304216672
   1006 16:11923036-G-C-0_T_R_2304225522
   1006 15:63391720-C-G-0_B_R_2304192211
   1005 rs75939001-138_B_F_2304134512
   1005 rs187562876-138_T_F_2304124641
   1005 rs12399807-138_T_F_2304116937
   1005 8:40472371-A-T-0_T_R_2304181745
   1004 rs61993646-138_T_R_2296558163
   1004 rs192449672-138_B_F_2300056085
   1004 rs183642112-138_T_F_2304123737
   1004 8:130618511-A-T-0_B_R_2304218964
   1003 rs192877536-138_T_R_2304125900
```

Lets look at the top hit

```bash
grep "rs4413915-138_T_F_2304127707" ${ARRAY}.sam | awk '$10 ~ "[ATGC]"' 
```

```
rs4413915-138_T_F_2304127707-ilmprb-rs4413915_PobeB     0       1       89793532        0       50M     *       0       0       ATTGACCACATAGTTGGAAGTAAAGCTCTACTCAGCAAATGTAAAAGAAG      *       NM:i:1  MD:Z:49C0       AS:i:49 XS:i:49 XR:Z:dna:chromosome chromosome:GRCh37:1:1:249250621:1
rs4413915-138_T_F_2304127707-ilmprb-rs4413915_PobeA     0       3       133402777       0       50M     *       0       0       ATTGACCACATAGTTGGAAGTAAAGCTCTACTCAGCAAATGTAAAAGAAC      *       NM:i:0  MD:Z:50 AS:i:50 XS:i:50 XR:Z:dna:chromosome chromosome:GRCh37:3:1:198022430:1
```

Hits CHR 1:89793532 and 3:133402777

The sequence...

A:`ATTGACCACATAGTTGGAAGTAAAGCTCTACTCAGCAAATGTAAAAGAAG`  
M:`|||||||||||||||||||||||||||||||||||||||||||||||||*`  
B:`ATTGACCACATAGTTGGAAGTAAAGCTCTACTCAGCAAATGTAAAAGAAC`

Probe A and B differ by the terminal base. 

Now lets BLAT it.   

**BLAT Search Results**  
BLAT: http://genome.ucsc.edu/cgi-bin/hgBlat

Just look. This is a snap shot of the results. This probe hits multiple regions. 

```
BLAT Search Results

   ACTIONS      QUERY           SCORE START  END QSIZE IDENTITY CHRO STRAND  START    END      SPAN
---------------------------------------------------------------------------------------------------
browser details YourSeq           49     1    49    50 100.0%     X   -   80217749  80217797     49
browser details YourSeq           49     1    49    50 100.0%     X   -   80235666  80235714     49
browser details YourSeq           49     1    49    50 100.0%     X   +   80285055  80285103     49
browser details YourSeq           48     1    50    50  98.0%     1   -  115560057 115560106     50
browser details YourSeq           48     1    50    50  98.0%     2   +  146542664 146542713     50
browser details YourSeq           47     3    49    50 100.0%     X   -   67600656  67600702     47
```

**UCSC Mapping of SNP with ID rs4413915**

**`rs4413915 at chrX:80284854-80285354`**

The BLAT mapping Looks ok - the top hit matches the annotations -  but, the fact is, that this is not a unique hit. BWA maps the full length of this sequence (CIGAR 50M) `>500` times. 

Note, Probe A and B sequences were taken from Illumina's data file. Really, this is one read/sequence (another oversight - or my mistake?).  

Getting counts of the chromosomes this probe hits.

```bash
grep "rs4413915-138_T_F_2304127707" ${ARRAY}.sam | awk '{print $3}' | sort | uniq -c | \
sort -rgk1
```

Chr X is top hit (most frequent chromosome probe is mapped to). 

```
    118 X
    101 4
    100 2
     97 1
     85 3
     61 11
     58 6
     58 5
     51 10
     47 8
     47 7
     46 12
     30 14
     30 13
     26 9
     26 18
     26 15
     17 20
     17 16
     15 Y
     14 19
     13 17
      9 21
```

Should we trust these variants? I do not think so.

If illumina technology is based on hybridisation, then we really can not rely on data from 
multi-mapping probes. Unless, Illumina protocols and methods are **PERFECT** 
and error free. 


**now make a file**

```bash
## 1. Full length of Probes maps to genome CIGAR 50M
grep -w "50M" ${ARRAY}.sam | \
awk 'BEGIN{OFS="\t";} {print $1, $3, $4, $6, $10}' | \
sed -e 's/-ilmprb-/\t/g' > ${ARRAY}.probe_mapping

awk '{print $1}' | sort | uniq -c | sort -grk1 | head -20
```

**Count N VAR Orginal**

```bash
## Count N VAR Orginal
NVAR_ORIGINAL=`wc -l ${ARRAY}.txt | awk '{print $1-1}'` && \
echo -e "Number or Variants in ${ARRAY}: ${NVAR_ORIGINAL}"
```

```
Number or Variants in MEGA_Consortium_15063755_B2: 1705969
```

```bash
## Get good qual mapped reads
samtools view -S -q 20 ${ARRAY}.sam | \
awk '{print $6}'| sort | uniq -c | sort -grk1 | head -20
```

### Is the Probe Seq Unique or Not?

At most a sequence should only appear twice? (Probe A and B are the same sometimes). 

Counting the number of time Probe A sequence occurs in the annotation file:   

```bash
## Probe A seq counts
awk -F, 'BEGIN{OFS="\t";} {print $7}' MEGA_Consortium_15063755_B2.txt | \
sort | uniq -c | sort -grk1 | head
```

Probes appear multiple times

```
      8 AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
      3 TTTGTCATACATGGCAGCGTAAGTGTAAGCAAACTCTCCTATGAACACTC
      3 TGGGACTTTTGAGCTGATGAGAAGACTGAGATTTTGGACTTGAAGCTGTA
      3 TGGAAATGTCTGGGAAAGCCAGTTGGAGCAGAGATGTGACAAAGATCAAC
      3 TCATGCTACAATGTGCACTGTGTACAGAAACTGTGAATAGAGAAGTAGCC
      3 GTTGTCCTGGCTCAACAGTCCCTTCCGGCCCGCACCAGTCCCATGCCCAC
      3 GGCATGCTCATCAGCGTCCTGGGCATTTGGGTCCCTGGATGTGGCTCCAA
      3 GGAAACATCTATGTGTCCCCTTGGTTAAGATAACAGAGTAAATCTAGAGC
      3 GAGTACCTCATCTTATTCCCTGCCTGAATCTGCTGTTTTCTTCTGCAGCC
      3 GAGATGAAAACAGGCGCACCAAGAACATGCCTCAGGGCTCATTTCCATCA
```      

### BAD: Same probe A sequence, different names

looking at the most frequent hit `AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG`

```bash
grep -w AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG MEGA_Consortium_15063755_B2.txt | \
awk -F, 'BEGIN{OFS="\t";} {print $2,$3,$4,$5,$6,$7,$8,$9}'
```

```
19:45411941-A-G-0_B_F_2304705815        19:45411941-A-G BOT     [T/C]   0068697136      AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-A-G-R1-0_B_F_2304705805     19:45411941-A-G-R1      BOT     [T/C]   0036688128      AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-A-G-R2-0_B_F_2304705807     19:45411941-A-G-R2      BOT     [T/C]   0009732934      AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-A-G-R3-0_B_F_2304705809     19:45411941-A-G-R3      BOT     [T/C]   0014664267      AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-A-G-R4-0_B_F_2304705811     19:45411941-A-G-R4      BOT     [T/C]   0086619289      AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-A-G-R5-0_B_F_2304705813     19:45411941-A-G-R5      BOT     [T/C]   0045718285      AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-T-C-0_B_F_2304248373        19:45411941-T-C BOT     [T/C]   0038690189      AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-T-C-F7-0_B_F_2304705786     19:45411941-T-C-F7      BOT     [T/C]   0002726194      AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG

```

We checked for the string **`19:45411941`** in an GenomeStudio project and found a lot 
of other **variants with the same prefix.**   

Now looking for **`19:45411941`** in the annotation file.

```bash
grep -w 19:45411941 MEGA_Consortium_15063755_B2.txt | \
awk -F, 'BEGIN{OFS="\t";} {print $2,$3,$4,$5,$6,$7,$8,$9}'
```

The following (below) is what we find.  
 
- These all match GenomeStudio annotations.    
- These all have the same cluster pattern (all Homozygous A).  
- This looks like the same variant represented 21 times.   


```
19:45411941-A-G-0_B_F_2304705815        19:45411941-A-G BOT     [T/C]   0068697136      AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-A-G-R1-0_B_F_2304705805     19:45411941-A-G-R1      BOT     [T/C]   0036688128      AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-A-G-R2-0_B_F_2304705807     19:45411941-A-G-R2      BOT     [T/C]   0009732934      AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-A-G-R3-0_B_F_2304705809     19:45411941-A-G-R3      BOT     [T/C]   0014664267      AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-A-G-R4-0_B_F_2304705811     19:45411941-A-G-R4      BOT     [T/C]   0086619289      AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-A-G-R5-0_B_F_2304705813     19:45411941-A-G-R5      BOT     [T/C]   0045718285      AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-T-C-0_B_F_2304248373        19:45411941-T-C BOT     [T/C]   0038690189      AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-T-C-F1-0_B_F_2304705774     19:45411941-T-C-F1      BOT     [T/C]   0079799156      AGGAGCTGCAGGCGACGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-T-C-F10-0_B_F_2304705792    19:45411941-T-C-F10     BOT     [T/C]   0086781479      AGGAGCTGCAGGCGGCGCAGACCCAGCTGGGCGCGGACATGGAGGACGTG
19:45411941-T-C-F11-0_B_F_2304705794    19:45411941-T-C-F11     BOT     [T/C]   0095679572      AGGAGCTGCAGACGGCACAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-T-C-F12-0_B_F_2304705796    19:45411941-T-C-F12     BOT     [T/C]   0004605221      AGGAGATGCAGGCGACGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-T-C-F13-0_B_F_2304705798    19:45411941-T-C-F13     BOT     [T/C]   0069758946      AGAAGATGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-T-C-F14-0_B_F_2304705800    19:45411941-T-C-F14     BOT     [T/C]   0094784840      AGGAGCTGCAGGCGGCGCAGGCCCGGATGGGCACGGACATGGAGGACGTG
19:45411941-T-C-F15-0_B_F_2304705802    19:45411941-T-C-F15     BOT     [T/C]   0057701981      AGGAGCTGCAGGCGACGCCGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-T-C-F2-0_B_F_2304705776     19:45411941-T-C-F2      BOT     [T/C]   0070776894      AGGAGCTGCAGGCGGCGCAGGCCCGTCTGGGCGCGGACATGGAGGACGTG
19:45411941-T-C-F3-0_B_F_2304705778     19:45411941-T-C-F3      BOT     [T/C]   0021706595      AGGAGCTGCAGGCGGCGCAGGCCCGGTTGGGCGCGGACATGGAGGACGTG
19:45411941-T-C-F4-0_B_F_2304705780     19:45411941-T-C-F4      BOT     [T/C]   0057639192      AGGAGCTGCAGGCGGCGCAGGCCAGGCTGGGAGCGGACATGGAGGACGTG
19:45411941-T-C-F5-0_B_F_2304705782     19:45411941-T-C-F5      BOT     [T/C]   0061792957      AGGAGCTGCAGGCAGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-T-C-F6-0_B_F_2304705784     19:45411941-T-C-F6      BOT     [T/C]   0094628221      AGGAGCTGCAGGCGGCGCAGACACGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-T-C-F7-0_B_F_2304705786     19:45411941-T-C-F7      BOT     [T/C]   0002726194      AGGAGCTGCAGGCGGCGCAGGCCCGGCTGGGCGCGGACATGGAGGACGTG
19:45411941-T-C-F9-0_B_F_2304705790     19:45411941-T-C-F9      BOT     [T/C]   0068668877      AGGAGCTGCAGGCGGCGCAGGCCCGGCTAGGCGCGGACATGGAGGACGTG
```

### UCSC BLAT 19:45411941* sequence

![19:45411941 BLAT](./figs/chr-19-45411941-blat.png)

**Looking at Probe B sequences**

```bash
## Probe B seq counts
awk -F, 'BEGIN{OFS="\t";} {print $9}' MEGA_Consortium_15063755_B2.txt | \
sort | uniq -c | sort -grk1 | head
```

Probe B sequence duplication is not as bad as Probe A

```
      2 TTTTTTTTTTAAGTCAATACTTCTTAGTTTATTTACCTATCTATTTTTTT
      2 TTTTTTTTTCTCCACGCCACAGAACTGCTGCTGGGGGGAGGGGGATGGGA
      2 TTTTTTCTGACTATGTCTGAGTAAAAACAGATCTAGGCTTAGTTGAATTA
      2 TTTTTTCCCCAGTTTTTCTGGGTTGTCATCTCTGTGCTTTTACTCTACGG
      2 TTTTTTAGAATACGTTCTCAGAATTGGGACTTCCAGGTCAATGGCTATGA
      2 TTTTTTAATGCAACATCTCTATGGAAAGAAAAGAAAACTACTGAAAGGAT
      2 TTTTTTAACCTTATTTGACCTTGCGACTTTACAAATCATTGCTGGACTTC
      2 TTTTTGTGGGACCTTGGCTGGGTCATTTTCATTGCTCAGGCCTGTTTTCG
      2 TTTTTGGCTTATCCTACTAGTGTGTCTTTTCACAAATATAACCAAATTCT
```

looking at the most frequent hit `TTTTTTTTTTAAGTCAATACTTCTTAGTTTATTTACCTATCTATTTTTTT `

```bash
grep -w TTTTTTTTTTAAGTCAATACTTCTTAGTTTATTTACCTATCTATTTTTTT MEGA_Consortium_15063755_B2.txt | \
awk -F, 'BEGIN{OFS="\t";} {print $2,$3,$4,$5,$6,$7,$8,$9}'
```

#### BAD: Same probe sequence, different names

```
JHU_14.83197666-1_T_R_2222134330        JHU_14.83197666 TOP     [A/T]   0001643920      TTTTTTTTTTAAGTCAATACTTCTTAGTTTATTTACCTATCTATTTTTTA      0037618859      TTTTTTTTTTAAGTCAATACTTCTTAGTTTATTTACCTATCTATTTTTTT
rs116745907-138_T_R_2297106218  rs116745907     TOP     [A/T]   0003733361      TTTTTTTTTTAAGTCAATACTTCTTAGTTTATTTACCTATCTATTTTTTA      0087762158      TTTTTTTTTTAAGTCAATACTTCTTAGTTTATTTACCTATCTATTTTTTT
```

Here (above), the probe sequence `TTTTTTTTTTAAGTCAATACTTCTTAGTTTATTTACCTATCTATTTTTTT`
is seen twice in the annotation file.

This probde is assigned to two different variant names `JHU_14.83197666` and `rs116745907`.

In GenomeStudio, these two variants have identical clusters. **They are the exact same variant.**


## Bad Illumina Probes and Variants 

A Plan of attack...

When a GenomeStudio project is created the user has the option to `zero` out variants 
that we have determined to be problematic. 

These are variants that are duplicated and/or variants where the associated probe sequence(s) does not uniquely map back to the reference genome. 

Removing these variants will speed up clustering times and improve SNP and Sample call rates.
More importantly, the end user is then not faced with analysing un-reliable data. 

#### Do these probes represent any published GWAS findings?
We plan on interesting these lists if un-reliable variants with GWAS hits. In the hope, that non of the reported hits are from probes/variants that should have never made it into the final analyses. 

#### TO ADD TO PIPELINE 
We need to build into the pipeline a method to detect and/or flag these 
variants for removal, either, before or after the GenomeStudio stage.  

- A variant that is represented more than once, but given a different Illumina identifier.
    - same probe sequence
    - different Illumina identifier string either `IlmnID` or `Name`
- A variant whose probe sequence maps more than once to the reference genome
    - Probe A and or Probe B have `CIGAR == 50M` and map `> 1`
    - check that variant is not counted twice : where Probe A == Probe B 



*************

## Thoughts on BPM only Data
Illumina are either lazy or forgetful or these are "special" and Illumina, with their 
collaborators, don not want to share the data.

*************

 **`bin/create_update_allele_file.sh`**

```bash
#!/usr/bin/env bash
set -o errexit
set -o nounset

##########################################################################################
##											##
##	converts illumina genotype manifest.csv file to A/B update allele file		##
##											##
##########################################################################################


manifest=$1

awk -F, 'BEGIN {OFS="\t"} NR>8 && NF>6 {\
        if ($3=="TOP") print $2, "A B", substr($4, 2, 1)" "substr($4, 4, 1) ;\
        else if ($3=="BOT" && $4=="[A/G]") print $2, "A B", "T C";\
        else if ($3=="BOT" && $4=="[A/C]") print $2, "A B", "T G";\
        else if ($3=="BOT" && $4=="[A/T]") print $2, "A B", "T A";\
        else if ($3=="BOT" && $4=="[C/A]") print $2, "A B", "G T";\
        else if ($3=="BOT" && $4=="[C/G]") print $2, "A B", "G C";\
        else if ($3=="BOT" && $4=="[C/T]") print $2, "A B", "G A";\
        else if ($3=="BOT" && $4=="[G/A]") print $2, "A B", "C T";\
        else if ($3=="BOT" && $4=="[G/C]") print $2, "A B", "C G";\
        else if ($3=="BOT" && $4=="[G/T]") print $2, "A B", "C A";\
        else if ($3=="BOT" && $4=="[T/A]") print $2, "A B", "A T";\
        else if ($3=="BOT" && $4=="[T/G]") print $2, "A B", "A C";\
        else if ($3=="BOT" && $4=="[T/C]") print $2, "A B", "A G";\
        else print $2, "A B", substr($4, 2, 1)" "substr($4, 4, 1)}'\
        $manifest > $manifest.update_alleles_file

```

***********

## **bpm** only

No csv for these yet...

```
└── scratch
    ├── cvdsnp55v1_a.bpm
    ├── humanomni1-quad_v1-0_h.bpm
    └── humanomni25Exome-8v1_a.bpm
```

## Extracting an Illumina Manifest (.bpm) file 

Found through trial and error - the internet once said tha a `.bpm` was a compressed file of some sort...giving up for now...FU ILLUMINA!  

```bash
file -z -i cvdsnp55v1_a.bpm
```

Result: **application/octet-stream; charset=binary**  

```
cvdsnp55v1_a.bpm: application/octet-stream; charset=binary
```

```
##http://docstore.mik.ua/orelly/unix3/upt/ch21_12.htm  
#### DONT WORK 
## rename or copy bpm to bz2
### cp -v cvdsnp55v1_a.bpm cvdsnp55v1_a.bz2
## extract
### tar xjv cvdsnp55v1_a.bz2
```


***********