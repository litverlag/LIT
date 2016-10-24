class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
   include Rails.application.routes.url_helpers

  #The method access_denied would be defined in application_controller.rb.
  # Here is one example that redirects the user from the page they don't
  # have permission to access to a resource they have permission to access
  # (organizations in this case), and also displays the error message in the browser:
  def access_denied(exception)
    redirect_to "/admin/access_denied"
  end

	##
	# Arbitrary constraints checks.
	#		This is a pretty crappy routine...
	#
	# Example: 
	#   We check if the column :bindung_bezeichnung is in the data hash that
	#   shall be updated, if so we force valid @projekt.externer_druck entry by
	#   adding to the column hash, if instance is @projekt, otherwise we add to
	#   new_data and call @projekt.update() ourselfs.
	#   We do this to not push useless updates.
	#
	# Note:
	#		This method should probably moved to a subclass of this controller.. as
	#		we only need it in some Controllers.
	#
	def check_constraints(instance, data)
		#puts "[+] starting constraints checks"
		new_data = {}

		# Tiny helper to choose how to update, that is locally or the data hash
		def push(newH, oldH, cur_instance, entry, value)
			if cur_instance == @projekt
				# check if we need to update a sub-hash
				unless oldH.key?(entry)
					update_me = oldH[:buch_attributes]
				else
					update_me = oldH
				end
				update_me.update({entry => value}) unless oldH[entry] == value
			else
				newH.update({entry => value}) unless oldH[entry] == value
			end
		end

		# Another helper to determine if our data includes entry.
		def need_to_update?(entry, data)
			need = false
			data.flatten.each { |i| 
				if i.class != String and not i.nil?
					i.keys.each { |ii| 
						need = true if ii == entry 
					}
				else
					need = true if i == entry
				end
			}
			return need
		end

		if need_to_update?('bindung_bezeichnung', data)
			faden_or_hardcover = I18n.t('bi_names').values.delete_if{ |i| i == I18n.t('bi_names.k') }
			klebe = I18n.t('bi_names.k')
			current = data.include?('buch_attributes') ? 
				data[:buch_attributes][:bindung_bezeichnung] : 
				data[:bindung_bezeichnung]
			if faden_or_hardcover.include? current
				value = true
			elsif klebe.include? current
				value = false
			end
			#puts "[+] pushing externerner druck with '#{value}'"
			push(new_data, data, instance, :externer_druck, value) unless value.nil?
		end

		@projekt.update(new_data) unless new_data.empty?

		#puts "[-] finished constraints checks"
	end

end
