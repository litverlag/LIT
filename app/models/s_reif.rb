class SReif < Gprod
	def self.default_scope
		SReif.joins("INNER JOIN status_satz on status_satz.gprod_id = gprods.id")\
		.where("status_satz.status IS NOT NULL")
	end
end