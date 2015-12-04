ActiveAdmin.register Um do
  menu label: 'Um'
  menu priority: 5
  config.filters = false
  actions :index, :show, :edit, :update

  controller do

    include StatusLogic

    def permitted_params
         params.permit!
       end

  end

  index title: 'Umschlag' do
    column('Status') {|um| status_tag(um.statusumschl.status)}
    column :projektname
    actions
  end

  show do
    render :partial
  end

end
