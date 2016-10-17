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

		if dep.include? 'Umschlag' or dep.include? 'Superadmin'
			columns do
				column do
					panel I18n.t('headlines.um_pod') do
						table do
							pod = Projekt.ransack(final_deadline_gt: Date.today).result.map.sort_by do |v| 
								v.final_deadline 
							end
							th I18n.t('buecher_names.isbn')
							th I18n.t('status_names.statusumschl')
							th I18n.t('gprod_names.final_deadline')
							th I18n.t('gprod_names.umschlag_deadline')
							th I18n.t('gprod_names.projektname')
							th I18n.t('search_labels.lektor')
							pod.each do |p|
								next if p.statusumschl.status.eql? I18n.t('scopes_names.fertig_filter')
								tr ''
								td link_to(p.buch.isbn, "/admin/ums/#{p.id}") unless p.buch.nil?
								td p.statusumschl.status
								td p.final_deadline
								td p.umschlag_deadline
								td p.projektname
								td p.buch.lektor.name unless p.buch.lektor.nil? unless p.buch.nil?
							end	
						end
					end
				end
			end
		end

  end # content
end
