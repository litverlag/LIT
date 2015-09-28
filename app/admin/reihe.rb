ActiveAdmin.register Reihe do
  filter :name
  filter :r_code

  #menu priority:99
  menu false
  
  index download_links: [:csv,:xml,:json,:odt] do
    selectable_column
    column :r_code
    column :name
    actions
  end

  controller do
    def permitted_params
      params.permit!
    end
    
    def index
      super do |format|#index!, html
        format.odt {odt}
      end
    end

    def odt #TODO: selection
      report = ODFReport::Report.new("#{Rails.root}/app/reports/test.odt") do |r|
        r.add_field(:test, 'foobar')
        r.add_table("Tabelle1", Reihe.select("id,name"), :header=>true) do |t|
          t.add_column(:name, :name)
          t.add_column(:id, :id)
        end
      end

      send_data report.generate, type: 'application/vnd.oasis.opendocument.text', disposition: 'attachment', filename: 'report.odt'
    end
  end
  
  show do
    
    attributes_table do
      row :name
      row :r_code
    end
    
    panel "Bände der Reihe" do
      table_for reihe.buecher do
        column "Name" do |b|
          b.name
        end
        column "Titel" do |b|
          link_to b.titel1, admin_buch_path(b)
        end
        column "ISBN" do |b|
          b.isbn
        end
      end
    end
    
    panel "Herausgeber" do
      table_for reihe.autoren do
        column "Name" do |a|
          link_to a.fullname, admin_autor_path(a)
        end
      end
    end
    
  end
  
  form do |f|
      f.inputs 'Details' do
        f.input :name
        f.input :r_code
      end
      
      f.inputs 'Bände' do
        f.has_many :reihen_zuordnungen, heading: nil, allow_destroy: true, new_record: 'Band hinzufügen' do |a|
          a.input :buch_id, :label => 'Titel', :input_html => { :class => 'buch-input'}
        end
      end
      
      f.inputs 'Herausgeber' do
        f.has_many :reihen_hg_zuordnungen, heading: nil, allow_destroy: true, new_record: 'Herausgeber hinzufügen' do |a|
          a.input :autor_id, :label => 'Name', :input_html => { :class => 'autor-input'}
        end
      end
      f.actions
    end

end
