require 'active_fedora'

class HypatiaCollection < ActiveFedora::Base
  has_relationship "member_of", :is_member_of, :inbound => true
  has_relationship "member_of_collection", :is_member_of_collection, :inbound => true
end