#!/usr/bin/env bash
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

echo -e "\n>>>> START [make-fasta-from-annotation-csv.sh ${1}]\n"
#sleep 1s

## beadChip name 
BEADCHIP=`basename ${MY_FILE} .csv`

## remove header and tails and add new name for look-ups
echo -e ".... Make new annotation file: remove header and ending guff and add new name for look-ups > [${BEADCHIP}.txt]"

    awk -F "," 'NR > 7 {print $0}' ${BEADCHIP}.csv | grep -v ^00 | grep -v "Controls" | \
            awk -F "," '{print $1"  "$2","$0}' > ${BEADCHIP}.txt

## Get Probe A Only Variants fasta
echo -e ".... Make Fasta File for Variants with single probe sequence (A) only > [${BEADCHIP}.single.probe.A.fasta]"

    cat ${BEADCHIP}.txt  | sed '1d' | tr ',' '\t' | awk ' $9 !~ /[ATCG]/ ' | \
            awk '{print ">"$1"\n"$7}' > ${BEADCHIP}.single.probe.A.fasta

## Get Probe A & B Variants fasta
echo -e ".... Make Fasta File for Variants with mulitiple probe sequences (A & B) > [${BEADCHIP}.multi.probe.A.and.B.fasta]"

    cat ${BEADCHIP}.txt  | sed '1d' | tr ',' '\t' | awk -F "\t" ' $9 ~ /[ATCG]/ ' | \
            awk '{print ">"$1"_PobeA""\n"$7"\n"">"$1"_PobeB""\n"$9}' >  ${BEADCHIP}.multi.probe.A.and.B.fasta

## Combine fasta files for mapping
echo -e ".... Make Fasta File for All Variants: single and mulitiple probe sequences (A & B) > [${BEADCHIP}.fasta]"

    cat ${BEADCHIP}.single.probe.A.fasta ${BEADCHIP}.multi.probe.A.and.B.fasta > ${BEADCHIP}.fasta

## END    
echo -e "\n>>>> DONE [make-fasta-from-annotation-csv.sh ${1}]\n"
#sleep 1s
