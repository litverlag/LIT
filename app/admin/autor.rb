ActiveAdmin.register Autor do
  filter :vorname
  filter :name
  filter :institut

  #menu priority:99



  controller do
    def permitted_params
      params.permit!
    end
  end

  index do
    column 'Vollständiger Name', :fullname
    column :institut

    actions
  end

  show do

  end

end
