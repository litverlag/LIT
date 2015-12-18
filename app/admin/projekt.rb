ActiveAdmin.register Projekt do
  menu label: "Meine Projekte"
  #menu priority: x
  config.filters = false
   controller do

    include StatusLogic

    ##
    # It would be great if this class could be in a helper modulde, but it's not that easy beacause of ActiveAdmin
    # This method is used to replace the string coming from the HTML form ()permitted_params["format"]) by an instance of the right
    # format class so that an association can be done with the klass.update method. Same procedure with papier and umschlag




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
       elsif not @projekt.buch = Buch.create(Hash[:name ,"unbekannt"])
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

      @array_of_format_bezeichungen = ChoosableValue.formate
      @array_of_umschlag_bezeichnungen =ChoosableValue.umschlaege
      @array_of_papier_bezeichungen = ChoosableValue.papiere


      @button_text_add = "Neuen Autor erstellen"
      @button_text_asso = "Autor hinzufügen"
      @button_text_edit = "Autor bearbeiten"

      respond_to do |format|
        format.html
        format.js {

        }
      end


    end



     def update

       puts "____________________________UPDATE___________________________"
       #Proc for the updating if there is already an Author
           updateProc = Proc.new{|modelinstance ,data|
             js_action = "project_changed"
             if data != nil
               if not modelinstance.update(data)
                 render 'edit'
               end
             end}

       @button_text_add = "Neuen Autor erstellen"
       @button_text_asso = "Autor hinzufügen"
       @button_text_edit = "Autor bearbeiten"


       respond_to do |format|
         format.html
         format.js {
           #Find the new projekt associated with the current Lektor
           @projekt = current_admin_user.lektor.gprod.find(params[:id])
           if permitted_params[:gprod] then updateProc.call(@projekt,permitted_params[:gprod]) end
           if permitted_params[:buch] then updateProc.call(@projekt.buch,permitted_params[:buch]) end


           # This part is used to update to a new status with the status_logic module
           if permitted_params[:status]
             changeStatusByUser(@projekt,@projekt.statusfinal, permitted_params[:status][:freigabe_final])
             changeStatusByUser(@projekt,@projekt.statusumschl, permitted_params[:status][:freigabe_umschlag])
             changeStatusByUser(@projekt,@projekt.statuspreps, permitted_params[:status][:freigabe_preps])
             changeStatusByUser(@projekt,@projekt.statustitelei, permitted_params[:status][:freigabe_titelei])
             puts permitted_params[:status]
           end


<<<<<<< HEAD
           # TO BE INTERNATIONALIZED this strings are temporary for the names of the buttons


=======
         puts "\n\n\n\n\n"
       puts "Parameter:"
       puts "----------"
       puts permitted_params[:projekt]
       puts "----------"
        puts "\n\n\n\n\n"

       @projekt = current_admin_user.lektor.gprod.find(params[:id])
       updateProc.call(@projekt,permitted_params[:projekt] )
       updateProc.call(@projekt.buch,permitted_params[:buch] )
>>>>>>> 3e4c4a08970d622a49fe68be0a200c76912f1622

           # It is checked if the the User want to create a new Author or if he wants to make an association with one who already exists
           # if there is no Author in the Database we get an Error, if there is on he gets associated.
           if permitted_params[:commit].eql?(@button_text_asso)
             if not Autor.associate_with(@projekt,permitted_params[:autor])
               @js_action = "autor_add"
               render "_projectShow.js.erb"
             end
             return
           end
           if permitted_params[:commit].eql?(@button_text_add)
             @projekt.autor = Autor.create(permitted_params[:autor])
             @projekt.save
             @js_action = "autor_new"
             render "_projectShow.js.erb"
             return
           end
           if permitted_params[:commit].eql?( @button_text_edit)
             updateProc.call(@projekt.autor,permitted_params[:autor])
             @js_action = "autor_new"
             render "_projectShow.js.erb"
             return
           end


           render "_projectShow.js.erb"
         }
       end

       redirect_to collection_path, notice: "Projekt erfolgreich bearbeitet"

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
