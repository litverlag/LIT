ActiveAdmin.register Preps do
  menu label: 'Preps'
  menu priority: 13
  config.filters = true
	config.sort_order = 'final_deadline_asc'
  actions :index, :show, :edit, :update

  #scopes -> filter the viewable project in the table
  scope (I18n.t("scopes_names.alle_filter")), :alle_filter
  scope (I18n.t("scopes_names.fertig_filter")), :fertig_filter
  scope (I18n.t("scopes_names.bearbeitung_filter")), :bearbeitung_filter
  scope (I18n.t("scopes_names.verschickt_filter")), :verschickt_filter
  scope (I18n.t("scopes_names.neu_filter")), :neu_filter
  scope (I18n.t("scopes_names.problem_filter")), :problem_filter

  controller do

    #from models/concerns
    include StatusLogic

    # inlcude external stuff for sorting in the index view
		def scoped_collection
      super.includes [ :statussatz, :lektor ]
		end

    def permitted_params
      params.permit!
    end


    def show
      #departement is set to choose the right department for the Show / Edit View
      @department = "preps"
      puts "______________PREPS______SHOW___________________-"
      @projekt = Gprod.find(permitted_params[:id])
    end





    def edit
      # This variable decides how the view is rendered, depending on the *_settings.yml in conf
      @department = "preps"
      @projekt = Gprod.find(permitted_params[:id])


    end

    def update
      puts "______________PREPS______UPDATE___________________-"
      @projekt = Gprod.find(permitted_params[:id])
			begin
				@projekt.update!(permitted_params[:gprod])
			rescue ActiveRecord::RecordInvalid
				redirect_to "/admin/preps/#{@projekt.id}/edit"
				flash[:alert] = I18n.t 'flash_notice.revised_failure.new_project_invalid'
				return
			end

      respond_to do |format|
        format.js{
          #Part to update the status
          if permitted_params[:status]
            permitted_params[:status].each do  |status_key,status_value|
              changeStatusByUser(@projekt, @projekt.send(status_key), status_value)
            end
          end

          render '_new_Input_response.js.erb'
        }
      end
    end


    ##
    # Match download link with corresponding method which generates the output
    # in this case we use print_report for the .odt output
    def index
      super do |format|#index!, html
        format.odt {print_report("preps_report", method(:preps))}
      end
    end
  end

  index title: I18n.t("headlines.preps_preps"), download_links: [:odt, :csv] do
		column I18n.t("status_names.statuspreps"), sortable: 'status_preps.status' do |p|
			status_tag(p.statuspreps.status)
		end
		column I18n.t("gprod_names.projektname"), sortable: :projektname do |p|
			link_to(p.projektname, "/admin/preps/#{p.id}")
		end
		column I18n.t("buecher_names.isbn") do |p|
			raw p.buch.isbn.gsub('-', '&#8209;') rescue '-'
		end
		column I18n.t("gprod_names.final_deadline"), sortable: :final_deadline do |p|
			raw "<div class='deadline'>#{p.final_deadline}</div>"
		end
		column I18n.t("gprod_names.preps_deadline"), sortable: :preps_deadline do |p|
			raw "<div class='deadline'>#{p.preps_deadline}</div>"
		end
		column I18n.t('gprod_names.muster_art') do |p|
			p.muster_art
		end
		column I18n.t("search_labels.lektor"), sortable: 'lektoren.name' do |p|
			p.lektor.fox_name rescue '-'
		end
		column I18n.t("gprod_names.preps_bemerkungen") do |p|
			p.preps_bemerkungen
		end
		column I18n.t("gprod_names.lektor_bemerkungen_public") do |p|
			p.lektor_bemerkungen_public
		end
  end

	filter :final_deadline
	filter :preps_deadline
	filter :satzproduktion
	filter :lektor_id_eq, as: :select, collection: proc {Lektor.all}, label: 'Lektoren'
	filter :buch_isbn_cont, as: :string, label: I18n.t('buecher_names.isbn')
	filter :statussatz_status, as: :select, 
		collection: proc {$SATZ_STATUS}, label: I18n.t('status_names.statussatz')
  filter :projekt_email_adresse
	filter :projektname
	filter :buch_reihen_name_cont, as: :string, label: I18n.t('buecher_names.r_code')

  show do
    render partial: "show_view"
  end




  form partial: 'newInput'


end
