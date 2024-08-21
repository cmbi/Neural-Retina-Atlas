import pandas as pd
orfs = pd.read_csv('ont.ORF_prob.best.tsv', sep = '\t')
orfs_without_stop = orfs.copy()
orfs_without_stop['ORF_end'] = orfs_without_stop['ORF_end']-3
orfs_without_stop['ORF'] = orfs_without_stop['ORF']-3
orfs_without_stop.to_csv('ont_best_orf_without_stop.tsv', index = False, sep = "\t")