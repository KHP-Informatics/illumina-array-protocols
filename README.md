# [illumina](http://www.illumina.com/)-array-protocols
** *work in progress..some links dont work and data and scritps to be added asap* **  

## Protocols for processing illumina SNP arrays 

**VERSION: v0.1**  
**Date: June 2015**  


A set of scripts and protocols that we use to processing raw Illumina SNP array data.

- BWA Mapping of probe sequences  
- Genomestudio SOP (Manual Calling & QC)    
- Standard QC (PLINK, bash...) and re-calling No-Calls using zCall  

## The Team 
**Bioinformatics** - Hamel Patel, Amos Folarin & Stephen Newhouse  @ [bluecell.io]()   

**Lab** - Charles Curtis & Team @ [The IoPPN Genomics & Biomarker Core Facility](http://www.kcl.ac.uk/ioppn/depts/mrc/research/The-IoPPN-Genomics--Biomarker-Core-Facility.aspx)  

![illuminaCSPro](./figs/CSProLogo-new-Cropped-313x105.png)

## Illumina Downloads Resource
We provide links out to Illumina product data, as these are often not easliy found by the web/tech/google niave.  

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

### No. Genotypes and Samples Processed  

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

`get-illumina-product-files.sh`


```bash
#!/usr/bin/env bash
set -o errexit
set -o nounset

## get illumina data for Human* SNP arrays
for i in \
PsychArray \
HumanCore \
HumanCore-24 \
HumanCoreExome \
HumanCoreExome-24  \
HumanCVD  \
HumanExome \
HumanGenotypingArrays \
HumanOmni1-Quad \
HumanOmni2-5Exome-8 \
HumanOmni5-Quad \
HumanOmni5Exome \
HumanOmni5MExome \
HumanOmni25 \
HumanOmniExpress \
HumanOmniExpress-24 \
HumanOmniExpressExome \
HumanOmniZhongHua-8; do
wget -r -c -b \
ftp://webdata:webdata@ussd-ftp.illumina.com/Downloads/ProductFiles/${i};
done
```
Not all of this works. We get Errors about file not existing.

```
--2015-06-12 12:16:30--  ftp://webdata:*password*@ussd-ftp.illumina.com/Downloads/ProductFiles/PsychArray
           => ‘ussd-ftp.illumina.com/Downloads/ProductFiles/.listing’
Resolving ussd-ftp.illumina.com (ussd-ftp.illumina.com)... 66.192.10.36
Connecting to ussd-ftp.illumina.com (ussd-ftp.illumina.com)|66.192.10.36|:21... connected.
Logging in as webdata ... Logged in!
==> SYST ... done.    ==> PWD ... done.
==> TYPE I ... done.  ==> CWD (1) /Downloads/ProductFiles ... done.
==> PASV ... done.    ==> LIST ... done.

     0K ..                                                      374M=0s

2015-06-12 12:16:35 (374 MB/s) - ‘ussd-ftp.illumina.com/Downloads/ProductFiles/.listing’ saved [2451]

ussd-ftp.illumina.com/Downloads/ProductFiles/.listing: No such file or directory
unlink: No such file or directory
--2015-06-12 12:16:35--  ftp://webdata:*password*@ussd-ftp.illumina.com/Downloads/ProductFiles/PsychArray
           => ‘ussd-ftp.illumina.com/Downloads/ProductFiles/PsychArray’
==> CWD not required.
==> SIZE PsychArray ... done.
==> PASV ... done.    ==> RETR PsychArray ...
No such file ‘PsychArray’.
```

Jobs killed and now trying...

```bash
wget -r -c -b ftp://webdata:webdata@ussd-ftp.illumina.com/Downloads/ProductFiles/;
```

## csv formats

**Header** `HumanCoreExome-24v1-0_A.csv`

- skip 7  
- remove tail -24



```bash
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

```bash
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

