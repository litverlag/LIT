ActiveAdmin.register Autor do
  config.filters = false
  menu false

  #menu priority:99



  controller do

    def permitted_params
      params.permit!
    end

    def show
      puts "____________________________SHOW___AUTOR________________________"
      @autor = Autor.find(permitted_params[:id])
    end

    def new
      puts "____________________________NEW___AUTOR________________________"
      @button_text_autor_input = "Autor erstellen"
      super
    end

    def create
      puts "____________________________CREATE__AUTOR________________________"
      @autor = Autor.create(ControllerHelper.make_compact(permitted_params[:autor]))
      @button_text_autor_input = "Autor erstellen"
      respond_to do |format|
        format.html
        format.js {
          render "_autorCreate.js.erb" #flash notice
        }
      end

    end

    def edit
      puts "____________________________EDIT___AUTOR________________________"
      @autor = Autor.find(params[:id])
      @button_text_autor_input = "Autor bearbeiten"



    end

    def update
      puts "____________________________UPDATE___AUTOR________________________"
      @autor = Autor.find(params[:id])

      if @autor.update(ControllerHelper.make_compact(permitted_params[:autor]))
        render "_autorShow.js.erb"
      end
    end


  end


  index do
    column 'Vollständiger Name', :fullname
    column :institut

    actions
  end

  show do
    render "autorShow"
  end



  form partial: 'autorInput'

end
