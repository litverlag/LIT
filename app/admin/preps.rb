ActiveAdmin.register Preps do
  menu label: 'Preps'
  menu priority: 13
  config.filters = false
  actions :index, :show, :edit, :update

  controller do

    include StatusLogic

    def permitted_params
         params.permit!
       end

  end

  index title: 'Preps' do
    column('Status') {|preps| status_tag(preps.statuspreps.status)}
    column :projektname
    actions
  end

  show do
    render :partial
  end

end
