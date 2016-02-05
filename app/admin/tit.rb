ActiveAdmin.register Tit do
  menu label: 'Titelei'
  #menu priority: 6
  config.filters = false
  actions :index, :show, :edit, :update

  scope (I18n.t("scopes_names.fertig_filter")), :fertig_filter
  scope (I18n.t("scopes_names.bearbeitung_filter")), :bearbeitung_filter
  scope (I18n.t("scopes_names.neu_filter")), :neu_filter
  scope (I18n.t("scopes_names.problem_filter")), :problem_filter


  controller do

    include StatusLogic

    def permitted_params
         params.permit!
       end


    def show
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

  end


  index title: 'Titelei' do
    column('Status') {|tit| status_tag tit.statustitelei.status}
    column :projektname
    actions
  end

  show do
    render partial: "titeleiShow"
  end

  form partial: 'newInput'

end
