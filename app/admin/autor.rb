ActiveAdmin.register Autor do
  filter :vorname
  filter :name
  filter :institut

  #menu priority:99
  menu

  index do
    selectable_column
    column 'Name', :fullname
    column :institut
    column :dienstadresse
    actions
  end

  controller do
    def permitted_params
      params.permit!
    end
  end
  
  show do
    
    attributes_table do
      row :anrede
      row :vorname
      row :name
      row :institut
    end
    
    panel "Bücher" do
      table_for autor.buecher do
        column "Titel" do |b|
          link_to b.titel1, admin_buch_path(b)
        end
      end
    end
    
    panel "Reihen" do
      table_for autor.reihen do
        column "Name" do |r|
          link_to r.name, admin_reihe_path(r)
        end
      end
    end
    
  end

end
