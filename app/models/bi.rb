##
# # /app/models/bi.rb
#
# Represents the departement Binderei at LIT
class Bi < Gprod
	 def self.default_scope
	  Bi.joins("INNER JOIN status_binderei on status_binderei.gprod_id = gprods.id")\
	 	.where("status_binderei.status IS NOT NULL")
	 end
	   
  #status_names array must be written in the same order of the status_strings array (see models/concerns/global_variables) + table name + symbol for StatusOptionsAdapter
  scope_maker([:neu_filter, :bearbeitung_filter, :fertig_filter, :problem_filter], "status_binderei", StatusOptionsAdapter.option(:statusbinderei)) 

	 
end
