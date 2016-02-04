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

  controller do

    include StatusLogic


    def permitted_params
      params.permit!
    end


    def show
      puts "______________DRUCK______SHOW___________________-"
      @projekt = Gprod.find(permitted_params[:id])
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
    column :projektname
    actions
  end


  show do
    render partial: "show_view"

  end

  form partial: 'newInput'


end
