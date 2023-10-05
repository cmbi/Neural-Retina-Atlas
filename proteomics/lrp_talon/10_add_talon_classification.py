import pandas as pd
import argparse


# Command line arguments
parser = argparse.ArgumentParser(description='Load file input and output locations')
parser.add_argument('--talon', action='store', dest= 'talon',help='talon abundance file')
parser.add_argument('--sqanti_p', action='store', dest= 'sqanti_protein',help='sqanti protein classification file')
parser.add_argument('--out', action='store', dest= 'output_file',help='Name of the output file')
results = parser.parse_args()

# Load classification
classification = pd.read_csv(results.talon, sep = '\t')

# Rename the novelty column to match sqanti notation
novelty_dict = {'ISM':'incomplete-splice_match', 'Known':'full-splice_match', 'NIC':'novel_in_catalog', 'NNC':'novel_not_in_catalog', 'Antisense':'antisense', 'Intergenic':'intergenic'}
classification['transcript_novelty'] = classification['transcript_novelty'].replace(novelty_dict, inplace=True)

# Load sqanti protein outout
sqanti_protein = pd.read_csv(results.sqanti_protein, sep = '\t')

# Replace sqanti protein columns with talon columns (for transcript information)
new = sqanti_protein.merge(classification, left_on = 'pb', right_on = 'annot_transcript_id')

# Drop the duplicate columns and keep the talon columns
new = new.drop(columns=['tx_cat', 'tx_transcripts', 'tx_gene'])

# Rename talon columns to match sqanti protein names
new = new.rename(columns={'transcript_novelty': 'tx_cat', 'annot_transcript_id':'tx_transcripts', 'annot_gene_id' : 'tx_gene'})

# Save the results
sqanti_protein.to_csv(results.output_file, sep ='\t')