#!/bin/bash

source /mnt/home2/tabear/anaconda3/etc/profile.d/conda.sh

out_folder=../../data/isoquant
script_folder=scripts
isoquant_gtf=../../data/transcriptomics/isoquant/00_aln.sorted/00_aln.sorted.transcript_models
isoquant_counts=../../data/transcriptomics/isoquant/00_aln.sorted.transcript_model_counts.tsv
classification=../../data/transcriptomics/isoquant/isoquant_transcript.SQANTI-like.tsv
gencode=../../data/ref_genome/gencode.v39.primary_assembly.annotation.gtf
genome=../../data/ref_genome/g38.fa 
dataset=$(basename $isoquant_gtf .transcript_models)
echo "$dataset"
name=hnr_50

# ####################### 0.Prepare sqanti-like file from isoquant gtf #########################
conda activate isoquant

python ${script_folder}/create_sqanti_from_gtf.py \
--input_gtf ${isoquant_gtf}.gtf \
--input_fl_counts $isoquant_counts \
--outputfile $classification

conda deactivate

conda activate lrp

######################## 1.Create a gencode database #########################
mkdir ${out_folder}/1_make_gencode_database

python ${script_folder}/1a_prepare_reference_tables.py \
--gtf $gencode \
--fa ../../data/ref_genome/gencode.v39.pc_translations.fa \
--ensg_gene ${out_folder}/1_make_gencode_database/ensg_gene.tsv \
--enst_isoname ${out_folder}/1_make_gencode_database/enst_isoname.tsv \
--gene_ensp ${out_folder}/1_make_gencode_database/gene_ensp.tsv \
--gene_isoname ${out_folder}/1_make_gencode_database/gene_isoname.tsv \
--isoname_lens ${out_folder}/1_make_gencode_database/isoname_lens.tsv \
--gene_lens ${out_folder}/1_make_gencode_database/gene_lens.tsv \
--protein_coding_genes ${out_folder}/1_make_gencode_database/protein_coding_genes.txt

python ${script_folder}/1b_make_gencode_database.py \
--gencode_fasta /mnt/xomics/tabear/ref_genome/GRCh38/pacbio/gencode.v39.pc_translations.fa \
--protein_coding_genes ${out_folder}/1_make_gencode_database/protein_coding_genes.txt \
--output_fasta ${out_folder}/1_make_gencode_database/gencode_protein.fasta \
--output_cluster ${out_folder}/1_make_gencode_database/gencode_isoname_clusters.tsv

######################### 2a. Convert the transcript_id in the isoquant output to uppercase to match the CPAT output #########################
python ${script_folder}/2a_gtf_uppercase.py \
--gtf ${isoquant_gtf}.gtf \
--gtf_out ${isoquant_gtf}_upper.gtf

/mnt/xomics/renees/tools/TransDecoder-TransDecoder-v5.5.0/util/gtf_genome_to_cdna_fasta.pl \
${isoquant_gtf}_upper.gtf \
$genome \
> ${isoquant_gtf}_upper.fasta

####################### 2. Filter pacbio output #########################
mkdir ${out_folder}/2_filter_isoquant

python ${script_folder}/2_filter_isoquant.py \
--classification ${lassification} \
--corrected_fasta ${isoquant_gtf}_upper.fasta \
--corrected_gtf ${isoquant_gtf}_upper.gtf \
--protein_coding_genes ${out_folder}/1_make_gencode_database/protein_coding_genes.txt \
--ensg_gene ${out_folder}/1_make_gencode_database/ensg_gene.tsv \
--filter_protein_coding yes \
--structural_categories_level novel \
--out_dir ${out_folder}/2_filter_isoquant

######################## 3. transcriptome_summary #########################
mkdir ${out_folder}/3_transcriptome_summary

python ${script_folder}/3_transcriptome_summary.py \
--sq_out ${out_folder}/2_filter_isoquant/filtered_isoquant_transcript.SQANTI-like.tsv \
--ensg_to_gene ${out_folder}/1_make_gencode_database/ensg_gene.tsv \
--enst_to_isoname ${out_folder}/1_make_gencode_database/enst_isoname.tsv \
--len_stats ${out_folder}/1_make_gencode_database/gene_lens.tsv \
--odir ${out_folder}/3_transcriptome_summary/

######################### 4. CPAT #########################
mkdir ${out_folder}/4_cpat

nextflow ${script_folder}/4_cpat.nf \
--name $name \
--hexamer ../../data/proteomics/Human_Hexamer.tsv \
--logit_model ../../data/proteomics/Human_logitModel.RData \
--sample_fasta ${out_folder}/2_filter_isoquant/filtered_${dataset}.transcript_models_upper.fasta \
--min_orf 50 \
--outdir ${out_folder}/4_cpat/


######################### 5. ORF calling (adapted to exclude stop codon) #########################
mkdir ${out_folder}/5_orf_calling

python ${script_folder}/5_orf_calling.py \
--orf_coord ${out_folder}/4_cpat/cpat/${name}.ORF_prob.tsv \
--orf_fasta ${out_folder}/4_cpat/cpat/${name}.ORF_seqs.fa \
--gencode $gencode \
--sample_gtf ${out_folder}/2_filter_isoquant/filtered_${dataset}.transcript_models_upper.gtf \
--pb_gene ${out_folder}/3_transcriptome_summary/pb_gene.tsv \
--classification ${out_folder}/2_filter_isoquant/filtered_$(basename $classification) \
--sample_fasta ${out_folder}/2_filter_isoquant/filtered_${dataset}.transcript_models_upper.fasta \
--num_cores 10 \
--output ${out_folder}/5_orf_calling/${name}

######################### 6. Refine ORF database #########################
mkdir ${out_folder}/6_refine_orf_database

python ${script_folder}/6_refine_orf_database.py \
--name ${out_folder}/6_refine_orf_database/$name \
--orfs ${out_folder}/5_orf_calling/${name}_best_orf_without_stop.tsv \
--pb_fasta ${out_folder}/2_filter_isoquant/filtered_${dataset}.transcript_models_upper.fasta \
--coding_score_cutoff 0.0

######################### 7. Make PacBio CDS GTF #########################
mkdir ${out_folder}/7_make_pacbio_cds_gtf

python ${script_folder}/7_make_pacbio_cds_gtf.py \
--sample_gtf ${out_folder}/2_filter_isoquant/filtered_${dataset}.transcript_models_upper.gtf \
--agg_orfs ${out_folder}/6_refine_orf_database/${name}_orf_refined.tsv \
--refined_orfs ${out_folder}/5_orf_calling/${name}_best_orf_without_stop.tsv \
--pb_gene ${out_folder}/3_transcriptome_summary/pb_gene.tsv \
--output_cds ${out_folder}/7_make_pacbio_cds_gtf/${name}_cds.gtf

######################### 8. Rename CDS to exon (changes classification to sqanti classification) #########################
mkdir ${out_folder}/8_rename_cds_to_exon

python ${script_folder}/8_rename_cds_to_exon.py \
--sample_gtf ${out_folder}/7_make_pacbio_cds_gtf/${name}_cds.gtf \
--sample_name ${out_folder}/8_rename_cds_to_exon/${name} \
--reference_gtf $gencode \
--reference_name ${out_folder}/8_rename_cds_to_exon/gencode \
--num_cores 10

######################### 9. SQANTI protein #########################
mkdir ${out_folder}/9_sqanti_protein

nextflow ${script_folder}/9_sqanti_protein.nf \
--outdir ${out_folder}/9_sqanti_protein \
--name $name \
--sample_gtf ${out_folder}/7_make_pacbio_cds_gtf/hnr_cds.gtf \
--best_orf ${out_folder}/5_orf_calling/hnr_best_orf_without_stop.tsv \
--reference_gtf ../../data/ref_genome/gencode.v39.primary_assembly.annotation.gtf \
--sample_exon ${out_folder}/8_rename_cds_to_exon/hnr_50.transcript_exons_only.gtf \
--sample_cds ${out_folder}/8_rename_cds_to_exon/hnr_50.cds_renamed_exon.gtf \
--reference_exon ${out_folder}/8_rename_cds_to_exon/gencode.transcript_exons_only.gtf \
--reference_cds ${out_folder}/8_rename_cds_to_exon/gencode.cds_renamed_exon.gtf \

######################### 10. Add Isoquant classification (to change the sqanti classification assigned in step 8 back to isoquant) #########################
mkdir ${out_folder}/10_add_isoquant_classification

python ${script_folder}/10_add_isoquant_classification.py \
--isoquant $classification \
--sqanti_p ${out_folder}/9_sqanti_protein/${name}.sqanti_protein_classification.tsv \
--out ${out_folder}/10_add_isoquant_classification/${name}.sqanti_protein_isoquant_classification.tsv 

######################### 11. 5' UTR status #########################
mkdir ${out_folder}/11_5utr 

python ${script_folder}/11a_get_gc_exon_and_5utr_info.py \
--gencode_gtf $gencode  \
--odir ${out_folder}/11_5utr 

python ${script_folder}/11b_classify_5utr_status.py \
--gencode_exons_bed ${out_folder}/11_5utr/gencode_exons_for_cds_containing_ensts.bed \
--gencode_exons_chain ${out_folder}/11_5utr/gc_exon_chain_strings_for_cds_containing_transcripts.tsv \
--sample_cds_gtf ${out_folder}/7_make_pacbio_cds_gtf/${name}_cds.gtf \
--odir ${out_folder}/11_5utr 
  
python ${script_folder}/11c_merge_5utr_info_to_pclass_table.py \
--name $name \
--utr_info ${out_folder}/11_5utr/pb_5utr_categories.tsv \
--sqanti_protein_classification ${out_folder}/10_add_isoquant_classification/${name}.sqanti_protein_isoquant_classification.tsv \
--odir ${out_folder}/11_5utr 


######################### 12. Protein Classification #########################
mkdir ${out_folder}/12_protein_classification 

python ${script_folder}/12a_protein_classification_add_meta.py \
--protein_classification ${out_folder}/11_5utr/${name}.sqanti_protein_classification_w_5utr_info.tsv \
--best_orf ${out_folder}/5_orf_calling/${name}_best_orf_without_stop.tsv \
--refined_meta ${out_folder}/6_refine_orf_database/${name}_orf_refined.tsv  \
--ensg_gene ${out_folder}/1_make_gencode_database/ensg_gene.tsv \
--name $name \
--dest_dir ${out_folder}/12_protein_classification/ 

python ${script_folder}/12b_protein_classification.py \
--sqanti_protein ${out_folder}/12_protein_classification/${name}.protein_classification_w_meta.tsv \
--name $name \
--dest_dir ${out_folder}/12_protein_classification/

######################### 13. Protein Gene Rename #########################
mkdir ${out_folder}/13_protein_gene_rename

python ${script_folder}/13_protein_gene_rename.py \
--sample_gtf ${out_folder}/7_make_pacbio_cds_gtf/${name}_cds.gtf \
--sample_protein_fasta ${out_folder}/6_refine_orf_database/${name}_orf_refined.fasta \
--sample_refined_info ${out_folder}/6_refine_orf_database/${name}_orf_refined.tsv \
--pb_protein_genes ${out_folder}/12_protein_classification/${name}.protein_classification.tsv \
--name ${out_folder}/13_protein_gene_rename/${name}

######################### 14. Protein Filter #########################
mkdir ${out_folder}/14_protein_filter

python ${script_folder}/14_protein_filter.py \
--protein_classification ${out_folder}/12_protein_classification/${name}.protein_classification.tsv \
--gencode_gtf $gencode \
--protein_fasta ${out_folder}/13_protein_gene_rename/${name}.protein_refined.fasta \
--sample_cds_gtf ${out_folder}/13_protein_gene_rename/${name}_with_cds_refined.gtf \
--min_junctions_after_stop_codon 2 \
--name 14_protein_filter/${name}

######################### 15. Make Hybrid Database #########################
mkdir ${out_folder}/15_hybrid_database

python ${script_folder}/15_make_hybrid_database.py \
--protein_classification ${out_folder}/12_protein_classification/${name}.protein_classification.tsv \
--pb_fasta ${out_folder}/14_protein_filter/${name}.filtered_protein.fasta \
--gc_fasta ${out_folder}/1_make_gencode_database/gencode_protein.fasta \
--name ${out_folder}/15_hybrid_database/${name}

conda deactivate