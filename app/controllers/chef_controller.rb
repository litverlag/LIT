class ChefController < TableController
  def index
    #standard settings begin
    columnHeader = ["Name","ISBN","Lektor","Priorität","MS Ein","SollIF",
                    "Titelei","Preps","Umschlag","Druck","Binderei","Fertig"]
    displayedColumns = ["gprods.projektname","buecher.isbn","lektoren.fox_name",
                        "gprods.prio","gprods.manusskript_eingang_date",
                        "gprods.final_deadline","status_titelei.status",
                        "status_preps.status","status_umschl.status",
                        "status_druck.status","status_binderei.status","status_final.status"]

    statusColumns = [6,7,8,9,10,11]
    filterableColumns = []

    editable = false
    notViewable = true

      displayedColumns += [ ]

    respond_to do |format|
      format.html {render template: "chef/terminplanung", locals: {columnHeader: columnHeader, displayedColumns: displayedColumns, statusColumns: statusColumns, filterableColumns: filterableColumns, notViewable: notViewable, editable: editable}}
      format.json {serve_table_data(Gprod.joins(:buch, :lektor, :titelei, :preps, :umschlag, :druck, :binderei, :final), displayedColumns, filterableColumns, editable, notViewable, "Gprods.id")}
    end
  end

  def produktion
    columnHeader = [  "Name","Auflage","Priorität","Papier","Format","Umschlag",
                      "Bindung","Lektor","Seiten",
                    ]
    displayedColumns = ["gprods.projektname","gprods.auflage","gprods.prio",
                        "buecher.papier_bezeichnung","buecher.format_bezeichnung",
                        "buecher.umschlag_bezeichnung","buecher.bindung_bezeichnung",
                        "lektoren.fox_name","buecher.seiten",
                      ]
    filterableColumns = []
    editable = false
    notViewable = true

    respond_to do |format|
      format.html {render template: "chef/produktion", locals: {columnHeader: columnHeader, displayedColumns: displayedColumns, filterableColumns: filterableColumns, notViewable: notViewable, editable: editable}}
      format.json {serve_table_data(Gprod.joins(:buch, :lektor), displayedColumns, filterableColumns, editable, notViewable, "Gprods.id")}
    end
  end

end
