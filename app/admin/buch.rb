ActiveAdmin.register Buch do
  filter :name
  filter :isbn
  filter :issn
  filter :titel1
  filter :sammelband
  filter :format
  
  
  #menu priority:1

  index title: 'Bücher' do
    selectable_column
    column 'ISBN', :short_isbn
    column 'Titel', :titel1
    column :seiten
    column("Preis") {|buch| number_to_currency buch.preis, locale: :de}
    column :sammelband
    actions
  end

  controller do
    def permitted_params
      params.permit!
    end
  end
  
  show do
    
    attributes_table do
      row :isbn
      row :titel1
      row :titel2
      row :titel3
      row :utitel1
      row :utitel2
      row :utitel3
      row :seiten
      row :preis
      row :sammelband
      row :erscheinungsjahr
    end
    
    panel "Autoren" do
      table_for buch.autoren do
        column "Name" do |a|
          link_to a.vorname + a.name, admin_autor_path(a)
        end
      end
    end
    
    panel "Reihen" do
      table_for buch.reihen do
        column "Reihe" do |r|
          link_to r.name, admin_reihe_path(r)
        end
        column "r_code" do |r|
          r.r_code
        end
      end
    end
    
  end

end

