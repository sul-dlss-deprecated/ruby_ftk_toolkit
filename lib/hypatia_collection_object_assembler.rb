# Assemble EAD into collection level objects for Hypatia. 
# @example Process an FTK report and a directory of files
#  my_fedora_config = "/path/to/fedora.yml"
class HypatiaCollectionObjectAssembler
  
  attr_accessor :ead            # The EAD to process
  attr_accessor :fedora_config  # The fedora config file
  attr_accessor :fedora_url     # the Fedora URL we're connecting to
  attr_accessor :collection     # The fedora object representing the collection
  
  def initialize(args)
    raise "Please give me an ead file to process" unless args[:ead]
    raise "I can't find the file #{args[:ead]}" unless File.file? args[:ead]
    @ead = args[:ead]
    raise "Please pass me a fedora config" unless args[:fedora_config]
    @fedora_config = args[:fedora_config]
    ActiveFedora.init(args[:fedora_config])
    @collection = ActiveFedora::Base.new(:pid_namespace => "hypatia")
  end
  
  
end