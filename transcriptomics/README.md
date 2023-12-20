
## Required data
- Raw data is available at EGA with accesion EGAD50000000101
- Intermediate files can be downloaded from Zenodo: 
- Publicly available short-read RNA-sequencing data included in the SQANTI3 and TALON analysis can be downloaded from  EBI's ArrayExpress (E-MTAB-4377).

## Iso-Seq analysis with IsoQuant

### Software
| Tool  | Version | Link |
| ----- | ------- | ---- | 
| CCS | 6.2.0 | https://ccs.how/ |
| Lima | 2.4.0 | https://lima.how/ |
| Isoseq3 | 3.4.0 | https://github.com/PacificBiosciences/IsoSeq   |
| Minimap2  | 2.24 | https://github.com/lh3/minimap2  |
| SAMtools  | 1.15 | https://github.com/samtools/samtools |
| IsoQuant | 3.1.2 | https://github.com/ablab/IsoQuant |

### Scripts
1. [CCS](ccs.sh) - creates circular consensus sequence of the raw reads
2. [Isoseq](isoseq.sh) - primer removal, isoseq refine and mapping to reference genome
3. [IsoQuant](isoquant.sh) - isoform classification with IsoQuant

## Iso-Seq analysis with SQANTI3

### Software
| Tool  | Version | Link |
| ----- | ------- | ---- | 
| cDNA_Cupcake | 28.0.0 | https://github.com/Magdoll/cDNA_Cupcake |
| SQANTI3 | 5.1 | https://github.com/ConesaLab/SQANTI3 |

### Scripts
Start with `flnc.bam` from the IsoQuant analysis
1. [Isoseq](sqanti/isoseq.sh) - Cluster the isoforms, align them to the reference genome, and run cDNA Cupcake filtering
2. [Chain samples and run SQANTI3](sqanti/cupcake_chain_samples.sh) - Combine the three individual samples with cDNA Cupcake merge, add a FL column to the output and run SQANTI3 quality control and rulesfilter


## Iso-Seq analysis with TALON

### Software
| Tool  | Version | Link |
| ----- | ------- | ---- | 
| TranscriptClean | 2.0.3 | https://github.com/mortazavilab/TranscriptClean |
| TALON | 5.0 | https://github.com/mortazavilab/TALON |

### Scripts
Start with `flnc.bam` from the Isoquant analysis
1. [Isoseq](talon/isoseq.sh) - align the reads with Minimap2 with -MD flag, run TranscriptClean, and label reads for internal priming
2. [TALON](talon.sh) - Run TALON and filter for reads in at least one sample and at least two counts.

