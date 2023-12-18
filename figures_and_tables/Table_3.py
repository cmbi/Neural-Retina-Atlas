# Import
import pandas as pd
import sys
sys.path.insert(1, '../scripts/')
import utils

# Load the isoquant transcripts
isoquant = pd.read_csv('../data/transcriptomics/isoquant/isoquant_classification.tsv', sep = '\t')

# Filter the isoforms for IRD genes
ird_genes = utils.ird_gene_list()
isoforms_ird = isoquant[isoquant['gene_symbol'].isin(ird_genes)]

# Group the transcript by gene
isoforms_ird['gene_count'] = isoforms_ird.groupby(['gene_symbol'])['FL_count'].transform(sum)

# Select genes for which the most common transcript is novel
idx = isoforms_ird.groupby(['gene_symbol'])['FL_count'].transform(max) == isoforms_ird['FL_count']
most_common = isoforms_ird[idx]
novel_most_common = most_common[most_common.structural_category.isin(['novel_in_catalog', 'novel_not_in_catalog'])]

# Check if the novel most common isoform also results in a novel ORF
novel_orfs = pd.read_csv('/mnt/xomics/tabear/atlas_paper/proteome/lrp_isoquant/14_protein_filter/hnr_50.classification_filtered.tsv', sep = '\t')
novel_orfs = novel_orfs[novel_orfs['pclass'].isin(['pNIC', 'pNNC'])]
novel_most_common = novel_most_common[novel_most_common.isoform.isin(novel_orfs.pb)]
novel_most_common['percentage_novel'] = novel_most_common.FL_count / novel_most_common.gene_count
novel_most_common_sorted = novel_most_common.sort_values('percentage_novel', ascending = False)
novel_most_common_sorted.to_csv('../data/transcriptomics/novel_ird_orfs.tsv', sep = '\t')