#!/bin/bash

source /mnt/home2/tabear/anaconda3/etc/profile.d/conda.sh

folder=../../../data/transcriptome/sqanti/sample1

conda activate isoseq

# Cluster
isoseq3 cluster \
../../../data/transcriptome/isoquant/sample1/flnc.bam \
${folder}/polished.bam \
--verbose \
--use-qvs \
--num-threads 20

# Minimap2
minimap2 \
-t 20 \
-ax splice -uf --secondary=no -C5 -O6,24 -B4 \
../../../data/ref_genome/hg38.fa \
${folder}/polished.hq.fasta.gz > reads.sam

conda deactivate

# 5.Samtools
samtools sort -O sam -o ${folder}/aln.sorted.sam -@ 20 ${folder}/reads.sam
***for IGV***
samtools view -b -o ${folder}/aln.sorted.bam ${folder}/aln.sorted.sam
samtools index -b -@ 20 ${folder}/aln.sorted.bam
*************

gzip -d ${folder}/polished.hq.fasta.gz

conda activate cupcake28

# 6.Cupcake
python3 ../../../tools/cDNA_Cupcake/cupcake/tofu/collapse_isoforms_by_sam.py \
--input ${folder}/polished.hq.fasta \
-s ${folder}/aln.sorted.sam \
-o ${folder}/isoforms \
--dun-merge-5-shorter

python3 ../../../tools/cDNA_Cupcake/cupcake/tofu/get_abundance_post_collapse.py \
${folder}/isoforms.collapsed \
${folder}/polished.cluster_report.csv

conda deactivate

# Create a fastq file for cupcake merge
../../../tools/bbmap/reformat.sh \
in=${folder}/isoforms.collapsed.rep.fa \
out=${folder}/isoforms.collapsed.rep.fastq

