module GlobalVariables

	#Statusbezeichnungen
	# Damit der User nicht ausversehen irgentwas einträgt wird als erste option immer "   " angegeben
	#Final

	  $MUSTER_ART = ["digital", "papier"]
		$FINAL_STATUS = [I18n.t("scopes_names.neu_filter"), 
				   I18n.t("scopes_names.bearbeitung_filter"), 
				   I18n.t("scopes_names.fertig_filter"), 
				   I18n.t("scopes_names.problem_filter")]
    #Druck
      #$DRUCK_STATUS = [I18n.t("scopes_names.musterdrucken_filter"), 
		  #		  I18n.t("scopes_names.nächsterAuftrag_filter"), 
		  #		  I18n.t("scopes_names.neu_filter"), 
		  #		  I18n.t("scopes_names.bearbeitung_filter"), 
		  #		  I18n.t("scopes_names.fertig_filter"), 
		  #		  I18n.t("scopes_names.problem_filter")]
      $DRUCK_STATUS = [
		  		  I18n.t("scopes_names.neu_filter"), 
		  		  I18n.t("scopes_names.bearbeitung_filter"), 
		  		  I18n.t("scopes_names.fertig_filter"), 
      ]
		#Externer Druck
    	$EXTERNER_DRUCK_STATUS = [
						I18n.t("scopes_names.neu_filter"), 
					  I18n.t("scopes_names.bearbeitung_filter"), 
						I18n.t("scopes_names.verschickt_filter"), 
					  I18n.t("scopes_names.fertig_filter"), 
					  I18n.t("scopes_names.problem_filter")]
    #Titelei
    	$TITELEI_STATUS = [I18n.t("scopes_names.neu_filter"), 
						I18n.t("scopes_names.bearbeitung_filter"), 
						I18n.t("scopes_names.verschickt_filter"), 
						I18n.t("scopes_names.fertig_filter"), 
						I18n.t("scopes_names.problem_filter")]
    #Satz
    	$SATZ_STATUS = [I18n.t("scopes_names.neu_filter"), 
					 I18n.t("scopes_names.bearbeitung_filter"), 
					 I18n.t("scopes_names.verschickt_filter"), 
					 I18n.t("scopes_names.fertig_filter"), 
					 I18n.t("scopes_names.problem_filter")]
    #Pre press
    	$PREPS_STATUS = [ I18n.t("scopes_names.neu_filter"), 
					   I18n.t("scopes_names.bearbeitung_filter"), 
					   I18n.t("scopes_names.verschickt_filter"), 
					   I18n.t("scopes_names.fertig_filter"), 
					   I18n.t("scopes_names.problem_filter")]
    #Offset/Schirm
    	$OFFSCH_STATUS = [I18n.t("scopes_names.neu_filter"), 
					   I18n.t("scopes_names.bearbeitung_filter"), 
					   I18n.t("scopes_names.fertig_filter"), 
					   I18n.t("scopes_names.problem_filter")]
    
		#Bildprüfung
    	$BILDPR_STATUS = [ I18n.t("scopes_names.neu_filter"), 
						I18n.t("scopes_names.bearbeitung_filter"), 
						I18n.t("scopes_names.fertig_filter"), 
						I18n.t("scopes_names.problem_filter")]
    
		#Umschlag
    	$UMSCHL_STATUS = [ I18n.t("scopes_names.neu_filter"), 
						I18n.t("scopes_names.bearbeitung_filter"), 
						I18n.t("scopes_names.verschickt_filter"), 
						I18n.t("scopes_names.fertig_filter"), 
						I18n.t("scopes_names.problem_filter")]
    #Buchhaltung
    	$RG_STATUS = [ I18n.t("scopes_names.neu_filter"), 
					I18n.t("scopes_names.bearbeitung_filter"), 
					I18n.t("scopes_names.fertig_filter"), 
					I18n.t("scopes_names.problem_filter")]
    
		#Binderei
    	$BINDEREI_STATUS = [ I18n.t("scopes_names.neu_filter"), 
						  I18n.t("scopes_names.bearbeitung_filter"), 
						  I18n.t("scopes_names.fertig_filter"), 
						  I18n.t("scopes_names.problem_filter")]

end
