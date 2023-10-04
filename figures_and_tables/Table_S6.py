# Import
import pandas as pd

# Load the file with transcript and ORD classification
sqanti_protein = pd.read_csv('../data/proteomics/hnr_50.classification_filtered.tsv', sep = '\t')

# Extract the transcript classification from the transcript name
sqanti_protein['tclass'] = [i[-1] for i in sqanti_protein.pb.str.split('.')]
transcript_class_count = {}
transcript_class_count['NNIC'] = sqanti_protein[sqanti_protein.tclass == 'NNIC'].pclass.value_counts()
transcript_class_count['NIC'] = sqanti_protein[sqanti_protein.tclass == 'NIC'].pclass.value_counts()

# Create a dataframe with the transcript counts
transcript_class_count_df = pd.DataFrame(transcript_class_count)
print(transcript_class_count_df)