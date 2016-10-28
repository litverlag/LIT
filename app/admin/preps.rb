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

      respond_to do |format|
        format.js{
          @projekt.update(permitted_params[:gprod])
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

  index title: I18n.t("gprod_names.preps_preps"), download_links: [:odt, :csv] do
		column I18n.t("status_names.statuspreps") do |p|
			status_tag(p.statuspreps.status)
		end
    column I18n.t("gprod_names.projektname"), sortable: :projektname do |p|
      p.projektname
    end
		column I18n.t("buecher_names.isbn") do |p|
			p.buch.isbn unless p.buch.nil?
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
		column I18n.t("search_labels.lektor") do |p|
			p.buch.lektor.name unless p.buch.lektor.nil? unless p.buch.nil?
		end
		column I18n.t("gprod_names.preps_bemerkungen") do |p|
			p.preps_bemerkungen
		end
		column I18n.t("gprod_names.lektor_bemerkungen_public") do |p|
			p.lektor_bemerkungen_public
		end

    actions
  end

	filter :final_deadline
	filter :preps_deadline
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
