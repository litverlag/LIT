ActiveAdmin.register Lf, as:"LF" do
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

  filter :lf_status
  filter :name
  filter :isbn
  filter :auflage
  filter :lf_sollf
  filter :bi
  filter :druck
  filter :prio
  filter :msein
  filter :lek
  filter :reihe
  filter :seiten
  filter :format
  filter :umschlag
  filter :titelei
  filter :satz
  filter :papier
  filter :vf
  filter :email
  filter :sonder

  menu label: 'LF', priority: 3
  index title: 'Liste Fertig' do
    column 'Status', :lf_status
  	column :name
    column 'ISBN', :isbn
    column :auflage
    column 'SollF', :lf_sollf
    column :bi
    column :druck
    column :prio
    column :msein
    column :lek
    column :reihe
    column :seiten
    column :format
    column :umschlag
    column :titelei
    column :satz
    column :papier
    column '4f', :vf
    column 'E-Mail', :email
    column :sonder
    actions
  end
end
