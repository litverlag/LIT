ActiveAdmin.register Tit do

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

  permit_params :name, :msein

  filter :name
  filter :isbn
  filter :Lek
  filter :tit_sollf
  filter :format
  filter :eintrag
  filter :versand
  filter :an
  filter :korrektur
  filter :freigabe
  filter :zum_druck
  filter :erscheinungsjahr
  filter :bemerkungen_1
  filter :bemerkungen_2
  filter :email

  scope :alle
  scope :neu
  scope :bearbeitung
  scope :fertig

  menu label: 'Tit', priority: 6
  index title: 'Titelei' do
    column("Status") {|tit| status_tag(tit.status)}
    column :name
    column 'ISBN', :isbn
    column :Lek
    column :tit_sollf
    column :format
    column :eintrag
    column :versand
    column :an
    column :korrektur
    column :freigabe
    column :zum_druck
    column :erscheinungsjahr
    column :bemerkungen_1
    column :bemerkungen_2
    column 'E-Mail', :email

    actions
  end

end
