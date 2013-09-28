#class LessPincode
  include Mongoid::Document
  include Mongoid::Timestamps

  field :officename
	field :pincode
	field :officetype
	field :deliverystatus
	field :divisionname
	field :regionname
	field :circlename
	field :taluk
	field :districtname
	field :statename
#end       
