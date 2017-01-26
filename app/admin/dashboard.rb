ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

		##
    # The argument here was, if this view is nice, we dont need to print those
    # lists for everyone (ask Michael if you don't know what i'm talking
    # about), as people see what they have to do without klicking anything. I
    # expected to need more diversity for the different departments, thus this
    # is very verbose.
    #
    ##
    # Note that we filter the Lektor list by the email address, as the Lektoren
    # have their name in it.
    #
    # Note that we do the same for the Umschlag-Leute.
    # (design@.. umschlag@..)

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
								or not p.statusfinal.freigabe rescue false
						}
					end
					th I18n.t('gprod_names.projektname')
					th I18n.t('gprod_names.prio')
					th I18n.t('gprod_names.final_deadline')
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
						td p.final_deadline
						td status_tag(p.statusbinderei.status)
						td status_tag(p.statusdruck.status)
						if p.externer_druck
							td "extern #{p.buch.bindung_bezeichnung}" rescue td 'extern'
						else
							td '-'
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
          # Here it is.
					if /(tex|umschlag)/.match(current_admin_user.email) or /admin/.match(current_admin_user.email)
						pod.delete_if { |p|
							p.buch.umschlag_bezeichnung == I18n.t('um_names.indesign') \
                or p.statusumschl.freigabe rescue true
						}
					elsif /i?n?design/.match(current_admin_user.email)
						pod.delete_if { |p|
							p.buch.umschlag_bezeichnung == I18n.t('um_names.tex') rescue true
						}
					end
					th I18n.t('buecher_names.isbn')
					th I18n.t('gprod_names.projektname')
          th I18n.t('buecher_names.umschlag_bezeichnung')
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
            td p.buch.umschlag_bezeichnung rescue '<kein Buch verlinkt>'
						td tagged_prio(p)
						td status_tag(p.statusumschl.status)
						td p.final_deadline
						td p.umschlag_deadline
						td p.lektor.name rescue td "<kein Lektor verlinkt>"
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
					pod.delete_if { |p| p.satzproduktion == false or not p.statussatz.freigabe }
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
			panel I18n.t('headlines.druck_pod') do
				table do
					pod = Projekt.ransack(final_deadline_gt: Date.yesterday).result.map
					pod = pod.sort_by { |v| v.final_deadline }
					pod.delete_if { |p| 
						p.buch.bindung_bezeichnung != I18n.t('bi_names.k') \
              or p.externer_druck rescue false 
					}
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
						td link_to(p.buch.isbn, "/admin/druck/#{p.id}") rescue td "<empty>"
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

		if dep.include? 'ExternerDruck' or dep.include? 'Superadmin'
			panel 'Aktuelle Externe Werke zum ExternenDruck' do
				table do
					pod = Projekt.ransack(final_deadline_gt: Date.yesterday).result.map
					pod = pod.sort_by { |v| v.final_deadline }
					pod.delete_if { |p| 
						p.buch.bindung_bezeichnung == I18n.t('bi_names.k') rescue false 
					}
					pod.sort! &z_top_prio
					th I18n.t('buecher_names.isbn')
					th I18n.t('gprod_names.projektname')
					th I18n.t('gprod_names.prio')
					th I18n.t('status_names.statusexternerdruck')
					th I18n.t("gprod_names.externer_druck_verschickt")
					th I18n.t("gprod_names.externer_druck_finished")
					th I18n.t("gprod_names.externer_druck_deadline")
					th I18n.t('gprod_names.final_deadline')
					pod.each do |p|
						next if p.statusexternerdruck.status.eql? I18n.t('scopes_names.fertig_filter')
						tr ''
						td link_to(p.buch.isbn, "/admin/druck/#{p.id}") rescue td "<empty>"
						td p.projektname
						td tagged_prio(p)
						td status_tag(p.statusexternerdruck.status)
						td p.externer_druck_verschickt
						td p.externer_druck_finished
						td p.externer_druck_deadline
						td p.final_deadline
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
						td link_to(p.buch.isbn, "/admin/preps/#{p.id}") rescue td "<empty>"
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
