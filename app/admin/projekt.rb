ActiveAdmin.register Projekt do
  menu label: "Meine Projekte"
  #menu priority: x
  config.filters = false
   controller do

    include StatusLogic



    def scoped_collection
      if current_admin_user.departments.where("name = ?", 'Lektor').any?
        super.where(lektor: current_admin_user.lektor)
      else
        super.all
      end
    end


     def permitted_params
       params.permit!
     end


     def create
       puts "____________________________CREATE__________________________"
       if not @projekt = Projekt.create(permitted_params[:projekt])
         render 'new'
       elsif not @projekt.buch = Buch.create(permitted_params[:buch])
         render 'new'
       elsif not createStatus(@projekt)
        render 'new'
       else
         @projekt.lektor = current_admin_user.lektor
         @projekt.save
         redirect_to collection_path, notice: "Projekt erfolgreich erstellt"
       end
     end

    def edit
      puts "____________________________EDIT___PROJEKT________________________"
      @projekt = current_admin_user.lektor.gprod.find(params[:id])
      #This methods are used to check if the Author can actually release project for the departments
      puts @projekt.buch.all_attributes_set?
      puts @projekt.buch.attributes

      respond_to do |format|
        format.html
        format.js
      end


    end



     def update
       puts "____________________________UPDATE___________________________"
       #Proc for the updating if there is already an Author
           updateProc = Proc.new{|modelinstance ,data|
             if data != nil
               if not modelinstance.update(data)
                 render 'edit'
               end
             end}


           #Find the new projekt associated with the current Lektor
           @projekt = current_admin_user.lektor.gprod.find(params[:id])
           updateProc.call(@projekt,permitted_params[:projekt] )
           updateProc.call(@projekt.buch,permitted_params[:buch])



           #This part is used to update to a new status with the status_logic module
           if permitted_params[:status]
             puts permitted_params[:status]
           end



           # It is checked if the the User want to create a new Author or if he wants to make an association with one who already exists
           # if there is no Author in the Database we get an Error, if there is on he gets associated.
           if permitted_params[:commit].eql?("Autor hinzufügen")
             if not Autor.associate_with(@projekt,permitted_params[:autor]) then redirect_to edit_admin_projekt_path, notice: "Kein Autor mit diesem Namen gefunden"
             end
           end
           if permitted_params[:commit].eql?("Neuen Autor erstellen")
             @projekt.autor = Autor.create(permitted_params[:autor])
             @projekt.save
             redirect_to collection_path, notice: 'Projekt erfolgreich überarbeitet'
           end

           redirect_to collection_path, notice: 'Projekt erfolgreich überarbeitet'


     end



     def destroy
       @projekt = current_admin_user.lektor.gprod.find(params[:id])
       @projekt.buch.destroy
       @projekt.destroy
       redirect_to collection_path, notice: "Projekt erfolgreich gelöscht"
     end

   end




   index do
     #render partial: 'projectindex'
     column('Status') {|projekt| projekt.statusfinal.status}
     column :projektname
     column  "Emailadresse des Projektes", :projekt_email_adresse


     actions
   end

  show do
    render partial: "projectShow"
  end



  form partial: 'projectInput' 

end
