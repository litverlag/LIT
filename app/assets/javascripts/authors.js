//= require table-filter

$(document).ready(function() {
  $("#bookSelect").select2({
    placeholder: 'Buecher auswaehlen',
    tags: true,
    templateSelection: template
  });
});

function template(wert){
  return "<h1>wert.text</h1>";
 }
