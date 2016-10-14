ActiveAdmin.register Druck do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if resource.something?
#   permitted
# end

  menu
  config.filters = true
  actions :index, :show, :edit, :update
  
  #scopes -> filter the viewable project in the table
  scope (I18n.t("scopes_names.alle_filter")), :alle_filter
  scope (I18n.t("scopes_names.musterdrucken_filter")), :musterdrucken
  scope (I18n.t("scopes_names.nächsterAuftrag_filter")), :nächsterAuftrag
  scope (I18n.t("scopes_names.fertig_filter")), :fertig_filter
  scope (I18n.t("scopes_names.bearbeitung_filter")), :bearbeitung_filter
  scope (I18n.t("scopes_names.neu_filter")), :neu_filter
  scope (I18n.t("scopes_names.problem_filter")), :problem_filter


  controller do

    #from models/concerns
    include StatusLogic


    def permitted_params
      params.permit!
    end


    def show
      puts "______________DRUCK______SHOW___________________-"
      @projekt = Gprod.find(permitted_params[:id])
      @department = "druck"
    end





    def edit

      @projekt = Gprod.find(permitted_params[:id])
      @department = "druck"

    end

    def update
      puts "______________DRUCK______UPDATE___________________-"
      @projekt = Gprod.find(permitted_params[:id])
      respond_to do |format|
        format.js{
          @projekt = Gprod.find(permitted_params[:id])

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

  index do
    column('Status') {|druck| status_tag(druck.statusdruck.status)}
		column I18n.t("status_names.statusumschl") do |p|
			status_tag(p.statusumschl.status)
		end
		column I18n.t("buecher_names.umschlag_bezeichnung") do |p|
			p.buch.umschlag_bezeichnung unless p.buch.nil?
		end
    column :projektname
		column I18n.t("buecher_names.isbn") do |p|
			p.buch.isbn unless p.buch.nil?
		end
		column I18n.t("gprod_names.auflage") do |p|
			p.auflage
		end
		column I18n.t("gprod_names.gesicherte_abnahme") do |p|
			p.gesicherte_abnahme
		end
		column I18n.t("gprod_names.prio"), sortable: :prio do |p|
			p.prio
		end
		column I18n.t("search_labels.lektor") do |p|
			p.buch.lektor.name unless p.buch.lektor.nil? unless p.buch.nil?
		end
		column I18n.t("status_names.statuspreps") do |p|
			status_tag(p.statuspreps.status) unless p.statuspreps.nil?
		end
		column I18n.t("gprod_names.final_deadline"), sortable: :final_deadline do |p|
			raw "<div class='deadline'>#{p.final_deadline}</div>"
		end
    actions
  end

	filter :statusumschl_status_eq, as: :select, 
		collection: proc {$UMSCHL_STATUS}, label: I18n.t('status_names.statusumschl')
	filter :statusumschl_status_not_eq, as: :select, 
		collection: proc {$UMSCHL_STATUS}, label: I18n.t('status_names.nstatusumschl')
	#filter :statusdruck_status_eq, as: :select, 
		#collection: proc {$DRUCK_STATUS}, label: I18n.t('status_names.statusdruck')
	#filter :statusdruck_status_not_eq, as: :select, 
		#collection: proc {$DRUCK_STATUS}, label: I18n.t('status_names.nstatusdruck')
	filter :statuspreps_status_eq, as: :select, 
		collection: proc {$PREPS_STATUS}, label: I18n.t('status_names.statuspreps')

	filter :buch_isbn_cont, as: :string, label: I18n.t('buecher_names.isbn')
	filter :prio
  filter :projekt_email_adresse
	filter :projektname
	filter :umschlag_deadline
	filter :preps_deadline
	filter :binderei_deadline
	filter :final_deadline
	filter :druck_deadline
	filter :titelei_deadline
	filter :satz_deadline

  show do
    render partial: "show_view"

  end

  form partial: 'newInput'


end
