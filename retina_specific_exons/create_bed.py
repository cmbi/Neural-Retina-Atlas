# %%
import pandas as pd

# %%
short_exons = pd.read_excel('../data/retina_specific_exons/pnas.2117090119.sd01.xlsx', sheet_name='hg38_RetMICs')

short_exons['chr'] = short_exons.COORD.str.split(':').str[0]
short_exons['start'] = short_exons.COORD.str.split(':').str[1].str.split('-').str[0]
short_exons['end'] = short_exons.COORD.str.split(':').str[1].str.split('-').str[1]

cols_to_keep = ['chr', 'start', 'end']
short_exons.loc[:, cols_to_keep].to_csv('../data/retina_specific_exons/short_exons.bed', sep = '\t', index=False)

# %%
long_exons = pd.read_excel('../data/retina_specific_exons/pnas.2117090119.sd01.xlsx', sheet_name='hg38_RetLONGs')
long_exons['chr'] = long_exons.COORD.str.split(':').str[0]
long_exons['start'] = long_exons.COORD.str.split(':').str[1].str.split('-').str[0]
long_exons['end'] = long_exons.COORD.str.split(':').str[1].str.split('-').str[1]
long_exons.loc[:, cols_to_keep].to_csv('../data/retina_specific_exons/long_exons.bed', sep = '\t', index=False)

