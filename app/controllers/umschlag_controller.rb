class UmschlagController < TableController
  before_filter :init

  private
  def init
    @stati = ["Neu", "In Bearbeitung", "Verschickt", "Fertig"]
    @statusColumnsEditable = [6]
  end

  public

  def index
    columnHeader = [  "Name","ISBN","Lektor","Priorität","MS Ein","SollIF","Status",
                    ]
    displayedColumns = ["gprods.projektname","buecher.isbn","lektoren.fox_name",
                        "gprods.prio","gprods.manusskript_eingang_date",
                        "gprods.final_deadline","status_umschl.status",
                      ]
    statusColumns = [6]
    filterableColumns = [0]
    editable = false
    notViewable = true

    respond_to do |format|
      format.html {render template: "umschlag/terminplanung", locals: {columnHeader: columnHeader, displayedColumns: displayedColumns, filterableColumns: filterableColumns, statusColumns: statusColumns, statusColumnsEditable: @statusColumnsEditable, notViewable: notViewable, editable: editable}}
      format.json {serve_table_data(Gprod.joins(:buch, :lektor, :umschlag), displayedColumns, filterableColumns, editable, notViewable, "Gprods.id", @statusColumnsEditable)}
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
    filterableColumns = [0]
    editable = false
    notViewable = true

    respond_to do |format|
      format.html {render template: "umschlag/produktion", locals: {columnHeader: columnHeader, displayedColumns: displayedColumns, filterableColumns: filterableColumns, notViewable: notViewable, editable: editable}}
      format.json {serve_table_data(Gprod.joins(:buch, :lektor), displayedColumns, filterableColumns, editable, notViewable, "Gprods.id")}
    end
  end

  def stati
    render json: @stati.to_s
  end

  def editStatus
    gprod = getStatusDataset
    return unless gprod

    gprod.umschlag.status = params[:value]

    if gprod.umschlag.save
      render plain: 'Erfolgreich gespeichert'
    else
      render plain: 'Fehler: Speichern fehlgeschlagen', status: 417
    end

  end
end
