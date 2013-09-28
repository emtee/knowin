#class InternationalEmsTariff1
  include Mongoid::Document
  include Mongoid::Timestamps

  field :sr_no
	field :country_continent_sub_continent
	field :document_first_250_gms_or_part_thereof_inr
	field :document_for_every_additional_250_gms_or_part_thereof_inr
	field :merchandise_first_250_gms_or_part_thereof_inr
	field :merchandise_for_every_additional_250_gms_or_part_thereof_inr
#end       
