

combined_cds_utr_gtffile <- function(gene, gtf_file_path, out_file_path) {
  
  # Import the CPAT gtf (only novel ORFs)
  gtf_cds <- rtracklayer::import(gtf_file_path)
  gtf_cds <- gtf_cds %>% dplyr::as_tibble()
  
  # Filter annotation for gene of interest
  goi_annotation_from_gtf <- gtf_cds  %>% 
    dplyr::filter(!is.na(gene_id), gene_id == gene) 
  
  # Extract exons
  exons <- goi_annotation_from_gtf %>% dplyr::filter(type == "exon")
  
  # Extract cds
  cds <- goi_annotation_from_gtf %>% dplyr::filter(type == "CDS")
  cds %>% head()
  
  # Add 3 base pairs to the end of CDS to include stop codon
  cds_w_stop <- cds %>%
    dplyr::group_by(transcript_id) %>%
    dplyr::mutate(
      end = ifelse(end == max(end), end + 3, end)
    ) %>%
    dplyr::ungroup()
  
  # Add UTR to CDS
  cds_utr <- add_utr(exons, cds, group_var = "transcript_id")
  
  # Combine data frames
  combined <- rbind(cds_utr, goi_annotation_from_gtf)

  combined$transcript_id <- sapply(combined$transcript_id, function(x) strsplit(x, "\\|")[[1]][2])
  
  # Export combined data to GTF file
  export(combined, out_file_path)
}