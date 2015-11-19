ActiveAdmin.register Autor do
  filter :vorname
  filter :name
  filter :institut

  #menu priority:99
  menu


  controller do
    def permitted_params
      params.permit!
    end
  end

  index do
    selectable_column
    column 'Vollständiger Name', :fullname
    column :institut

    actions
  end



end
