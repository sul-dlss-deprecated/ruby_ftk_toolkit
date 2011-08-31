require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(File.dirname(__FILE__), "/../../lib/ftk_file")
require File.join(File.dirname(__FILE__), "/../../lib/ftk_processor")
require File.join(File.dirname(__FILE__), "/../../lib/hypatia_file_object_assembler")
require File.join(File.dirname(__FILE__), "/../../lib/hypatia_collection_object_assembler")
require File.join(File.dirname(__FILE__), "/../factories/ftk_files.rb")

require 'rubygems'
require 'ruby-debug'
require 'factory_girl'
require 'tempfile'

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HypatiaCollectionObjectAssembler do
  before(:each) do
    @test_fedora_config = File.join(File.dirname(__FILE__), "/../config/fedora.yml")
    @test_fedora = "http://localhost:8983/fedora_url"
    @ead_file = File.join(File.dirname(__FILE__), "/../fixtures/Gould_EAD.xml")
    ENV['environment'] = 'test'
    @h = HypatiaCollectionObjectAssembler.new(:ead => @ead_file, :fedora_config => @test_fedora_config)
    
  end
  context "basic behavior" do
    it "can be instantiated" do
      @h.class.should eql(HypatiaCollectionObjectAssembler)
    end
    it "has an EAD file" do
      @h.ead.should eql(@ead_file)
    end
    it "raises an error if it isn't passed a fedora url" do
      lambda{ HypatiaCollectionObjectAssembler.new(:ead => @ead_file) }.should raise_exception
    end
    it "sets a fedora config" do
      @h.fedora_config.should eql(@test_fedora_config)
    end
    it "has a collection level object" do
      @h.collection.should be_instance_of(ActiveFedora::Base)
    end
  end

end