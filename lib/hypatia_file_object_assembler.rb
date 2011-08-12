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
  # @param [FtkFile] ff FTK file object
  # @return [Nokogiri::XML::Document]
  # @example document returned
  #  <?xml version="1.0"?>
  #  <mods:mods xmlns:mods="http://www.loc.gov/mods/v3">
  #   <mods:titleInfo>
  #     <mods:title>A Heartbreaking Work of Staggering Genius</mods:title>
  #   </mods:titleInfo>
  #   <mods:typeOfResource>Journal Article</mods:typeOfResource>
  #   <mods:physicalDescription>
  #     <mods:form>Punch Cards</mods:form>
  #   </mods:physicalDescription>
  #  </mods:mods>
  def buildDescMetadata(ff)
    builder = Nokogiri::XML::Builder.new do |xml|
      # Really, mods records should be in the mods namespace, 
      # but it makes it a bit of a pain to query them. 
      xml.mods('xmlns:mods' => "http://www.loc.gov/mods/v3") {
        xml.parent.namespace = xml.parent.namespace_definitions.first
        xml['mods'].titleInfo {
          xml['mods'].title_ ff.title
        }
        xml['mods'].typeOfResource_ ff.type
        xml['mods'].physicalDescription {
          xml['mods'].form_ ff.medium
        }
      }
    end
    builder.to_xml
  end
  
  # Build a contentMetadata datastream
  # @param [FtkFile] ff FTK file object
  # @return [Nokogiri::XML::Document]
  # @example document returned
  #  <?xml version="1.0"?>
  #  <contentMetadata type="born-digital" objectId="foofile.txt_9999">
  #    <resource data="metadata" id="analysis-text" type="analysis" objectId="????">
  #      <file size="504 B" format="WordPerfect 5.1" id="foofile.txt">
  #        <location type="filesystem">files/foofile.txt</location>
  #        <checksum type="md5">4E1AA0E78D99191F4698EEC437569D23</checksum>
  #        <checksum type="sha1">B6373D02F3FD10E7E1AA0E3B3AE3205D6FB2541C</checksum>
  #      </file>
  #    </resource>
  #  </contentMetadata>
  # @example calling this method
  #  @ff = FactoryGirl.build(:ftk_file)
  #  @hfo = HypatiaFileObjectAssembler.new(:fedora_config => @fedora_config)
  #  cm = @hfo.buildContentMetadata(@ff)
  #  doc = Nokogiri::XML(cm)
  #  doc.xpath("/contentMetadata/@type").to_s.should eql("born-digital")
  def buildContentMetadata(ff)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.contentMetadata("type" => "born-digital", "objectId" => ff.unique_combo) {
        xml.resource("id" => "analysis-text", "type" => "analysis", "data" => "metadata", "objectId" => "????"){
          xml.file("id" => ff.filename, "format" => ff.filetype, "size" => ff.filesize) {
            xml.location("type" => "filesystem") {
              xml.text ff.export_path
            }
            xml.checksum("type" => "md5") {
              xml.text ff.md5
            }
            xml.checksum("type" => "sha1") {
              xml.text ff.sha1
            }
          }
        }
      }
    end    
    builder.to_xml
  end
  
  # Build rightsMetadata datastream
  # @param [FtkFile] ff FTK file object
  # @return [Nokogiri::XML::Document]
  def buildRightsMetadata(ff)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.rightsMetadata("xmlns" => "http://hydra-collab.stanford.edu/schemas/rightsMetadata/v1", "version" => "0.1"){
        xml.access("type" => "discover"){
          xml.machine {
            xml.group "public"
          }
        }
        xml.access("type" => "read"){
          xml.machine {
            xml.group "public"
          }
        }
      }
    end
    builder.to_xml
  end
  
end