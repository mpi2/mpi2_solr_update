require 'test_helper'

class SolrUpdate::UtilTest < ActiveSupport::TestCase
  context 'SolrUpdate::Util' do

    setup do
      @testobj = Object.new
      @testobj.extend(SolrUpdate::Util)
    end

    should 'generate allele_image_url' do
      assert_equal 'http://www.knockoutmouse.org/targ_rep/alleles/55/allele-image',
              @testobj.allele_image_url(55)
    end

    should 'generate cre excised allele_image_url' do
      assert_equal 'http://www.knockoutmouse.org/targ_rep/alleles/55/allele-image-cre',
              @testobj.allele_image_url(55, :cre => true)
    end

    should 'generate genbank_file_url' do
      assert_equal 'http://www.knockoutmouse.org/targ_rep/alleles/55/escell-clone-genbank-file',
              @testobj.genbank_file_url(55)
    end

    should 'generate cre excised genbank_file_url' do
      assert_equal 'http://www.knockoutmouse.org/targ_rep/alleles/55/escell-clone-cre-genbank-file',
              @testobj.genbank_file_url(55, :cre => true)
    end

  end
end
