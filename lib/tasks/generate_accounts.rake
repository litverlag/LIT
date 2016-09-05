namespace :db do
	desc "Goes through departments and creates an account if non exists"
	task accounts: :environment do
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
