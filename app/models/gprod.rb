class Gprod < ActiveRecord::Base

  has_one :buch
  accepts_nested_attributes_for :buch

  belongs_to :lektor
  accepts_nested_attributes_for :lektor

  belongs_to :autor
  accepts_nested_attributes_for :autor

  def autor_name
    autor.name if autor
  end

  def autor_name=(name)
    self.autor = Autor.find_or_create_by_name(name) unless name.blank?
  end

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
