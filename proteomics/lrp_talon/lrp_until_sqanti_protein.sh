#!/bin/bash

out_folder=../../data/proteomics/talon
script_folder=proteomics/lrp_talon
talon_gtf=../../data/transcriptomics/talon/venice_fl2_talon
talon_classification=../../data/transcriptomics/talon/venice_talon_abundance_filtered.tsv
talon_classification_fl=../..data/transcriptome/talon/venice_talon_abundance_filtered_fl.tsv
gencode=../../data/ref_genome/gencode.v39.primary_assembly.annotation.gtf
genome=../../data/ref_genome/g38.fa 
dataset=$(basename $talon_gtf)
echo "$dataset"
name=hnr_50

conda activate lrp

######################## 0.Add FL to abundance file #########################
python ${script_folder}/0_add_fl_to_talon.py \
$talon_classification

######################## 1.Create a gencode database #########################
mkdir ${out_folder}/1_make_gencode_database

python ${script_folder}/1a_prepare_reference_tables/prepare_reference_tables.py \
--gtf $gencode \
--fa /mnt/xomics/tabear/ref_genome/GRCh38/pacbio/gencode.v39.pc_translations.fa \
--ensg_gene ${out_folder}/1_make_gencode_database/ensg_gene.tsv \
--enst_isoname ${out_folder}/1_make_gencode_database/enst_isoname.tsv \
--gene_ensp ${out_folder}/1_make_gencode_database/gene_ensp.tsv \
--gene_isoname ${out_folder}/1_make_gencode_database/gene_isoname.tsv \
--isoname_lens ${out_folder}/1_make_gencode_database/isoname_lens.tsv \
--gene_lens ${out_folder}/1_make_gencode_database/gene_lens.tsv \
--protein_coding_genes ${out_folder}/1_make_gencode_database/protein_coding_genes.txt

python ${script_folder}/1b_make_gencode_database/make_gencode_database.py \
--gencode_fasta /mnt/xomics/tabear/ref_genome/GRCh38/pacbio/gencode.v39.pc_translations.fa \
--protein_coding_genes ${out_folder}/1_make_gencode_database/protein_coding_genes.txt \
--output_fasta ${out_folder}/1_make_gencode_database/gencode_protein.fasta \
--output_cluster ${out_folder}/1_make_gencode_database/gencode_isoname_clusters.tsv

######################### 2a. Convert the transcript_id in the isoquant output to uppercase to match the CPAT output #########################
/mnt/xomics/renees/tools/TransDecoder-TransDecoder-v5.5.0/util/gtf_genome_to_cdna_fasta.pl \
${talon_gtf}.gtf \
$genome \
> ${talon_gtf}.fasta

####################### 2. Filter pacbio output #########################
mkdir ${out_folder}/2_filter_talon

python ${script_folder}/2_filter_talon/filter_talon.py  \
--talon_classification ${talon_classification_fl} \
--talon_fasta ${talon_gtf}.fasta \
--talon_gtf ${talon_gtf}.gtf \
--protein_coding_genes ${out_folder}/1_make_gencode_database/protein_coding_genes.txt \
--ensg_gene ${out_folder}/1_make_gencode_database/ensg_gene.tsv \
--filter_protein_coding yes \
--structural_categories_level novel \
--out_dir ${out_folder}/2_filter_talon


######################## 3. transcriptome_summary #########################
mkdir ${out_folder}/3_transcriptome_summary

python ${script_folder}/3_transcriptome_summary/transcriptome_summary.py \
--sq_out ${out_folder}/2_filter_talon/filtered_venice_talon_abundance_filtered_fl.tsv \
--ensg_to_gene ${out_folder}/1_make_gencode_database/ensg_gene.tsv \
--enst_to_isoname ${out_folder}/1_make_gencode_database/enst_isoname.tsv \
--len_stats ${out_folder}/1_make_gencode_database/gene_lens.tsv \
--odir ${out_folder}/3_transcriptome_summary/

######################## 4. CPAT #########################
mkdir ${out_folder}/4_cpat

nextflow ${script_folder}/4_cpat/cpat.nf \
--name $name \
--hexamer /mnt/xomics/tabear/atlas_paper/proteome/Human_Hexamer.tsv \
--logit_model /mnt/xomics/tabear/atlas_paper/proteome/Human_logitModel.RData \
--sample_fasta ${out_folder}/2_filter_talon/filtered_${dataset}.fasta \
--min_orf 50 \
--outdir ${out_folder}/4_cpat/

######################## 5. ORF calling (adapted to exclude stop codon) #########################
mkdir ${out_folder}/5_orf_calling

python ${script_folder}/5_orf_calling/orf_calling.py \
--orf_coord ${out_folder}/4_cpat/cpat/${name}.ORF_prob.tsv \
--orf_fasta ${out_folder}/4_cpat/cpat/${name}.ORF_seqs.fa \
--gencode $gencode \
--sample_gtf ${out_folder}/2_filter_talon/filtered_${dataset}.gtf \
--pb_gene ${out_folder}/3_transcriptome_summary/pb_gene.tsv \
--classification ${out_folder}/2_filter_talon/filtered_$(basename $talon_classification_fl) \
--sample_fasta ${out_folder}/2_filter_talon/filtered_${dataset}.fasta \
--num_cores 10 \
--output ${out_folder}/5_orf_calling/${name}

######################### 6. Refine ORF database #########################
mkdir ${out_folder}/6_refine_orf_database

python ${script_folder}/6_refine_orf_database/refine_orf_database.py \
--name ${out_folder}/6_refine_orf_database/$name \
--orfs ${out_folder}/5_orf_calling/${name}_best_orf_without_stop.tsv \
--pb_fasta ${out_folder}/2_filter_talon/filtered_${dataset}.fasta \
--coding_score_cutoff 0.0

######################### 7. Make PacBio CDS GTF #########################
mkdir ${out_folder}/7_make_pacbio_cds_gtf

python ${script_folder}/7_make_pacbo_cds_gtf/make_pacbio_cds_gtf.py \
--sample_gtf ${out_folder}/2_filter_talon/filtered_${dataset}.gtf \
--agg_orfs ${out_folder}/6_refine_orf_database/${name}_orf_refined.tsv \
--refined_orfs ${out_folder}/5_orf_calling/${name}_best_orf_without_stop.tsv \
--pb_gene ${out_folder}/3_transcriptome_summary/pb_gene.tsv \
--output_cds ${out_folder}/7_make_pacbio_cds_gtf/${name}_cds.gtf

######################### 8. Rename CDS to exon (changes classification to sqanti classification) #########################
mkdir ${out_folder}/8_rename_cds_to_exon

python ${script_folder}/8_rename_cds_to_exon/rename_cds_to_exon.py  \
--sample_gtf ${out_folder}/7_make_pacbio_cds_gtf/${name}_cds.gtf \
--sample_name ${out_folder}/8_rename_cds_to_exon/${name} \
--reference_gtf $gencode \
--reference_name ${out_folder}/8_rename_cds_to_exon/gencode \
--num_cores 10

conda deactivate
