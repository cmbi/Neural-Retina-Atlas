# Proteomics

Scripts are adapted from Miller at al. (https://github.com/sheynkman-lab/Long-Read-Proteogenomics)

> Miller, R.M., Jordan, B.T., Mehlferber, M.M. et al. Enhanced protein isoform characterization through long-read proteogenomics. Genome Biol 23, 69 (2022). https://doi.org/10.1186/s13059-022-02624-y

We reused as much as possible of the scripts. However, we used IsoQuant instead of SQANTI for our PacBio transcriptome, and we used MSFragger instead of Metamorpheus for mass-spectrometry analysis.

The following scripts were used (scripts marked with * were adapted or new)
- [1a. prepare reference table](/1a_prepare_reference_table.py)
- [1b. Create a GENCODE reference database](1b_make_gencode_database.py)
- [2a. Convert GTF to uppercase](2a_gtf_uppercase.py) 
- [2b. Filter isoquant classification file](2_filter_isoquant.py)* - Adapted to only filter for protein coding genes because percetnage A downstread and RTS stage are not included in the Isoquant data. Also, we only include novel transcripts in this pipeline to prevent IRF prediction on known transcripts
- [3 Transcriptome summary] * - modified so that it works withput Kallisto input
- [4 Open reading frame prediction with CPAT]
- [5 ORF calling] * - GENCODE ORFs do not include the stop codon so we modified the script to also remove stop codons from the CPAT ORFs
- [6. Refine ORF database] * changed order_pb_acc_numerically function
- [7. Create a a PacBio GTF file with coding sequence (cds) information]
- [8. Rename cdds to exon]
- [9. Classify ORFs with SQANTI protein]
- [10. Add IsoQuant classidication to SQANTI protein output]*
- [11a_get_gc_exon_and_5utr_info.py]
- [11b. Classify the 5' UTR status]
- [12a. Add meta data to protein classification]
- [12b. Protein classificatoin]
- [13. Rename proteins to genes]
- [14. Filter proteins]
- [15. Make a hybrid database]* - simplified, all novel ORFs are added to the database
- [16. MSFragger]*
- [17. Peptide novelty analysis] * Adapted to handle the MSFragger output, no comparison to Uniprot database
- [18. Add RGB colors to BED] * slighly modified to handle errors that occured while running the script
- [19. Make a region BED for UCSC] * slightly modified to add a file path for saving the file
- [20. Make a peptide GTF file] * adapted to work with the MSFragger output
