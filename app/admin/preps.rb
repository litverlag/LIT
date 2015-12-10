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

      @projekt = Gprod.find(permitted_params[:id])


    end

    def update
      puts "______________PREPS______UPDATE___________________-"
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

  index title: 'Preps' do
    column('Status') {|preps| status_tag(preps.statuspreps.status)}
    column :projektname
    actions
  end

  show do
    render partial: "prepsShow"
  end


  form partial: 'prepsInput'


end
