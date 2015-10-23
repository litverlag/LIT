module Status_changeable
  #TODO Bezeichnungen überarbeiten
  #TODO wie sollen die Status veränders werden (Button? Auswahl?)
  include GVar

    def status(status_tag)
      if self.public_send(status_tag).nil?
        update_attribute(status_tag.to_sym, $STATUS[0])
      end
      self.public_send(status_tag)
    end

    def change_status(status_tag)
      index = $STATUS.index(public_send(status_tag))
      update_attribute(status_tag.to_sym, $STATUS[index+1])
    end


end