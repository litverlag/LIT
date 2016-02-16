ActiveAdmin.register Tit do
  menu label: 'Tit'
  menu priority: 6
  config.filters = false
  actions :index, :show, :edit, :update


  controller do

    include StatusLogic, PrintReport

    def permitted_params
         params.permit!
       end


    def show
      puts "______________TITLEI______SHOW___________________-"
      @projekt = Gprod.find(permitted_params[:id])
    end





    def edit

      @projekt = Gprod.find(permitted_params[:id])


    end

    def update
      puts "______________TITLEI______UPDATE___________________-"
      @projekt = Gprod.find(permitted_params[:id])

      respond_to do |format|
        format.js{
          if permitted_params[:status]
            @projekt = Gprod.find(params[:id])
            changeStatusByUser(@projekt, @projekt.statustitelei, permitted_params[:status][:statustitelei])
            @projekt.save
          end

          render "_titeleiShow.js.erb"
        }
      end
    end

    ##
    # Match download link with corresponding method which generates the output
    # in this case we use print_report for the .odt output
    def index
      super do |format|#index!, html
        format.odt {print_report("titelei_report", method(:titelei))}
      end
    end

  end


  index title: 'Titelei', download_links: [:odt] do
    column('Status') {|tit| status_tag tit.statustitelei.status}
    column :projektname
    actions
  end

  show do
    render partial: "titeleiShow"
  end

  form partial: 'titeleiInput'

end
