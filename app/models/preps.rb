class Preps < Gprod
	def self.default_scope
		Preps.joins("INNER JOIN status_preps on status_preps.gprod_id = gprods.id")\
		.where("status_preps.status IS NOT NULL")
	end
end
