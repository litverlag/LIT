ActiveAdmin.register Preps do
  menu label: 'Preps'
  menu priority: 13
  config.filters = false
  actions :index, :show, :edit, :update


  controller do

    include StatusLogic

    def permitted_params
      params.permit!
    end


    def show
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
  end

  index title: 'Preps' do

    @test = [:projektname, :projekt_email_adresse]
    column('Status') {|preps| status_tag(preps.statuspreps.status)}
    @test.each do |value|
    column value
    end
    actions
  end

  show do
    render partial: "prepsShow"
  end




  form partial: 'newInput'


end
