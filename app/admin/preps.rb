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

      respond_to do |format|
        format.js{

          if permitted_params[:status]
            @projekt = Gprod.find(params[:id])
            changeStatusByUser(@projekt, @projekt.statuspreps, permitted_params[:status][:statuspreps])
          end

          render "_prepsShow.js.erb"


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




  form partial: 'prepsInput'


end
