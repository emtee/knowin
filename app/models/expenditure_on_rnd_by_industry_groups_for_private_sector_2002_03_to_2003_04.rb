#class ExpenditureOnRndByIndustryGroupsForPrivateSector200203To200304
  include Mongoid::Document
  include Mongoid::Timestamps

  field :industry_group
	field :no_of_rnd_units
	field :rnd_expenditure_rs_crores_2002_03
	field :rnd_expenditure_rs_crores_2003_04
	field :rnd_expenditure_as_percent_of_sto_2002_03
	field :rnd_expenditure_as_percent_of_sto_2003_04
#end       
