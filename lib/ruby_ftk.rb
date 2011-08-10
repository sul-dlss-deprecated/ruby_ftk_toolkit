
class RubyFtk
  
  attr_accessor :ftk_report   # The location of the ftk xml file we're processing
  
  def initialize(args = {})
    if args[:ftk_report]
      raise "Can't find file #{args[:ftk_report]}" unless File.file? args[:ftk_report]
      @ftk_report = args[:ftk_report]
    end
  end
  
  
end