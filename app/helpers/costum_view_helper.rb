  ##
  # Contains costum helpers to create faster views
module CostumViewHelper


  ##
  # This method is used to create statusbars for a costum status
  # === Example
  #
  #   CostumViewHelper.status_bar(@projekt, @projekt.statusfinal.status, "Finaler Status")
  #
  def status_bar(instance_of_projekt,status, name_of_status)

    render "/views_for_helpers/status", status: status, name: name_of_status, projekt: instance_of_projekt
  end

  ##
  # This method is used to create a row in a fieldset to change the status
  # === Example
  #
  #   CostumViewHelper.status_changer("Status der Titelei", "status[statustitlei]", $TITELEI_STATUS)
  #

  def status_changer(name, status_to_change , options)

    render "views_for_helpers/input_status_select", name: name ,selectname: status_to_change, options: options

  end
  #
  # #Final
  # $FINAL_STATUS = ["neu", "in bearbeitung", "fertig", "problem"]
  # #Druck
  # $DRUCK_STATUS = ["musterdrucken", "nächsterAuftrag", "neu", "bearbeitung", "fertig", "problem"]
  # #Titelei
  # $TITELEI_STATUS = ["neu", "in bearbeitung", "verschickt", "fertig", "problem"]
  # #Satz
  # $SATZ_STATUS = ["neu", "in bearbeitung", "verschickt", "fertig", "problem"]
  # #Pre press
  # $PREPS_STATUS = ["neu", "in bearbeitung", "verschickt", "fertig", "problem"]
  # #Offset/Schirm
  # $OFFSCH_STATUS = ["neu", "in bearbeitung", "fertig", "problem"]
  # #Bildprüfung
  # $BILDPR_STATUS = ["neu", "in bearbeitung", "fertig", "problem"]
  # #Umschlag
  # $UMSCHL_STATUS = ["neu", "in bearbeitung", "verschickt", "fertig", "problem"]
  # #Buchhaltung
  # $RG_STATUS = ["neu", "in bearbeitung", "fertig", "problem"]
  # #Binderei
  # $BINDEREI_STATUS = ["neu", "in bearbeitung", "fertig", "problem"]
  #
  #
  # #Musterarten
  # $MUSTER_ART = ["digital", "papier"]
  #


  ##costum view
  # This method is used to create a Panel with a set of infos.
  # The array has to have the
  # === Example
  #
  #   info_panel(@projekt, relevant_attr, names)
  def change_names_in_hash(relevant_attr, names)
    i= 0
    relevant_attr.keys.each do |key|
      if i < names.length
        relevant_attr[names[i]] = relevant_attr.delete key
        i = i+1
      else
        relevant_attr[key] = relevant_attr.delete key
      end

    end
    return relevant_attr
    #render "/views_for_helpers/info_panel", projekt_instance: projekt_instance, relevant_attr: relevant_attr, names: names
  end



end