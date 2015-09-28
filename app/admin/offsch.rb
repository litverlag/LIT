ActiveAdmin.register Offsch do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or

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
  filter :prio
  filter :offsch_sollf
  filter :lek
  filter :seiten
  filter :format
  filter :umschlag
  filter :bi
  filter :vf
  filter :an_autor
  filter :an_sch_mit_u
  filter :email


  menu label: 'Off/Sch', priority: 19
  index title: 'Off/Sch' do
    column :name
    column 'ISBN', :isbn
    column :auflage
    column :datum
    column :prio
    column :offsch_sollf
    column :lek
    column :seiten
    column :format
    column :umschlag
    column :bi
    column '4f', :vf
    column :an_autor
    column 'An_Sch_mit_U', :an_sch_mit_u
    column 'E-Mail', :email
    actions
  end

end
