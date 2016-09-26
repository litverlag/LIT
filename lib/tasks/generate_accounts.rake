namespace :db do
	desc "Goes through departments and creates an account if non exists"
	task accounts: :environment do
		# Create actual Departments.
		lektoren = [ 'hopf', 'rainer', 'richter', 'bellmann', 'berlin', 'wien' ]
		lektoren.each do |lektor|
			mail = "#{lektor}@lit-verlag.de"
			unless AdminUser.where(email: mail).first
				new = AdminUser.create!(email: mail,
																password: "password1",
																password_confirmation: "password1",)
				new.department_ids = Department.where(name: "Lektor").first.id
				new.lektor = Lektor.where(name: lektor).first
				new.lektor = Lektor.where(emailkuerzel: mail).first if new.lektor.nil?
				lek = new.lektor ? " with Lektor " : " without Lektor."
				puts "Creating #{lektor}@lit-verlag.de" + lek + new.lektor.to_s
				new.save!
			end
		end

		# Create at least one account for each Department.
		dep_list = []
		Department.all.select { |d| dep_list.append(d['id']) }
		admin_list = []
		AdminUser.all.select{ |a| admin_list.append(a.department_ids) }
		admin_list.flatten!

		(dep_list - admin_list).each do |id|
			d = Department.where(id: id).first
			new = AdminUser.create!(email: "#{d.name.downcase}@lit-verlag.de",
												password: "password1",
												password_confirmation: "password1")
			new.department_ids = id
			new.save!
			puts "Creating #{d.name.downcase}@lit-verlag.de without associated Lektor."
		end

	end
end
