ActiveAdmin.register Bi do
  menu label: 'Binderei'
  #menu priority: 15
  config.filters = false
  actions :index, :show, :edit, :update

  controller do

    include StatusLogic

    def permitted_params
      params.permit!
    end

    def show
      puts "______________BINDEREI______SHOW___________________-"
      @projekt = Gprod.find(permitted_params[:id])
    end

    def edit# This variable decides how the view is rendered, depending on the *_settings.yml in conf
      @department = "binderei"
      @projekt = Gprod.find(permitted_params[:id])
    end

    def update
      puts "______________BINDEREI______UPDATE___________________-"
      @projekt = Gprod.find(permitted_params[:id])

      respond_to do |format|
        format.js{

          @projekt.update permitted_params[:gprod]

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

  index title: 'Binderei' do
    column('Status') {|bi| status_tag(bi.statusbinderei.status)}
    column :projektname
    actions
  end

  show do
    render partial: "bindereiShow"
  end

  form partial: 'newInput'


end
