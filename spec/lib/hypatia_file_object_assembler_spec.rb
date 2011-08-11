require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(File.dirname(__FILE__), "/../../lib/ftk_file")
require File.join(File.dirname(__FILE__), "/../../lib/hypatia_file_object_assembler")
require 'rubygems'
require 'ruby-debug'

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
      hfo.process(@fixture_location)
    end
  end
end