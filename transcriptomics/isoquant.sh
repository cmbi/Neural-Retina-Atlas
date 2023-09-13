#!/bin/bash

isoquant.py \
--reference ../data/ref_genome/hg38.fa  \
--genedb ../data/gencode.v39.primary_assembly.annotation.gtf \
--complete_genedb \
--bam_list files.txt \
--read_group file_name \
--data_type pacbio_ccs \
--fl_data \
--sqanti_output \
--count_exons \
--threads 20 \
--model_construction_strategy fl_pacbio \
-o isoquant/ \
--check_canonical \
--transcript_quantification unique_only \
--gene_quantification unique_only \
--splice_correction_strategy default_pacbio 