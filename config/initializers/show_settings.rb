##
# Note: every function starting with "old_" is deprecated, and not used. The
# new code is below.
##


require 'singleton'
###
# This class is to test if a field is visible in the view
# it has three instances of Input settings on for the buecher field, one for
# the gprod fields and one for the Status_fields
#
#
class ShowSettings
  include Singleton
	#@status is used to insert new field/options pairs to the SettingsProvider
	#which do not come from a database table.
	@status = {:statusbildpr => "selectable", :statusbinderei => "selectable",
						:statusdruck => "selectable", :statusfinal => "selectable",
						:statusoffsch => "selectable", :statuspreps => "selectable",
						:statusrg => "selectable", :statussatz => "selectable",
						:statustitelei => "selectable", :statusumschl => "selectable"}
  GPRODS_PROVIDER = SettingsProvider.new("config/show_settings.yml",'gprods',"gprods_options")
  BUECHER_PROVIDER = SettingsProvider.new("config/show_settings.yml",'buecher',"buecher_options")
  #Instanziation of the Provider with a Hash table instead of a name of a database table
  STATUS_PROVIDER = SettingsProvider.new("config/show_settings.yml",@status,"status_options")

  def old_is_visible?(department, field)
    field = field.to_sym
    if department.nil?
      raise ArgumentError, "Department can't be nil"
    end
    if GPRODS_PROVIDER.get_all_options(department).nil?
      raise ArgumentError, "The department is not defiend in the yaml file"
    else
      if not GPRODS_PROVIDER.get_all_options(department)[field].nil?
        return GPRODS_PROVIDER.get_all_options(department)[field]
      elsif not BUECHER_PROVIDER.get_all_options(department)[field].nil?
        return BUECHER_PROVIDER.get_all_options(department)[field]
      elsif not  STATUS_PROVIDER.get_all_options(department)[field].nil?
        return STATUS_PROVIDER.get_all_options(department)[field]
      end
    end
  end

  def old_which_type(field)
    field = field.to_sym
    if not GPRODS_PROVIDER.names_and_types[field].nil?
      return GPRODS_PROVIDER.names_and_types[field]
    elsif not BUECHER_PROVIDER.names_and_types[field].nil?
      return BUECHER_PROVIDER.names_and_types[field]
    elsif not  STATUS_PROVIDER.names_and_types[field].nil?
      return STATUS_PROVIDER.names_and_types
    end
  end

  def old_all(table)
    case table
      when "gprods"
        GPRODS_PROVIDER.all_coloum_names
      when "buecher"
        BUECHER_PROVIDER.all_coloum_names
      when "status"
        STATUS_PROVIDER.all_coloum_names
      else
        raise ArgumentError, 
					"There is no table or manually defined SettingsProvider for you table"
    end
  end

  ##
	# In this method you have to change the type of the field manually. This is
	# necessary if you want to have more options for the views to choose from
  #
  def old_initialize
    #change the type to selectable because from the db it comes as a string
    BUECHER_PROVIDER.change_type(:papier_bezeichnung,'selectable')
    BUECHER_PROVIDER.change_type(:bindung_bezeichnung,'selectable')
    BUECHER_PROVIDER.change_type(:umschlag_bezeichnung,'selectable')
    BUECHER_PROVIDER.change_type(:format_bezeichnung,'selectable')

    GPRODS_PROVIDER.change_type(:prio,'selectable')
		GPRODS_PROVIDER.change_type(:bilder, 'selectable')

    GPRODS_PROVIDER.remove_attribute 'id'
    GPRODS_PROVIDER.remove_attribute 'lektor_id'
    GPRODS_PROVIDER.remove_attribute 'autor_id'
    GPRODS_PROVIDER.remove_attribute 'created_at'
    GPRODS_PROVIDER.remove_attribute 'updated_at'

    BUECHER_PROVIDER.remove_attribute 'autor_id'
    BUECHER_PROVIDER.remove_attribute 'lektor_id'
    BUECHER_PROVIDER.remove_attribute 'gprod_id'
    BUECHER_PROVIDER.remove_attribute 'id'
    BUECHER_PROVIDER.remove_attribute 'created_at'
    BUECHER_PROVIDER.remove_attribute 'updated_at'
	end



	##################
	# New code below #
	##################
	include ApplicationHelper

	##
	# replace is_visible?
	def is_visible?(dep_name, field)
		dep = Department.where(name: dep_name).first
		dep = Department.where(name: dep_name.camelcase).first if dep.nil?
		dep = Department.where(name: class_to_dep(dep_name)).first if dep.nil?

		if dep.nil?
			raise ArgumentError, "cannot find department: '#{dep_name}'" 
		elsif dep.department_show_setting.nil?
			raise RuntimeError, "show_settings for department '#{dep_name}' is nil"
		end

		field = field.to_s.gsub('_','').to_sym if field.to_s =~ /^status.*/i
		return true if dep.department_show_setting.send(field)
		return false
	end

	# Class initialization with some static variables.
	@@type_override = {
		:papier_bezeichnung=>"selectable",
		:bindung_bezeichnung=>"selectable",
		:umschlag_bezeichnung=>"selectable",
		:format_bezeichnung=>"selectable",
		:prio=>"selectable",
		:bilder=>"selectable",
	}
	tmp = ActiveRecord::Base.connection.tables\
		.map{|t| t if t =~ /^status_.*/i}.delete_if{|e| e.nil?}
	@@stati = {}
	tmp.each{|s| @@stati.update(s.gsub('_','').to_sym => 'selectable')}

	##
	# replace initialize
	## 
	# Todo: Maybe we should put it to class and not instance initialization
	# We did that ^.
	def initialize
	end

	##
	# replace all
	def all(table)
    case table
      when "gprods"
        ActiveRecord::Base.connection.columns('gprods').map{|g| g.name}\
					.delete_if { |n| 
					["id", "lektor_id", "autor_id", "created_at", "updated_at"]\
						.include? n 
				}
      when "buecher"
        ActiveRecord::Base.connection.columns('buecher').map{|g| g.name}\
					.delete_if { |n| 
					["autor_id", "lektor_id", "gprod_id", "id", "created_at", "updated_at"]\
						.include? n 
				}
      when "status"
        @@stati.keys #.map{|k| k.to_s} Symbols should be correct here.
      else
        raise ArgumentError, "There is no table for your table.. << #{table} >>"
    end
	end

	##
	# replace which_type
	##
	# Thoughts: This may result in a lot.. a lot of db lookups..
	#	Todo:			We have to cache these values.
	def which_type(field)
		return 'selectable' if field =~ /^status.*/i
		field = field.to_sym
		if @@type_override.include? field
			return @@type_override[field.to_sym]
		else
			table = nil
			{'buecher_names' => 'buecher', 
			 'gprod_names'   => 'gprods' ,
			}.each do |i, t|
				list = I18n.t(i).keys
				if list.include? field
					table = t
					break
				end
			end
			if table.nil?
				# Quote: <!-- at the moment other types of data are not managed -->
				#puts"Field not found: '#{field}'" 
				return nil
			end

			ActiveRecord::Base.connection.columns(table).each { |c|
				return c.type.to_s if c.name.to_s == field.to_s
			}
		end
	end

end
