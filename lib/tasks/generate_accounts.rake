namespace :db do
	desc "Goes through departments and creates an account if non exists"
	task accounts: :environment do
		# Create actual Departments.
		lektoren = [ 'hopf', 'rainer', 'richter', 'bellmann', 'berlin', 'wien' ]
		lektoren.each do |lektor|
			unless AdminUser.where(email: "#{lektor}@lit-verlag.de").first
				new = AdminUser.create!(email: "#{lektor}@lit-verlag.de",
																password: "password1",
																password_confirmation: "password1",)
				new.department_ids = Department.where(name: "Lektor").first.id
				new.lektor = Lektor.where(name: lektor).first
				puts "Creating #{lektor}@lit-verlag.de"
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
			puts "Creating #{d.name.downcase}@lit-verlag.de"
			new = AdminUser.create!(email: "#{d.name.downcase}@lit-verlag.de",
												password: "password1",
												password_confirmation: "password1")
			new.department_ids = id
		end

	end
end
