#!/bin/bash
#$ -cwd
#$ -o lrp_2.out
#$ -e lrp_2.err
#$ -V
#$ -pe smp 1
#$ -q all.q@narrativum.umcn.nl,all.q@noggo.umcn.nl

source /mnt/home2/tabear/anaconda3/etc/profile.d/conda.sh

out_folder=/mnt/xomics/tabear/atlas_paper/proteome/lrp_talon
script_folder=/mnt/xomics/tabear/atlas_paper/proteome/modules_talon
talon_classification_fl=/mnt/xomics/tabear/atlas_paper/transcriptome/talon/venice_talon_abundance_filtered_fl.tsv
gencode=/mnt/xomics/tabear/ref_genome/GRCh38/pacbio/gencode.v39.primary_assembly.annotation.gtf
name=hnr_50

conda activate lrp

######################### 10. Add Isoquant classification (to change the sqanti classification assigned in step 8 back to isoquant) #########################
mkdir ${out_folder}/10_add_talon_classification

python ${script_folder}/10_add_TALON_classification/add_talon_classification.py \
--talon $talon_classification_fl \
--sqanti_p ${out_folder}/9_sqanti_protein/${name}.sqanti_protein_classification.tsv \
--out ${out_folder}/10_add_talon_classification/${name}.sqanti_protein_talon_classification.tsv 


######################### 11. 5' UTR status #########################
mkdir ${out_folder}/11_5utr 

python ${script_folder}/11_5p_utr_status/1_get_gc_exon_and_5utr_info.py \
--gencode_gtf $gencode  \
--odir ${out_folder}/11_5utr 

python ${script_folder}/11_5p_utr_status/2_classify_5utr_status.py \
--gencode_exons_bed ${out_folder}/11_5utr/gencode_exons_for_cds_containing_ensts.bed \
--gencode_exons_chain ${out_folder}/11_5utr/gc_exon_chain_strings_for_cds_containing_transcripts.tsv \
--sample_cds_gtf ${out_folder}/7_make_pacbio_cds_gtf/${name}_cds.gtf \
--odir ${out_folder}/11_5utr 
  
python ${script_folder}/11_5p_utr_status/3_merge_5utr_info_to_pclass_table.py \
--name $name \
--utr_info ${out_folder}/11_5utr/pb_5utr_categories.tsv \
--sqanti_protein_classification ${out_folder}/10_add_talon_classification/${name}.sqanti_protein_talon_classification.tsv \
--odir ${out_folder}/11_5utr 

######################### 12. Protein Classification #########################
mkdir ${out_folder}/12_protein_classification 

python ${script_folder}/12_protein_classification/protein_classification_add_meta.py \
--protein_classification ${out_folder}/11_5utr/${name}.sqanti_protein_classification_w_5utr_info.tsv \
--best_orf ${out_folder}/5_orf_calling/${name}_best_orf_without_stop.tsv \
--refined_meta ${out_folder}/6_refine_orf_database/${name}_orf_refined.tsv  \
--ensg_gene ${out_folder}/1_make_gencode_database/ensg_gene.tsv \
--name $name \
--dest_dir ${out_folder}/12_protein_classification/ 

python ${script_folder}/12_protein_classification/protein_classification.py \
--sqanti_protein ${out_folder}/12_protein_classification/${name}.protein_classification_w_meta.tsv \
--name $name \
--dest_dir ${out_folder}/12_protein_classification/

######################### 13. Protein Gene Rename #########################
mkdir ${out_folder}/13_protein_gene_rename

python ${script_folder}/13_protein_gene_rename/protein_gene_rename.py \
--sample_gtf ${out_folder}/7_make_pacbio_cds_gtf/${name}_cds.gtf \
--sample_protein_fasta ${out_folder}/6_refine_orf_database/${name}_orf_refined.fasta \
--sample_refined_info ${out_folder}/6_refine_orf_database/${name}_orf_refined.tsv \
--pb_protein_genes ${out_folder}/12_protein_classification/${name}.protein_classification.tsv \
--name ${out_folder}/13_protein_gene_rename/${name}

######################### 14. Protein Filter #########################
mkdir ${out_folder}/14_protein_filter

python ${script_folder}/14_protein_filter/protein_filter.py \
--protein_classification ${out_folder}/12_protein_classification/${name}.protein_classification.tsv \
--gencode_gtf $gencode \
--protein_fasta ${out_folder}/13_protein_gene_rename/${name}.protein_refined.fasta \
--sample_cds_gtf ${out_folder}/13_protein_gene_rename/${name}_with_cds_refined.gtf \
--min_junctions_after_stop_codon 2 \
--name 14_protein_filter/${name}

######################### 15. Make Hybrid Database #########################
mkdir ${out_folder}/15_hybrid_database

python ${script_folder}/15_make_hybrid_database/make_hybrid_database.py \
--protein_classification ${out_folder}/12_protein_classification/${name}.protein_classification.tsv \
--pb_fasta ${out_folder}/14_protein_filter/${name}.filtered_protein.fasta \
--gc_fasta ${out_folder}/1_make_gencode_database/gencode_protein.fasta \
--name ${out_folder}/15_hybrid_database/${name}

conda deactivate