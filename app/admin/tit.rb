ActiveAdmin.register Tit do
  menu label: 'Titelei'
  #menu priority: 6
  config.filters = true
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
    include StatusLogic, PrintReport


    def permitted_params
         params.permit!
    end


    def show
      #departement is set to choose the right department for the Show / Edit View
      @department = "titelei"
      puts "______________TITLEI______SHOW___________________-"
      @projekt = Gprod.find(permitted_params[:id])
    end





    def edit
      puts "______________TITLEI______EDIT___________________-"
      # This variable decides how the view is rendered, depending on the *_settings.yml in conf
      @department = "titelei"
      @projekt = Gprod.find(permitted_params[:id])

    end

    def update
      puts "______________TITLEI______UPDATE___________________-"
      @projekt = Gprod.find(permitted_params[:id])
			begin
				@projekt.update!(permitted_params[:gprod])
			rescue ActiveRecord::RecordInvalid
				redirect_to "/admin/tits/#{@projekt.id}/edit"
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
        format.odt {print_report("titelei_report", method(:titelei))}
      end
    end

  end


  index title: I18n.t("gprod_names.titelei_titelei"), download_links: [:odt, :csv] do
		column I18n.t("status_names.statustitelei") do |p|
			status_tag(p.statustitelei.status)
		end
		column I18n.t("gprod_names.projektname"), sortable: :projektname do |p|
			link_to(p.projektname, "/admin/tits/#{p.id}")
		end
		column I18n.t("buecher_names.isbn") do |p|
			raw "#{p.buch.isbn.gsub('-', '&#8209;')}" rescue '-'
		end
		column I18n.t("search_labels.lektor") do |p|
			p.buch.lektor.name unless p.buch.lektor.nil? unless p.buch.nil?
		end
		column I18n.t("gprod_names.final_deadline"), sortable: :final_deadline do |p|
			raw "<div class='deadline'>#{p.final_deadline}</div>"
		end
		column I18n.t("gprod_names.titelei_deadline"), sortable: :titelei_deadline do |p|
			raw "<div class='deadline'>#{p.titelei_deadline}</div>"
		end
		column I18n.t("gprod_names.titelei_versand_datum_fuer_ueberpr"), 
			sortable: :titelei_versand_datum_fuer_ueberpr do |p|
			p.titelei_versand_datum_fuer_ueberpr
		end
		column I18n.t("gprod_names.titelei_korrektur_date"), 
		 sortable: :titelei_korrektur_date	do |p|
			p.titelei_korrektur_date
		end
		column I18n.t("gprod_names.titelei_freigabe_date"), 
		 sortable: :titelei_freigabe_date	do |p|
			p.titelei_freigabe_date
		end
		column I18n.t("gprod_names.titelei_zusaetze") do |p|
			p.titelei_zusaetze
		end
		column I18n.t("gprod_names.titelei_bemerkungen") do |p|
			p.titelei_bemerkungen
		end
		column I18n.t("gprod_names.projekt_email_adresse"), 
		 sortable: :projekt_email_adresse	do |p|
			p.projekt_email_adresse
		end
  end

	filter :buch_isbn_cont, as: :string, label: I18n.t('buecher_names.isbn')
  filter :projekt_email_adresse
	filter :projektname
	filter :titelei_bemerkungen
	filter :lektor_bemerkungen_public
	filter :final_deadline
	filter :titelei_deadline
	filter :satz_deadline
	filter :final_deadline_not_null, as: :string, label: 'sollf present'

  show do
    render partial: "show_view"
  end

  form partial: 'newInput'

end
