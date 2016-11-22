ActiveAdmin.register SReif do
  menu label: 'SReif'
  menu priority: 4
  #config.filters = true
  config.filters = true
  actions :index, :show, :edit, :update
	config.sort_order = 'final_deadline_asc'
  menu
  
  #scopes -> filter the viewable project in the table
  scope (I18n.t("scopes_names.alle_filter")), :alle_filter
  scope (I18n.t("scopes_names.fertig_filter")), :fertig_filter
  scope (I18n.t("scopes_names.bearbeitung_filter")), :bearbeitung_filter
  scope (I18n.t("scopes_names.verschickt_filter")), :verschickt_filter
  scope (I18n.t("scopes_names.neu_filter")), :neu_filter
  scope (I18n.t("scopes_names.problem_filter")), :problem_filter

  controller do

    #from models/concerns
    #ACHTUNG: SATZ IS FOR NOW NOT IMPLEMENTED IN THE STATUS LOGIC
    include StatusLogic

    def permitted_params
      params.permit!
    end


    def show
      #departement is set to choose the right department for the Show / Edit View
      @department = "satz"
      puts "______________SREIF______SHOW___________________-"
      @projekt = Gprod.find(permitted_params[:id])
    end





    def edit
      # This variable decides how the view is rendered, depending on the *_settings.yml in conf
      @department = "satz"
      @projekt = Gprod.find(permitted_params[:id])


    end

    def update
      puts "______________SREIF_____UPDATE___________________-"
      @projekt = Gprod.find(permitted_params[:id])

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

  end

  index title: 'Satz' do
		column I18n.t("status_names.statussatz") do |p|
			status_tag(p.statussatz.status)
		end
    column I18n.t("gprod_names.projektname"), sortable: :projektname do |p|
			link_to(p.projektname, "/admin/s_reifs/#{p.id}")
    end
		column I18n.t("buecher_names.isbn") do |p|
			raw p.buch.isbn.gsub('-', '&#8209;') unless p.buch.nil?
		end
		column I18n.t("gprod_names.final_deadline"), sortable: :final_deadline do |p|
			raw "<div class='deadline'>#{p.final_deadline}</div>"
		end
		column I18n.t("gprod_names.satz_deadline"), sortable: :satz_deadline do |p|
			raw "<div class='deadline'>#{p.satz_deadline}</div>"
		end
		column I18n.t("search_labels.lektor") do |p|
			p.buch.lektor.name unless p.buch.lektor.nil? unless p.buch.nil?
		end
		column I18n.t("gprod_names.lektor_bemerkungen_public") do |p|
			p.lektor_bemerkungen_public
		end
		column I18n.t('gprod_names.satzproduktion'), sortable: :satzproduktion do |p|
			p.satzproduktion
		end
    #actions
  end

	filter :satzproduktion, as: :select
	filter :buch_isbn_cont, as: :string, label: I18n.t('buecher_names.isbn')
	filter :statusumschl_status, as: :select, 
		collection: proc {$UMSCHL_STATUS}, label: I18n.t('status_names.statusumschl')
	filter :lektor
	filter :projektname
	filter :final_deadline
	filter :satz_deadline

  show do
    render partial: "show_view"
  end

  form partial: 'newInput'


end
