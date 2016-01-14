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

      @projekt = Gprod.find(permitted_params[:id])


    end

    def update
      puts "______________OFFSCH______UPDATE___________________-"
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

  index title: 'Offsch' do
    column('Status') {|offsch| status_tag(offsch.statusoffsch.status)}
    column :projektname
    actions
  end

  show do
    render partial: "offschShow"
  end

  form partial: 'offschInput'

end
