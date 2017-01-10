# Default to status 'fertig', so we don't see all those old projekts.
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
						status: I18n.t("scopes_names.fertig_filter"),
						gprod_id: gprod['id'],
					)
					gprod.send("#{method}=", s)

					gprod.save!
				end
			end
		end

	end
end
