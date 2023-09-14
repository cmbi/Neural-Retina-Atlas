#!/bin/bash
#$ -cwd
#$ -o lrp_1.out
#$ -e lrp_1.err
#$ -V
#$ -pe smp 1
#$ -q all.q@narrativum.umcn.nl,all.q@noggo.umcn.nl

source /mnt/home2/tabear/anaconda3/etc/profile.d/conda.sh

out_folder=/mnt/xomics/tabear/atlas_paper/proteome/lrp_isoquant
script_folder=/mnt/xomics/tabear/atlas_paper/proteome/modules_isoquant
gencode=/mnt/xomics/tabear/ref_genome/GRCh38/pacbio/gencode.v39.primary_assembly.annotation.gtf
database_fasta=/mnt/xomics/tabear/atlas_paper/proteome/lrp_isoquant/15_hybrid_database/hnr_50_hybrid.fasta
name=hnr_50

conda activate lrp

# ######################### 17. Novel peptides #########################
# mkdir ${out_folder}/17_novel_peptides

# python ${script_folder}/17_peptide_novelty_analysis.py \
# --pacbio_peptides ${out_folder}/16a_MSFragger_trypsin/peptide.tsv \
# --gencode_fasta ${out_folder}/1_make_gencode_database/gencode_protein.fasta \
# --name ${out_folder}/17_novel_peptides/trypsin

# python ${script_folder}/17_peptide_novelty_analysis.py \
# --pacbio_peptides ${out_folder}/16b_MSFragger_chymotrypsin/peptide.tsv \
# --gencode_fasta ${out_folder}/1_make_gencode_database/gencode_protein.fasta  \
# --name ${out_folder}/17_novel_peptides/chymotrypsin

# python ${script_folder}/17_peptide_novelty_analysis.py \
# --pacbio_peptides ${out_folder}/16c_MSFragger_aspnlysc/peptide.tsv \
# --gencode_fasta ${out_folder}/1_make_gencode_database/gencode_protein.fasta \
# --name ${out_folder}/17_novel_peptides/aspn_lysc

# # Combined
# head -n 1 ${out_folder}/16a_MSFragger_trypsin/peptide.tsv > ${out_folder}/17_novel_peptides/peptides_combined.tsv
# tail -n +2 -q ${out_folder}/16a_MSFragger_trypsin/peptide.tsv ${out_folder}/16b_MSFragger_chymotrypsin/peptide.tsv ${out_folder}/16c_MSFragger_aspnlysc/peptide.tsv >> ${out_folder}/17_novel_peptides/peptides_combined.tsv

# head -n 1 ${out_folder}/17_novel_peptides/peptides_combined.tsv > ${out_folder}/17_novel_peptides/peptides_combined_unique.tsv
# tail -n +2 -q ${out_folder}/17_novel_peptides/peptides_combined.tsv | sort | uniq >> ${out_folder}/17_novel_peptides/peptides_combined_unique.tsv

# python ${script_folder}/17_peptide_novelty_analysis.py \
# --pacbio_peptides ${out_folder}/17_novel_peptides/peptides_combined_unique.tsv \
# --gencode_fasta ${out_folder}/1_make_gencode_database/gencode_protein.fasta \
# --name ${out_folder}/17_novel_peptides/combined

# ######################### 18. Protein track visualization #########################
# mkdir ${out_folder}/18_protein_track_visualization

# gtfToGenePred ${out_folder}/14_protein_filter/${name}_with_cds_filtered.gtf ${out_folder}/18_protein_track_visualization/${name}_hybrid_cds.genePred
# genePredToBed ${out_folder}/18_protein_track_visualization/${name}_hybrid_cds.genePred ${out_folder}/18_protein_track_visualization/${name}_hybrid_cds.bed12

# # Changed file
# python ${script_folder}/18_track_add_rgb_colors_to_bed.py \
# --name ${out_folder}/18_protein_track_visualization/${name} \
# --bed_file ${out_folder}/18_protein_track_visualization/${name}_hybrid_cds.bed12

# ######################## 19. Multiregion BED #########################
# mkdir ${out_folder}/19_multiregion_bed

# python ${script_folder}/19_make_region_bed_for_ucsc.py \
# --name ${out_folder}/19_multiregion_bed/${name}  \
# --sample_gtf ${out_folder}/14_protein_filter/${name}_with_cds_filtered.gtf \
# --reference_gtf $gencode

# ######################### 20. Peptide track visualization #########################
# mkdir ${out_folder}/20_peptide_track_visualization

# # Trypsin
# python ${script_folder}/20_make_peptide_gtf_file.py \
# --name ${out_folder}/20_peptide_track_visualization/${name}_trypsin \
# --sample_gtf ${out_folder}/14_protein_filter/${name}_with_cds_filtered.gtf \
# --reference_gtf $gencode \
# --peptides ${out_folder}/16a_MSFragger_trypsin/peptide.tsv \
# --pb_gene ${out_folder}/12_protein_classification/${name}_genes.tsv \
# --gene_isoname ${out_folder}/1_make_gencode_database/gene_isoname.tsv \
# --refined_fasta $database_fasta

# # Chymotrypsin
# python ${script_folder}/20_make_peptide_gtf_file.py \
# --name ${out_folder}/20_peptide_track_visualization/${name}_chymotrypsin \
# --sample_gtf ${out_folder}/14_protein_filter/${name}_with_cds_filtered.gtf \
# --reference_gtf $gencode \
# --peptides ${out_folder}/16b_MSFragger_chymotrypsin/peptide.tsv \
# --pb_gene ${out_folder}/12_protein_classification/${name}_genes.tsv \
# --gene_isoname ${out_folder}/1_make_gencode_database/gene_isoname.tsv \
# --refined_fasta $database_fasta

# # AspN+LysC
# python ${script_folder}/20_make_peptide_gtf_file.py \
# --name ${out_folder}/20_peptide_track_visualization/${name}_aspnlysc \
# --sample_gtf ${out_folder}/14_protein_filter/${name}_with_cds_filtered.gtf \
# --reference_gtf $gencode \
# --peptides ${out_folder}/16c_MSFragger_aspnlysc/peptide.tsv \
# --pb_gene ${out_folder}/12_protein_classification/${name}_genes.tsv \
# --gene_isoname ${out_folder}/1_make_gencode_database/gene_isoname.tsv \
# --refined_fasta $database_fasta

# # Combined
# python ${script_folder}/20_make_peptide_gtf_file.py \
# --name ${out_folder}/20_peptide_track_visualization/${name}_combined \
# --sample_gtf ${out_folder}/14_protein_filter/${name}_with_cds_filtered.gtf \
# --reference_gtf $gencode \
# --peptides ${out_folder}/17_novel_peptides/peptides_combined_unique.tsv \
# --pb_gene ${out_folder}/12_protein_classification/${name}_genes.tsv \
# --gene_isoname ${out_folder}/1_make_gencode_database/gene_isoname.tsv \
# --refined_fasta $database_fasta

for enzyme in trypsin chymotrypsin aspnlysc combined
do 
    gtfToGenePred ${out_folder}/20_peptide_track_visualization/${name}_${enzyme}_peptides.gtf ${out_folder}/20_peptide_track_visualization/${name}_${enzyme}_peptides.genePred
    genePredToBed ${out_folder}/20_peptide_track_visualization/${name}_${enzyme}_peptides.genePred ${out_folder}/20_peptide_track_visualization/${name}_${enzyme}_peptides.bed12
    # add rgb to colorize specific peptides 
    python ${script_folder}/20_finalize_peptide_bed.py \
    --bed ${out_folder}/20_peptide_track_visualization/${name}_${enzyme}_peptides.bed12 \
    --name ${out_folder}/20_peptide_track_visualization/${name}_${enzyme}
done

conda deactivate