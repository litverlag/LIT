require 'singleton'

class InputSettings
  include Singleton

  @status = {"statusbildpr": :"selectable", "statusbinderei": :"selectable", "statusdruck": :"selectable", "statusfinal": :"selectable", "statusoffsch": :"selectable", "statuspreps": :"selectable", "statusrg": :"selectable", "statussatz": :"selectable", "statustitelei": :"selectable", "statusumschl": :"selectable"}
  GPRODS_PROVIDER = SettingsProvider.new("config/import_settings.yml",'gprods',"gprods_options")
  BUECHER_PROVIDER = SettingsProvider.new("config/import_settings.yml",'buecher',"buecher_options")
  STATUS_PROVIDER = SettingsProvider.new("config/import_settings.yml",@status,"status_options")

  def is_visible?(department, field)
   # begin
    if not GPRODS_PROVIDER.get_all_options[department][field].nil?
      return GPRODS_PROVIDER.get_all_options[department][field]
    elsif not BUECHER_PROVIDER.get_all_options[department][field].nil?
      return BUECHER_PROVIDER.get_all_options[department][field]
    elsif not  STATUS_PROVIDER.get_all_options[department][field].nil?
      return STATUS_PROVIDER.get_all_options[department][field]
    end
   # rescue
   #   raise ArgumentError, "In the YAML file is a definition missing"
    #end

  end



  def which_type(field)
    field = field.to_sym
    if not GPRODS_PROVIDER.names_and_types[field].nil?
      return GPRODS_PROVIDER.names_and_types[field]
    elsif not BUECHER_PROVIDER.names_and_types[field].nil?
      return BUECHER_PROVIDER.names_and_types[field]
    elsif not  STATUS_PROVIDER.names_and_types[field].nil?
      return STATUS_PROVIDER.names_and_types
    end
  end

  def all(table)
    case table
      when "gprods"
        GPRODS_PROVIDER.all_coloum_names
      when "buecher"
        BUECHER_PROVIDER.all_coloum_names
      when "status"
        STATUS_PROVIDER.all_coloum_names
      else
        raise ArgumentError, "There is no table or manually defined SettingsProvider for you table "
    end
  end



  ##
  # In this method you have to change the type of the field manually. This is necessary if you want to have more
  # options for the views to choose from
  #
  def initialize
    BUECHER_PROVIDER.change_type(:papier_bezeichnung,"selectable")
    BUECHER_PROVIDER.change_type(:bindung_bezeichnung,"selectable")
    BUECHER_PROVIDER.change_type(:umschlag_bezeichnung,"selectable")
    BUECHER_PROVIDER.change_type(:format_bezeichnung,"selectable")

  end


end

