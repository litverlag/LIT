class Tit < Gprod

  #TODO Bezeichnungen überarbeiten
  #TODO wie sollen die Status veränders werden (Button? Auswahl?)

  STATUS = ["neu", "bearbeitung", "fertig"]

  scope :alle, -> {}
  scope :neu, -> { where(tit_status: STATUS[0])}
  scope :bearbeitung, -> { where(tit_status: STATUS[1])}
  scope :fertig, -> { where(tit_status: STATUS[2])}


  def status
    if self.tit_status.nil?
      update_attribute(:tit_status, STATUS[0])
    end
    self.tit_status
  end

  def change_status

  end
end