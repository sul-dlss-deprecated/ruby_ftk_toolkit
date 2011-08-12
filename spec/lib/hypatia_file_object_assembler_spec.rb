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
      doc.xpath("/xmlns:mods/xmlns:titleInfo/xmlns:title/text()").to_s.should eql(@ff.title)
      doc.xpath("/xmlns:mods/xmlns:typeOfResource/text()").to_s.should eql(@ff.type)
      doc.xpath("/xmlns:mods/xmlns:physicalDescription/xmlns:form/text()").to_s.should eql(@ff.medium)
    end
  end
end