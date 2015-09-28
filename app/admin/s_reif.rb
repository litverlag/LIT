ActiveAdmin.register SReif do

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
  actions :index, :show, :update, :edit

  filter :name
  filter :isbn
  filter :sreif_sollf
  filter :prio
  filter :lek
  filter :seiten
  filter :format
  filter :umschlag
  filter :titelei
  filter :bi 
  filter :satz
  filter :druck
  filter :papier
  filter :gewicht
  filter :volumen
  filter :reihe
  filter :vf
  filter :auflage
  filter :email
  filter :sonder

  menu label: 'SReif', priority: 4
  index title: 'Satz Reif' do
    column :name
    column 'ISBN', :isbn
    column 'SollF', :sreif_sollf
    column :prio
    column :lek
    column :seiten
    column :format
    column :umschlag
    column :titelei
    column :bi
    column :satz
    column :druck
    column :papier
    column :gewicht
    column :volumen
    column :reihe
    column '4f', :vf
    column :auflage
    column 'E-Mail', :email
    column :sonder
    actions
  end

end
