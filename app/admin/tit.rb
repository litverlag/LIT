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

  #member_action :status, :method => :post do
  #  resource.change_status('tit_status')
  #  redirect_to collection_path, notice: "Bestätigt"
  #end


  controller do

    def permitted_params
         params.permit!
       end

  end




  #scope :alle
  #scope :neu
  #scope :bearbeitung
  #scope :fertig

  menu label: 'Tit', priority: 6

  index title: 'Titelei' do
    #column("Status") {|model| status_tag(model.status('titelei_status'))}


    actions
  end

  #action_item only: :show do
  #
  #  link_to 'Nächster Status', status_admin_tit_path, method: :post
  #
  #end



  form do |f|
    f.inputs "Titelei-Eintrag bearbeiten" do
      permitted_params.each do |p|
       # f.input p
      end
    end
    f.actions
    end


end
