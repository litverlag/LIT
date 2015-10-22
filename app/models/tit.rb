class Tit < Gprod
  include Status_changeable

  scope :alle, -> {}
  scope :neu, -> { where(tit_status: $STATUS[0])}
  scope :bearbeitung, -> { where(tit_status: $STATUS[1])}
  scope :fertig, -> { where(tit_status: $STATUS[2])}

end