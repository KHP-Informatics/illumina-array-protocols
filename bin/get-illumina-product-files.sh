#!/usr/bin/env bash
set -o errexit
set -o nounset

## get illumina data for Human* SNP arrays

wget -r -c -b ftp://webdata:webdata@ussd-ftp.illumina.com/downloads/productfiles/
