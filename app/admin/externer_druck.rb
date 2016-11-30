ActiveAdmin.register ExternerDruck do
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
      @department = "ExternerDruck"
      @projekt = Gprod.find(permitted_params[:id])
    end

    def edit
      @department = "ExternerDruck"
      @projekt = Gprod.find(permitted_params[:id])
    end

    def update
      @projekt = Gprod.find(permitted_params[:id])
			begin
				@projekt.update!(permitted_params[:gprod]) if permitted_params[:gprod]
				#@projekt.update!(permitted_params[:buch]) if permitted_params[:buch]
			rescue ActiveRecord::RecordInvalid
				redirect_to "/admin/externer_druck/#{@projekt.id}/edit"
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
			super { |format| format.odt {print_report("ext_druck_report", method(:externer_druck))} }
		end
  end

  index do
    column('Status') {|druck| status_tag(druck.statusexternerdruck.status)}
		column I18n.t("status_names.statuspreps") do |p|
			status_tag(p.statuspreps.status) rescue '-'
		end
		column I18n.t("status_names.statusumschl") do |p|
			status_tag(p.statusumschl.status)
		end
		column I18n.t("buecher_names.umschlag_bezeichnung") do |p|
			p.buch.umschlag_bezeichnung rescue '-'
		end
		column I18n.t("gprod_names.projektname"), sortable: :projektname do |p|
			link_to(p.projektname, "/admin/externer_druck/#{p.id}")
		end
		column I18n.t("buecher_names.isbn") do |p|
			raw p.buch.isbn.gsub('-', '&#8209;') rescue '-'
		end
		column I18n.t("gprod_names.auflage") do |p|
			p.auflage
		end
		column I18n.t("buecher_names.bindung_bezeichnung") do |p|
			p.buch.bindung_bezeichnung rescue '-'
		end
		column I18n.t("gprod_names.prio"), sortable: :prio do |p|
			p.prio
		end
		column I18n.t("search_labels.lektor") do |p|
			p.buch.lektor.name rescue '-'
		end
		column I18n.t("gprod_names.final_deadline"), sortable: :final_deadline do |p|
			raw "<div class='deadline'>#{p.final_deadline}</div>"
		end
		column I18n.t("gprod_names.externer_druck_deadline"), sortable: :final_deadline do |p|
			raw "<div class='deadline'>#{p.externer_druck_deadline}</div>"
		end
		column I18n.t("gprod_names.externer_druck_finished"), sortable: :final_deadline do |p|
			raw "<div class='deadline'>#{p.externer_druck_finished}</div>"
		end
		column I18n.t("gprod_names.externer_druck_bemerkungen"), sortable: :final_deadline do |p|
			raw "<div class='deadline'>#{p.externer_druck_bemerkungen}</div>"
		end
  end

	filter :final_deadline
	filter :externer_druck_deadline
	filter :buch_bindung_bezeichnung, as: :select, 
		collection: proc{ChoosableOption.instance.bindung_bezeichnung :all}, 
		label: I18n.t('buecher_names.bindung_bezeichnung')
	filter :statusumschl_status_eq, as: :select, 
		collection: proc {$UMSCHL_STATUS}, label: I18n.t('status_names.statusumschl')
	filter :statusumschl_status_not_eq, as: :select, 
		collection: proc {$UMSCHL_STATUS}, label: I18n.t('status_names.nstatusumschl')
	filter :statuspreps_status_eq, as: :select, 
		collection: proc {$PREPS_STATUS}, label: I18n.t('status_names.statuspreps')
	filter :buch_isbn_cont, as: :string, label: I18n.t('buecher_names.isbn')
	filter :projektname
	filter :prio
  filter :projekt_email_adresse

  show do
    render partial: "show_view"
  end

  form partial: 'newInput'
end
