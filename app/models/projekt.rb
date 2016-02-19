##
# # /app/models/peojekt.rb
#
# Represents a whole project in the LIT Verlag
class Projekt < Gprod


	belongs_to :lektor

  def self.default_scope
    Preps.joins("INNER JOIN status_final on status_final.gprod_id = gprods.id")
  end

	##
	# This method is used to find a Grod if there is a current_admin_user associated with a Lektor
	# you can only acces the Gprods of this Lektor. If the User has the Departement "Superadmin"
	# you can access all Gprods
	def self.find_projekt_by_id(id,current_admin_user)
		departName = []
		current_admin_user.departments.to_a.each do |a|
			departName.append a.name
		end
		if departName.include? "Superadmin"
			@projekt = Gprod.find(id)
		elsif !current_admin_user.lektor.nil?
			@projekt = current_admin_user.lektor.gprod.find(id)
		end

	end



end
