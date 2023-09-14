# %%
import argparse
import pandas as pd
from gtfparse import read_gtf

# %%
def main():
    parser = argparse.ArgumentParser(description='Process Isoquant data and create SQANTI-like output.')
    parser.add_argument('--input_gtf', required=True, help='Path to input GTF file')
    parser.add_argument('--input_fl_counts', required=True, help='Path to input FL counts TSV file')
    parser.add_argument('--outputfile', required=True, help='Path to output SQANTI-like TSV file')

    args = parser.parse_args()

    # Read Isoquant gtf file
    # Read Isoquant GTF file and FL counts TSV file
    gtf = read_gtf(args.input_gtf, result_type="pandas")
    fl = pd.read_csv(args.input_fl_counts, sep='\t', usecols=['#feature_id', 'count'])

    # Extract relevant columns from GTF
    transcripts = gtf[gtf['feature'] == 'transcript']
    exons = gtf[gtf['feature'] == 'exon']

    #Calculate transcript lengths
    exon_lengths = exons.groupby('transcript_id')['end'].max() - exons.groupby('transcript_id')['start'].min() + 1
    transcripts['length'] = exon_lengths.reindex(transcripts['transcript_id']).values
    
    # Add the structural category as a separate column
    transcripts['structural_category'] = 'full-splice_match'
    transcripts.loc[transcripts['transcript_id'].str.endswith('.nic'), 'structural_category'] = 'novel_in_catalog'
    transcripts.loc[transcripts['transcript_id'].str.endswith('.nnic'), 'structural_category'] = 'novel_not_in_catalog'

    # Merge with FL counts
    result = pd.merge(transcripts, fl, left_on='transcript_id', right_on='#feature_id')

    # Rename and format columns
    result = result[['transcript_id', 'length', 'structural_category', 'gene_id', 'transcript_id_x', 'alternatives', 'count']]
    result.columns = ['isoform', 'length', 'structural_category', 'associated_gene', 'associated_transcript', 'subcategory', 'FL_count']
    result['isoform'] = result['isoform'].str.upper()
    result['associated_transcript'] = result['associated_transcript'].str.upper()

    # Save the sqanti_like file
    result.to_csv(args.outputfile, sep='\t', index=False)

if __name__ == '__main__':
    main()