# Currently Mr. Meessen.
class ExternerDruck < Gprod
	# Crappy SQL join..
  def self.default_scope
    ExternerDruck.joins("INNER JOIN status_druck on status_druck.gprod_id = gprods.id")\
    .where("status_druck.status IS NOT NULL")
  end
  scope_maker([:neu_filter, :bearbeitung_filter, :verschickt_filter, :fertig_filter, :problem_filter], "status_externer_druck", StatusOptionsAdapter.option(:statusexternerdruck))
end
