class TableController < ApplicationController
  before_filter :sanitize_page_params

  protected

  def serve_table_data (query, displayedColumns, filterableColumns, editable=false, notViewable = false, tableId="id", statusColumnsEditable=[], editPath=nil, showPath=nil)
    @editPath = editPath ? editPath : lambda { |id| url_for controller: "#{controller_name}", action: 'edit', id: id }
    @showPath = showPath ? showPath : lambda { |id| url_for controller: "#{controller_name}", action: 'show', id: id }

    #make data accessible for view
    @editable = editable
    @notViewable = notViewable
    @tableId = tableId
    @displayedColumns = displayedColumns
    @filterableColumns = filterableColumns
    @statusColumnsEditable = statusColumnsEditable

    entries = append_filter_from_params(query, filterableColumns).order(get_order_from_params)
    @count = entries.count

    selectedColumns = displayedColumns
    selectedColumns << tableId #necessary as identifier for opening the edit or show page
    selectedColumns = selectedColumns.map {|columnName| columnName + " as " + (columnName.gsub ".", "_") }

    @dataset = entries.select(selectedColumns.join(",")).offset(params[:offset]).limit(params[:limit])
    render "shared/table_components/table_data"
  end

  private

  #extracts the filter option from params[:filter] and returns searchableDbQuerry with appended filter.
  #params[:filter] ist of the following form(where >var< represents a variable):
  #[{"field": ">FilterableColumnName<", "method":">filterMethid<", "searchTerm":">termTosearchFor<" }, ... ]
  #valid filterMethods are: begins, ends, contains, equals (there is no explicit check for equals, because it is implied if none of the other is present)
  def append_filter_from_params(searchableDbQuerry, allowedSearchFields)
    return searchableDbQuerry unless params[:filter]

    begin
      (JSON.parse params[:filter]).each do |searchParameter|
        if @filterableColumns.include? begin Integer(searchParameter["field"]) rescue nil end

          searchTerm = ""
          searchTerm += "%" if ["ends", "contains"].include? searchParameter["method"]
          searchTerm += searchParameter['searchTerm']
          searchTerm += "%" if ["begins", "contains"].include? searchParameter["method"]

          #In this case it is ok, to concat the querry from Strings, because 'searchParameter["field"]' has already been validated
          searchableDbQuerry = searchableDbQuerry.where("lower(#{@displayedColumns[searchParameter['field'].to_i]}) LIKE lower(:searchTerm)", searchTerm: searchTerm)
        end
      end
    rescue JSON::ParserError => e
      logger.error "[JSON][AUTHOR] Invalid Param: 'filter'='#{params[:filter]}' raised JSON exception: #{e}"
      searchableDbQuerry
    end
    #necessary to return an "ActiveRecord::Relation" in case that params[:filter] is invalid
    searchableDbQuerry
  end

  #securely creates an order string to use in order() function from the sort param
  def get_order_from_params
    params[:sort] && params[:sort] <= @displayedColumns.length ? @displayedColumns[params[:sort]] + " " + params[:order] + "  NULLS LAST" : ""
  end

  def sanitize_page_params
    params[:offset] = params.has_key?(:offset) ? params[:offset].to_i : 0
    params[:limit] = params.has_key?(:limit) && params[:limit].to_i != 0 ? params[:limit].to_i : 25
    params[:order] = params.has_key?(:order) && params[:order].downcase == "asc" ? "ASC" : "DESC"
    params[:sort] = params.has_key?(:sort) ? begin Integer(params[:sort]) rescue nil end : nil
  end

  protected

  def getStatusDataset
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

    gprod
  end

end
