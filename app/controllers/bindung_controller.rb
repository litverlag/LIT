class BindungController < TableController
  before_filter :init

  private
  def init
    @stati = ["Neu", "In Bearbeitung", "Fertig"]
    @statusColumnsEditable = [7]
  end

  public

  def index
    columnHeader = ["Name","ISBN","Lektor","Priorität","MS Ein","SollIF","Format","Status"]
    displayedColumns = ["gprods.projektname","buecher.isbn","lektoren.fox_name",
                        "gprods.prio","gprods.manusskript_eingang_date","gprods.final_deadline",
                        "buecher.format_bezeichnung","status_binderei.status"]
    statusColumns = [7]
    filterableColumns = [0,1]

    editable = false
    notViewable = true

    respond_to do |format|
      format.html {render template: "bindung/index", locals: {columnHeader: columnHeader, displayedColumns: displayedColumns, statusColumns: statusColumns, statusColumnsEditable: @statusColumnsEditable, filterableColumns: filterableColumns, notViewable: notViewable, editable: editable}}
      format.json {serve_table_data(Gprod.left_outer_joins(:buch, :lektor, :binderei), displayedColumns, filterableColumns, editable, notViewable, "Gprods.id", @statusColumnsEditable)}
    end
  end

  def stati
    render json: @stati.to_s
  end

  def editStatus
    gprod = getStatusDataset
    return unless gprod

    gprod.binderei.status = params[:value]

    if gprod.binderei.save
      render plain: 'Erfolgreich gespeichert'
    else
      render plain: 'Fehler: Speichern fehlgeschlagen', status: 417
    end

  end
end
