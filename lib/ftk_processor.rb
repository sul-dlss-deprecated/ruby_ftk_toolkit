require 'nokogiri'
require 'active-fedora'

class FtkProcessor
  
  attr_accessor :ftk_report       # The location of the ftk xml file we're processing
  attr_reader :collection_title # The name of the collection
  attr_reader :call_number      # The call number of the collection
  attr_reader :series           # The series
  attr_reader :file_count       # The number of files described by this FTK report
  attr_reader :files            # A Hash of all the file descriptions
  
  # Initialize an FTK object. 
  # If you don't pass in any arguments, it won't do anything, and you'll need to manually set the FTK report location and run
  # "process_ftk_report" yourself.
  # For fastest processing, pass the location of the ftk report in at initialization time
  # @example instantiating with an FTK report
  #  r = FtkProcessor.new(:ftk_report => "/path/to/FTK_report.xml")
  def initialize(args = {})
    
    if args[:fedora_config]
      ActiveFedora.init(args[:fedora_config])
    else
      ActiveFedora.init
    end
    
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
      getMd5(node,unique_combo)
      getSha1(node,unique_combo)
      getExportPath(node,unique_combo)
      getRestricted(node,unique_combo)
      getDuplicate(node,unique_combo)
    end
  end
  
  # Is this a duplicate file? 
  # @param [Nokogiri::XML::Element] node
  # @param [String] unique_combo the Hash key for each file
  def getDuplicate(node,unique_combo)
    @files[unique_combo][:duplicate] = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Duplicate File']]/fo:table-cell[2]/fo:block/text()").to_s
  end
  
  # Extract the export path for a given file
  # @param [Nokogiri::XML::Element] node
  # @param [String] unique_combo the Hash key for each file
  def getRestricted(node,unique_combo)
    @files[unique_combo][:restricted] = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Flagged Privileged']]/fo:table-cell[2]/fo:block/text()").to_s
  end
  
  # Extract the export path for a given file
  # @param [Nokogiri::XML::Element] node
  # @param [String] unique_combo the Hash key for each file
  def getExportPath(node,unique_combo)
    @files[unique_combo][:export_path] = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Exported as']]/fo:table-cell[2]/fo:block/fo:basic-link/@external-destination").to_s
  end
  
  # Extract the md5 checksum for a given file
  # @param [Nokogiri::XML::Element] node
  # @param [String] unique_combo the Hash key for each file
  def getMd5(node,unique_combo)
    @files[unique_combo][:md5] = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='MD5 Hash']]/fo:table-cell[2]/fo:block/text()").to_s
  end
  
  # Extract the sha1 checksum for a given file
  # @param [Nokogiri::XML::Element] node
  # @param [String] unique_combo the Hash key for each file
  def getSha1(node,unique_combo)
    @files[unique_combo][:sha1] = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='SHA1 Hash']]/fo:table-cell[2]/fo:block/text()").to_s
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