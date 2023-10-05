#!/bin/bash
#$ -cwd
#$ -o lrp_1.out
#$ -e lrp_1.err
#$ -V
#$ -pe smp 10
#$ -q all.q@narrativum.umcn.nl,all.q@noggo.umcn.nl

source /mnt/home2/tabear/anaconda3/etc/profile.d/conda.sh

out_folder=/mnt/xomics/tabear/atlas_paper/proteome/lrp_talon
script_folder=/mnt/xomics/tabear/atlas_paper/proteome/modules_isoquant
gencode=/mnt/xomics/tabear/ref_genome/GRCh38/pacbio/gencode.v39.primary_assembly.annotation.gtf
database_fasta=/mnt/xomics/tabear/atlas_paper/proteome/lrp_talon/15_hybrid_database/hnr_50_hybrid.fasta
name=hnr_50

# Define enzyme types
enzymes=("trypsin" "chymotrypsin" "aspn_lysc" "combined")

conda activate lrp

######################### 17. Novel peptides #########################
mkdir ${out_folder}/17_novel_peptides

# Function to run peptide novelty analysis
run_novelty_analysis() {
    python "${script_folder}/17_peptide_novelty_analysis.py" \
    --pacbio_peptides "$1" \
    --gencode_fasta "${out_folder}/1_make_gencode_database/gencode_protein.fasta" \
    --name "$2"
}

# Run peptide novelty analysis for each enzyme
run_novelty_analysis "${out_folder}/16_MSFragger/trypsin/peptide.tsv" "${out_folder}/17_novel_peptides/trypsin"
run_novelty_analysis "${out_folder}/16_MSFragger/chymotrypsin/peptide.tsv" "${out_folder}/17_novel_peptides/chymotrypsin"
run_novelty_analysis "${out_folder}/16_MSFragger/aspn_lysc/peptide.tsv" "${out_folder}/17_novel_peptides/aspn_lysc"

# Combine peptide files
mkdir ${out_folder}/16_MSFragger/combined
head -n 1 "${out_folder}/16_MSFragger/trypsin/peptide.tsv" > "${out_folder}/16_MSFragger/combined/combined_peptides.tsv"
tail -n +2 -q "${out_folder}/16_MSFragger/trypsin/peptide.tsv" "${out_folder}/16_MSFragger/chymotrypsin/peptide.tsv" "${out_folder}/16_MSFragger/aspn_lysc/peptide.tsv" >> "${out_folder}/16_MSFragger/combined/combined_peptides.tsv"

# Remove duplicates from the combined file
head -n 1 "${out_folder}/16_MSFragger/combined/combined_peptides.tsv" > "${out_folder}/16_MSFragger/combined/peptide.tsv"
tail -n +2 -q "${out_folder}/16_MSFragger/combined/combined_peptides.tsv" | sort | uniq >> "${out_folder}/16_MSFragger/combined/peptide.tsv"

# Run peptide novelty analysis for the combined file
run_novelty_analysis "${out_folder}/16_MSFragger/combined/peptide.tsv" "${out_folder}/17_novel_peptides/combined"


######################### 18. Protein track visualization #########################
mkdir ${out_folder}/18_protein_track_visualization

gtfToGenePred ${out_folder}/14_protein_filter/${name}_with_cds_filtered.gtf ${out_folder}/18_protein_track_visualization/${name}_hybrid_cds.genePred
genePredToBed ${out_folder}/18_protein_track_visualization/${name}_hybrid_cds.genePred ${out_folder}/18_protein_track_visualization/${name}_hybrid_cds.bed12

# Changed file
python ${script_folder}/18_track_add_rgb_colors_to_bed.py \
--name ${out_folder}/18_protein_track_visualization/${name} \
--bed_file ${out_folder}/18_protein_track_visualization/${name}_hybrid_cds.bed12

######################## 19. Multiregion BED #########################
mkdir ${out_folder}/19_multiregion_bed

python ${script_folder}/19_make_region_bed_for_ucsc.py \
--name ${out_folder}/19_multiregion_bed/${name}  \
--sample_gtf ${out_folder}/14_protein_filter/${name}_with_cds_filtered.gtf \
--reference_gtf $gencode

######################## 20. Peptide track visualization #########################
mkdir ${out_folder}/20_peptide_track_visualization

# Loop over enzyme types
for enzyme in "${enzymes[@]}"
do 
    #Create peptide GTF file
    python "${script_folder}/20_make_peptide_gtf_file.py" \
    --name "${out_folder}/20_peptide_track_visualization/${name}_${enzyme}" \
    --sample_gtf "${out_folder}/14_protein_filter/${name}_with_cds_filtered.gtf" \
    --reference_gtf "$gencode" \
    --peptides "${out_folder}/16_MSFragger/${enzyme}/peptide.tsv" \
    --pb_gene "${out_folder}/12_protein_classification/${name}_genes.tsv" \
    --gene_isoname "${out_folder}/1_make_gencode_database/gene_isoname.tsv" \
    --refined_fasta "$database_fasta"

    #Convert GTF file to BED file
    gtfToGenePred "${out_folder}/20_peptide_track_visualization/${name}_${enzyme}_peptides.gtf" "${out_folder}/20_peptide_track_visualization/${name}_${enzyme}_peptides.genePred"
    genePredToBed "${out_folder}/20_peptide_track_visualization/${name}_${enzyme}_peptides.genePred" "${out_folder}/20_peptide_track_visualization/${name}_${enzyme}_peptides.bed12"
    
    #Colorize specific peptides in BED file
    python "${script_folder}/20_finalize_peptide_bed.py" \
    --bed "${out_folder}/20_peptide_track_visualization/${name}_${enzyme}_peptides.bed12" \
    --name "${out_folder}/20_peptide_track_visualization/${name}_${enzyme}"
done

conda deactivate