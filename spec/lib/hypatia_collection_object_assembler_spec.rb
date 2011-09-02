require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(File.dirname(__FILE__), "/../../lib/ftk_file")
require File.join(File.dirname(__FILE__), "/../../lib/ftk_processor")
require File.join(File.dirname(__FILE__), "/../../lib/hypatia_file_object_assembler")
require File.join(File.dirname(__FILE__), "/../../lib/hypatia_collection_object_assembler")
require File.join(File.dirname(__FILE__), "/../../lib/hypatia_collection")

require File.join(File.dirname(__FILE__), "/../factories/ftk_files.rb")

require 'rubygems'
require 'ruby-debug'
require 'factory_girl'
require 'tempfile'

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HypatiaCollectionObjectAssembler do
  before(:each) do
    @test_fedora_config = File.join(File.dirname(__FILE__), "/../config/fedora.yml")
    @ead_file = File.join(File.dirname(__FILE__), "/../fixtures/Xanadu_EAD.xml")
    ENV['environment'] = 'test'
    @h = HypatiaCollectionObjectAssembler.new(:ead => @ead_file, :fedora_config => @test_fedora_config)
    
  end
  context "EAD processing" do
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
      @h.collection.should be_instance_of(HypatiaCollection)
    end
    it "creates a descMetadata file" do
      doc = Nokogiri::XML(@h.buildDescMetadata)
      doc.xpath("/mods:mods/mods:titleInfo/mods:title/text()").to_s.should eql("Keith Henson. Papers relating to Project Xanadu, XOC and Eric Drexler")
      # doc.xpath("/mods:mods/mods:typeOfResource/text()").to_s.should eql(@ff.type)
      # doc.xpath("/mods:mods/mods:physicalDescription/mods:form/text()").to_s.should eql(@ff.medium)
      
    end
  end

end