import pandas as pd
import numpy as np

df = pd.read_csv('all_samples.chained_count.txt', sep='\t')
df = df.fillna(0)
df['count_fl'] = df['sample1'] + df['sample2'] + df['sample3']
df = df.astype({'count_fl': int})
df = df.rename({'superPBID': 'pbid'}, axis='columns')
df = df.drop(columns=['sample1', 'sample2', 'sample3'])
df.to_csv('all_samples.chained.abundance.txt', index=False, sep='\t')