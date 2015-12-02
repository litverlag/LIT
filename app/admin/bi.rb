ActiveAdmin.register Bi do
  menu label: 'Bi'
  menu priority: 15
  config.filters = false
  actions :index, :show, :edit, :update

  controller do

    include StatusLogic

    def permitted_params
      params.permit!
    end


  end

  index title: 'Binderei' do
    column('Status') {|bi| bi.statusbinderei.status}
    column :projektname
    actions
  end

end
