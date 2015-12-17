module GlobalVariables

	#Statusbezeichnungen
	# Damit der User nicht ausversehen irgentwas einträgt wird als erste option immer "   " angegeben
	#Final

	  $MUSTER_ART = ["digital", "papier"]
		$FINAL_STATUS = ["" ,"neu", "in bearbeitung", "fertig", "problem"]
    #Druck
    	$DRUCK_STATUS = ["" , "musterdrucken", "nächsterAuftrag", "neu", "bearbeitung", "fertig", "problem"]
    #Titelei
    	$TITELEI_STATUS = ["" ,"neu", "in bearbeitung", "verschickt", "fertig", "problem"]
    #Satz
    	$SATZ_STATUS = ["" , "neu", "in bearbeitung", "verschickt", "fertig", "problem"]
    #Pre press
    	$PREPS_STATUS = ["", "neu", "in bearbeitung", "verschickt", "fertig", "problem"]
    #Offset/Schirm
    	$OFFSCH_STATUS = ["" , "neu", "in bearbeitung", "fertig", "problem"]
    #Bildprüfung
    	$BILDPR_STATUS = ["" , "neu", "in bearbeitung", "fertig", "problem"]
    #Umschlag
    	$UMSCHL_STATUS = ["" , "neu", "in bearbeitung", "verschickt", "fertig", "problem"]
    #Buchhaltung
    	$RG_STATUS = ["" , "neu", "in bearbeitung", "fertig", "problem"]
    #Binderei
    	$BINDEREI_STATUS = ["" , "neu", "in bearbeitung", "fertig", "problem"]



end