##
# # /app/models/um.rb
# Represents the part of the production process handled by Umschlag departemt

class Um < Gprod
	def self.default_scope
		Um.joins("INNER JOIN status_umschl on status_umschl.gprod_id = gprods.id")\
		.where("status_umschl.status IS NOT NULL")
	end

	def check_constraints
		super
	end
	  
  #status_names array must be written in the same order of the status_strings
  # array (see models/concerns/global_variables) + table name + symbol for
  # StatusOptionsAdapter
  scope_maker([:neu_filter, :bearbeitung_filter, :verschickt_filter, :fertig_filter, :problem_filter], "status_umschl", StatusOptionsAdapter.option(:statusumschl)) 
end
