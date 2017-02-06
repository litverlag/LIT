class TiteleiController < TableController
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
                        "gprods.final_deadline","status_titelei.status",
                      ]
    statusColumns = [6]
    filterableColumns = [0]
    editable = false
    notViewable = true

    respond_to do |format|
      format.html {render template: "titelei/terminplanung", locals: {columnHeader: columnHeader, displayedColumns: displayedColumns, filterableColumns: filterableColumns, statusColumns: statusColumns, statusColumnsEditable: @statusColumnsEditable, notViewable: notViewable, editable: editable}}
      format.json {serve_table_data(Gprod.joins(:buch, :lektor, :titelei), displayedColumns, filterableColumns, editable, notViewable, "Gprods.id", @statusColumnsEditable)}
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
      format.html {render template: "titelei/produktion", locals: {columnHeader: columnHeader, displayedColumns: displayedColumns, filterableColumns: filterableColumns, notViewable: notViewable, editable: editable}}
      format.json {serve_table_data(Gprod.joins(:buch, :lektor), displayedColumns, filterableColumns, editable, notViewable, "Gprods.id", [], lambda{|id| url_for controller: controller_name, action: :editProduktion, id: id })}
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

  def stati
    render json: @stati.to_s
  end

  def editStatus
    if !@stati.include? params[:value] or @statusColumnsEditable.include? params[:name]
      render plain: 'Fehler: Wert ungültig oder keine Berechtigung', status: 417
    end
    begin
      params[:pk] = Integer(params[:pk])
    rescue
      render plain: 'Fehler: Id keine Zahl', status: 417
    end

    gprod = Gprod.find(params[:pk])
    if !gprod
      render plain: 'Fehler: Datensatz nicht gefunden', status: 417
    end

    gprod.titelei.status = params[:value]

    if gprod.titelei.save
      render plain: 'Erfolgreich gespeichert'
    else
      render plain: 'Fehler: Speichern fehlgeschlagen', status: 417
    end

  end
end
