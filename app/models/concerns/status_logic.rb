module StatusLogic

  include GlobalVariables
=begin
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
=end
     def createStatus(projekt)
    if not projekt.statusfinal = StatusFinal.create()
      return false
    elsif not projekt.statusdruck = StatusDruck.create()
      return false
    elsif not projekt.statustitelei = StatusTitelei.create()
      return false
    elsif not projekt.statussatz = StatusSatz.create()
      return false
    elsif not projekt.statuspreps = StatusPreps.create()
      return false
    elsif not projekt.statusoffsch = StatusOffsch.create()
      return false
    elsif not projekt.statusumschlag = StatusUmschlag.create()
      return false
    elsif not projekt.statusrg = StatusRg.create()
      return false
    elsif not projekt.statusbildpr = StatusBildpr.create()
      return false
    elsif not projekt.statusbinderei = StatusBinderei.create()
      return false
    else
      return true
    end
  end

  #TODO diese Funktion sollte mit einer Combobox zusammenarbeiten
  #Beispiel Parameter: changeStatus(projekt.statustitelei, "Fertig")
  def changeStatus(statusRecord, newStatus) 
    statusRecord.status = newStatus
    statusRecord.updated_by = current_admin_user.email #hier entweder der volle name oder id aus der Datenbank
    statusRecord.updated.at = Time.now()
  end


end