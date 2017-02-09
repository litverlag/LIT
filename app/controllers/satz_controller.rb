class SatzController < TableController
  before_filter :init

  private
  def init
    @stati = ["Neu", "In Bearbeitung", "Verschickt", "Fertig"]
    @statusColumnsEditable = []
  end

  public

  def index
    columnHeader = ["Name","ISBN","Lektor","Priorität","Seiten","Format","Bearbeiter","Eingang","Deadline","Kommentare"]
    displayedColumns = ["gprods.projektname","buecher.isbn","lektoren.fox_name",
                        "gprods.prio", "buecher.seiten",
                        "buecher.format_bezeichnung","users.nachname", #bearbeiter
                        "status_satz.eingang_at","status_satz.deadline_soll","status_satz.kommentar"]
    statusColumns = []
    filterableColumns = [0,1]

    editable = false
    notViewable = true

    respond_to do |format|
      format.html {render template: "preps/index", locals: {columnHeader: columnHeader, displayedColumns: displayedColumns, statusColumns: statusColumns, statusColumnsEditable: @statusColumnsEditable, filterableColumns: filterableColumns, notViewable: notViewable, editable: editable}}
      format.json {serve_table_data(Gprod.left_outer_joins(:buch, :lektor, satz: :bearbeiter), displayedColumns, filterableColumns, editable, notViewable, "Gprods.id", @statusColumnsEditable)}
    end
  end

  def stati
    render json: @stati.to_s
  end

  def editStatus
    gprod = getStatusDataset
    return unless gprod

    gprod.preps.status = params[:value]

    if gprod.preps.save
      render plain: 'Erfolgreich gespeichert'
    else
      render plain: 'Fehler: Speichern fehlgeschlagen', status: 417
    end

  end
end
