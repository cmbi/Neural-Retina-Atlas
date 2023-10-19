import pandas as pd
import requests, sys

# Take the input and output file from the command line
inputfile = sys.argv[1]
outputfile = sys.argv[2]

# read the classification file as dataframe
df = pd.read_csv(inputfile, sep = '\t')

unique_geneids = set(df['associated_gene'])
unique_geneids = list(unique_geneids)

unique_geneids = [i.split('.')[0] for i in unique_geneids]

# split the gene ids into chunks of 100
chunks = [unique_geneids[x:x+1000] for x in range(0, len(unique_geneids), 1000)]

# Connect to the ensemble rest API to retrieve the gene names

genes = {}

counter = 0
for i in chunks:
    server = "https://rest.ensembl.org"
    ext = "/lookup/id/"
    headers={ "Content-Type" : "application/json", "Accept" : "application/json"}
    r = requests.post(server+ext, headers=headers, json ={'ids' :  i})
    decoded = r.json()
    for j in decoded:
        try:
            genes[decoded[j]['id']] = decoded[j]['display_name']
        except:
            pass
        
    print(counter*100)

    counter += 1

genename = []

for i in df['associated_gene']:
    i = i.split('.')[0]
    try:
        name = genes[i]
    except:
        name = i
        
    genename.append(name)
    
# add the gene name of all genes in the classification file to the dataframe
df.insert(8, 'gene name', genename)

df.to_csv(outputfile) 
