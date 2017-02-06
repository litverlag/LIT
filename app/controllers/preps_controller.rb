class PrepsController < TableController
  before_filter :init

  private
  def init
    @stati = ["Neu", "In Bearbeitung", "Verschickt", "Fertig"]
    @statusColumnsEditable = [7]
  end

  public

  def index
    columnHeader = ["Name","ISBN","Lektor","Priorität","MS Ein","SollIF","Format","Status"]
    displayedColumns = ["gprods.projektname","buecher.isbn","lektoren.fox_name",
                        "gprods.prio","gprods.manusskript_eingang_date","gprods.final_deadline",
                        "buecher.format_bezeichnung","status_preps.status"]
    statusColumns = [7]
    filterableColumns = [0,1]

    editable = false
    notViewable = true

    respond_to do |format|
      format.html {render template: "preps/index", locals: {columnHeader: columnHeader, displayedColumns: displayedColumns, statusColumns: statusColumns, statusColumnsEditable: @statusColumnsEditable, filterableColumns: filterableColumns, notViewable: notViewable, editable: editable}}
      format.json {serve_table_data(Gprod.joins(:buch, :lektor, :preps), displayedColumns, filterableColumns, editable, notViewable, "Gprods.id", @statusColumnsEditable)}
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
