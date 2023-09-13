#!/bin/bash

source /mnt/home2/tabear/anaconda3/etc/profile.d/conda.sh

name="sample1"
folder=../data/transcriptomics/isoquant/${name}

conda activate isoseq

# CCS
# add the path to the raw data file
ccs ${name}.subreads.bam ${folder}/ccs.bam  --min-rq 0.99 --num-threads 20 --maxLength=25000 --min-passes 3

conda deactivate