ActiveAdmin.register Lektor do
  #menu priority:99
  menu

  controller do
    def permitted_params

      params.permit!
    end
  end



end


