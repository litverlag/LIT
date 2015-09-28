ActiveAdmin.register Bi do

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
  filter :datum
  filter :lek
  filter :seiten
  filter :format
  filter :umschlag
  filter :bi
  filter :vf
  filter :tagesleistung

  menu label: 'Bi', priority: 18
  index title: 'Binderei' do
    column :name
    column 'ISBN', :isbn
    column :auflage
    column :datum
    column :lek
    column :seiten
    column :format
    column :umschlag
    column :bi
    column '4f', :vf
    column :tagesleistung
    actions
  end

end
