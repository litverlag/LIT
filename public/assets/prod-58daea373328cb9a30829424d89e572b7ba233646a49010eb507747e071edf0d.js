(function() {
  'use strict';
  var autor, buch, initSelect2, lektor;

  autor = {
    placeholder: "Suchen",
    allowClear: false,
    minimumInputLength: 3,
    initSelection: function(element, callback) {
      var id;
      id = $(element).val();
      if (id !== '') {
        return $.ajax('/admin/autoren.json?q[id_equals]=' + id, {
          dataType: 'json'
        }).done(function(data) {
          callback({
            text: data[0].anrede + " " + data[0].vorname + " " + data[0].name
          });
        });
      }
    },
    ajax: {
      url: '/admin/autoren.json',
      dataType: 'json',
      data: function(term, page) {
        return {
          'q[fullname_contains]': term
        };
      },
      results: function(data, page) {
        return {
          results: data.map(function(i) {
            return {
              id: i.id,
              text: i.anrede + " " + i.vorname + " " + i.name
            };
          })
        };
      },
      cache: true
    }
  };

  lektor = {
    placeholder: "Suchen",
    allowClear: false,
    minimumInputLength: 3,
    initSelection: function(element, callback) {
      var id;
      id = $(element).val();
      if (id !== '') {
        return $.ajax('/admin/projekte.json?q[id_equals]=' + id, {
          dataType: 'json'
        }).done(function(data) {
          callback({
            text: data[0].name + " " + data[0].fox_name
          });
        });
      }
    },
    ajax: {
      url: '/admin/projekte.json',
      dataType: 'json',
      data: function(term, page) {
        return {
          'q[fullname_contains]': term
        };
      },
      results: function(data, page) {
        return {
          results: data.map(function(i) {
            return {
              id: i.id,
              text: i.name + " " + i.fox_name
            };
          })
        };
      },
      cache: true
    }
  };

  buch = {
    placeholder: "Suchen",
    allowClear: false,
    minimumInputLength: 3,
    initSelection: function(element, callback) {
      var id;
      id = $(element).val();
      if (id !== '') {
        return $.ajax('/admin/buecher.json?q[id_equals]=' + id, {
          dataType: 'json'
        }).done(function(data) {
          callback({
            text: data[0].titel1
          });
        });
      }
    },
    ajax: {
      url: '/admin/buecher.json',
      dataType: 'json',
      data: function(term, page) {
        return {
          'q[titel1_contains]': term
        };
      },
      results: function(data, page) {
        return {
          results: data.map(function(i) {
            return {
              id: i.id,
              text: i.titel1
            };
          })
        };
      },
      cache: true
    }
  };

  initSelect2 = function(inputs, extra, c) {
    if (extra == null) {
      extra = {};
    }
    return inputs.each(function() {
      var item, options;
      item = $(this);
      options = $.extend({
        allowClear: true
      }, extra, item.data('select2'));
      item.data(c, null);
      return item.select2(options);
    });
  };

  $(document).on('has_many_add:after', '.has_many_container', function(e, fieldset) {
    initSelect2(fieldset.find('.autor-input'), autor, 'autor-input');
    return initSelect2(fieldset.find('.buch-input'), buch, 'buch-input');
  });

  $(document).ready(function() {
    initSelect2($(".autor-input"), autor, 'autor-input');
    initSelect2($(".buch-input"), buch, 'buch-input');
  });

}).call(this);
