#!/bin/bash

name="sample1"
folder="../../data/transcriptomics/talon/${name}"

conda activate bamfastq

# convert BAM to FASTQ
bam2fastq -o ${folder}/flnc.fastq ../../data/transcriptomics/isoquant/${name}/flnc.bam

conda deactivate

conda activate isoseq

# Minimap2
minimap2 \
-t 20 \
-ax splice -uf --secondary=no -C5 -O6,24 -B4 --MD \
../../../data/ref_genome/hg38.fa \
 ${folder}/flnc.fastq >  ${folder}/reads.sam

conda deactivate

# Samtools
samtools sort -O sam -o  ${folder}/aln.sorted.sam -@ 20  ${folder}/reads.sam
# ***for IGV***#
samtools view -b -o  ${folder}/aln.sorted.bam  ${folder}/aln.sorted.sam
samtools index -b -@ 20  ${folder}/aln.sorted.bam
# *************

conda activate talon

# TranscriptClean
python ../../tools/TranscriptClean/TranscriptClean.py \
--sam  ${folder}/aln.sorted.sam \
--canonOnly \
--genome ../../data/ref_genome/hg38.small.fa \
--spliceJns "../../data/transcriptomics/short_reads/SJ.retina.tc.tab" \
--outprefix ${folder}/$name \
--threads 20

# Label reads for internal priming
talon_label_reads \
--f ${name}_clean.sam \
--g ../../data/ref_genome/hg38.fa  \
--t 8 \
--deleteTmp \
--o ${folder}/$name

conda deactivate