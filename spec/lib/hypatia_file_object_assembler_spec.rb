require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(File.dirname(__FILE__), "/../../lib/ftk_file")
require File.join(File.dirname(__FILE__), "/../../lib/ftk_processor")
require File.join(File.dirname(__FILE__), "/../../lib/hypatia_file_object_assembler")
require File.join(File.dirname(__FILE__), "/../factories/ftk_files.rb")

require 'rubygems'
require 'ruby-debug'
require 'factory_girl'
require 'tempfile'

describe HypatiaFileObjectAssembler do
  before(:all) do
    @fedora_config = File.join(File.dirname(__FILE__), "/../config/fedora.yml")
    @ftk_report = File.join(File.dirname(__FILE__), "/../fixtures/Gould_FTK_Report.xml")
    @file_dir = File.join(File.dirname(__FILE__), "/../fixtures/files")
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
      hfo.process(@ftk_report,@file_dir)
      hfo.ftk_report.should eql(@ftk_report)
      hfo.file_dir.should eql(@file_dir)
    end
  end
  
  context "creating datastreams" do
    before(:all) do
      @ff = FactoryGirl.build(:ftk_file)
      @fedora_config = File.join(File.dirname(__FILE__), "/../config/fedora.yml")
      @hfo = HypatiaFileObjectAssembler.new(:fedora_config => @fedora_config)
    end
    it "creates a descMetadata file" do
      doc = Nokogiri::XML(@hfo.buildDescMetadata(@ff))
      doc.xpath("/mods:mods/mods:titleInfo/mods:title/text()").to_s.should eql(@ff.title)
      doc.xpath("/mods:mods/mods:typeOfResource/text()").to_s.should eql(@ff.type)
      doc.xpath("/mods:mods/mods:physicalDescription/mods:form/text()").to_s.should eql(@ff.medium)
    end
    it "creates a contentMetadata file" do
      doc = Nokogiri::XML(@hfo.buildContentMetadata(@ff))
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
      doc = Nokogiri::XML(@hfo.buildRightsMetadata(@ff))
      doc.xpath("/xmlns:rightsMetadata/xmlns:access[@type='discover']/xmlns:machine/xmlns:group/text()").to_s.should eql(@ff.access_rights.downcase)
      doc.xpath("/xmlns:rightsMetadata/xmlns:access[@type='read']/xmlns:machine/xmlns:group/text()").to_s.should eql(@ff.access_rights.downcase)
    end
    it "creates a RELS-EXT datastream" do
      doc = Nokogiri::XML(@hfo.buildRelsExt(@ff))
      doc.xpath("/rdf:RDF/rdf:Description/hydra:isGovernedBy/@rdf:resource").to_s.should eql("info:fedora/hypatia:fixture_xanadu_apo")
    end
  end
  
  context "creating bags" do
    before(:all) do
      @ff = FactoryGirl.build(:ftk_file)
      @fedora_config = File.join(File.dirname(__FILE__), "/../config/fedora.yml")
      @hfo = HypatiaFileObjectAssembler.new(:fedora_config => @fedora_config)
      @ftk_report = File.join(File.dirname(__FILE__), "/../fixtures/Gould_FTK_Report.xml")
      @file_dir = File.join(File.dirname(__FILE__), "/../fixtures")
    end
    it "knows where to put bags it creates" do
      Dir.mktmpdir {|dir|
        hfo = HypatiaFileObjectAssembler.new(:fedora_config => @fedora_config, :bag_destination => dir)
        hfo.bag_destination.should eql(dir)
       }
    end
    
    it "throws an exception if you try to create a bag without telling it where the payload files are" do
      Dir.mktmpdir { |dir|
        hfo = HypatiaFileObjectAssembler.new(:fedora_config => @fedora_config, :bag_destination => dir)
        lambda { hfo.create_bag(@ff) }.should raise_exception
      }
    end
    
    it "creates a bagit package for an ftk_file" do
      Dir.mktmpdir {|dir|
        hfo = HypatiaFileObjectAssembler.new(:fedora_config => @fedora_config, :bag_destination => dir)
        hfo.file_dir = @file_dir
        bag = hfo.create_bag(@ff)
        
        File.file?(File.join(dir,@ff.unique_combo,"/data/contentMetadata.xml")).should eql(true)
        File.file?(File.join(dir,@ff.unique_combo,"/data/descMetadata.xml")).should eql(true)
        File.file?(File.join(dir,@ff.unique_combo,"/data/RELS-EXT.xml")).should eql(true)
        File.file?(File.join(dir,@ff.unique_combo,"/data/rightsMetadata.xml")).should eql(true)
        File.file?(File.join(dir,@ff.unique_combo,"/data/#{@ff.destination_file}")).should eql(true)
        bag.valid?.should eql(true)
       }
    end
  end
end