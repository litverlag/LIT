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
       @projekt = Projekt.new
       @projekt.buch = Buch.new
     end


     def create
       if @projekt = Projekt.create(permitted_params[:projekt])
          @projekt.buch = Buch.create(permitted_params[:buch])
          redirect_to collection_path, notice: "Projekt erfolgreich erstellt"
       else
         render 'new'
       end
     end

     def edit
       @projekt = Projekt.find(params[:id])
     end

     def update
       @projekt = Projekt.find(params[:id])
       if @projekt.update(permitted_params[:projekt])
         redirect_to collection_path, notice: "Projekt erfolgreich überarbeitet"
       else
         render 'edit'
       end
     end

   end


  menu label: "Meine Projekte"

  index title: "Meine Projekte" do
    column :druck
    column('Name') {|p| p.buch.name }

    actions

  end



   form partial: 'projectInput'





end
