class Gprod < ActiveRecord::Base

  include StatusLogic

  has_one :buch
  accepts_nested_attributes_for :buch

  belongs_to :lektor
  accepts_nested_attributes_for :lektor

  belongs_to :autor
  accepts_nested_attributes_for :autor

  def self.scope_maker(status_names, table, status_strings)
    status_names.length.times do |i|
      scope (status_names[i]), -> {
        Gprod.joins("INNER JOIN #{table} ON (gprods.id = #{table}.gprod_id)").where("#{table}.status = ?", status_strings[i])
      }
    end
  end
  
  #status_names array must be written in the same order of the status_strings array (see models/concerns/global_variables)
  scope_maker([:neu_filter, :bearbeitung_filter, :fertig_filter, :problem_filter], "status_final", StatusOptionsAdapter.option(:statusfinal)) 

  scope :try_filter, -> {
    puts "!!!!!!!!!!!!!!!!!!!!!!"
    Gprod.joins("INNER JOIN status_final ON (gprods.id = status_final.gprod_id)").where("status_final.status = ?", "neu")
  }



  validates :projektname, :projekt_email_adresse,presence: true

  has_one :statusfinal, class_name: StatusFinal
  accepts_nested_attributes_for :statusfinal
  has_one :statusdruck, class_name: StatusDruck
  accepts_nested_attributes_for :statusdruck
  has_one :statustitelei, class_name: StatusTitelei
  accepts_nested_attributes_for :statustitelei
  has_one :statussatz, class_name: StatusSatz
  accepts_nested_attributes_for :statussatz
  has_one :statuspreps, class_name: StatusPreps
  accepts_nested_attributes_for :statuspreps
  has_one :statusoffsch, class_name: StatusOffsch
  accepts_nested_attributes_for :statusoffsch
  has_one :statusbildpr, class_name: StatusBildpr
  accepts_nested_attributes_for :statusbildpr
  has_one :statusumschl, class_name: StatusUmschl
  accepts_nested_attributes_for :statusumschl
  has_one :statusrg, class_name: StatusRg
  accepts_nested_attributes_for :statusrg
  has_one :statusbinderei, class_name: StatusBinderei
  accepts_nested_attributes_for :statusbinderei



end
