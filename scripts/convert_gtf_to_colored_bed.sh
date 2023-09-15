#!/bin/bash

source /mnt/home2/tabear/anaconda3/etc/profile.d/conda.sh

conda activate lrp

# IsoQuant transcripts
gtfToGenePred ../data/transcriptomics/isoquant_aln.sorted.transcript_models.gtf ../data/transcriptomics/isoquant_aln.sorted.transcript_models.genePred
genePredToBed ../data/transcriptomics/isoquant_aln.sorted.transcript_models.genePred  ../data/transcriptomics/isoquant_aln.sorted.transcript_models.bed12
python add_color_to_gtf.py ../data/transcriptomics/isoquant_aln.sorted.transcript_models.bed12 ../data/transcriptomics/isoquant_aln.sorted.transcript_models_colored.bed12 --mapping_function transcript

# IsoQuant ORFs
gtfToGenePred ../data/proteomics/hnr_50_with_cds_filtered.gtf ../data/proteomics/hnr_50_with_cds_filtered.genePred
genePredToBed  ../data/proteomics/hnr_50_with_cds_filtered.genePred  ../data/proteomics/hnr_50_with_cds_filtered.bed12
python add_color_to_gtf.py ../data/proteomics/hnr_50_with_cds_filtered.bed12 ../data/proteomics/hnr_50_with_cds_filtered_colored.bed12 --mapping_function orf

conda deactivate

