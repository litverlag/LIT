ActiveAdmin.register Lektor do
  #menu priority:99
  menu false

  controller do
    def permitted_params

      params.permit!
    end
  end


  show do
    render :partial
  end


end


