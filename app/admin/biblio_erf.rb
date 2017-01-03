ActiveAdmin.register BiblioErf do
  menu
  config.filters = true
  actions :index, :show, :edit, :update

  scope (I18n.t("scopes_names.alle_filter")), :alle_filter
  scope (I18n.t("scopes_names.verschickt_filter")), :verschickt_filter
  scope (I18n.t("scopes_names.fertig_filter")), :fertig_filter
  scope (I18n.t("scopes_names.bearbeitung_filter")), :bearbeitung_filter
  scope (I18n.t("scopes_names.neu_filter")), :neu_filter
  scope (I18n.t("scopes_names.problem_filter")), :problem_filter

	controller do
    include StatusLogic, PrintReport

    def permitted_params
      params.permit!
    end

    def show
      @department = "BiblioErf"
      @projekt = Gprod.find(permitted_params[:id])
    end

    def edit
      @department = "BiblioErf"
      @projekt = Gprod.find(permitted_params[:id])
    end

    def update
      @projekt = Gprod.find(permitted_params[:id])
			begin
				@projekt.update!(permitted_params[:gprod]) if permitted_params[:gprod]
				#@projekt.update!(permitted_params[:buch]) if permitted_params[:buch]
			rescue ActiveRecord::RecordInvalid
				redirect_to "/admin/biblio_erf/#{@projekt.id}/edit"
				flash[:alert] = I18n.t 'flash_notice.revised_failure.new_project_invalid'
				return
			end
      respond_to do |format|
        format.js{
          @projekt = Gprod.find(permitted_params[:id])
          if permitted_params[:status]
            permitted_params[:status].each do  |status_key,status_value|
              changeStatusByUser(@projekt, @projekt.send(status_key), status_value)
            end
          end
          render '_new_Input_response.js.erb'
        }
      end
    end

		def index
			super { |format| format.odt {print_report("biblio_erf_report", method(:biblio_erf))} }
		end
  end

  index do
    column('Status') {|s| status_tag(s.statusbiblioerf.status)}
		column I18n.t("gprod_names.projektname"), sortable: :projektname do |p|
			link_to(p.projektname, "/admin/biblio_erf/#{p.id}")
		end
		column I18n.t("buecher_names.isbn") do |p|
			raw p.buch.isbn.gsub('-', '&#8209;') rescue '-'
		end
		column I18n.t("gprod_names.prio"), sortable: :prio do |p|
			p.prio
		end
		column I18n.t("search_labels.lektor") do |p|
			p.buch.lektor.name rescue '-'
		end

		#		Dont know if we need this. DB entries dont exist yet.
#		column I18n.t("gprod_names.biblio_erf_bemerkungen") do |p|
#			p.biblio_erf_bemerkungen
#		end
#		column I18n.t("gprod_names.biblio_erf_verschickt"), sortable: :biblio_erf_verschickt do |p|
#			p.biblio_erf_verschickt
#		end

		#		Dont know if we need this. DB entries dont exist yet.
#		column I18n.t("gprod_names.biblio_erf_finished"), sortable: :biblio_erf_finished do |p|
#			raw "<div class='deadline'>#{p.biblio_erf_finished}</div>"
#		end
#		column I18n.t("gprod_names.biblio_erf_deadline"), sortable: :biblio_erf_deadline do |p|
#			raw "<div class='deadline'>#{p.biblio_erf_deadline}</div>"
#		end
#		column I18n.t("gprod_names.final_deadline"), sortable: :final_deadline do |p|
#			raw "<div class='deadline'>#{p.final_deadline}</div>"
#		end
  end

	filter :biblio_erf
	filter :final_deadline
#	filter :biblio_erf_deadline
	filter :buch_isbn_cont, as: :string, label: I18n.t('buecher_names.isbn')
	filter :projektname
	filter :prio
  filter :projekt_email_adresse

  show do
    render partial: "show_view"
  end

  form partial: 'newInput'
end
