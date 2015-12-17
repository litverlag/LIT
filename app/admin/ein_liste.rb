ActiveAdmin.register EinListe do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if resource.something?
#   permitted
# end

  menu false
  actions :index, :show, :edit, :update
  controller do
    def permitted_params

      params.permit!
    end
  end


 #actions :index, :show, :update, :edit

=begin
I tried to make a dynamic scope for each Lektor in belonging to a Project
  scope "Published", :if => proc {  @lekt = []
                     current_admin_user.projekte.to_a.each do |a|
                       @lekt.append a.name
                     end
                   lektor.to_a

                   } do |gprod|
                     gprod
                   end
=end
 # scope_to :projekte, association_method: :projekte
  #filter :lektor, as: :select, collection: @lektoren_arr.all.map{ |u| ["#{u.name}"] }



  filter :name
  filter :isbn
  filter :auflage
  filter :prio
  filter :druck
  filter :bi
  filter :msein
  filter :sollf_ein_liste
  filter :lek
  filter :korr
  filter :form
  filter :datei
  filter :seiten
  filter :reihe
  filter :titelei
  filter :format
  filter :papier
  filter :umschlag
  filter :satz
  filter :vf
  filter :email
  filter :sonder

  menu label: 'EinListe', priority: 2



  index do
    column 'Status', :ein_liste_status
    column :name
    column 'ISBN', :isbn
    column :auflage
    column :prio
    column :druck
    column :bi
    column :msein
    column :sollf_ein_liste
    column :lek
    column :korr
    column :form
    column :datei
    column :seiten
    column :reihe
    column :titelei
    column :format
    column :papier
    column :umschlag
    column :satz
    column '4f', :vf
    column 'E-Mail', :email
    column :sonder
    actions
  end


  show do
    attributes_table do
      row :ein_liste_status
      row :name
      row :isbn
      row :auflage
      row :prio
      row :druck
      row :bi
      row :msein
      row :sollf_ein_liste
      row :lek
      row :korr
      row :form
      row :datei
      row :seiten
      row :reihe
      row :titelei
      row :format
      row :papier
      row :umschlag
      row :satz
      row :vf
      row :email
      row :sonder
      row :lektor
    end
  end



end
