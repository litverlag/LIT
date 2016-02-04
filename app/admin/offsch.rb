ActiveAdmin.register Offsch do
  menu label: 'Offsch'
  menu priority: 14
  config.filters = false
  actions :index, :show, :edit, :update
  menu false
  controller do

    include StatusLogic

    def permitted_params
      params.permit!
    end


    def show
      puts "______________OFFSCH______SHOW___________________-"
      @projekt = Gprod.find(permitted_params[:id])
    end





    def edit

      # This variable decides how the view is rendered, depending on the *_settings.yml in conf
      @department = "Offsch"
      @projekt = Gprod.find(permitted_params[:id])


    end

    def update
      puts "______________OFFSCH______UPDATE___________________-"
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

  index title: 'Offsch' do
    column('Status') {|offsch| status_tag(offsch.statusoffsch.status)}
    column :projektname
    actions
  end

  show do
    render partial: "offschShow"
  end

  form partial: 'newInput'

end
