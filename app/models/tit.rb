class Tit < Gprod

	# def self.default_scope
	# 	Tit.joins("INNER JOIN status_titelei on status_titelei.gprod_id = gprods.id")\
	# 	.where("status_titelei.status IS NOT NULL")
	# end
	
  #status_names array must be written in the same order of the status_strings array (see models/concerns/global_variables)
  scope_maker([:musterdrucken, :nächsterAuftrag, :neu_filter, :bearbeitung_filter, :fertig_filter, :problem_filter], "status_final", StatusOptionsAdapter.option(:statusfinal)) 

	
end