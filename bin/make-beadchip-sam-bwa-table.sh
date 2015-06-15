#!/usr/bin/env bash
set -o errexit
set -o nounset

echo -e "\n>>>>START [make-beadchip-sam-bwa-table.sh ${1}]\n"   

## Assume awscli installed and set up properly
## This is set up specifically for our usage
S3BUCKET="illumina-probe-mappings"
BUCKET_URL="https://s3-eu-west-1.amazonaws.com/${S3BUCKET}"

## set names and get information
ILM_MANIFEST=${1}
BEAD_ARRAY=`basename ${ILM_MANIFEST} .csv`
FASTA=${BEAD_ARRAY}.fasta
SAM=${BEAD_ARRAY}.sam
SAMMD5=`md5sum ${SAM} | awk '{print $1}'`
SAM_SIZE=`du -h ${SAM} | awk '{print $1}'`



## make beadchip-sam-bwa-table.md
if [[ ! -e "beadchip-sam-bwa-table.md" ]]; then
        touch beadchip-sam-bwa-table.md
        echo -e "| BeadArray | Fasta | SAM File | Size | MD5 |" >> beadchip-sam-bwa-table.md
        echo -e "|-----------|-------|----------|------|-----|" >> beadchip-sam-bwa-table.md
fi

## add to table 
echo -e ".... Updating [beadchip-sam-bwa-table.md]"

    echo -e "| [${ILM_MANIFEST}](${BUCKET_URL}/) | [${FASTA}](${BUCKET_URL}/) | [${SAM}](${BUCKET_URL}/${SAM}) | ${SAM_SIZE} | ${SAMMD5}|" >> beadchip-sam-bwa-table.md

## copy to amazon s3 http://docs.aws.amazon.com/cli/latest/reference/s3/cp.html
#echo -e "\n.... Copying [${SAM}] to amazon s3 : [aws s3 cp ${SAM} s3://${S3BUCKET} --acl public-read]\n"
#
#   aws s3 cp ${SAM} s3://${S3BUCKET} --acl public-read 
#
#   echo -e "\n>>>>DONE [make-beadchip-sam-bwa-table.sh ${1}]\n"   
