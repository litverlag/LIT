ActiveAdmin.register SReif do
  menu label: 'SReif'
  menu priority: 4
  config.filters = false
  actions :index, :show, :edit, :update

  controller do

    include StatusLogic

    def permitted_params
         params.permit!
       end

  end

  index title: 'Satz' do
    column('Status') {|satz| satz.statussatz.status}
    column :projektname
    actions
  end

  show do
    render :partial
  end

end
