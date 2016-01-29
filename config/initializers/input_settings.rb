require 'singleton'

class InputSettings
  include Singleton

# PROVIDER = SettingsProvider.new("config/import_settings.yml",['gprods','buecher'])


  def is_visible?(department, field)
    #if department.is_a? Symbol
    #  department = department.to_s
    #end
    #PROVIDER.get_all_options[department][field]
    true
  end


  def which_type(field)
    #PROVIDER.names_and_types[field]
    "boolean"
  end

  def all(table)
    #PROVIDER.all_coloum_names
    if(table == "gprods")
      return ["projektname", "auflage_lektor", "final_deadline"]
    end
    if(table == "buecher")
      return ["issn", "isbn", "id"]
    end
  end
end

