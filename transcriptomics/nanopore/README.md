# Oxford Nanopore Technology (ONT) data analysis

## 1. CPAT

```
../tools/TransDecoder-v5.5.0/util/gtf_genome_to_cdna_fasta.pl \
../data/transcriptomics/ont.gtf ../data/ref_genome/hg38.fa > ../data/transcriptomics/ont.fa

nextflow ../proteomics/lrp_isoquant/4_cpat.nf \
--name ont \
--hexamer ../data/proteomics/Human_Hexamer.tsv \
--logit_model ../data/proteomics/Human_logitModel.RData \
--sample_fasta ../data/transcriptomics/ont.fa \
--min_orf 50 \
--outdir cpat/
```

## 2. Reove seqID from the best_orf file

```
cut -f 2- < cpat/cpat/ont.ORF_prob.best.tsv > ../data/transcriptomics/ont.ORF_prob.best.tsv
```

## 3. Convert GTF to BED
The AGAT singularity container can be pulled as descrobed on the [AGAT GitHub](https://github.com/NBISweden/AGAT)

```
singularity shell -B `pwd`:/mnt/data/ agat_1.0.0--pl5321hdfd78af_0.sif
agat_convert_sp_gff2bed.pl -gff /mnt/data/ont.gtf -o /mnt/data/ont.bed
```

## 4. Convert CPAT output to BED
The container is available at docker under rlsalz/biopj

```
singularity shell -B `pwd`:/mnt/data/ suspect.sif
python /mnt/data/transcriptomics/nanopore/cpat_to_bed.py /mnt/data/data/transcriptomics/ont.ORF_prob.best.tsv /mnt/data/data/transcriptomics/ont.bed /mnt/data/data/transcriptomics/ont_cds.bed
```

## 5. Add UTR to BED

```
python add_utr_to_bed.py
```

## 6. Convert BED to GTF

```
bedToGenePred transcripts_and_orfs.bed ont.genePred
genePredToGtf file ont.genePred ont_ucsc.gtf
```
