module StatusLogic

  include GlobalVariables



  ##
  # Interface used to set all relevant project status which have been changed by the user
  # === Example
  #
  #   changeStatusByUser(projekt1, projekt1.titeleistatus, "Fertig")

  def changeStatusByUser(projekt, statusToChange, newStatus)
    if newStatus.class == String
      statusToChange.status = newStatus
      statusToChange.updated_by = current_admin_user.email
      statusToChange.updated_at = Time.now()
      statusToChange.save

    elsif newStatus.class == TrueClass or newStatus.class == FalseClass
      # TODO: check if setting freigabe is legal
      statusToChange.freigabe = newStatus
      statusToChange.freigabe_at = Time.now()
      statusToChange.save
      freigabeLogic(projekt)
    end

    internalStatusLogic(projekt, statusToChange, newStatus)

  end





  ##
  # Method used to set all relevant status which have been changed through logic
  # === Example
  #
  #   changeStatusByUser(projekt1, projekt1.titeleistatus, "Fertig")

  def changeStatusByLogic(statusToChange, newStatus)
    if newStatus.class == String
      statusToChange.status = newStatus
      statusToChange.updated_by = 'automatisch_generierter_status'
      statusToChange.updated_at = Time.now()
      statusToChange.save

    elsif newStatus.class == TrueClass or newStatus.class == FalseClass
      statusToChange.freigabe = newStatus
      statusToChange.freigabe_at = Time.now()
      statusToChange.save
    end
  end





  ##
  # Internal Logic which reacts to previous status changes and concludes new status
  # === Example
  #
  #   changeStatusByUser(projekt1, projekt1.titeleistatus, "Fertig")

  def internalStatusLogic(projekt, lastChangedStatus, changedTo)
    locationOfChange = "#{lastChangedStatus.class}"


  ################################
  # Changes concerning freigabe
  ################################

    ##
    # If statusfinal freigabe is set, make project visible for Titelei, Satz, Preps, Umschlag
    if locationOfChange == "StatusFinal" and changedTo == true
      changeStatusByLogic(projekt.statustitelei, $TITELEI_STATUS[0])
      changeStatusByLogic(projekt.statussatz, $SATZ_STATUS[0])
      changeStatusByLogic(projekt.statuspreps, $PREPS_STATUS[0])
      changeStatusByLogic(projekt.statusumschl, $UMSCHL_STATUS[0])

    ##
    # If statustitelei freigabe is set, make project visible for Titelei
    elsif locationOfChange == "StatusTitelei" and changedTo == true
      changeStatusByLogic(projekt.statustitelei, $TITELEI_STATUS[0])
    
    ##
    # If statussatz freigabe is set, make project visible for Satz
    elsif locationOfChange == "StatusSatz" and changedTo == true
      changeStatusByLogic(projekt.statussatz, $SATZ_STATUS[0])

    ##
    # If statuspreps freigabe is set, make project visible for Preps
    elsif locationOfChange == "StatusPreps" and changedTo == true
      changeStatusByLogic(projekt.statuspreps, $PREPS_STATUS[0])

    ##
    # If statusumschl freigabe is set, make project visible for Umschlag
    elsif locationOfChange == "statusumschl" and changedTo == true
      changeStatusByLogic(projekt.statusumschl, $UMSCHL_STATUS[0])


  ################################
  # Changes concerning status
  ################################
    end


  end





  ##
  # Method used to complete freigabe status

  def freigabeLogic(projekt)
    ##
    # If freigabe for statusfinal is set, all deparments freigabe status are set
    if projekt.statusfinal.freigabe
      changeStatusByLogic(projekt.statustitelei, true)
      changeStatusByLogic(projekt.statussatz, true)
      changeStatusByLogic(projekt.statuspreps, true)
      changeStatusByLogic(projekt.statusumschl, true)

    ##
    # If all departments freigabe status are set and statusfinal freigabe is not set
    # statusfinal freigabe will be set
    elsif not projekt.statusfinal.freigabe \
      and projekt.statustitelei.freigabe \
      and projekt.statussatz.freigabe \
      and projekt.statuspreps.freigabe \
      and projekt.statusumschl.freigabe

      changeStatusByLogic(projekt.statusfinal, true)
    end

  end




  ##
  # Method used to instantiate all relevant project status
  
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
    elsif not projekt.statusumschl = StatusUmschl.create()
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

end





