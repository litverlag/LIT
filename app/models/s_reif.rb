class SReif < Gprod
	#def self.default_scope
	#	SReif.joins("INNER JOIN status_satz on status_satz.gprod_id = gprods.id")\
	#	.where("status_satz.status IS NOT NULL")
	#end
	
	#status_names array must be written in the same order of the status_strings array (see models/concerns/global_variables) + table name + symbol for StatusOptionsAdapter
  scope_maker([:neu_filter, :bearbeitung_filter, :verschickt_filter, :fertig_filter, :problem_filter], "status_satz", StatusOptionsAdapter.option(:statussatz)) 

end