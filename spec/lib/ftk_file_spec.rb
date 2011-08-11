require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(File.dirname(__FILE__), "/../../lib/ruby_ftk")
require File.join(File.dirname(__FILE__), "/../../lib/ftk_file")
require 'rubygems'
require 'ruby-debug'

describe FtkFile do
  context "basic behavior" do
    it "can instantiate" do
      hfo = FtkFile.new
      hfo.class.should eql(FtkFile)
    end
    it "responds to all of the fields a file object needs" do
      hfo = FtkFile.new
      
      fields = [:filename=,:id=,:filesize=,:filetype=,:filepath=,:disk_image_number=,
          :file_creation_date=,:file_accessed_date=,:file_modified_date=,:medium=,:title=,
          :access_rights=,:duplicate=,:restricted=,:md5=,:sha1=,:export_path=]
      fields.each do |field|
        hfo.send(field,"foo").should eql("foo")
      end
    end
  end
end