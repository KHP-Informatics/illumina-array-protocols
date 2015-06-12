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
