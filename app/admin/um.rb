ActiveAdmin.register Um do
  menu label: 'Umschlag'
  #menu priority: 5
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
    include StatusLogic, PrintReport



    def permitted_params
      params.permit!
    end


    def show
      #departement is set to choose the right department for the Show / Edit View
      @department = "umschlag"
      @projekt = Gprod.find(permitted_params[:id])

			# Computing the backsize. Should probably be moved to projekt change
			# submission, to be called less often. FIXME
			unless @projekt.buch.nil?
				bz = @projekt.buch.backsize()
				@projekt.buch.update({:rueckenstaerke => bz}) unless bz.nil?
			end
    end

    def edit

      # This variable decides how the view is rendered, depending on the *_settings.yml in conf
      @department = "umschlag"
      @projekt = Gprod.find(permitted_params[:id])


    end

    def update
      @projekt = Gprod.find(permitted_params[:id])

      respond_to do |format|

        format.js{
					#check_constraints(permitted_params[:gprod])
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
        format.odt {print_report("umschlag_report", method(:umschlag))}
      end
    end

  end

  index title: I18n.t("gprod_names.umschlag_umschlag"), download_links: [:odt, :csv] do
		column I18n.t("status_names.statusumschl") do |p|
			status_tag(p.statusumschl.status)
		end
		column I18n.t("status_names.statussatz") do |p|
			status_tag(p.statussatz.status)
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
		column I18n.t("gprod_names.umschlag_deadline"), sortable: :umschlag_deadline do |p|
			raw "<div class='deadline'>#{p.umschlag_deadline}</div>"
		end
		column I18n.t("buecher_names.r_code") do |p|
			p.buch.reihen.first unless p.buch.nil?
		end
		column I18n.t("search_labels.lektor") do |p|
			p.buch.lektor.name unless p.buch.lektor.nil? unless p.buch.nil?
		end
		column I18n.t("gprod_names.projekt_email_adresse") do |p|
			p.projekt_email_adresse
		end
		column I18n.t("gprod_names.umschlag_bemerkungen") do |p|
			p.umschlag_bemerkungen
		end
		column I18n.t("gprod_names.lektor_bemerkungen_public") do |p|
			p.lektor_bemerkungen_public
		end

    actions
  end

	filter :buch_isbn_cont, as: :string, label: I18n.t('buecher_names.isbn')
	##
	# Not working, but the same is working fine for a 'Projekt'. FIXME
	# The problem is that 'INNER JOIN' in ALL the abteilungs-classes.. because
	# ransack does a 'left join' by default.
	#
	#filter :statusumschl_status, as: :select, 
		#collection: proc {$UMSCHL_STATUS}, label: I18n.t('status_names.statusumschl')

	filter :statussatz_status, as: :select, 
		collection: proc {$SATZ_STATUS}, label: I18n.t('status_names.statussatz')
	filter :buch_umschlag_bezeichnung_eq, 
		as: :select, 
		collection: proc {ChoosableOption.instance.umschlag_bezeichnung :all},
		label: I18n.t('buecher_names.umschlag_bezeichnung')

  filter :projekt_email_adresse
	filter :projektname
	filter :umschlag_deadline
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
