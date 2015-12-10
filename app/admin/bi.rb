ActiveAdmin.register Bi do
  menu label: 'Bi'
  menu priority: 15
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





    def edit

      @projekt = Gprod.find(permitted_params[:id])


    end

    def update
      puts "______________BINDEREI______UPDATE___________________-"
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

  index title: 'Binderei' do
    column('Status') {|bi| status_tag(bi.statusbinderei.status)}
    column :projektname
    actions
  end

  show do
    render partial: "bindereiShow"
  end

  form partial: 'bindereiInput'


end
