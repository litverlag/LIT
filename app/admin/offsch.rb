ActiveAdmin.register Offsch do
  menu label: 'Offsch'
  menu priority: 14
  config.filters = false
  actions :index, :show, :edit, :update

  controller do

    include StatusLogic

    def permitted_params
         params.permit!
       end

  end

  index title: 'Offsch' do
    column('Status') {|offsch| status_tag(offsch.statusoffsch.status)}
    column :projektname
    actions
  end

  show do
    render :partial
  end

end
