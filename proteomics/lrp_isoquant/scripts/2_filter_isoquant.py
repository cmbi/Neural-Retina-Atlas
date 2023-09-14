#!/usr/bin/env python3
#%%
import pandas as pd 
import re 
import argparse
import logging
import gtfparse
from Bio import SeqIO

logging.basicConfig(filename='isoquant_filter.log', encoding='utf-8', level=logging.DEBUG) 

"""
Filter IsoQuant results based on several criteria 
- protein coding only
        Transcript aligns to a Gencode-annotated protein coding gene.
"""

structural_categories = {
    'all': ['full-splice_match', 'novel_not_in_catalog', 'novel_in_catalog'],
    'novel': ['novel_not_in_catalog', 'novel_in_catalog']
}


def string_to_boolean(string):
    """
    Converts string to boolean

    Parameters
    ----------
    string :str
    input string

    Returns
    ----------
    result : bool
    output boolean
    """
    if isinstance(string, bool):
        return str
    if string.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif string.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')


def filter_protein_coding(classification, protein_coding_filename, ensg_gene_filename):
    """
    Filter classification to only contain genes that are known to be protein-coding per Gencode
    
    Parameters
    ----------
    orfs : pandas DataFrame
        called ORFs
    protein_coding_filename : filename
        file of protein-coding genes. text file seperated by lines
    """
    logging.info("Filtering for only protein coding genes")
    with open(protein_coding_filename, 'r') as file:
        protein_coding_genes = file.read().splitlines()
    ensg_gene = pd.read_table(ensg_gene_filename, header=None)
    ensg_gene.columns = ['gene_id', 'gene_name']
    ensg_gene = ensg_gene[ensg_gene['gene_name'].isin(protein_coding_genes)]
    protein_coding_gene_ids = set(ensg_gene['gene_id'])
    classification = classification[classification['associated_gene'].isin(protein_coding_gene_ids)]
    return classification


def save_filtered_gtf(gtf_file, filtered_isoforms, results):
    logging.info("Saving GTF")
    base_name = gtf_file.split("/")[-1]
    with open(gtf_file, "r") as ifile, open(f"{results.output_directory}/filtered_{base_name}", "w") as ofile:
        for line in ifile.readlines():
            # added try and pass tp skip first line of gtf (first line does not contain any transcript information)
            try:
                transcript = re.findall('transcript_id "([^"]*)"', line)[0]
                if transcript in filtered_isoforms:
                    ofile.write(line)
            except:
                pass


def save_filtered_fasta(fasta_file, filtered_isoforms, results):
    logging.info("Saving FASTA")
    filtered_sequences = []  # Setup an empty list
    for record in SeqIO.parse(fasta_file, "fasta"):
        if record.id in filtered_isoforms:
            filtered_sequences.append(record)
    base_name = fasta_file.split("/")[-1]
    SeqIO.write(filtered_sequences, f"{results.output_directory}/filtered_{base_name}", "fasta")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--classification", action='store', dest= 'classification_file',help='Classification File')
    parser.add_argument("--corrected_gtf", action="store", dest="corrected_gtf")
    parser.add_argument("--corrected_fasta", action="store", dest="corrected_fasta")
    parser.add_argument("--filter_protein_coding", action="store", dest="filter_protein_coding", help="yes/no whether to keep only protein coding genes", default="yes")
    parser.add_argument("--protein_coding_genes", action="store", dest="protein_coding_genes", required=False)
    parser.add_argument("--ensg_gene", action="store", dest="ensg_gene", required=False)
    parser.add_argument("--structural_categories_level", action="store", dest="structural_categories_level", default="strict")
    parser.add_argument("--out_dir", action="store", dest="output_directory", default="strict")
    
    results = parser.parse_args()
    # Get boolean filtering decisions
    is_protein_coding_filtered = string_to_boolean(results.filter_protein_coding)

    # Read classification table
    classification = pd.read_table(results.classification_file)
    classification = classification[~classification['associated_gene'].isna()]
    classification = classification[classification['associated_gene'].str.startswith("ENSG")]

    # Filter classification file
    if is_protein_coding_filtered:
        classification = filter_protein_coding(classification, results.protein_coding_genes, results.ensg_gene)

    if results.structural_categories_level in structural_categories.keys():
        classification = classification[classification['structural_category'].isin(structural_categories[results.structural_categories_level])]
    
    # Isoforms that have been filtered
    filtered_isoforms = set(classification['isoform'])
    # Save Data
    base_name = results.classification_file.split("/")[-1]
    base_name = ".".join(base_name.split('.')[:-1])
    classification.to_csv(f"{results.output_directory}/filtered_{base_name}.tsv", index=False, sep = "\t")
    save_filtered_gtf(results.corrected_gtf,filtered_isoforms, results)
    save_filtered_fasta(results.corrected_fasta, filtered_isoforms, results)

#%%
    

if __name__=="__main__":
    main()
