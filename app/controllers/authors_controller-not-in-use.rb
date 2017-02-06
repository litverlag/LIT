class AuthorsController < TableController
  def new
  end

  def create
  end

  def edit
  end

  def delete
  end

  def show
  end

  def index
    columnHeader = ["Name", "Vorname", "Anrede", "Institut"]
    displayedColumns = ["autoren.name", "vorname", "autoren.anrede", "institut"]
    filterableColumns = [0,1,2,3]
    editable = true
    notViewable = true

    respond_to do |format|
      format.html {render template: "authors/index", locals: {columnHeader: columnHeader, displayedColumns: displayedColumns, filterableColumns: filterableColumns, notViewable: notViewable, editable: editable}}
      format.json {serve_table_data(Autor.all, displayedColumns, filterableColumns, editable, notViewable)}
    end
  end

end
