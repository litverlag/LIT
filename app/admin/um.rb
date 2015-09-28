ActiveAdmin.register Um do

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
  filter :sollf_um
  filter :verschickt
  filter :lek
  filter :umschlag
  filter :format
  filter :seiten
  filter :ruecken
  filter :bi 
  filter :bild
  filter :klapptext
  filter :frei
  filter :warten
  filter :besonderheit
  filter :rueckenfrei
  filter :stand
  filter :email

  menu label: 'Um', priority: 5
  index title: 'Umschlag' do
    column :name
    column 'ISBN', :isbn
    column :sollf_um
    column :verschickt
    column :lek
    column :umschlag
    column :format
    column :seiten
    column :ruecken
    column :bi
    column :bild
    column :klapptext
    column :frei
    column :warten
    column :besonderheit
    column 'Rückenfehlt/frei', :rueckenfrei
    column 'stand', :stand
    column 'E-Mail', :email

    actions
  end

end
