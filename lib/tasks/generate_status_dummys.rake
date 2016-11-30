namespace :db do
	desc "Goes through all Gprod's and creates every missing Status*"
	task stati: :environment do

		s_method = ["statusbildpr", "statusbinderei", "statusdruck",
							"statusexternerdruck", "statusfinal", "statusoffsch",
							"statuspreps", "statusrg", "statussatz", "statustitelei",
							"statusumschl"]
		s_class = [ StatusBildpr, StatusBinderei, StatusDruck, 
							StatusExternerDruck, StatusFinal, StatusOffsch, 
							StatusPreps, StatusRg, StatusSatz, StatusTitelei, 
							StatusUmschl ]
		s_comb = s_method.zip(s_class)

		Gprod.all.each do |gprod|
			s_comb.each do |method, status|
				if gprod.send(method).nil?
					s = status.create!(
						status: I18n.t("scopes_names.neu_filter"),
						gprod_id: gprod['id'],
					)
					gprod.send("#{method}=", s)
					#gprod.statusbildpr				= s if status[1] == StatusBildpr
					#gprod.statusbinderei			= s if status[1] == StatusBinderei  
					#gprod.statusdruck					= s if status[1] == StatusDruck  
					#gprod.statusexternerdruck	= s if status[1] == StatusExternerDruck  
					#gprod.statusfinal					= s if status[1] == StatusFinal  
					#gprod.statusoffsch				= s if status[1] == StatusOffsch
					#gprod.statuspreps					= s if status[1] == StatusPreps  
					#gprod.statusrg						= s if status[1] == StatusRg
					#gprod.statussatz					= s if status[1] == StatusSatz  
					#gprod.statustitelei				= s if status[1] == StatusTitelei  
					#gprod.statusumschl				= s if status[1] == StatusUmschl  

					gprod.save!
				end
			end
		end

	end
end
