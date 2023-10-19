# author: Renee Salz

import pandas as pd

transcript_bed = 'ont.combined.bed'
orf_bed = 'ont_cds.combined.bed'

transcripts=pd.read_table(transcript_bed, names = ['chrom', 'chromStart', 'chromEnd', 'name', 'score', 'strand', 'thickStart', 'thickEnd', 'itemRgb', 'blockCount', 'blockSizes', 'blockStarts'])
orfs=pd.read_table(orf_bed, header=0, names = ['chrom', 'chromStart', 'chromEnd', 'name', 'score', 'strand', 'thickStart', 'thickEnd', 'itemRgb', 'blockCount', 'blockSizes', 'blockStarts'])
orfs['transcript']=orfs['name'].str.split('_ORF',1).apply(lambda x: x[0])
combined=transcripts.merge(orfs[['transcript','name','thickStart','thickEnd']],left_on='name',right_on='transcript',suffixes=('','_orf'))
combined.blockCount = [int(i) for i in combined.blockCount]
combined[['chrom', 'chromStart', 'chromEnd', 'name_orf', 'score', 'strand', 'thickStart_orf', 'thickEnd_orf', 'itemRgb', 'blockCount', 'blockSizes', 'blockStarts']].to_csv("transcripts_and_orfs.bed",sep='\t',header=False,index=False)