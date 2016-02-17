ActiveAdmin.register Preps do
  menu label: 'Preps'
  menu priority: 13
  config.filters = false
  actions :index, :show, :edit, :update

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

  index title: 'Preps', download_links: [:odt] do

    @test = [:projektname, :projekt_email_adresse]
    column('Status') {|preps| status_tag(preps.statuspreps.status)}
    @test.each do |value|
    column value
    end
    actions
  end

  show do
    render partial: "show_view"
  end




  form partial: 'newInput'


end
