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
  config.filters = false
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
    column :projektname
    actions
  end


  show do
    render partial: "show_view"

  end

  form partial: 'newInput'


end
