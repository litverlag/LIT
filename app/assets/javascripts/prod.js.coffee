'use strict';

autor = 
	{
		placeholder: "Suchen"
		allowClear: false
		minimumInputLength: 3
		initSelection: (element, callback) -> 
			id = $(element).val()
			if id != ''
				$.ajax('/admin/autoren.json?q[id_equals]=' + id, dataType: 'json').done (data) ->
					callback {text: "#{data[0].anrede} #{data[0].vorname} #{data[0].name}"}
					return

		ajax: {
			url: '/admin/autoren.json'
			dataType: 'json'
			data: (term, page) -> { 'q[fullname_contains]':  term }
			results: (data, page) -> { results: data.map (i) -> {id: i.id ,text: "#{i.anrede} #{i.vorname} #{i.name}"}}
			cache: true
		}
	}


lektor = 
	{
		placeholder: "Suchen"
		allowClear: false
		minimumInputLength: 3
		initSelection: (element, callback) -> 
			id = $(element).val()
			if id != ''
				$.ajax('/admin/projekte.json?q[id_equals]=' + id, dataType: 'json').done (data) ->
					callback {text: "#{data[0].name} #{data[0].fox_name}"}
					return

		ajax: {
			url: '/admin/projekte.json'
			dataType: 'json'
			data: (term, page) -> { 'q[fullname_contains]':  term }
			results: (data, page) -> { results: data.map (i) -> {id: i.id ,text: "#{i.name} #{i.fox_name}"}}
			cache: true
		}
	}


buch = 
	{
		placeholder: "Suchen"
		allowClear: false
		minimumInputLength: 3
		initSelection: (element, callback) -> 
			id = $(element).val()
			if id != ''
				$.ajax('/admin/buecher.json?q[id_equals]=' + id, dataType: 'json').done (data) ->
					callback {text: data[0].titel1}
					return

		ajax: {
			url: '/admin/buecher.json'
			dataType: 'json'
			data: (term, page) -> { 'q[titel1_contains]':  term }
			results: (data, page) -> { results: data.map (i) -> {id: i.id ,text: i.titel1}}
			cache: true
		}
	}

initSelect2 = (inputs, extra = {}, c) ->
  inputs.each ->
    item = $(this)
    # reading from data allows <input data-select2='{"tags": ['some']}'> to be passed to select2
    options = $.extend(allowClear: true, extra, item.data('select2'))
    # because select2 reads from input.data to check if it is select2 already
    item.data(c, null)
    item.select2(options)

$(document).on 'has_many_add:after', '.has_many_container', (e, fieldset) ->
  initSelect2(fieldset.find('.autor-input'), autor,'autor-input')
  initSelect2(fieldset.find('.buch-input'), buch,'buch-input')

$(document).ready ->
  initSelect2($(".autor-input"), autor,'autor-input')
  initSelect2($(".buch-input"), buch,'buch-input')
  return
