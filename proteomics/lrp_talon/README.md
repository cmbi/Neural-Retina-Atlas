# Proteomics

Scripts are adapted from Miller at al. (https://github.com/sheynkman-lab/Long-Read-Proteogenomics)

> Miller, R.M., Jordan, B.T., Mehlferber, M.M. et al. Enhanced protein isoform characterization through long-read proteogenomics. Genome Biol 23, 69 (2022). https://doi.org/10.1186/s13059-022-02624-y

We reused as much as possible of the scripts. However, we used MSFragger instead of Metamorpheus for mass-spectrometry analysis. Scripts that are the same as used for the Isoquant analysis can be found in the [IsoQuant folder](../lrp_isoquant/).
The following scripts were used (scripts marked with * were adapted or new):

The new part in the script is marked with 
 ``` 
############################################# modified #############################################
                                         changed or new code
############################################# modified #############################################
 ``` 

 - [0. Add FL count to TALON output](0_add_fl_to_talon.py)*
    - Script to add a FL count column to the TALON classification because TALON only provides the count for each individual sample
- [1a. prepare reference table](../lrp_isoquant/1a_prepare_reference_tables.py)*
    - Modified to work with GENCODE v39
- [1b. Create a GENCODE reference database](../lrp_isoquant/1b_make_gencode_database.py)
- [2a. Filter TALON classification file](2_filter_talon.py)*
    - Modified to work with the TALON output
    - Only filters for protein coding genes (percentage A downstream and RTS stage are not included in the TALON output)
    - Only includes novel transcripts because we do not want to predict open reading frames of known transcripts
    - Collapse isoforms and collapse classification are skipped because they are specific to SQANTI3
- [3. Transcriptome summary](3_transcriptome_summary.py)*
    - Modified to match the TALON column names and works without Kallisto input
- [4. Open reading frame prediction with CPAT](../lrp_isoquant/4_cpat.nf)
- [5. ORF calling](5_orf_calling.py)* 
    - Modified to work with TALON column names
    - Added code to create an additional file with the best ORFs without stop codon to match the GENCODE gtf
- [6. Refine ORF database](6_refine_orf_database.py)*
    - Different function for ordering of transcript accession numbers
- [7. Create a a PacBio GTF file with coding sequence (CDS) information](../lrp_isoquant/7_make_pacbio_cds_gtf.py)*
    - We use the 'transcript_id' column from the gtf instead of 'gene_id' and modified the script to work with TALON column names
- [8. Rename CDS to exon](../lrp_isoquant/8_rename_cds_to_exon.py)
- [9. Classify ORFs with SQANTI protein](../lrp_isoquant/9_sqanti_protein.nf)
- [10. Add TALON Classification](10_add_talon_classification.py)
- [11a. Get GENCODE exon and 5UTR info](../lrp_isoquant/11a_get_gc_exon_and_5utr_info.py)
- [11b. Classify the 5' UTR status](../lrp_isoquant/11b_classify_5utr_status.py)
- [11c. Merge ' UTR info to protein class table](../lrp_isoquant/11c_merge_5utr_info_to_pclass_table.py)
- [12a. Add meta data to protein classification](../lrp_isoquant/12a_protein_classification_add_meta.py)
- [12b. Protein classificatoin](../lrp_isoquant/12b_protein_classification.py)
- [13. Rename proteins to genes](../lrp_isoquant/13_protein_gene_rename.py)
- [14. Filter proteins](../lrp_isoquant/14_protein_filter.py)
- [15. Make a hybrid database](../lrp_isoquant/15_make_hybrid_database.py)*
    - simplified to include all novel ORFs in the database, no filtering based on CPM or transcript length
- [16. MSFragger](../lrp_isoquant/msfragger.sh)
    - replaces MetaMorpheus because MSFragger can handle raw Bruker timsTOF Pro data
- [17. Peptide novelty analysis](../lrp_isoquant/17_peptide_novelty_analysis.py)*
    - Only comparison to GENCODE and not to Uniprot
    - Different column names in the peptide file because we used MSFragger
- [18. Add RGB colors to BED](../lrp_isoquant/18_track_add_rgb_colors_to_bed.py)*
    - Small modification because the CPM is read as float instead of string
- [19. Make a region BED for UCSC](../lrp_isoquant/19_make_region_bed_for_ucsc.py)*
    - Small modification for saving the BED file
- [20. Finalize peptide BED](../lrp_isoquant/20_finalize_peptide_bed.py)
- [20. Make a peptide GTF file](../lrp_isoquant/20_make_peptide_gtf_file.py)*
    - adapted to work with the MSFragger output: 
        - different column names in peptide file
        - remove contaminants from peptide list
        - create a list of transcripts for multi-mapping peptides

