ActiveAdmin.register Um do
  menu label: 'Um'
  menu priority: 5
  config.filters = false
  actions :index, :show, :edit, :update

  controller do

    include StatusLogic

    def permitted_params
      params.permit!
    end


    def show
      puts "______________UMSCHLAG______SHOW___________________-"
      @projekt = Gprod.find(permitted_params[:id])
    end
    
    def edit

      @projekt = Gprod.find(permitted_params[:id])


    end

    def update
      puts "______________UMSCHLAG______UPDATE___________________-"
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

  index title: 'Umschlag' do
    column('Status') {|um| status_tag(um.statusumschl.status)}
    column :projektname
    actions
  end

  show do
    render partial: "umschlagShow"
  end

  form partial: 'umschlagInput'



end
