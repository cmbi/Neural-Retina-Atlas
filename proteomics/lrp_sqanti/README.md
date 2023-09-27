# Proteomics

Scripts are adapted from Miller at al. (https://github.com/sheynkman-lab/Long-Read-Proteogenomics)

> Miller, R.M., Jordan, B.T., Mehlferber, M.M. et al. Enhanced protein isoform characterization through long-read proteogenomics. Genome Biol 23, 69 (2022). https://doi.org/10.1186/s13059-022-02624-y

We reused as much as possible of the scripts. However, we used MSFragger instead of Metamorpheus for mass-spectrometry analysis.

The following scripts were used (scripts marked with * were adapted or new):

The new part in the script is marked with 
 ``` 
############################################# modified #############################################
                                         changed or new code
############################################# modified #############################################
 ``` 

- [1a. prepare reference table](1a_prepare_reference_table.py)*
    - Modified to work with GENCODE v39
- [1b. Create a GENCODE reference database](1b_make_gencode_database.py)
- [2a. Convert GTF to uppercase](2a_gtf_uppercase.py)* 
    - new script to convert the transcript name in the IsoQuant gtf to uppercasae to match CPAT output later on 
- [2b. Filter isoquant classification file](2_filter_isoquant.py)*
    - Only filters for protein coding genes (percentage A downstream and RTS stage are not included in the Isoquant output)
    - Only includes novel transcripts because we do not want to predict open reading frames of known transcripts
    - collapse isoforms and collapse classification are skipped because they are specific to SQANTI3
- [3. Transcriptome summary](3_transcriptome_summary.py) * 
    - modified so that it works without Kallisto input
- [4. Open reading frame prediction with CPAT](4_cpat.nf)
- [5. ORF calling](5_orf_calling.py)* 
    - added code to create an additional file with the best ORFs without stop codon to match the GENCODE gtf
    - the count column is called 'FL_count' instead of 'FL' in the IsoQuant file
- [6. Refine ORF database](6_refine_orf_database.py)*
    - We replaced the function to order ORFs by accession number because IsoQuant accession numbers do not start with 'PB'
    - the count column is called 'FL_count' instead of 'FL' in the IsoQuant file
- [7. Create a a PacBio GTF file with coding sequence (CDS) information](7_make_pacbio_cds_gtf.py)*
    - We use the 'transcript_id' column from the gtf instead of 'gene_id'
- [8. Rename CDS to exon](8_rename_cds_to_exon.py)
- [9. Classify ORFs with SQANTI protein](9_sqanti_protein.nf)
- [10. Add IsoQuant classidication to SQANTI protein output](10_add_isoquant_classification.py)*
    - new script to replace the SQANTI3 transcript classification with the IsoQuant classification
- [11a. Get GENCODE exon and 5UTR info](11a_get_gc_exon_and_5utr_info.py)
- [11b. Classify the 5' UTR status](11b_classify_5utr_status.py)
- [11c. Merge ' UTR info to protein class table](11c_merge_5utr_info_to_pclass_table.py)
- [12a. Add meta data to protein classification](12a_protein_classification_add_meta.py)
- [12b. Protein classificatoin](12b_protein_classification.py)
- [13. Rename proteins to genes](13_protein_gene_rename.py)
- [14. Filter proteins](14_protein_filter.py)
- [15. Make a hybrid database](15_make_hybrid_database.py)*
    - simplified to include all novel ORFs in the database, no filtering based on CPM or transcript length
- [16. MSFragger](msfragger.sh)
    - replaces MetaMorpheus because MSFragger can handle raw Bruker timsTOF Pro data
- [17. Peptide novelty analysis](17_peptide_novelty_analysis.py)
    - Only comparison to GENCODE and not to Uniprot
    - Different column names in the peptide file because we used MSFragger
- [18. Add RGB colors to BED](18_track_add_rgb_colors_to_bed.py)*
    - Small modification because the CPM is read as float instead of string
- [19. Make a region BED for UCSC](19_make_region_bed_for_ucsc.py)*
    - Small modification for saving the BED file
- [20. Finalize peptide BED](20_finalize_peptide_bed.py)
- [20. Make a peptide GTF file](20_make_peptide_gtf_file.py)*
    - adapted to work with the MSFragger output: 
        - different column names in peptide file
        - remove contaminants from peptide list
        - create a list of transcripts for multi-mapping peptides

