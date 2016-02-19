ActiveAdmin.register SReif do
  menu label: 'SReif'
  menu priority: 4
  config.filters = false
  actions :index, :show, :edit, :update
  menu
  
  scope (I18n.t("scopes_names.alle_filter")), :alle_filter
  scope (I18n.t("scopes_names.fertig_filter")), :fertig_filter
  scope (I18n.t("scopes_names.bearbeitung_filter")), :bearbeitung_filter
  scope (I18n.t("scopes_names.verschickt_filter")), :verschickt_filter
  scope (I18n.t("scopes_names.neu_filter")), :neu_filter
  scope (I18n.t("scopes_names.problem_filter")), :problem_filter

  
  controller do

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
    column('Status') {|satz| status_tag(satz.statussatz.status)}
    column :projektname
    actions
  end

  show do
    render partial: "show_view"
  end

  form partial: 'newInput'


end
