class Fach < ActiveRecord::Base
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
    index = STATUS.index(self.tit_status)
    update_attribute(:tit_status, STATUS[index+1])
  end
end
