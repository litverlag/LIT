class Um < Gprod
	def self.default_scope
		Um.joins("INNER JOIN status_umschl on status_umschl.gprod_id = gprods.id")\
		.where("status_umschl.status IS NOT NULL")
	end
end