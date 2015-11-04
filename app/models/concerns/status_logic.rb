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
  def changeStatusByUser(statusRecord, newStatus) 
    statusRecord.status = newStatus
    statusRecord.updated_by = current_admin_user.email #hier entweder der volle name oder id aus der Datenbank
    statusRecord.updated.at = Time.now()
  end

  def changeStatusByLogic(statusRecord, newStatus)
    statusRecord.status = newStatus
    statusRecord.updated_by = 'automatisch_generierter_status'
    statusRecord.updated.at = Time.now()
  end

  def statusLogic(projekt)
    if projekt.freigegeben \
      and projekt.statusfinal.status.nil? \
      and projekt.statustitelei.status.nil? \
      and projekt.statussatz.status.nil? \
      and projekt.statusumschlag.status.nil?

      #Finalen Status setzen
      changeStatusByLogic(projekt.statusfinal, $FINAL_STATUS[0])
      #Titelei Status setzen
      changeStatusByLogic(projekt.statustitelei, $TITELEI_STATUS[0])
      #Satz Status setzen
      changeStatusByLogic(projekt.statussatz, $SATZ_STATUS[0])
      #Umschlag Status setzen
      changeStatusByLogic(projekt.statusumschlag, $UMSCHLAG_STATUS[0])



    elsif projekt.statustitelei.status == $TITELEI_STATUS[1] \
      or projekt.statussatz.status == $SATZ_STATUS[1] \
      or projekt.statusumschlag.status == $UMSCHLAG_STATUS[1]]

      #Final Status setzen
      changeStatusByLogic(projekt.statusfinal, $FINAL_STATUS[1])



    elsif projekt.statustitelei.status == $TITELEI_STATUS[2] \
      and projekt.statussatz.status == $SATZ_STATUS[2] \
      and projekt.statusumschlag.status == $UMSCHLAG_STATUS[2]

      #Preps Status setzen
      changeStatusByLogic(projekt.statuspreps, $PREPS_STATUS[0])



    elsif projekt.statuspreps.status == $PREPS_STATUS[2]

      #Druck Status setzen
      changeStatusByLogic(projekt.statusdruck, $DRUCK_STATUS[0])



    elsif projekt.statusdruck.status == $DRUCK_STATUS[2]

      #Binderei Status setzen
      changeStatusByLogic(projekt.statusbinderei, $BINDEREI_STATUS[0])



    elsif projekt.statusbinderei.status == $BINDEREI_STATUS[2]

      #Buchhaltungs Status setzen
      changeStatusByLogic(projekt.statusrg, $RG_STATUS[0])



    elsif projekt.statusrg.status == $RG_STATUS[2]

      #Final Status setzen
      changeStatusByLogic(projekt.statusfinal, $FINAL_STATUS[2])


    end


  end

end





