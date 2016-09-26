namespace :db do
	desc "Goes through all Gprod's and creates every missing Status*"
	task stati: :environment do

		s_method = ["statusbildpr", "statusbinderei", "statusdruck", "statusfinal",
								"statusoffsch", "statuspreps", "statusrg", "statussatz",
								"statustitelei", "statusumschl"]
		s_class = [ StatusBildpr, StatusBinderei, StatusDruck, StatusFinal,
								StatusOffsch, StatusPreps, StatusRg, StatusSatz, StatusTitelei,
								StatusUmschl ]
		s_comb = s_method.zip(s_class)

		Gprod.all.each do |gprod|
			s_comb.each do |status|
				if gprod.send(status[0]).nil?
					s = status[1].create!(
						status: I18n.t("scopes_names.neu_filter"),
						gprod_id: gprod['id'],
					)
					gprod.statusbildpr		= s if status[1] == StatusBildpr
					gprod.statusbinderei	= s if status[1] == StatusBinderei  
					gprod.statusdruck			= s if status[1] == StatusDruck  
					gprod.statusfinal			= s if status[1] == StatusFinal  
					gprod.statusoffsch		= s if status[1] == StatusOffsch
					gprod.statuspreps			= s if status[1] == StatusPreps  
					gprod.statusrg				= s if status[1] == StatusRg
					gprod.statussatz			= s if status[1] == StatusSatz  
					gprod.statustitelei		= s if status[1] == StatusTitelei  
					gprod.statusumschl		= s if status[1] == StatusUmschl  

					gprod.save!
				end
			end
		end

	end
end
