ActiveAdmin.register Autor do
  config.filters = false
  menu label: 'Autoren'
  menu priority:99
  config.filters = true



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
			begin
				@autor = Autor.create(ControllerHelper.make_compact(permitted_params[:autor]))
			rescue ActiveRecord::RecordInvalid
				redirect_to "/admin/autoren/#{@autor.id}/edit"
				flash[:alert] = I18n.t 'flash_notice.revised_failure.new_project_invalid'
				return
			end
			flash[:notice] = I18n.t 'flash_notice.revised_success.author_create'
			redirect_to "/admin/autoren/#{@autor.id}"
			return
      #@button_text_autor_input = "Autor erstellen"
      #respond_to do |format|
      #  format.html
      #  format.js {
      #    render "_autorCreate.js.erb" #flash notice
      #  }
      #end
    end

    def edit
      puts "____________________________EDIT___AUTOR________________________"
      @autor = Autor.find(params[:id])
      @button_text_autor_input = "Autor bearbeiten"
    end

    def update
      puts "____________________________UPDATE___AUTOR________________________"
      @autor = Autor.find(params[:id])
			begin
				@autor.update!(ControllerHelper.make_compact(permitted_params[:autor]))
			rescue ActiveRecord::RecordInvalid
				redirect_to "/admin/autoren/#{@autor.id}/edit"
				flash[:alert] = I18n.t 'flash_notice.revised_failure.new_project_invalid'
				return
			end
			flash[:notice] = I18n.t 'flash_notice.revised_success.author_update'
			redirect_to "/admin/autoren/#{@autor.id}"
			#render "_autorShow.js.erb"
    end

  end

  index do
    column :name
    column :vorname
    column :anrede
    column :institut

    actions
  end

	filter :name
	filter :email
  filter :anrede
  filter :institut

  show do
    render "autorShow"
  end

  form partial: 'autorInput'

end
