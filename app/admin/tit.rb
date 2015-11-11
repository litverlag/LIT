ActiveAdmin.register Tit do
  menu label: 'Tit'
  menu priority: 6
  config.filters = false
  actions :index, :show, :edit, :update

  controller do

    include StatusLogic

    def permitted_params
         params.permit!
       end

  end


  index title: 'Titelei' do
    column('Status') {|tit| tit.statustitelei.status}
    column :projektname


    actions
  end




  #form do |f|
  #  f.inputs "Titelei-Eintrag bearbeiten" do
  #    permitted_params.each do |p|
  #     # f.input p
  #    end
  #  end
  #  f.actions
  #  end


end
