require 'active_fedora'

class HypatiaItem < ActiveFedora::Base
  has_relationship "members", :is_member_of
  has_relationship "members", :is_member_of, :inbound => true
  has_relationship "member_of_collection", :is_member_of_collection
end