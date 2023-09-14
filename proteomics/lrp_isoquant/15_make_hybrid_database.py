#!/usr/bin/env python3
#%%
import pandas as pd 
from Bio import SeqIO
from collections import defaultdict
import argparse
#%%
parser = argparse.ArgumentParser()
parser.add_argument('--protein_classification',action='store',dest='pclass')
parser.add_argument('--pb_fasta',action='store',dest='pb_fasta')
parser.add_argument('--gc_fasta',action='store',dest='gc_fasta')
parser.add_argument('--name',action='store',dest='name')
args = parser.parse_args()

# Read in the classification file

pclass = pd.read_table(args.pclass)
all_genes = set(pclass['pr_gene'])
pclass_accs = set(pclass['pb'])

pb_fasta = defaultdict(list)
for record in SeqIO.parse(args.pb_fasta,'fasta'):
    gene = record.description.split('fullname GN=')[1].strip()
    acc = record.id.split('|')[1].strip()
    if acc in pclass_accs:
        pb_fasta[gene].append(record)

gc_genes_all = set()
gc_fasta = defaultdict(list)
for record in SeqIO.parse(args.gc_fasta, 'fasta'):
    gene_split = record.description.split('GN=')
    gene = gene_split[1].strip()
    gc_genes_all.add(gene)
    gc_fasta[gene].append(record)

aggregated_fasta = []
for gene in gc_fasta:
    aggregated_fasta = aggregated_fasta + gc_fasta[gene]
for gene in pb_fasta:
    aggregated_fasta = aggregated_fasta + pb_fasta[gene]


SeqIO.write(aggregated_fasta, f'{args.name}_hybrid.fasta', 'fasta')
# %%
