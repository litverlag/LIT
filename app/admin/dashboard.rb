ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end

		dep = current_admin_user.departments.first.name

		if dep.include? 'Superadmin'
			div class: "blank_slate_container", id: "dashboard_default_message" do
				span class: "blank_slate" do
					span '-- Superadmin welcome page --'
					small I18n.t("active_admin.dashboard_welcome.call_to_action")
				end
			end
		end

		if dep.include? 'Lektor' or dep.include? 'Superadmin'
			columns do
				column do
					panel I18n.t('headlines.lek_pod') do
						table do
							pod = Projekt.ransack(final_deadline_gt: Date.today).result.map
							pod = pod.sort_by { |v| v.final_deadline }
							pod.sort! { |a,b| 
								if a.prio == b.prio 
									0
								elsif a.prio == "Z" 
									-1 
								elsif b.prio == "Z" 
									1 
								else
									0
								end 
							}
							unless /admin/.match(current_admin_user.email)
								pod.delete_if { |p| 
									not /#{current_admin_user.email.sub(/@.*/, '')}/i.match(p.lektor.name) \
										rescue false
								}
							end
							th I18n.t('buecher_names.isbn')
							th I18n.t('gprod_names.projektname')
							th I18n.t('gprod_names.prio')
							th I18n.t('status_names.statusfinal')
							th I18n.t('gprod_names.final_deadline')
							th I18n.t('search_labels.lektor')
							pod.each do |p|
								next if p.statusfinal.status.eql? I18n.t('scopes_names.fertig_filter')
								tr ''
								td link_to(p.buch.isbn, "/admin/ums/#{p.id}") rescue td "<empty>"
								td p.projektname
								td p.prio
								td status_tag(p.statusfinal.status)
								td p.final_deadline
								#unless p.buch.lektor.nil? and not p.buch.nil?
								td p.buch.lektor.name rescue td "<empty>"
							end	
						end
					end
				end
			end
		end

		if dep.include? 'Umschlag' or dep.include? 'Superadmin'
			columns do
				column do
					panel I18n.t('headlines.um_pod') do
						table do
							pod = Projekt.ransack(final_deadline_gt: Date.today).result.map
							pod = pod.sort_by { |v| v.final_deadline }
							pod.sort! { |a,b|
								if a.prio == b.prio
									0
								elsif a.prio == "Z"
									-1
								elsif b.prio == "Z"
									1
								else
									0
								end
							}
							if /tex/.match(current_admin_user.email) or /admin/.match(current_admin_user.email)
								pod.delete_if { |p| 
									p.buch.umschlag_bezeichnung == I18n.t('um_names.indesign') rescue true
								}
							end
							th I18n.t('buecher_names.isbn')
							th I18n.t('gprod_names.projektname')
							th I18n.t('gprod_names.prio')
							th I18n.t('status_names.statusumschl')
							th I18n.t('gprod_names.final_deadline')
							th I18n.t('gprod_names.umschlag_deadline')
							th I18n.t('search_labels.lektor')
							pod.each do |p|
								next if p.statusumschl.status.eql? I18n.t('scopes_names.fertig_filter')
								if p.prio == "Z"
									cur_status = status_tag(
										class: I18n.t('scopes_names.problem_filter'), 
										label: p.prio
									)
								else
									cur_status = p.prio
								end
								tr ''
								td link_to(p.buch.isbn, "/admin/ums/#{p.id}") rescue td "<empty>"
								td p.projektname
								td cur_status
								td status_tag(p.statusumschl.status)
								td p.final_deadline
								td p.umschlag_deadline
								td p.buch.lektor.name rescue td "<empty>"
							end	
						end
					end
				end
			end
		end

		if dep.include? 'Titelei' or dep.include? 'Superadmin'
			columns do
				column do
					panel I18n.t('headlines.tit_pod') do
						table do
							pod = Projekt.ransack(final_deadline_gt: Date.today).result.map
							pod = pod.sort_by { |v| v.final_deadline }
							pod.sort! { |a,b|
								if a.prio == b.prio
									0
								elsif a.prio == "Z"
									-1
								elsif b.prio == "Z"
									1
								else
									0
								end
							}
							th I18n.t('buecher_names.isbn')
							th I18n.t('gprod_names.projektname')
							th I18n.t('gprod_names.prio')
							th I18n.t('status_names.statustitelei')
							th I18n.t('gprod_names.final_deadline')
							th I18n.t('headlines.sollf_diff')
							th I18n.t('search_labels.lektor')
							pod.each do |p|
								next if p.statustitelei.status.eql? I18n.t('scopes_names.fertig_filter')
								if p.prio == "Z"
									cur_status = status_tag(
										class: I18n.t('scopes_names.problem_filter'), 
										label: p.prio
									)
								else
									cur_status = p.prio
								end
								tr ''
								td link_to(p.buch.isbn, "/admin/ums/#{p.id}") rescue td "<empty>"
								td p.projektname
								td cur_status
								td status_tag(p.statustitelei.status)
								td p.final_deadline
								td (p.final_deadline - Date.today).to_i
								td p.buch.lektor.name rescue td "<empty>"
							end	
						end
					end
				end
			end
		end


  end # content
end
