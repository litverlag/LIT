ActiveAdmin.register Projekt do

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

   controller do
     def permitted_params
       params.permit!
     end

     def new
       @projekt = Gprod.new
     end


     def create
       permitted_params
       @projekt = Gprod.new(params[:gprod])
       @projekt.save
       redirect_to collection_path
     end

     def update
       permitted_params
       @projekt = Gprod.find(params[:id])
       if @projekt.update(params[:gprod])
         redirect_to collection_path
       else
         render 'edit'
       end
     end

     def edit
      @projekt = Gprod.find(params[:id])
     end
   end


  menu label: "Meine Projekte"

  index title: "Meine Projekte" do
    column :druck
    #column('Name') {|p| p.buch.name }

    actions

  end



   form partial: 'projectInput'





end
