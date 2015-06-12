# [illumina](http://www.illumina.com/)-array-protocols
** *work in progress..some links dont work and data and scripts to be added asap* **  

****

# Protocols for processing illumina SNP arrays 
 
**VERSION: v0.1**  
**Date: June 2015**  
**Authors: Stephen Newhouse, Hamel Patel, Amos Folarin, Charles Curtis**

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

## Scratch (Lab Book)
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

`bin/make-fasta-from-annotation-csv.sh`

```sh
#!/usr/bin/env sh
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
samtools sort -@ ${NCPU} -T temp_ -O sam -o ${array}.sam && \
samtools index ${array}.sam && \
rm ${array}.sam]\n"

## Run BWA 
docker run --rm \
-w /home/pipeman \
-e HOME=/home/pipeman \
-e USER=pipeman --user pipeman \
-i -t compbio/ngseasy-bwa:1.0 /bin/bash -c \
"bwa mem -t 32 -V -M -a ${refGenome} ${FASTA}.fasta | \
samblaster --addMateTags --excludeDups | \
samtools sort -@ 32 -T temp_ -O sam -o ${array}.sam && \
samtools index ${array}.sam && \
rm ${array}.sam"
wait

echo -e "\n>>>> END [aln-fasta-bwa-docker.sh ${1} ${2} ${3}]\n"
```