ActiveAdmin.register SReif do
  menu label: 'SReif'
  menu priority: 4
  config.filters = false
  actions :index, :show, :edit, :update
  menu false
  controller do

    include StatusLogic

    def permitted_params
      params.permit!
    end


    def show
      puts "______________SREIF______SHOW___________________-"
      @projekt = Gprod.find(permitted_params[:id])
    end





    def edit

      @projekt = Gprod.find(permitted_params[:id])


    end

    def update
      puts "______________SREIF_____UPDATE___________________-"
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

  index title: 'Satz' do
    column('Status') {|satz| status_tag(satz.statussatz.status)}
    column :projektname
    actions
  end

  show do
    render partial: "satzShow"
  end

  form partial: 'satzInput'


end
