module StatusLogic

  include GlobalVariables



  ##
  # Interface used to set all relevant project status which have been changed by the user
  # === Example
  #
  #   changeStatusByUser(projekt1, projekt1.titeleistatus, "Fertig")

  def changeStatusByUser(projekt, statusToChange, newStatus)
    if newStatus == "True"
      newStatus = true
    elsif newStatus == "False"
      newStatus = false
    end

    if newStatus.class == String
      statusToChange.status = newStatus
      statusToChange.updated_by = current_admin_user.email
      statusToChange.updated_at = Time.now()
      statusToChange.save

    elsif newStatus.class == TrueClass or newStatus.class == FalseClass
      # TODO: can freigabe be unsetted if it was setted?
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
    # Satzproduktion true
    ################################

    if projekt.satzproduktion

      ################################
      # Changes concerning freigabe
      ################################

      if changedTo == true

        ##
        # If freigabe for project is set, project get visible for Satz
        if locationOfChange == "StatusFinal"
          changeStatusByLogic(projekt.statussatz, $SATZ_STATUS[0])
        end

      ################################
      # Changes concerning freigabe
      ################################

      elsif changedTo.class == String

        # TODO
				# ?? What to do??

      end


    ################################
    # Satzproduktion false
    ################################

    elsif not projekt.satzproduktion

      ################################
      # Changes concerning freigabe
      ################################

      if changedTo == true

        ##
        # If statusfinal freigabe is set, make project visible for Titelei, Preps, Umschlag
        if locationOfChange == "StatusFinal"
          changeStatusByLogic(projekt.statustitelei, $TITELEI_STATUS[0])
          changeStatusByLogic(projekt.statuspreps, $PREPS_STATUS[0])
          changeStatusByLogic(projekt.statusumschl, $UMSCHL_STATUS[0])

        ##
        # If statustitelei freigabe is set, make project visible for Titelei
        elsif locationOfChange == "StatusTitelei"
          changeStatusByLogic(projekt.statustitelei, $TITELEI_STATUS[0])

        ##
        # If statuspreps freigabe is set, make project visible for Preps
        elsif locationOfChange == "StatusPreps"
          changeStatusByLogic(projekt.statuspreps, $PREPS_STATUS[0])

        ##
        # If statusumschl freigabe is set, make project visible for Umschlag
        elsif locationOfChange == "StatusUmschl"
          changeStatusByLogic(projekt.statusumschl, $UMSCHL_STATUS[0])

        end


      ################################
      # Changes concerning status
      ################################

      elsif changedTo.class == String

        if locationOfChange == "StatusTitelei"

          # Nothing special happens, but Preps should see that Titelei finished

        elsif locationOfChange == "StatusPreps"

          if projekt.muster_art == $MUSTER_ART[1]

            ##
            # If Preps started working on the project and a muster needs to be printed
            # project get visible for Druck with status that refers to the muster
            if changedTo == "bearbeitung"
              changeStatusByLogic(projekt.statusdruck, $DRUCK_STATUS[0])

            end

          else

            ##
            # If Preps started working on the project and no muster needs to be printed
            # poject gets visible for Druck
            if changedTo == "bearbeitung"
              changeStatusByLogic(projekt.statusdruck, $DRUCK_STATUS[1])

            end
          end

          ##
          # If Preps finished, project is going to be a new task for Druck
          if changedTo == "fertig"
            changeStatusByLogic(projekt.statusdruck, $DRUCK_STATUS[2])

          end

        elsif locationOfChange == "StatusUmschl"

          ##
          # If Umschlag finished, project is going to be a new task for Druck
          if changedTo == "fertig"
            changeStatusByLogic(projekt.statusdruck, $DRUCK_STATUS[0])

          end


        ########################

        elsif locationOfChange == "StatusDruck"

          ##
          # If Druck finished, project is going to be a new task for Binderei
          if changedTo == "fertig"
            changeStatusByLogic(projekt.statusbinderei, $BINDEREI_STATUS[0])


          end

        #########################

        elsif locationOfChange == "StatusBinderei"

          ##
          # If Binderei finished, project is done and is going to be a new task for Buchhaltung
          if changedTo == "fertig"
            changeStatusByLogic(projekt.statusfinal, $FINAL_STATUS[2])
            projekt.buchistfertig = true

            changeStatusByLogic(projekt.statusrg, $RG_STATUS[0])


          end
        

        end

      end

    end
    


  end





  ##
  # Method used to complete freigabe status

  def freigabeLogic(projekt)

    ################################
    # Satzproduktion true
    ################################

    if projekt.satzproduktion

      ##
      # If freigabe for statusfinal is set, department satz freigabe status will be set
      if projekt.statusfinal.freigabe
        changeStatusByLogic(projekt.statussatz, true)
      end



    ################################
    # Satzproduktion false
    ################################

    elsif not projekt.satzproduktion

      ##
      # If freigabe for statusfinal is set, all deparments freigabe status are set
      if projekt.statusfinal.freigabe
        changeStatusByLogic(projekt.statustitelei, true)
        changeStatusByLogic(projekt.statuspreps, true)
        changeStatusByLogic(projekt.statusumschl, true)

      ##
      # If all departments freigabe status are set and statusfinal freigabe is not set
      # statusfinal freigabe will be set
      elsif not projekt.statusfinal.freigabe \
        and projekt.statustitelei.freigabe \
        and projekt.statuspreps.freigabe \
        and projekt.statusumschl.freigabe

        changeStatusByLogic(projekt.statusfinal, true)
      end

    end


  end




  ##
  # Method used to instantiate all relevant project status
  
  def createStatus(projekt)
		begin
			projekt.statusfinal = StatusFinal.create!()
			projekt.statusdruck = StatusDruck.create!()
			projekt.statustitelei = StatusTitelei.create!()
			projekt.statussatz = StatusSatz.create!()
			projekt.statuspreps = StatusPreps.create!()
			projekt.statusoffsch = StatusOffsch.create!()
			projekt.statusumschl = StatusUmschl.create!()
			projekt.statusrg = StatusRg.create!()
			projekt.statusbildpr = StatusBildpr.create!()
			projekt.statusbinderei = StatusBinderei.create!()
		rescue
      return false
    end
		return true
  end

end





