require 'active_fedora'

# Represents an archival collection
class HypatiaCollection < ActiveFedora::Base
  has_relationship "member_of", :is_member_of, :inbound => true
  has_relationship "member_of_collection", :is_member_of_collection, :inbound => true
end