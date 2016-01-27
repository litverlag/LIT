require 'singleton'

class InputSettings
  include Singleton

 PROVIDER = SettingsProvider.new("config/import_settings.yml",['gprods','buecher'])


  def is_visible?(department, field)
    if department.is_a? Symbol
      department = department.to_s
    end
    PROVIDER.get_all_options[department][field]
  end


  def which_type(field)
    PROVIDER.names_and_types[field]
  end

  def all
    PROVIDER.all_coloum_names
  end
end

