require 'nokogiri'

class RubyFtk
  
  attr_accessor :ftk_report       # The location of the ftk xml file we're processing
  attr_accessor :collection_title  # The name of the collection
  attr_accessor :call_number      # The call number of the collection
  
  def initialize(args = {})
    if args[:ftk_report]
      raise "Can't find file #{args[:ftk_report]}" unless File.file? args[:ftk_report]
      @ftk_report = args[:ftk_report]
    end
    @doc = Nokogiri::XML(File.open(@ftk_report)) if @ftk_report
    process_ftk_report if @doc
  end
  
  # Extract data from the ftk xml report
  def process_ftk_report
    get_title_and_call_number
  end
  
  # WHAT_DOES_THIS_METHOD_DO?
  # @param
  # @return
  # @example
  def get_title_and_call_number
    text = @doc.xpath("//fo:page-sequence[2][fo:flow/fo:block[text()='Case Information']]/fo:flow/fo:table[1]/fo:table-body/fo:table-row[3]/fo:table-cell[2]/fo:block/text()")
    split_text = text.to_s.partition(" ")
    @collection_title = split_text[2]
    @call_number = split_text[0]
  end
  
end