module StatusLogic
  #TODO User und Datum loggen

  include GlobalVariables

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