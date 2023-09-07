# %%
import pandas as pd
from gtfparse import read_gtf
import sys

# %%
input_gtf = '/mnt/xomics/tabear/pacbio/atlas_paper/isoquant/isoquant_3.1.2/isoquant_alzheimer_retina/00_aln.sorted/00_aln.sorted.transcript_models.gtf'
input_fl_counts = '/mnt/xomics/tabear/pacbio/atlas_paper/isoquant/isoquant_3.1.2/isoquant_alzheimer_retina/00_aln.sorted/00_aln.sorted.transcript_model_grouped_counts.tsv'
outputfile = '/mnt/xomics/tabear/pacbio/atlas_paper/isoquant/isoquant_3.1.2/isoquant_alzheimer_retina/00_aln.sorted/retina_alzheimers_isoquant_transcript.SQANTI-like.tsv'

# %%
# Read Isoquant gtf file
gtf = read_gtf(input_gtf, result_type="pandas")

# Sum up length of exons to get the transcript length
exons = gtf[gtf['feature'] == 'exon']
exons['length'] = exons['end'] - exons['start'] + 1
transcript_length = exons.groupby(by='transcript_id')['length'].sum()
# Create a dataframe with all transcripts and add the length
transcripts = gtf[gtf['feature'] == 'transcript']
result = pd.merge(transcripts, transcript_length, on='transcript_id')

# %%
# Add the FL count
fl = pd.read_csv(input_fl_counts, sep = '\t')
result = pd.merge(result, fl, left_on='transcript_id', right_on='#feature_id')

# %%
# Add the structural category as separate column
structural_category = []

for index, row in result.iterrows():
    if 'transcript' in row['transcript_id']:
        novelty = row['transcript_id'].split('.')[-1]
        if novelty == 'nic':
            structural_category.append('novel_in_catalog')
        elif novelty == 'nnic':
            structural_category.append('novel_not_in_catalog')
        else:
            structural_category.append('error')
    else:
        structural_category.append('full-splice_match')

result['structural_category'] = structural_category
result.head()

# %%
# Get the dataframe into format
# isoform, length, structural_category, associated_gene, associated_transcript, subcategory, FL_count
sqanti_like = result[['transcript_id', 'length', 'structural_category', 'gene_id', 'transcript_id', 'alternatives', 'count']]
#sqanti_like = result[['transcript_id', 'length', 'structural_category', 'gene_id', 'transcript_id', 'alternatives', 'brain_s1', 'retina_s1', 'retina_s2', 'retina_s3']]

sqanti_like.columns = ['isoform', 'length', 'structural_category', 'associated_gene','associated_transcript', 'subcategory', 'FL_count']
#qanti_like.columns = ['isoform', 'length', 'structural_category', 'associated_gene','associated_transcript', 'subcategory', 'brain_s1', 'retina_s1', 'retina_s2', 'retina_s3']

# Convert transcript_id to uppercase
sqanti_like['isoform'] = sqanti_like['isoform'].str.upper()
sqanti_like['associated_transcript'] = sqanti_like['associated_transcript'].str.upper()

# %%
# Save the sqanti_like file
sqanti_like.to_csv(outputfile, sep = '\t', index=False)
# %%
