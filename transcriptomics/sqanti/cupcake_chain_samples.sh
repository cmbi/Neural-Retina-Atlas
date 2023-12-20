#!/bin/bash

folder=../../data/transcriptomics/sqanti

conda activate cupcake28

# Chain the three samples
python3 ../../tools/cDNA_Cupcake/cupcake/tofu/counting/chain_samples.py \
samples.config count_fl --dun-merge-5-shorter --cpus 16

# Add a FL column to the abundance file
python ../../scripts/create_abundance.py

# Cupcake
python3 ../../tools/cupcake/tofu/filter_by_count.py \
${folder}/all_samples.chained \
--min_count=2 \
--dun_use_group_count

python3 ../../tools/cupcake/tofu/filter_away_subset.py \
${folder}/all_samples.chained.min_fl_2

conda deactivate

# SQANTI3 quality control
singularity run --bind ../../Neural-Retina-Atlas \
../../tools/sqanti3_5.1.sif sqanti3_qc.py \
${folder}/all_samples.chained.min_fl_2.filtered.gff \
../../data/ref_genome/gencode.v39.primary_assembly.annotation.gtf \
../../data/ref_genome/hg38.fa \
--CAGE_peak ../../data/ref_genome/human.refTSS_v3.1.hg38.bed \
--polyA_motif_list ../../data/ref_genome/mouse_and_human.polyA_motif.txt \
--polyA_peak ../../data/ref_genome/atlas.clusters.2.0.GRCh38.96.bed \
-fl ${folder}/all_samples.chained_count.txt \
--short_reads ../../data/sqanti/short_reads/tigem.fofn.sh \
-t 16 \
--skipORF \
--report pdf 

# SQANTI3 rules filter
singularity run --bind ../../Neural-Retina-Atlas \
../../tools/sqanti3_5.1.sif sqanti3_filter.py \
rules \
--isoforms ${folder}/all_samples.chained.min_fl_2.filtered_corrected.fasta \
--gtf ${folder}/all_samples.chained.min_fl_2.filtered_corrected.gtf \
--filter_mono_exonic \
${folder}/all_samples.chained.min_fl_2.filtered_classification.txt
