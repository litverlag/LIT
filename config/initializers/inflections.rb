# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'reihe', 'reihen'
  inflect.irregular 'reihen_zuordnung', 'reihen_zuordnungen'
  inflect.irregular 'reihen_hg_zuordnung', 'reihen_hg_zuordnungen'
  inflect.irregular 'faecher_zuordnung', 'faecher_zuordnungen'
  inflect.irregular 'autor', 'autoren'
  inflect.irregular 'buch', 'buecher'
  inflect.irregular 'lektor', 'lektoren'
  inflect.irregular 'fach', 'faecher'
  inflect.irregular 'land', 'laender'
  inflect.irregular 'format', 'formate'
  inflect.irregular 'umschlag', 'umschlaege'
  inflect.irregular 'bindung', 'bindungen'
  inflect.irregular 'papier', 'papiere'
  inflect.irregular 'land', 'laender'
  inflect.irregular 'rechte', 'rechte'
  inflect.irregular 'projekt', 'projekte'
  #Plural für Status-Tabellen
  inflect.irregular 'final', 'final'
  inflect.irregular 'druck', 'druck'
  inflect.irregular 'titelei', 'titelei'
  inflect.irregular 'satz', 'satz'
  inflect.irregular 'preps', 'preps'
  inflect.irregular 'offsch', 'offsch'
  inflect.irregular 'bildpr', 'bildpr'
  #inflect.irregular 'umschlag', 'umschlag' #Ueberschneidung!!!
  inflect.irregular 'umschl', 'umschl'
  inflect.irregular 'rg', 'rg'
  inflect.irregular 'binderei', 'binderei'
  inflect.irregular 'rechnung', 'rechnungen'
  inflect.uncountable 'cip'
end