class LektorController < TableController
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
    filterableColumns = [0,1]

    editable = false
    notViewable = true

      displayedColumns += [ ]

    respond_to do |format|
      format.html {render template: "lektor/terminplanung", locals: {columnHeader: columnHeader, displayedColumns: displayedColumns, statusColumns: statusColumns, filterableColumns: filterableColumns, notViewable: notViewable, editable: editable}}
      format.json {serve_table_data(Gprod.left_outer_joins(:buch, :lektor, :titelei, :preps, :umschlag, :druck, :binderei, :final).where("lektoren.id": current_user.lektor.id), displayedColumns, filterableColumns, editable, notViewable, "Gprods.id")}
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
    filterableColumns = [0,1]
    editable = true
    notViewable = true

    respond_to do |format|
      format.html {render template: "lektor/produktion", locals: {columnHeader: columnHeader, displayedColumns: displayedColumns, filterableColumns: filterableColumns, notViewable: notViewable, editable: editable}}
      format.json {serve_table_data(Gprod.left_outer_joins(:buch, :lektor).where("lektoren.id": current_user.lektor.id), displayedColumns, filterableColumns, editable, notViewable, "Gprods.id", [], lambda{|id| url_for controller: controller_name, action: :editProduktion, id: id })}
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
      render html: "Id ist keine Zahl", status: 404
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

  def newProduktion
  end

  def createProduktion
    @gprod = Gprod.new

    #direct form data
    @gprod.projektname = params[:inputProjektname]
    @gprod.auflage = params[:inputAuflage]
    @gprod.prio = params[:inputPrio]

    buch = Buch.new
    buch.isbn = params[:inputIsbn]
    buch.papier_bezeichnung = params[:inputPapier]
    buch.format_bezeichnung = params[:inputFormat]
    buch.umschlag_bezeichnung  = params[:inputUmschlag]
    buch.bindung_bezeichnung = params[:inputBindung]
    buch.seiten = params[:inputSeiten]
    @gprod.buch = buch

    #automatic associations
    @gprod.lektor = current_user.lektor

    titelei = Titelei.new
    titelei.status = "Neu"
    @gprod.titelei = titelei

    preps = Preps.new
    preps.status = "Neu"
    @gprod.preps = preps

    druck = Druck.new
    druck.status = "Neu"
    @gprod.druck = druck

    umschlag = Umschlag.new
    umschlag.status = "Neu"
    @gprod.umschlag = umschlag

    binderei = Binderei.new
    binderei.status = "Neu"
    @gprod.binderei = binderei

    final = Final.new
    final.status = "Neu"
    @gprod.final = final


    unless @gprod.save
      render html: "Datensatz konnte nicht gespeichert werden", status: 400
      return
    end

    redirect_to action: :produktion
  end

end
