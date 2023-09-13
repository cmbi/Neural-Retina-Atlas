#!/bin/bash

conda activate talon

folder=../../data/transcriptomics/talon

# Create database
talon_initialize_database \
--f ../../data/ref_genome/gencode.v39.primary_assembly.annotation.gtf \
--g hg38 \
--a gencode_v39 \
--o ${folder}/venice

# Add samples to database
talon \
--f config.csv \
--db venice.db \
--build hg38 \
--threads 10 \
--o ${folder}/venice

# Filter transcripts
talon_filter_transcripts \
--db venice.db \
-a gencode_v39 \
--minCount 2 \
--minDatasets 1 \
--o ${folder}/flcount2_1.csv

# Get counts for filtered transcripts
talon_abundance \
--db venice.db \
--a gencode_v39 \
--build hg38 \
--whitelist ${folder}/flcount2_1.csv \
--o ${folder}/venice

# Create GTF file
talon_create_GTF \
--db venice.db \
--a gencode_v39 \
--build hg38 \
--o ${folder}/venice_fl2 \
--whitelist ${folder}/flcount2_1.csv

conda deactivate