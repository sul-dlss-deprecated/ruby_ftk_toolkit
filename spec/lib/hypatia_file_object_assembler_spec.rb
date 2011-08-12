require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(File.dirname(__FILE__), "/../../lib/ftk_file")
require File.join(File.dirname(__FILE__), "/../../lib/ftk_processor")
require File.join(File.dirname(__FILE__), "/../../lib/hypatia_file_object_assembler")
require File.join(File.dirname(__FILE__), "/../factories/ftk_files.rb")

require 'rubygems'
require 'ruby-debug'
require 'factory_girl'

describe HypatiaFileObjectAssembler do
  before(:all) do
    @fedora_config = File.join(File.dirname(__FILE__), "/../config/fedora.yml")
    @ftk_report = File.join(File.dirname(__FILE__), "/../fixtures/Gould_FTK_Report.xml")
  end
  context "basic behavior" do
    it "can instantiate" do
      hfo = HypatiaFileObjectAssembler.new
      hfo.class.should eql(HypatiaFileObjectAssembler)
    end
    it "takes a fedora config file as an argument" do
      hfo = HypatiaFileObjectAssembler.new(:fedora_config => @fedora_config)
      Fedora::Repository.instance.fedora_version.should eql("3.4.2")
    end
    it "processes an FTK report" do
      hfo = HypatiaFileObjectAssembler.new(:fedora_config => @fedora_config)
      hfo.expects(:create_bag).at_least(56).returns(nil)
      hfo.process(@ftk_report)
    end
  end
  
  context "creating bags" do
    before(:all) do
      @ff = FactoryGirl.build(:ftk_file)
      @hfo = HypatiaFileObjectAssembler.new(:fedora_config => @fedora_config)
    end
    it "creates a descMetadata file" do
      dm = @hfo.buildDescMetadata(@ff)
      doc = Nokogiri::XML(dm)
      doc.xpath("/mods:mods/mods:titleInfo/mods:title/text()").to_s.should eql(@ff.title)
      doc.xpath("/mods:mods/mods:typeOfResource/text()").to_s.should eql(@ff.type)
      doc.xpath("/mods:mods/mods:physicalDescription/mods:form/text()").to_s.should eql(@ff.medium)
    end
    it "creates a contentMetadata file" do
      cm = @hfo.buildContentMetadata(@ff)
      doc = Nokogiri::XML(cm)
      doc.xpath("/contentMetadata/@type").to_s.should eql("born-digital")
      doc.xpath("/contentMetadata/@objectId").to_s.should eql(@ff.unique_combo)
      doc.xpath("/contentMetadata/resource/@type").to_s.should eql("analysis")
      doc.xpath("/contentMetadata/resource/file/@id").to_s.should eql(@ff.filename)
      doc.xpath("/contentMetadata/resource/file/@format").to_s.should eql(@ff.filetype)
      doc.xpath("/contentMetadata/resource/file/location/@type").to_s.should eql("filesystem")
      doc.xpath("/contentMetadata/resource/file/location/text()").to_s.should eql(@ff.export_path)      
      doc.xpath("/contentMetadata/resource/file/checksum[@type='md5']/text()").to_s.should eql(@ff.md5)      
      doc.xpath("/contentMetadata/resource/file/checksum[@type='sha1']/text()").to_s.should eql(@ff.sha1)
    end
    it "creates a rightsMetdata file" do
      rm = @hfo.buildRightsMetadata(@ff)
      doc = Nokogiri::XML(rm)
      doc.xpath("/xmlns:rightsMetadata/xmlns:access[@type='discover']/xmlns:machine/xmlns:group/text()").to_s.should eql(@ff.access_rights.downcase)
      doc.xpath("/xmlns:rightsMetadata/xmlns:access[@type='read']/xmlns:machine/xmlns:group/text()").to_s.should eql(@ff.access_rights.downcase)
    end
    it "creates a RELS-EXT datastream" do
      doc = Nokogiri::XML(@hfo.buildRelsExt(@ff))
      doc.xpath("/rdf:RDF/rdf:Description/hydra:isGovernedBy/@rdf:resource").to_s.should eql("info:fedora/hypatia:fixture_xanadu_apo")
    end
  end
end