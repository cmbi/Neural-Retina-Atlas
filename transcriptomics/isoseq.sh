#!/bin/bash

name="sample1"
folder=../data/transcriptomics/isoquant/${name}

conda activate isoseq

# Lima
lima ccs.bam \
data/pacbio/primers.fasta \
${folder}/fl.bam \
--isoseq \
-j 20 \
--peek-guess 

# Refine
isoseq3 refine \
${folder}/fl.NEB_5p--NEB_Clontech_3p.bam \
data/pacbio/primers.fasta flnc.bam \
-j 20 \
--require-polya

conda deactivate
conda activate bamfastq

# convert BAM to FASTQ
bam2fastq -o ${folder}/flnc.fastq ${folder}/flnc.bam

conda deactivate
conda activate isoseq

# Minimap2
minimap2 \
-t 20 \
-ax splice -uf --secondary=no -C5 -O6,24 -B4 --MD \
../data/ref_genome/hg38.fa \
 ${folder}/flnc.fastq > reads.sam

conda deactivate

# Samtools
samtools sort -O sam -o aln.sorted.sam -@ 20 reads.sam
samtools view -b -o aln.sorted.bam aln.sorted.sam
samtools index -b -@ 20 aln.sorted.bam

