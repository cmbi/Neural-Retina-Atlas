# Oxford Nanopore Technology (ONT) data analysis

## 1. IsoQuant

```
isoquant.py \
--reference ../../data/ref_genome/GRCh38/hg38.fa  \
--genedb ../../data/ref_genome/gencode.v39.primary_assembly.annotation.gtf \
--complete_genedb \
--bam_list files.txt \
--read_group file_name \
--data_type nanopore \
--fl_data \
--threads 20 \
--model_construction_strategy default_ont \
-o isoquant/ \
--check_canonical \
--transcript_quantification unique_only \
--gene_quantification unique_only \
--splice_correction_strategy default_ont
```

## 2. CPAT

```
../../tools/TransDecoder-TransDecoder-v5.5.0/util/gtf_genome_to_cdna_fasta.pl \
ont.combined.gtf $genome > ont.isoquant.combined.fa

nextflow ../proteomics/lrp_isoquant/4_cpat.nf \
--name ont_isoquant \
--hexamer /mnt/xomics/tabear/atlas_paper/proteome/modules_isoquant/Human_Hexamer.tsv \
--logit_model /mnt/xomics/tabear/atlas_paper/proteome/Human_logitModel.RData \
--sample_fasta ont.isoquant.combined.fa \
--min_orf 50 \
--outdir cpat/
```

## 3. Reove seqID from the best_orf file

```
cut -f 2- < cpat/cpat/ont_isoquant.ORF_prob.best.tsv > ../data/transcriptomics/ont.ORF_prob.best.tsv
```

## 4. Remove stop codon from ORF to match PacBio data

```
python remove_stop_codon_from_orf.py
```

## 5. Convert GTF to BED
The AGAT singularity container can be pulled as descrobed on the [AGAT GitHub](https://github.com/NBISweden/AGAT)

```
python ../../proteomics/lrp_isoquant/2a_gtf_uppercase.py \
--gtf ont.combined.gtf \
--gtf_out ont.combined_upper.gtf

singularity shell -B `pwd`:/mnt/data/ agat_1.0.0--pl5321hdfd78af_0.sif
agat_convert_sp_gff2bed.pl -gff /mnt/data/ont.combined_upper.gtf-o /mnt/data/ont.combined.bed
```

## 6. Convert CPAT output to BED
The container is available at docker under rlsalz/biopj

```
singularity shell -B `pwd`:/mnt/data/ suspect.sif
python /mnt/data/cpat_to_bed.py /mnt/data/ont_best_orf_without_stop.tsv /mnt/data/ont.combined.bed /mnt/data/ont_cds.combined.bed
```

## 7. Add UTR to BED

```
python add_utr_to_bed.py
```

## 8. Convert BED to GTF

```
bedToGenePred transcripts_and_orfs.bed ont.genePred
genePredToGtf file ont.genePred ont_ucsc.gtf
```
