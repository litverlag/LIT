##
# # /app/models/Gprod.rb
# This class represents a whole project for the production it starts with a lektor creating a projekt inherited
# from Gprod. If he releases the project for the first departments they can access the Gprod class and change attributes in their Views.
# Gprod is of course associated with, Buch , Lektor and Autor, but it has also an association with a state (status) for each departement. The states are
# saved in additional tables where they are also logged, but for further information look in the corresponding files,
class Gprod < ActiveRecord::Base

  include StatusLogic

  has_one :buch
  accepts_nested_attributes_for :buch

  belongs_to :lektor
  accepts_nested_attributes_for :lektor

  belongs_to :autor
  accepts_nested_attributes_for :autor

  ##
  # The Class method scope_maker is used to create a scope for the states in the index view.
  # The method is called when initializing the Gprod class and it creates a scope for each symvbol in the status_names array
  # *table* is the name of the status table for instance "status_final" for StatusFinal.
  # *status_strings* are the possible options available for this status.
  #       scope_maker(status_names, table, status_strings)
  def self.scope_maker(status_names, table, status_strings)
    scope :alle_filter, -> {}
    status_names.length.times do |i|
      scope (status_names[i]), -> {
        #this SQL interrogation is possible only using the INNER JOIN in default scope (in every Abteilung)
        Gprod.where("#{table}.status = ?", status_strings[i])
      }
    end
  end
  
  #status_names array must be written in the same order of the status_strings array (see models/concerns/global_variables) + table name + symbol for StatusOptionsAdapter
  scope_maker([:neu_filter, :bearbeitung_filter, :fertig_filter, :problem_filter], "status_final", StatusOptionsAdapter.option(:statusfinal))



  validates :projektname, :projekt_email_adresse, presence: true
	validates :projekt_email_adresse, format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

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
