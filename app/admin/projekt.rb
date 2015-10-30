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
       if not @projekt = Projekt.create(permitted_params[:projekt])
         render 'new'
       elsif not @projekt.buch = Buch.create(permitted_params[:buch])
         render 'new'
       #elsif not @projekt.autor = Autor.create(permitted_params[:autor])
       #  render 'new'
       else
         @projekt.lektor = current_admin_user.lektoren.first
         redirect_to collection_path, notice: "Projekt erfolgreich erstellt"
       end
     end

     def edit
       @projekt = Projekt.find(params[:id])
     end

     def update
       @projekt = Projekt.find(params[:id])
       if @projekt.update(permitted_params[:projekt])
          if @projekt.buch.update(permitted_params[:buch])
            redirect_to collection_path, notice: "Projekt erfolgreich überarbeitet"
       else
         render 'edit'
       end
       end
     end

     def destroy
       @projekt = Projekt.find(params[:id])
       @projekt.buch.destroy
       @projekt.destroy
       redirect_to collection_path, notice: "Projekt erfolgreich gelöscht"

     end

     def scoped_collection
       #This method scoped all shown db entries by the following condition. We use it here so that each Lektor can see only his own projects

       super.where(druck: 'abc')
     end

   end







  menu label: "Meine Projekte"

   index row_class: ->projekt { 'active' if true }  do
     column :druck
     actions
   end



   form partial: 'projectInput'





end
