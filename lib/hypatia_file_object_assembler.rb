class HypatiaFileObjectAssembler
  
  attr_accessor :ftk_processor 
  
  def initialize(args={})
    @logger = Logger.new('logs/logfile.log')
    @logger.debug 'Initializing Hypatia File Object Assembler'
    
    if args[:fedora_config]
      ActiveFedora.init(args[:fedora_config])
    else
      ActiveFedora.init
    end
  end
  
  # Process an FTK report and turn each of the files into fedora objects
  # @param [String] the path to the FTK report
  def process(ftk_report)
    @logger.debug "ftk report = #{ftk_report}"
    @ftk_processor = FtkProcessor.new(:ftk_report => ftk_report, :logfile => @logger)
    @ftk_processor.files.each do |ftk_file|
      create_bag(ftk_file[1])
    end
  end
  
  # WHAT_DOES_THIS_METHOD_DO?
  # @param [FtkFile] The FTK file object 
  # @return 
  # @example
  def create_bag(ff)
    
  end
  
  # Build a MODS record for the FtkFile 
  # @param [FtkFile] The FTK file object
  # @return
  def buildDescMetadata(ff)
    builder = Nokogiri::XML::Builder.new do |xml|
      # Really, mods records should be in the mods namespace, 
      # but it makes it a bit of a pain to query them. 
      xml.mods('xmlns' => "http://www.loc.gov/mods/v3") {
      # xml.mods {
        xml.titleInfo {
          xml.title_ ff.title
        }
        xml.typeOfResource_ ff.type
        xml.physicalDescription {
          xml.form_ ff.medium
        }
      }
    end
    builder.to_xml
  end
  
end