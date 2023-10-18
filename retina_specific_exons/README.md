# Retina specific exons

We compared our results to previous reserach by looking for previously identfiied retina-specific exons in the PacBio retina transcriptome.

## Data
- `exons.gtf` - GTF file with all exons from the PacBio data
- `long_exons.bed` and `short_exons.bed` contain retina specific exons idenified by Ciampi et al. 
- `Musashi.bed` contains photoreceptor specific exons in mice identified by Muprhy et al. 

## Commands
The exons from the PacBio data were extracted with awk 

```
awk -F "\t" '$3=="exon"' \
../data/transcriptomics/isoquant_aln.sorted.transcript_models.gtf \
> exons.gtf
```

We used bedtools intersect to determine which retina-specific exons were present in the PacBio data 
```
bedtools intersect -u -f 1 \
-a short_exons.bed \
-b exons.gtf \
> overlap_short_exons.bed
```
```
bedtools intersect -u -f 1 \
-a long_exons.bed \
-b exons.gtf \
> overlap_long_exons.bed
```
```
bedtools intersect -u -f 1 \
-a Musashi.bed \
-b exons.gtf \
> overlap_musashi.bed
```
