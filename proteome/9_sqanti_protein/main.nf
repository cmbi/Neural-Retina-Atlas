#!/usr/bin/env nextflow

if (!params.sample_gtf) exit 1, "Cannot find any file for parameter --sample_gtf: ${params.sample_gtf}"
ch_sample_gtf =  Channel.value(file(params.sample_gtf))

if (!params.best_orf) exit 1, "Cannot find any file for parameter --best_orf: ${params.best_orf}"
ch_best_orf =  Channel.value(file(params.best_orf))

if (!params.reference_gtf) exit 1, "Cannot find any file for parameter --reference_gtf: ${params.reference_gtf}"
ch_reference_gtf =  Channel.value(file(params.reference_gtf))

ch_sample_transcript_exon_only = Channel.value(file(params.sample_exon))
ch_sample_cds_renamed = Channel.value(file(params.sample_cds))
ch_ref_transcript_exon_only = Channel.value(file(params.reference_exon))
ch_ref_cds_renamed = Channel.value(file(params.reference_cds))

process sqanti_protein{
    publishDir "${params.outdir}/${params.name}/sqanti_protein/", mode: 'copy'
    input:
        file(sample_exon) from ch_sample_transcript_exon_only
        file(sample_cds) from ch_sample_cds_renamed
        file(reference_exon) from ch_ref_transcript_exon_only
        file(reference_cds) from ch_ref_cds_renamed
        file(best_orf) from ch_best_orf
    output:
        file("${params.name}.sqanti_protein_classification.tsv") into ch_sqanti_protein_classification
    script:
    """
    sqanti3_protein.py \
    $sample_exon \
    $sample_cds \
    $best_orf \
    $reference_exon \
    $reference_cds \
    -d ./ \
    -p ${params.name}
    """
}
