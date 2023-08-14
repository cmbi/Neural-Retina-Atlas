from gtfparse import read_gtf
import argparse

def uppercase_gtf(gtf,outfile_name):
    outfile=open(outfile_name,'w')
    with open(gtf) as gtf_file:
        for line in gtf_file:
            if 'transcript_id "' in line:
                beginning,tid=line.split('transcript_id "',1)
                tid,ending=tid.split('"',1)
                to_write=beginning+'transcript_id "'+tid.upper()+'"'+ending
                outfile.write(to_write)
            else:
                outfile.write(line)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--gtf', action='store', dest= 'sample_gtf',help='sample gtf file location')
    parser.add_argument('--gtf_out', action='store', dest= 'gtf_out',help='output file location')
    results = parser.parse_args()
    uppercase_gtf(results.sample_gtf,results.gtf_out)

if __name__ == '__main__':
    main()

