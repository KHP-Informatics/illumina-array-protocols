#!/usr/bin/env bash
set -o errexit
set -o nounset
########################################################################################################
# Program: aln-bwa
# Version 0.1
# Author: Stephen Newhouse (stephen.j.newhouse@gmail.com);
###########################################################################################


###################################
## BWA > samblaster > samtools
#

array=""
refGenome=""

bwa mem -t 32 -V -M -a ${refGenome} ${array}.fasta | \
samblaster --addMateTags --excludeDups | \
samtools sort -@ 32 -T temp_ -O sam -o ${array}.sam && \
samtools index ${array}.sam && \
rm ${array}.sam
