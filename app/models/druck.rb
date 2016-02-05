class Druck < Gprod
  
  #status_names array must be written in the same order of the status_strings array (see models/concerns/global_variables)
  scope_maker([:musterdrucken, :nächsterAuftrag, :neu_filter, :bearbeitung_filter, :fertig_filter, :problem_filter], "status_final", StatusOptionsAdapter.option(:statusfinal)) 

end
