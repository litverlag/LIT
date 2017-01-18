require 'singleton'
##
# See config/initializers/show_settings.rb for updated stuff.

###
# This class is to test if a field is visible in the view
# it has three instances of Input settings on for the buecher field, one for
# the gprod fields and one for the Status_fields
#
#
class InputSettings
  include Singleton
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
		return true if dep.department_input_setting.send(field)
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
	# DONE: Maybe we should put it to class and not instance initialization
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
	#	TODO:			We have to cache these values.
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
