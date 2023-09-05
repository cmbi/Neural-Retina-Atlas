import matplotlib.pyplot as plt
from matplotlib_venn import venn2, venn3, venn3_circles
import numpy as np
import mygene
import pandas as pd

def absolute_value(val):
    a  = np.round(val/100.*isoforms.protein_coding.value_counts().sum())
    return int(a)


def ird_gene_list():
    with open('/mnt/xomics/tabear/retnet/unique_retnetgenes.txt', 'r') as file:
        ird_genes = file.readlines()
    ird_genes = [i.strip() for i in ird_genes]
    return ird_genes

def replace_geneid_by_symbol(id):
    mg = mygene.MyGeneInfo()
    try:
        return mg.getgene(id.split('.')[0])['symbol']
    except:
        return id
    
def replace_geneid_dataframe(sqanti_like_file, column):
    mg = mygene.MyGeneInfo()
    isoforms = pd.read_csv(sqanti_like_file, sep = '\t')
    isoforms.column = isoforms.column.str.split('.')
    isoforms.column = isoforms.column.str[0]
    gene_symbol = mg.querymany(isoforms[column])

    dict_genes = {}
    for i in gene_symbol:
        try:
            id = i['query']
            symbol = i['symbol']
            dict_genes[id] = symbol
        except:
            id = i['query']
            dict_genes[id] = id
    isoforms['gene_symbol'] = isoforms[column].replace(dict_genes)
    return isoforms

def overlap3(data, title, name1, name2, name3, size = (10,10), colors = ('black','dimgray', 'gainsboro')):
    # Find the overlap of transcripts between the 3 samples
    sample1 = data[(data[name1] != 0) & (data[name2] == 0) & (data[name3] == 0)]
    sample2 = data[(data[name1] == 0) & (data[name2] != 0) & (data[name3] == 0)]
    sample3 = data[(data[name1] == 0) & (data[name2] == 0) & (data[name3] != 0)]

    sample12 = data[(data[name1] != 0) & (data[name2] != 0) & (data[name3] == 0)]
    sample23 = data[(data[name1] == 0) & (data[name2] != 0) & (data[name3] != 0)]
    sample13 = data[(data[name1] != 0) & (data[name2] == 0) & (data[name3] != 0)]

    sample123 = data[(data[name1] != 0) & (data[name2] != 0) & (data[name3] != 0)]

    rc = {'figure.figsize':size,
        'axes.facecolor':'white',
        'figure.facecolor':'white',
        'axes.grid' : False,
        'font.size' : 20} 

    plt.rcParams.update(rc)

    venn3(subsets = (len(sample1.index), len(sample2.index), len(sample12.index), len(sample3.index), 
                    len(sample13.index), len(sample23.index), len(sample123.index)), 
                    set_labels = (name1, name2, name3), 
                    set_colors = colors)
    plt.savefig(f'figures/{title}.svg',  bbox_inches='tight', dpi = 300)
