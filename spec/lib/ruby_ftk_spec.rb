require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(File.dirname(__FILE__), "/../../lib/ruby_ftk")
require 'rubygems'
require 'ruby-debug'


describe RubyFtk do
  
  context "basic behavior" do
    it "can instantiate" do
      r = RubyFtk.new
      r.class.should eql(RubyFtk)
    end
    
    it "can accept an FTK XML report as input" do
      fixture_location = File.join(File.dirname(__FILE__), "/../fixtures/Gould_FTK_Report.xml")
      r = RubyFtk.new(:ftk_report => fixture_location)
      r.ftk_report.should eql(fixture_location)
    end
  end
  
  context "extract collection level values" do
    before(:all) do
      @report = File.join(File.dirname(__FILE__), "/../fixtures/Gould_FTK_Report.xml")
      @r = RubyFtk.new(:ftk_report => @report)
    end
    
    it "can extract the collection title" do
      @r.collection_title.should eql("Stephen Jay Gould papers")
    end
    
    it "can extract the collection call number" do
      @r.call_number.should eql("M1437")
    end
    
    it "can extract the series information" do
      @r.series.should eql("Series 6: Born Digital Materials")
    end
  end
  
  context "extract file description" do
    before(:all) do
      @report = File.join(File.dirname(__FILE__), "/../fixtures/Gould_FTK_Report.xml")
      @r = RubyFtk.new(:ftk_report => @report)
    end
    
    it "knows how many files are represented" do
      @r.file_count.should eql(56)
    end
    
    it "knows the file name of each file" do
      @r.files["NATHIN32_52007"][:filename].should eql("NATHIN32")
      @r.files["NATHIN32_52007"][:id].should eql("52007")
    end
    
    it "knows the size of each file" do
      @r.files["NATHIN32_52007"][:filesize].should eql("37180 B")
    end
  end
  
end