ActiveAdmin.register Fach do
  #menu priority:99
  menu false
  index title: 'Fächer'
  
  controller do
    def permitted_params
      params.permit!
    end
  end

  show do
    render :partial
  end


end
