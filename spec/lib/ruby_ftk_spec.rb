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
  end
  
end