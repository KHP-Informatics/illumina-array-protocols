#!/usr/bin/env bash
set -o errexit
set -o nounset

## set name
#
array_csv=""

## remove header and strip stupid end of the files
#
awk -F ","   'NR > 7 {print $0}' ${array_csv}.csv | grep -v ^00 | grep -v "Controls" > ${array}_annotations.csv

