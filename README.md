# illumina-array-protocols

**Protocols/scripts for processing illumina SNP arrays**  

**VERSION: v0.1**  
**Bioinformatics** - Hamel Patel, Amos Folarin & Stephen Jeffrey Newhouse  
**Lab** - MRC SGDP (Charles Curtis)  

******

A set of scripts and protocols that we use to processing raw Illumina SNP array data.

- BWA Mapping of probe sequences  
- Genomestudio SOP (Manual Calling & QC)    
- Standard QC (PLINK, bash...) and re-calling No-Calls using zCall  

## BWA Mapping  

Illumina SNP arrays include alot of probes that map to multiple (>500) sites in the Genome.
For each array we map the probe sequences to the relevant genome build using BWA (as indicated by Illumina manifests), and
identify probes that map 100% to multiple regions (>1 hit) of the genome.

These probes are either flagged for removal before re-calling, or depending on what the data looks likes in Genomestudio,
are zeroed at the Genomestudio stage before clustering.  

More details soon....

## Genomestudio 

## Qualitty Control and Re-Calling  


******
Copyright (C) 2015 Hamel Patel, Amos Folarin & Stephen Jeffrey Newhouse


