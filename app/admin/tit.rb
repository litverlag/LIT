ActiveAdmin.register Tit do
  menu label: 'Tit'
  menu priority: 6
  config.filters = false
  actions :index, :show, :edit, :update

  controller do

    include StatusLogic

    def permitted_params
         params.permit!
       end


    ##
    # TEST TEST TEST
    def edit
      @projekt = Gprod.find(params[:id])
      changeStatusByUser(@projekt, @projekt.statuspreps, "fertig")
    end

  end


  index title: 'Titelei' do
    column('Status') {|tit| tit.statustitelei.status}
    column :projektname

    actions
  end

  show do
    render :partial
  end

end
