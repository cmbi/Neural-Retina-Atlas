#!/usr/bin/env python3
#%%
from selectors import EpollSelector
import pandas as pd 
import re 
import argparse
import logging
from Bio import SeqIO
import os

logging.basicConfig(filename='sqanti_filter.log', encoding='utf-8', level=logging.DEBUG) 

"""
Filter SQANTI results based on several criteria 
- protein coding only
        PB transcript aligns to a Gencode-annotated protein coding gene.
- percent A downstream
        perc_A_downstreamTTS : percent of genomic "A"s in the downstream 20 bp window. 
        If this number if high (say > 0.8), the 3' end site of this isoform is probably not reliable.
- RTS stage
        RTS_stage: TRUE if one of the junctions could be a RT switching artifact.
"""
############################################# modified #############################################
structural_categories = {
    'strict':['Known', 'NIC', 'NNC', 'ISM', ],
    'all': ['Antisense', 'Intergenic', 'ISM', 'Known', 'NNC', 'NIC'], 
    'novel': ['NIC', 'NNC']
}
############################################# modified #############################################

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
    Filter classification to only contain genes that are known to be protein-coding
    per Gencode
    
    Parameters
    ----------
    orfs : pandass DataFrame
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
    classification = classification[classification['annot_gene_id'].isin(protein_coding_gene_ids)]
    return classification

def filter_intra_polyA(classification, percent_polyA_downstream):
    logging.info("Filtering Intra PolyA")
    classification = classification[classification['perc_A_downstream_TTS'] <= percent_polyA_downstream]
    return classification

def filter_rts_stage(classification):
    logging.info("Filtering RTS Stage")
    classification = classification[classification['RTS_stage'] == False]
    return classification

def filter_illumina_coverage(classification, min_coverage):
    """Filters accessions that are not FSM,ISM,NIC to only include accessions where 
    the minimum coverage of all junctions is at least min_coverage. If illumina data is 
    not provided then returns original classification
    Args:
        classification (pandas DataFrame): sqanti classification file
        min_coverage (int): minimum coverage all junctions must meet if not FSM,ISM,NIC
    Returns:
        pandas DataFrame: filtered classification
    """
    structural_categories_to_not_filter = ['novel_in_catalog','incomplete-splice_match', 'full-splice_match', ]
    if classification['min_cov'].isnull().values.all():
        return classification
    else:
        classification = classification[
            (classification['structural_category'].isin(structural_categories_to_not_filter)) | 
            (classification['min_cov'] >= min_coverage)]
        return classification

def save_filtered_sqanti_gtf(gtf_file, filtered_isoforms, results):
    logging.info("Saving GTF")
    base_name = gtf_file.split("/")[-1]
    with open(gtf_file, "r") as ifile, open(f"{results.output_directory}/filtered_{base_name}", "w") as ofile:
        for line in ifile.readlines():
            ############################################# modified #############################################
            try:
                transcript = re.findall('talon_transcript ".*?";', line)
                t = transcript[0].split('"')[1]
                t = int(t)
                if t in filtered_isoforms:
                    ofile.write(line)
            except:
                pass
            ############################################# modified #############################################



def save_filtered_sqanti_fasta(fasta_file, filtered_isoforms, results):
    logging.info("Saving FASTA")
    filtered_sequences = []  # Setup an empty list
    for record in SeqIO.parse(fasta_file, "fasta"):
        ############################################# modified #############################################
        if record.name in filtered_isoforms:
        ############################################# modified #############################################
            filtered_sequences.append(record)

    base_name = fasta_file.split("/")[-1]
    SeqIO.write(filtered_sequences, f"{results.output_directory}/filtered_{base_name}", "fasta")

def main():
    parser = argparse.ArgumentParser()
    ############################################# modified #############################################
    parser.add_argument("--talon_classification", action='store', dest= 'classification_file',help='SQANTI Classification File')
    parser.add_argument("--talon_gtf", action="store", dest="corrected_gtf")
    parser.add_argument("--talon_fasta", action="store", dest="corrected_fasta")
    ############################################# modified #############################################
    parser.add_argument("--filter_protein_coding", action="store", dest="filter_protein_coding", help="yes/no whether to keep only protein coding genes", default="yes")
    parser.add_argument("--protein_coding_genes", action="store", dest="protein_coding_genes", required=False)
    parser.add_argument("--ensg_gene", action="store", dest="ensg_gene", required=False)
    parser.add_argument("--structural_categories_level", action="store", dest="structural_categories_level", default="strict")
    parser.add_argument("--out_dir", action="store", dest="output_directory", default="strict")
    ############################################# modified #############################################
    # parser.add_argument("--filter_intra_polyA", action="store", dest="filter_intra_polyA", default="yes")
    # parser.add_argument("--filter_template_switching", action="store", dest="filter_template_switching", default="yes")
    # parser.add_argument("--percent_A_downstream_threshold", action="store", dest="percent_A_downstream_threshold", default=95,type=float)
    # parser.add_argument("--percent_A_downstream_threshold", action="store", dest="percent_A_downstream_threshold", default=95,type=float)
    ############################################# modified #############################################

    results = parser.parse_args()

    # Get boolean filtering decisions
    is_protein_coding_filtered = string_to_boolean(results.filter_protein_coding)

    # Read sqanti classification table
    classification = pd.read_table(results.classification_file)
    ############################################# modified #############################################
    classification = classification[~classification['annot_gene_id'].isna()]
    classification = classification[classification['annot_gene_id'].str.startswith("ENSG")]
    ############################################# modified #############################################

    # Filter classification file
    if is_protein_coding_filtered:
        classification = filter_protein_coding(classification, results.protein_coding_genes, results.ensg_gene)

    ############################################# modified #############################################
    # if is_intra_polyA_filtered:
    #     classification = filter_intra_polyA(classification, results.percent_A_downstream_threshold)
    # if is_template_switching_filtered:
    #     classification = filter_rts_stage(classification)
    # classification = filter_illumina_coverage(classification, results.min_illumina_coverage
    ############################################# modified #############################################

    if results.structural_categories_level in structural_categories.keys():
        classification = classification[classification['transcript_novelty'].isin(structural_categories[results.structural_categories_level])]

    # Isoforms that have been filtered
    ############################################# modified #############################################
    filtered_isoforms = set(classification['transcript_ID'])
    filtered_isoforms_fasta = set(classification['annot_transcript_id'])
    ############################################# modified #############################################

    # Save Data
    base_name = results.classification_file.split("/")[-1]
    base_name = ".".join(base_name.split('.')[:-1])
    classification.to_csv(f"{results.output_directory}/filtered_{base_name}.tsv", index=False, sep = "\t")
    save_filtered_sqanti_gtf(results.corrected_gtf,filtered_isoforms, results)
    save_filtered_sqanti_fasta(results.corrected_fasta, filtered_isoforms_fasta, results)
#%%
    

if __name__=="__main__":
    main()

