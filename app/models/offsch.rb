class Offsch < Gprod
	#def self.default_scope
	#	Offsch.joins("INNER JOIN status_offsch on status_offsch.gprod_id = gprods.id")\
	#	.where("status_offsch.status IS NOT NULL")
	#end
	
	#status_names array must be written in the same order of the status_strings array (see models/concerns/global_variables) + table name + symbol for StatusOptionsAdapter
  scope_maker([:neu_filter, :bearbeitung_filter, :fertig_filter, :problem_filter], "status_offsch", StatusOptionsAdapter.option(:statusoffsch)) 

end
