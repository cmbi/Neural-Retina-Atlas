import pandas as pd
import sys
import os

# Load the TALON classification file
file = sys.argv[1]
df = pd.read_csv(file, sep = '\t')

# Combine the three individual FL counts for the samples in one FL column
df['FL'] = df['venice_sample1'] + df['venice_sample2'] + df['venice_sample3']
df = df.drop(['venice_sample1', 'venice_sample2', 'venice_sample3'], axis=1)

# Save the result to a file
outfile = os.path.splitext(file)[0]
df.to_csv(f'{outfile}_fl.tsv', sep = '\t', index = None)
