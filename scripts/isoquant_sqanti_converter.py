#!/usr/bin/env python3

import pandas as pd
import argparse

#make function for each of the dataframe partitions to filter
def collapse_reads(df,mapping):
    df['isoform']=df.isoform.apply(lambda x: mapping[x] if x in mapping else None)
    return(df.dropna(subset=['isoform']).drop_duplicates('isoform'))

def create_mapping_from_df(file):
    df=pd.read_table(file)
    df=df[df.transcript_id!='*']
    df.groupby('transcript_id')
    return(dict(zip(df["#read_id"],df.transcript_id)))

def main():
    parser = argparse.ArgumentParser(description='collapse read-level sqanti output to transcript level')
    parser.add_argument('sqanti_read', help='SQANTI classification file read-level from isoquant')
    parser.add_argument('read_mapping', help='isoquant file that ends with .transcript_model_reads.tsv')
    parser.add_argument('counts', help='isoquant file that ends with .transcript_model_counts.tsv')
    args=parser.parse_args()

    read_to_transcript=create_mapping_from_df(args.read_mapping)
    df=pd.DataFrame()
    for x in pd.read_table(args.sqanti_read, chunksize=5000):
        df=pd.concat([df,collapse_reads(x,read_to_transcript)])
    df=df.dropna(subset=['isoform']).drop_duplicates('isoform').merge(pd.read_table(args.counts,index_col=0,names=['FL_count'],header=0),left_on='isoform',right_index=True)
    df['isoform']=df['isoform'].str.upper() # make upper case
    df.to_csv('isoquant_transcript.SQANTI-like.tsv',sep='\t',index=False)

if __name__ == '__main__':
    main()
