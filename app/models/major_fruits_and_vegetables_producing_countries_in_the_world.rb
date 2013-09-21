#class MajorFruitsAndVegetablesProducingCountriesInTheWorld
  include Mongoid::Document
  include Mongoid::Timestamps

  field :fruits_2009_10_area_in_hectare
	field :fruits_2010_11_area_in_hectare
	field :fruits2009_10_production_in_tonnes
	field :fruits2010_11_production_in_tonnes
	field :fruits2009_10_productivity_in_tonnes_hectare
	field :fruits2010_11_productivity_in_tonnes_hectare
	field :vegetables_2009_10_area_in_hectare
	field :vegetables_2010_11_area_in_hectare
	field :vegetables2009_10_production_in_tonnes
	field :vegetables2010_11_production_in_tonnes
	field :vegetables2009_10_productivity_in_tonnes_hectare
	field :vegetables2010_11_productivity_in_tonnes_hectare
#end       
