ActiveAdmin.register Um do
  menu label: 'Um'
  menu priority: 5
  config.filters = false
  actions :index, :show, :edit, :update

  controller do

    include StatusLogic, PrintReport

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

      respond_to do |format|

        format.js{
          if permitted_params[:status]
            puts permitted_params[:status][:statusumschlag]
            @projekt = Gprod.find(params[:id])
            changeStatusByUser(@projekt, @projekt.statusumschl, permitted_params[:status][:statusumschlag])
          end

          render '_umschlagShow.js'
        }
      end
    end


    ##
    # Match download link with corresponding method which generates the output
    # in this case we use print_report for the .odt output
    def index
      super do |format|#index!, html
        format.odt {print_report("umschlag_report", method(:umschlag))}
      end
    end

  end

  index title: 'Umschlag', download_links: [:odt] do
    column('Status') { |um| status_tag(um.statusumschl.status) }
    column :projektname
    actions
  end

  show do
    render partial: "umschlagShow"
  end

  form partial: 'umschlagInput'


end
