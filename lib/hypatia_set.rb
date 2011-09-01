require 'active_fedora'

class HypatiaSet < ActiveFedora::Base
  has_relationship "member_of", :is_member_of
  has_relationship "member_of_collection", :is_member_of_collection
end