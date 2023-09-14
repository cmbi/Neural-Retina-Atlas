import pandas as pd
import argparse


# Command line arguments
parser = argparse.ArgumentParser(description='Load file input and output locations')
parser.add_argument('--isoquant', action='store', dest= 'isoquant',help='isoquant SQANTI-like tsv file')
parser.add_argument('--sqanti_p', action='store', dest= 'sqanti_protein',help='sqanti protein classification file')
parser.add_argument('--out', action='store', dest= 'output_file',help='Name of the output file')
results = parser.parse_args()

# Load classification
classification = pd.read_csv(results.isoquant, sep = '\t')

# Load sqanti protein outout
sqanti_protein = pd.read_csv(results.sqanti_protein, sep = '\t')

# Replace sqanti protein columns with isoquant columns (for transcript information)
new = sqanti_protein.merge(classification, left_on = 'pb', right_on = 'isoform')

# Drop the duplicate columns and keep the isoquant columns
new = new.drop(columns=['tx_cat', 'tx_subcat', 'tx_transcripts', 'tx_gene'])

# Rename isoquant columns to match sqanti protein names
new = new.rename(columns={'structural_category': 'tx_cat', 'subcategory' : 'tx_subcat', 'associated_transcript':'tx_transcripts', 'associated_gene' : 'tx_gene'})

# Save the results
sqanti_protein.to_csv(results.output_file, sep ='\t')