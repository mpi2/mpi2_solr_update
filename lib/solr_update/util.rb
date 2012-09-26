module SolrUpdate::Util
  def allele_image_url(allele_id)
    return SolrUpdate::Config.fetch('targ_rep_url') + "/alleles/#{allele_id}/allele-image"
  end

  def genbank_file_url(allele_id)
    return SolrUpdate::Config.fetch('targ_rep_url') + "/alleles/#{allele_id}/escell-clone-genbank-file"
  end
end
