ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

		##
		# I expected to need more diversity for the different departments, thus
		# this is pretty verbose.

		dep = current_admin_user.departments.first.name
		z_top_prio = Proc.new { |a,b|
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
		def tagged_prio(p)
			if p.prio == "Z"
				status_tag(
					class: I18n.t('scopes_names.problem_filter'),
					label: p.prio
				)
			else
				p.prio
			end
		end

		if dep.include? 'Superadmin'
			div class: "blank_slate_container", id: "dashboard_default_message" do
				span class: "blank_slate" do
					span '-- Superadmin welcome page --'
					small I18n.t("active_admin.dashboard_welcome.call_to_action")
				end
			end
		end

		if dep.include? 'Lektor' or dep.include? 'Superadmin'
			panel I18n.t('headlines.lek_pod') do
				table do
					pod = Projekt.ransack(final_deadline_gt: Date.yesterday).result.map
					pod = pod.sort_by { |v| v.final_deadline }
					pod.sort! &z_top_prio
					unless /admin/.match(current_admin_user.email)
						pod.delete_if { |p|
							not /#{current_admin_user.email.sub(/@.*/, '')}/i.match(p.lektor.name) \
								rescue false
						}
					end
					th I18n.t('gprod_names.projektname')
					th I18n.t('gprod_names.prio')
					th I18n.t("status_names.statusbinderei")
					th I18n.t("status_names.statusdruck")
					th I18n.t("gprod_names.externer_druck")
					th I18n.t("status_names.statusumschl")
					th I18n.t("status_names.statussatz")
					th I18n.t('search_labels.lektor')
					pod.each do |p|
						next if p.statusfinal.status.eql? I18n.t('scopes_names.fertig_filter')
						tr ''
						td link_to(p.projektname, "/admin/projekte/#{p.id}") rescue td "-"
						td tagged_prio(p)
						td status_tag(p.statusbinderei.status)
						td status_tag(p.statusdruck.status)
						if p.externer_druck
							td "extern #{p.buch.bindung_bezeichnung}" rescue td 'extern'
						else
							td p.buch.bindung_bezeichnung rescue td 'extern'
						end
						td status_tag(p.statusumschl.status)
						if p.satzproduktion
							td status_tag(p.statussatz.status)
						else
							td "-"
						end
						td p.buch.lektor.name rescue td "-"
					end
				end
			end
		end

		if dep.include? 'Umschlag' or dep.include? 'Superadmin'
			panel I18n.t('headlines.um_pod') do
				table do
					pod = Projekt.ransack(final_deadline_gt: Date.yesterday).result.map
					pod = pod.sort_by { |v| v.final_deadline }
					pod.sort! &z_top_prio
					if /(tex|umschlag)/.match(current_admin_user.email) or /admin/.match(current_admin_user.email)
						pod.delete_if { |p|
							p.buch.umschlag_bezeichnung == I18n.t('um_names.indesign') rescue true
						}
					elsif /i?n?design/.match(current_admin_user.email)
						pod.delete_if { |p|
							p.buch.umschlag_bezeichnung == I18n.t('um_names.tex') rescue true
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
						tr ''
						td link_to(p.buch.isbn, "/admin/ums/#{p.id}") rescue td "<empty>"
						td p.projektname
						td tagged_prio(p)
						td status_tag(p.statusumschl.status)
						td p.final_deadline
						td p.umschlag_deadline
						td p.buch.lektor.name rescue td "<empty>"
					end
				end
			end
		end

		if dep.include? 'Titelei' or dep.include? 'Superadmin'
			panel I18n.t('headlines.tit_pod') do
				table do
					pod = Projekt.ransack(final_deadline_gt: Date.yesterday).result.map
					pod = pod.sort_by { |v| v.final_deadline }
					pod.sort! &z_top_prio
					th I18n.t('buecher_names.isbn')
					th I18n.t('gprod_names.projektname')
					th I18n.t('gprod_names.prio')
					th I18n.t('status_names.statustitelei')
					th I18n.t('gprod_names.final_deadline')
					th I18n.t('headlines.sollf_diff')
					th I18n.t('search_labels.lektor')
					pod.each do |p|
						next if p.statustitelei.status.eql? I18n.t('scopes_names.fertig_filter')
						tr ''
						td link_to(p.buch.isbn, "/admin/tits/#{p.id}") rescue td "<empty>"
						td p.projektname
						td tagged_prio(p)
						td status_tag(p.statustitelei.status)
						td p.final_deadline
						td (p.final_deadline - Date.yesterday).to_i
						td p.buch.lektor.name rescue td "<empty>"
					end
				end
			end
		end

		if dep.include? 'Satz' or dep.include? 'Superadmin'
			panel I18n.t('headlines.lek_pod') do
				table do
					pod = Projekt.ransack(final_deadline_gt: Date.yesterday).result.map
					pod = pod.sort_by { |v| v.final_deadline }
					pod.sort! &z_top_prio
					pod.delete_if { |p| p.satzproduktion == false }
					th I18n.t('buecher_names.isbn')
					th I18n.t('gprod_names.projektname')
					th I18n.t('gprod_names.prio')
					th I18n.t('status_names.statussatz')
					th I18n.t('gprod_names.final_deadline')
					th I18n.t('gprod_names.satz_deadline')
					th I18n.t('search_labels.lektor')
					pod.each do |p|
						next if p.statussatz.status.eql? I18n.t('scopes_names.fertig_filter')
						tr ''
						td link_to(p.buch.isbn, "/admin/s_reifs/#{p.id}") rescue td "<empty>"
						td p.projektname
						td tagged_prio(p)
						td status_tag(p.statussatz.status)
						td p.final_deadline
						td p.satz_deadline
						td p.buch.lektor.name rescue td "<empty>"
					end
				end
			end
		end

		if dep.include? 'Pod' or dep.include? 'Superadmin'
			panel I18n.t('headlines.lek_pod') do
				table do
					pod = Projekt.ransack(final_deadline_gt: Date.yesterday).result.map
					pod = pod.sort_by { |v| v.final_deadline }
					pod.sort! &z_top_prio
					th I18n.t('buecher_names.isbn')
					th I18n.t('gprod_names.projektname')
					th I18n.t('gprod_names.prio')
					th I18n.t('status_names.statusdruck')
					th I18n.t('gprod_names.final_deadline')
					th I18n.t('gprod_names.druck_deadline')
					th I18n.t('search_labels.lektor')
					pod.each do |p|
						next if p.statusdruck.status.eql? I18n.t('scopes_names.fertig_filter')
						tr ''
						td link_to(p.buch.isbn, "/admin/s_reifs/#{p.id}") rescue td "<empty>"
						td p.projektname
						td tagged_prio(p)
						td status_tag(p.statusdruck.status)
						td p.final_deadline
						td p.druck_deadline
						td p.buch.lektor.name rescue td "<empty>"
					end
				end
			end
		end

		if dep.include? 'PrePs' or dep.include? 'Superadmin'
			panel I18n.t('headlines.lek_pod') do
				table do
					pod = Projekt.ransack(final_deadline_gt: Date.yesterday).result.map
					pod = pod.sort_by { |v| v.final_deadline }
					pod.sort! &z_top_prio
					th I18n.t('buecher_names.isbn')
					th I18n.t('gprod_names.projektname')
					th I18n.t('gprod_names.prio')
					th I18n.t('status_names.statuspreps')
					th I18n.t('gprod_names.final_deadline')
					th I18n.t('gprod_names.preps_deadline')
					th I18n.t('search_labels.lektor')
					pod.each do |p|
						next if p.statuspreps.status.eql? I18n.t('scopes_names.fertig_filter')
						tr ''
						td link_to(p.buch.isbn, "/admin/s_reifs/#{p.id}") rescue td "<empty>"
						td p.projektname
						td tagged_prio(p)
						td status_tag(p.statuspreps.status)
						td p.final_deadline
						td p.preps_deadline
						td p.buch.lektor.name rescue td "<empty>"
					end
				end
			end
		end

  end # content
end
