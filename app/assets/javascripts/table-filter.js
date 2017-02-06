function activateInlineEditingofStatusFields(){
  $('.statusCell').editable();
}

function tableRefresh(event, table_id) {
    $( "#"+table_id ).bootstrapTable('refresh');
    event.preventDefault();
}

/*callback for bootstrap table
 *adds params from filter sidebar to queryParams
 *in form of:
 *[{"field": ">FilterableColumnName<", "method":">filterMethod<", "searchTerm":">termTosearchFor<" }, ... ]
*/
function tableGetFilterParams(filterId, params) {
  var filter = [];

  //iterates through every row of the filter component form
  $("#" + filterId + " .filter-row").each(function() {
    var field = this.getAttribute("name");
    var method = this.getElementsByTagName("select")[0].value;
    var searchTerm = this.getElementsByTagName("input")[0].value;

    //only add to filter, if not blank
    if (searchTerm) {
      filter.push({field:field, method:method, searchTerm:searchTerm});
    }
  });

  params["filter"] = JSON.stringify(filter);
  return params;
}

function tableFormatActions(value, row, index){
  var buttons = [];
    value.forEach(function(link){
      if (link.startsWith("show:")) {
        buttons = buttons.concat([  '<a href='+link.substr(link.indexOf(':')+1)+' title="Ansehen">',
                                        '<i class="glyphicon glyphicon-eye-open"></i>',
                                        '</a \>']);
      }
      if (link.startsWith("edit:")) {
        buttons = buttons.concat([  '<a href='+link.substr(link.indexOf(':')+1)+' title="Editieren"' + (value.length > 1 ? ' style="margin-left:15px;"' : '') + '>',
                                        '<i class="glyphicon glyphicon-pencil"></i>',
                                        '</a \>']);
      }
    });

  return buttons.join('');
}

function statusCellFormatEditable(value, row, index){
  args = value.split(":");
  value = statusCellFormat(args[0], row, index)
  return '<a href="#" class="statusCell" data-pk="'+args[1]+'" data-name="'+args[4]+'" data-type="select" data-source="'+args[2]+'" data-url="'+args[3]+'" data-title="Status Bearbeiten">'+value+'</a>'
}

function statusCellFormat(value, row, index){
  value = value.trim().toLowerCase()
  if (value === "fertig"){
    return "<span class='label label-success label-custom-size'>"+value+'</span>'
  }
  if (value === "problem"){
    return "<span class='label label-danger label-custom-size'>"+value+"</span>"
  }
  if (value === "in bearbeitung"){
    return "<span class='label label-warning label-custom-size'>"+value+'</span>'
  }
  if (value === "neu"){
    return "<span class='label label-primary label-custom-size'>"+value+"</span>"
  }
  if (value === "verschickt"){
    return "<span class='label label-default label-custom-size'>"+value+"</span>"
  }
  return value;
}

function statusCellStyle(){
  return {css: {"width": "70px;"}};
}

function actionCellStyle(value, row, index, field) {
  if (value.length == 2){
    return {css: {"width": "70px;"}};
  }
  else{
    return {classes: 'text-nowrap', css: {"width": "40px;"}}
  }
}
