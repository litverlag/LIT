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
       #Autor kann erst  initialisiert werden, wenn die View passend erweitert wurde
       #elsif not @projekt.autor = Autor.create(permitted_params[:autor])
       #  render 'new'
       else
         @projekt.lektor = current_admin_user.lektoren.first    # .first wird genutzt, da ein Lektor_User immer nur einen Lektor besitzen soll
         @projekt.save
         redirect_to collection_path, notice: "Projekt erfolgreich erstellt"
       end
     end

     def edit
       @projekt = Projekt.find(params[:id])
     end

     def update
       if lektorAccess(Projekt.find(params[:id]))
         @projekt = Projekt.find(params[:id])
         if not @projekt.update(permitted_params[:projekt])
           render 'edit'
         elsif not @projekt.buch.update(permitted_params[:buch])
           render 'edit'
         #elsif not @projekt.autor.update(permitted_params[:buch])
         #  render 'edit'
         else
           redirect_to collection_path, notice: "Projekt erfolgreich überarbeitet"
         end
       else
         redirect_to admin_access_denied_path
       end
     end

     def destroy
       @projekt = Projekt.find(params[:id])
       if lektorAccess(Projekt.find(params[:id]))
         @projekt.buch.destroy
         @projekt.destroy
         redirect_to collection_path, notice: "Projekt erfolgreich gelöscht"
       else
         redirect_to admin_access_denied_path
       end
     end


     def scoped_collection
       #This method scoped all shown db entries by the following condition. We use it here so that each Lektor can see only his own projects
       super.where(lektor: current_admin_user.lektoren.first)
     end


     def lektorAccess(projekt)
       if projekt.lektor == current_admin_user.lektoren.first
         return true
       else
         return false
       end
     end

   end







  menu label: "Meine Projekte"

   index do
     column :kommentar_public
     actions
   end



   form partial: 'projectInput'




end
