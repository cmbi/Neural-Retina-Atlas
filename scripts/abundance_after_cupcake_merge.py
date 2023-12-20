import pandas as pd
import numpy as np
import requests, sys

# This script combines the individual FL counts of sample 1, sample2, and sample 3 after cupcake merge

# Take the input and output file from the command line
if len(sys.argv) != 3:
    print("Usage: python script_name.py <input_file> <output_file>")
    sys.exit(1)
inputfile = sys.argv[1]
outputfile = sys.argv[2]

df = pd.read_csv(inputfile, sep='\t', usecols=['superPBID', 'sample1', 'sample2', 'sample3'])
df = df.fillna(0)
df['count_fl'] = df['sample1'] + df['sample2'] + df['sample3']
df = df.rename(columns={'superPBID': 'pbid'}).drop(columns=['sample1', 'sample2', 'sample3'])
df['count_fl'] = df[['sample1', 'sample2', 'sample3']].sum(axis=1).astype(int)
df['count_fl'] = df['count_fl'].astype(int)
df.to_csv(outputfile, index=False, sep='\t')
