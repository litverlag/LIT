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


    end

    def update
      puts "______________DRUCK______UPDATE___________________-"
      @projekt = Gprod.find(permitted_params[:id])

      if permitted_params[:status]
        puts permitted_params[:status][:statustitelei]
        @projekt = Gprod.find(params[:id])
        changeStatusByUser(@projekt, @projekt.statustitelei, permitted_params[:status][:statustitelei])
        @projekt.save
      end

      redirect_to collection_path

    end

  end

  index do
    column :projektname
    actions
  end


  show do
    render partial: "druckShow"

  end

  form partial: 'druckInput'


end
