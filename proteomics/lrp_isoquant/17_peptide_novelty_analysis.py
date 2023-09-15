#!/usr/bin/env python3

# Find novel peptides that have been detected from a MetaMorpheus
# MS search against the PacBio database.


#%%

import pandas as pd
from Bio import SeqIO
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--pacbio_peptides',action='store',dest='peptides')
parser.add_argument('--gencode_fasta',action='store',dest='gencode_fasta')
############################################# modified #############################################
# parser.add_argument('--uniprot_fasta', action='store',dest='uniprot_fasta')
############################################# modified #############################################
parser.add_argument('--name',action='store',dest='name')
args = parser.parse_args()

# read in pacbio peptides
peps = pd.read_table(args.peptides)

############################################# modified #############################################
# peps = peps[(peps['QValue']<=0.01) & (peps['Decoy/Contaminant/Target']=='T')]
# peps = peps[['Gene Name', 'Protein Accession', 'Base Sequence', 'Score', 'QValue']]
peps = peps[['Protein Description', 'Protein ID', 'Peptide', 'Probability', 'Peptide Length']]
peps.columns = ['gene', 'acc', 'seq', 'prob', 'len']

def get_first_gene_name(gene_str):
    try:
        return gene_str.split('=')[1]
    except:
        return gene_str
############################################# modified #############################################


peps['gene'] = peps['gene'].apply(get_first_gene_name)

# all detected peptides (pacbio sample-specific) (that map to only novel isoforms)
############################################# modified #############################################
peps_pb = peps[peps['acc'].str.startswith('pb|')]
############################################# modified #############################################
sample_peptides = peps_pb['seq'].to_list()

# import all the sequences from gencode into a big string
gencode_seq = [str(rec.seq) for rec in SeqIO.parse(args.gencode_fasta, 'fasta')]
gencode_all_sequences = ','.join(gencode_seq)

############################################# modified #############################################
# uniprot_seq = [str(rec.seq) for rec in SeqIO.parse(args.uniprot_fasta, 'fasta')]
# uniprot_all_sequences = ','.join(uniprot_seq)
############################################# modified #############################################

# find novel peptides
novel_peps = set()
############################################# modified #############################################
# novel_peps_to_gencode = set()
# novel_peps_to_uniprot = set()

for pep in sample_peptides:
    # some peptides are indistinguishable (have I/L), take first one
    if '|' in pep:
        pep = pep.split('|')[0]
    # is the base peptide sequence in the ref database
    if pep not in gencode_all_sequences:
        novel_peps.add(pep)
    # if pep not in gencode_all_sequences:
    #     novel_peps_to_gencode.add(pep)
    # if pep not in uniprot_all_sequences:
    #     novel_peps_to_uniprot.add(pep)

# novel_peps = novel_peps_to_gencode.intersection(novel_peps_to_uniprot)
############################################# modified #############################################

# write out the pacbio accession and genename for each novel peptide
peps_novel = peps[peps['seq'].isin(novel_peps)]
peps_novel.to_csv(f'{args.name}.pacbio_novel_peptides_to_gencode.tsv', sep='\t', index=None)

############################################# modified #############################################
# peps_novel.to_csv(f'{args.name}.pacbio_novel_peptides.tsv', sep='\t', index=None)

# peps_novel_to_gencode = peps[peps['seq'].isin(novel_peps_to_gencode)]
# peps_novel_to_gencode.to_csv(f'{args.name}.pacbio_novel_peptides_to_gencode.tsv', sep='\t', index=None)


# peps_novel_to_uniprot= peps[peps['seq'].isin(novel_peps_to_uniprot)]
# peps_novel_to_uniprot.to_csv(f'{args.name}.pacbio_novel_peptides_to_uniprot.tsv', sep='\t', index=None)
############################################# modified #############################################

# %%
