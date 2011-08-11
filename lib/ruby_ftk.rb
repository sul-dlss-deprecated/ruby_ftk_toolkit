require 'nokogiri'

class RubyFtk
  
  attr_accessor :ftk_report       # The location of the ftk xml file we're processing
  attr_accessor :collection_title # The name of the collection
  attr_accessor :call_number      # The call number of the collection
  attr_accessor :series           # The series
  attr_accessor :file_count       # The number of files described by this FTK report
  attr_accessor :files            # A Hash of all the file descriptions
  
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
    @files = {}
    get_title_and_call_number
    get_series
    get_file_descriptions
  end
  
  def get_title_and_call_number
    text = @doc.xpath("//fo:page-sequence[2][fo:flow/fo:block[text()='Case Information']]/fo:flow/fo:table[1]/fo:table-body/fo:table-row[3]/fo:table-cell[2]/fo:block/text()")
    split_text = text.to_s.partition(" ")
    @collection_title = split_text[2]
    @call_number = split_text[0]
  end
  
  def get_series
    @series = @doc.xpath("//fo:page-sequence[1][fo:flow/fo:block[text()='Case Information']]/fo:flow/fo:block[7]/text()").to_s
  end
  
  def get_file_descriptions
    file_array = @doc.xpath("//fo:table-body[fo:table-row/fo:table-cell/fo:block[text()='File Comments']]")
    @file_count = file_array.length
    file_array.each do |node|
      filename = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Name']]/fo:table-cell[2]/fo:block/text()").to_s
      id = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Item Number']]/fo:table-cell[2]/fo:block/text()").to_s
      unique_combo = "#{filename}_#{id}"
      filesize = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Logical Size']]/fo:table-cell[2]/fo:block/text()").to_s
      filetype = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='File Type']]/fo:table-cell[2]/fo:block/text()").to_s
      filepath = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Path']]/fo:table-cell[2]/fo:block/text()").to_s
      disk_image_number = filepath.slice(0,5)
      file_creation_date = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Created Date']]/fo:table-cell[2]/fo:block/text()").to_s
      file_accessed_date = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Accessed Date']]/fo:table-cell[2]/fo:block/text()").to_s
      file_modified_date = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Modified Date']]/fo:table-cell[2]/fo:block/text()").to_s
      
      @files[unique_combo] = {:id => id, 
        :filename => filename, 
        :filesize => filesize,
        :filetype => filetype,
        :filepath => filepath,
        :disk_image_number => disk_image_number,
        :file_creation_date => file_creation_date,
        :file_accessed_date => file_accessed_date,
        :file_modified_date => file_modified_date
        }
      getLabels(node,unique_combo)
      
    end
  end
  
  # Extract the labels attached to a file and split them apart
  # The FTK report stores them like this:
  # [access_rights]Public,[medium]3.5 inch Floppy Disks,[type]Natural History Magazine Column 
  # @param [Nokogiri::XML::Element] node
  # @param [String] unique_combo the Hash key for each file
  def getLabels(node, unique_combo)
    label_hash = {}
    labels = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Label']]/fo:table-cell[2]/fo:block/text()").to_s
    labels.split(',[').each do |pair|
      key = pair.split(']')[0].gsub('[','')
      value = pair.split(']')[1].strip
      @files[unique_combo][key.to_sym] = value # Add these values to the hash directly
    end
  end
  
end