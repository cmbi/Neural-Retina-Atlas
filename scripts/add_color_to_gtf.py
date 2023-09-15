import pandas as pd
import argparse

# Define a custom function to map transcript names to colors
def map_transcript_class_to_color(name):
    if 'nnic' in name:
        return '175,62,77'
    elif 'ENST' in name:
        return '78,128,152'
    elif 'nic' in name:
        return '231,111,81'
    else:
        return None


# Define a custom function to map ORF classification to colors
def map_orf_class_to_color(name):
    if 'pNNC' in name:
        return '175,62,77'
    elif 'pFSM' in name:
        return '78,128,152'
    elif 'pNIC' in name:
        return '231,111,81'
    else:
        return None

def add_color_to_bed(input_file, output_file, mapping_function):
    bed = pd.read_csv(input_file, sep = '\t', header= None)
    bed.columns = ['chrom', 'chromStart', 'chromEnd', 'name', 'score', 'strand', 'tickStart', 'thickEnd', 'itemRgb', 'blockCount', 'blockSizes', 'blockStarts']
    # only keep the transcript name and protein classification in the name
    if mapping_function == map_orf_class_to_color:
        bed['name'] = bed['name'].str.split('|').str[1:3].str.join('|')
    bed['itemRgb'] = bed['name'].apply(mapping_function)
    bed.to_csv(output_file, sep = '\t', header=False, index = False)

def main():
    parser = argparse.ArgumentParser(description='Add color information to a BED file.')
    parser.add_argument('input_file', help='Path to the input BED file')
    parser.add_argument('output_file', help='Path to the output BED file')
    parser.add_argument('--mapping_function', choices=['transcript', 'orf'], default='transcript',
                        help='Choose mapping function: "transcript" or "orf" (default: "transcript")')

    args = parser.parse_args()

    if args.mapping_function == 'transcript':
        mapping_function = map_transcript_class_to_color
    elif args.mapping_function == 'orf':
        mapping_function = map_orf_class_to_color

    add_color_to_bed(args.input_file, args.output_file, mapping_function)

if __name__ == "__main__":
    main()
    