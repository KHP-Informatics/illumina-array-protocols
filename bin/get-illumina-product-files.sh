#!/usr/bin/env bash
set -o errexit
set -o nounset

## get illumina data for Human* SNP arrays
for i in PsychArray \
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
        
        wget -r -c -b ftp://webdata:webdata@ussd-ftp.illumina.com/Downloads/ProductFiles/${i};
        
        done
