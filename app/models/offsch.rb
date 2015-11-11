class Offsch < Gprod
	def self.default_scope
		Offsch.joins("INNER JOIN status_offsch on status_offsch.gprod_id = gprods.id")\
		.where("status_offsch.status IS NOT NULL")
	end
end
