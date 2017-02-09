class DruckController < TableController
  before_filter :init

  private
  def init
    @stati = ["Neu", "In Bearbeitung", "Fertig", "Problem"]
    @statusColumnsEditable = [6]
  end

  public

  def index
    columnHeader = [  "Name","ISBN","Lektor","Priorität","MS Ein","SollIF","Status",
                    ]
    displayedColumns = ["gprods.projektname","buecher.isbn","lektoren.fox_name",
                        "gprods.prio","gprods.manusskript_eingang_date",
                        "gprods.final_deadline","status_druck.status",
                      ]
    statusColumns = [6]
    filterableColumns = [0]
    editable = false
    notViewable = true

    respond_to do |format|
      format.html {render template: "druck/terminplanung", locals: {columnHeader: columnHeader, displayedColumns: displayedColumns, filterableColumns: filterableColumns, statusColumns: statusColumns, statusColumnsEditable: @statusColumnsEditable, notViewable: notViewable, editable: editable}}
      format.json {serve_table_data(Gprod.left_outer_joins(:buch, :lektor, :druck), displayedColumns, filterableColumns, editable, notViewable, "Gprods.id", @statusColumnsEditable)}
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
    editable = true
    notViewable = true

    respond_to do |format|
      format.html {render template: "druck/produktion", locals: {columnHeader: columnHeader, displayedColumns: displayedColumns, filterableColumns: filterableColumns, notViewable: notViewable, editable: editable}}
      format.json {serve_table_data(Gprod.left_outer_joins(:buch, :lektor), displayedColumns, filterableColumns, editable, notViewable, "Gprods.id", [], lambda{|id| url_for controller: controller_name, action: :editProduktion, id: id })}
    end
  end

  def editProduktion
    begin
      id = Integer(params[:id])
    rescue
      render html: "Id ist keine Zahl", status: 404
      return
    end

    begin
      @gprod = Gprod.find(id)
    rescue ActiveRecord::RecordNotFound
      render html: "Projekt nicht gefunden", status: 404
      return
    end
  end

  def updateProduktion
    begin
      id = Integer(params[:id])
    rescue
      render html: "Id ist keine Zahl", status: 400
      return
    end

    begin
      @gprod = Gprod.find(id)
    rescue ActiveRecord::RecordNotFound
      render html: "Projekt nicht gefunden", status: 404
      return
    end

    @gprod.projektname = params[:inputProjektname]
    @gprod.buch.isbn = params[:inputIsbn]
    @gprod.auflage = params[:inputAuflage]
    @gprod.prio = params[:inputPrio]
    @gprod.buch.papier_bezeichnung = params[:inputPapier]
    @gprod.buch.format_bezeichnung = params[:inputFormat]
    @gprod.buch.umschlag_bezeichnung  = params[:inputUmschlag]
    @gprod.buch.bindung_bezeichnung = params[:inputBindung]
    @gprod.buch.seiten = params[:inputSeiten]

    unless @gprod.save
      render html: "Datensatz konnte nicht gespeichert werden", status: 400
      return
    end

    redirect_to action: :produktion
  end

  def stati
    render json: @stati.to_s
  end

  def editStatus
    gprod = getStatusDataset
    return unless gprod

    gprod.druck.status = params[:value]

    if gprod.druck.save
      render plain: 'Erfolgreich gespeichert'
    else
      render plain: 'Fehler: Speichern fehlgeschlagen', status: 417
    end

  end
end
