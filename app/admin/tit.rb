ActiveAdmin.register Tit do
  menu label: 'Titelei'
  #menu priority: 6
  config.filters = false
  actions :index, :show, :edit, :update


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
      @array_of_format_bezeichungen = ChoosableOption.instance.format :all
      @array_of_umschlag_bezeichnungen = ChoosableOption.instance.umschlag :all
      @array_of_papier_bezeichungen = ChoosableOption.instance.papier :all

    end

    def update
      puts "______________TITLEI______UPDATE___________________-"
      @projekt = Gprod.find(permitted_params[:id])

      respond_to do |format|
        format.js{
          puts permitted_params
          @projekt.update(permitted_params[:gprod])
          if permitted_params[:status]
            @projekt = Gprod.find(params[:id])
            changeStatusByUser(@projekt, @projekt.statustitelei, permitted_params[:status][:statustitelei])
            @projekt.save
          end

          render "_titeleiShow.js.erb"
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
