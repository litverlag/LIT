class BiblioErf < Gprod

  def self.default_scope
    BiblioErf.joins("INNER JOIN status_biblio_erf on status_biblio_erf.gprod_id = gprods.id")\
    .where("status_biblio_erf.status IS NOT NULL")
  end

  scope_maker([:neu_filter, :bearbeitung_filter, :verschickt_filter, :fertig_filter, :problem_filter], "status_biblio_erf", StatusOptionsAdapter.option(:statusbiblioerf))
end
