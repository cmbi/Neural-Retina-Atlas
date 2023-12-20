## Scripts 

#### [Abundance after cupcake merge](abundance_after_cupcake_merge.py)
This script combines the individual FL counts of sample 1, sample2, and sample 3 after cupcake merge to create the FL column required for SQANTI3.

#### [Add color to GTF](add_color_to_gtf.py)
This script is used to color the transcript and ORF isoforms according to their IsoQuant classification.

#### [Convert GTF to colored BED](convert_gtf_to_colored_bed.sh)
This script contains the information on how `add_color_to_gtf.py` was used to create the visualisatiions for the UCSC genome browser.

#### [NCBI human protein coding genes](genes_ncbi_human_proteincoding.py) and [NCBI gene results to Python](ncbi_gene_results_to_python.py)
These scripts are used to perform the Gene Ontology enrichment analysis in Figure 2D. 

#### [IsoQuant to SQANTI3 converter](isoquant_sqanti_converter.py)
This script converts the IsoQuant output into a SQANTI3-like classification file that is required for the long-read proteogenomics pipeline by Miller et al.

#### [Replace gene identifier](replace_identifier.py)
This script is used to add a gene name column to the IsoQuant output based on the gene id column.

#### [Utils (R)](utils.R)
This script contains the `combined_cds_utr_gtffile` function that is used to create the IsoQuant track in Figure 5. 

#### [Utils (Python)](utils.py)
