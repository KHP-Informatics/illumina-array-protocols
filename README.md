# [illumina](http://www.illumina.com/)-array-protocols
**Protocols/scripts for processing illumina SNP arrays**  
**VERSION: v0.1**  

### The Team 
**Bioinformatics** - Hamel Patel, Amos Folarin & Stephen Jeffrey Newhouse  
**Lab** - MRC SGDP (Charles Curtis)  

******

A set of scripts and protocols that we use to processing raw Illumina SNP array data.

- BWA Mapping of probe sequences  
- Genomestudio SOP (Manual Calling & QC)    
- Standard QC (PLINK, bash...) and re-calling No-Calls using zCall  

### Illumina Web Resources
This links takes you to Illumina's download page, which provides access to product documentation and
manifests.

- [Illumina Downloads](http://support.illumina.com/downloads.html)

### BeadChips
- [HumanCoreExome-24 v1.0 BeadChip](http://support.illumina.com/downloads/humancoreexome-24-v1-0-product-files.html)  
- [HumanOmniExpressExome-8 v1.1 BeadChip](http://support.illumina.com/downloads/humanomniexpressexome-8v1-1_product_files.html)   


****** 

## 1. BWA Mapping  

Illumina SNP arrays include alot of probes that map to multiple (>500) sites in the Genome.  

For each array we map the probe sequences to the relevant genome build using BWA (as indicated by Illumina manifests), and
identify probes that map 100% to multiple regions (>1 hit) of the genome.

These probes are either flagged for removal before re-calling, or depending on what the data looks likes in Genomestudio,
are zeroed at the Genomestudio stage before clustering.  

Those familiar with Illumina Arrays, will see that alot of the probes we identify are those poorly clustered variants, no-calls for alot of samples, messy clouds and/or the always homozygous variants - no matter the population or number of samples. 

More details soon....  

**Running BWA**  

```bash
###################################
## BWA > samblaster > samtools
# run on a 32 core machine 
#
bwa mem -t 32 -V -M -a ${refGenome} ${array}.fasta | \
samblaster --addMateTags --excludeDups | \
samtools sort -@ 32 -T xx -O sam -o ${array}.sam && \
samtools index ${array}.sam && \
rm ${array}.sam
```

### Illumina Array Annotations

- [mega_array_annotations.txt](https://s3-eu-west-1.amazonaws.com/illumina-probe-mappings/mega_array_annotations.txt.gz)  
- ["HumanCoreExome-24v1-0_A.csv"](ftp://webdata:webdata@ussd-ftp.illumina.com/Downloads/ProductFiles/HumanCoreExome-24/Product_Files/HumanCoreExome-24v1-0_A.csv)  
- [HumanOmniExpressExome-8-v1-1-C.csv](ftp://webdata:webdata@ussd-ftp.illumina.com/Downloads/ProductFiles/HumanOmniExpressExome/v1-1/HumanOmniExpressExome-8-v1-1-C.csv)  
- []()
- []()
- []()

### Probe Lists
- ...
- ...  

### BWA BAM Files
**MEGA**    
- [mega_array_seq_sorted.bam](https://s3-eu-west-1.amazonaws.com/illumina-probe-mappings/mega_array_seq_sorted.bam)  
- [mega_array_seq_sorted.bam.bai](https://s3-eu-west-1.amazonaws.com/illumina-probe-mappings/mega_array_seq_sorted.bam.bai)  

**OMNI**  
- ...   
- ...     

## 2. Genomestudio 

More details soon....

## 3. Quality Control and Re-Calling  

More details soon....

******

### Genotypes and Samples Processed  


******
Copyright (C) 2015 Hamel Patel, Amos Folarin & Stephen Jeffrey Newhouse


