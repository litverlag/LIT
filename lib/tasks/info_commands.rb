namespace :info do
	desc "Puts lektoren"
	task lek: :environment do
		Lektor.all.select do |l| 
			t = l['name']
			puts t unless t.nil? or t.empty?
		end
	end
end
