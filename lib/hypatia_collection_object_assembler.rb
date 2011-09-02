# Assemble EAD into collection level objects for Hypatia. 
# @example Process an FTK report and a directory of files
#  my_fedora_config = "/path/to/fedora.yml"
class HypatiaCollectionObjectAssembler
  
  attr_accessor :ead            # The EAD to process
  attr_accessor :fedora_config  # The fedora config file
  attr_accessor :fedora_url     # the Fedora URL we're connecting to
  attr_accessor :collection     # The fedora object representing the collection
  
  XPATH = {
    :title => "/ead/archdesc[@level='collection']/did/unittitle/text()"
    
  }
  
  def initialize(args)
    if args[:logfile]
      @logger = args[:logfile]
    else
      @logger = Logger.new('logs/collection_processor.log')
    end
    
    raise "Please give me an ead file to process" unless args[:ead]
    raise "I can't find the file #{args[:ead]}" unless File.file? args[:ead]
    @ead = args[:ead]
    raise "Please pass me a fedora config" unless args[:fedora_config]
    @fedora_config = args[:fedora_config]
    ActiveFedora.init(args[:fedora_config])
    @collection = HypatiaCollection.new(:pid_namespace => "hypatia")
    @doc = Nokogiri::XML(File.open(@ead))
    @doc.remove_namespaces!
  end
  
  # build the descMetadata datastream from the ead
  # @return [Nokogiri::XML::Document]
  def buildDescMetadata
    @logger.debug "building desc metadata for collection #{@ead} "
    reader = Nokogiri::XML::Reader(File.read(@ead))
    builder = Nokogiri::XML::Builder.new do |xml|
      reader.each do |node|
        node.read until node.name=='archdesc' and node.attribute("level")=='collection'
        node.read until node.name=='unittitle'
        node.read # to get to the inside of the unittitle tag
        
        xml.mods('xmlns:mods' => "http://www.loc.gov/mods/v3") {
          xml.parent.namespace = xml.parent.namespace_definitions.first
          xml['mods'].titleInfo {
            xml['mods'].title_ node.value
          }
          
          @logger.debug "!! #{node.value}"
        
          xml['mods'].name('type' => 'personal') {
            xml['mods'].namePart 
          }
        }
      
      end
    end
    @logger.debug builder.to_xml
    builder.to_xml
  end
  
end