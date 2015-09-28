ActiveAdmin.register Preps do

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
  filter :auflage
  filter :preps_sollf
  filter :muster
  filter :bi
  filter :druck
  filter :prio
  filter :lek
  filter :seiten
  filter :format
  filter :umschlag
  filter :titelei
  filter :satz
  filter :papier
  filter :vf
  filter :email
  filter :preps_betreuer
  filter :preps_kommentar

  menu label: 'Preps', priority: 13
  index title: 'Preps' do
    column :name
    column 'ISBN', :isbn
    column :auflage
    column 'SollF', :preps_sollf
    column :muster
    column :bi
    column :druck
    column :prio
    column :lek
    column :seiten
    column :format
    column :umschlag
    column :titelei
    column :satz
    column :papier
    column '4f', :vf
    column 'E-Mail', :email
    column 'Betreuer', :preps_betreuer
    column 'kommentar', :preps_kommentar
    actions
  end

end
