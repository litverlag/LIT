##
# # /app/models/peojekt.rb
#
# Represents a whole project in the LIT Verlag
class Projekt < Gprod


	belongs_to :lektor

  #deadline_offset_from_today = 7

  def self.default_scope
    Gprod.joins("INNER JOIN status_final on status_final.gprod_id = gprods.id")
  end

  ##
  # This generates :im_verzug_#{lektor kuerzel} scopes.
  Lektor.where("emailkuerzel not like '%unknown%'").map{|l| l.fox_name}.each do |lek|
    base_name = 'im_verzug_'
    scope_name = (base_name + lek).to_sym
    scope (scope_name), -> {
      g = Projekt.joins("INNER JOIN lektoren on lektoren.id = gprods.lektor_id")
      g = g.where("status_final.status <> ?", I18n.t('scopes_names.fertig_filter'))
      g = g.where("lektoren.fox_name = ?", lek)
      g = g.where("final_deadline < ?", Date.today + 7)
      # FIXME We cannot filter columns with this scope.
      # Following does not help...
      #g.merge Projekt.includes [ :statusdruck, :statusumschl, :statuspreps, :statusbinderei, :statustitelei, :lektor ]
    }
  end

  ##
  # Now we generate :im_verzug_#{department} scopes.
  Department.all.map{|d| d.name}.each do |dep|
    next if ['superadmin', 'lektor'].include? dep
    base_name = 'im_verzug_'
    department_short = dep[0..2]
    scope_name = (base_name + department_short).to_sym

    # Inconsistent naming is such a joy! I'm so happy right now.
    table = case dep
    when 'umschlag'
      'umschl'
    when 'pod'
      'druck'
    when 'externerdruck'
      'externer_druck'
    when 'rechnung'
      'rg'
    when 'bildprüfung'
      'bildpr'
    else 
      dep
    end
    dep = table if ['rg', 'bildpr', 'druck', 'externer_druck'].include? table # INCONSISTENCYY

    scope (scope_name), -> {
      g = Projekt.joins("INNER JOIN status_#{table} on status_#{table}.gprod_id = gprods.id")
      g = g.where("status_#{table}.status <> ?", I18n.t('scopes_names.fertig_filter'))

      # We add final status check, cuz we have some incomplete old data in the db.
      g = g.where("status_final.status <> ?", I18n.t('scopes_names.fertig_filter'))
      g = g.where("final_deadline < ?", Date.today + 7)

      # Also filter externer_druck from druck view.
      if table == 'druck'
        g = g.where("not externer_druck")
      end

      g = g.where("#{dep}_deadline < ? OR #{dep}_deadline is NULL", Date.today + 7)

      # FIXME We cannot filter columns with this scope.
      # Following does not help...
      #g.merge Projekt.includes [ :statusdruck, :statusumschl, :statuspreps, :statusbinderei, :statustitelei, :lektor ]
      g.merge Projekt.includes [:lektor, ]
    }
  end rescue nil

	##
	# This method is used to find a Grod if there is a current_admin_user associated with a Lektor
	# you can only acces the Gprods of this Lektor. If the User has the Departement "Superadmin"
	# you can access all Gprods, same if you DON'T have an associated Lektor.
	def self.find_projekt_by_id(id,current_admin_user)
		departName = []
		current_admin_user.departments.to_a.each do |a|
			departName.append a.name
		end
		if departName.include? "Superadmin"
			@projekt = Gprod.find(id)
		elsif not current_admin_user.lektor.nil?
			@projekt = current_admin_user.lektor.gprod.find(id)
		else
			@projekt = Gprod.find(id)
		end

		if @projekt.buch.nil?
			@projekt.buch = Buch.create!
		end

		@projekt

	end

end
