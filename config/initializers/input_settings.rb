require 'singleton'

class InputSettings
  include Singleton

 GPRODS_PROVIDER = SettingsProvider.new("config/import_settings.yml",'gprods',"gropds_options")
 #BUECHER_PROVIDER = SettingsProvider.new("config/import_settings.yml",'buecher',"buecher_options")


  def is_visible?(department, field)

  end


  def which_type(field)

  end

  def all(table)
    PROVIDER.all_coloum_names[table]
  end

  def configurate_status(filename)
    yam = YAML.load_file(Rails.root.join(filename))
    puts yam
    status = ["statusbildpr", "statusbinderei", "statusdruck", "statusfinal", "statusoffsch", "statuspreps", "statusrg", "statussatz", "statustitelei", "statusumschl"]
    yam[:status].each do |key,value|
      status.each {|stat|GPRODS_PROVIDER.add_attributes(departm, stat, "status")}
    end

  end

  InputSettings.instance.configurate_status "config/import_settings.yml"
end

