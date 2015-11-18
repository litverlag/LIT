ActiveAdmin.register Projekt do
  menu label: "Meine Projekte"
  #menu priority: x
  config.filters = false

   controller do

    include StatusLogic

    before_action :set_locale

    def set_locale
      I18n.locale = :de
    end

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
      super
      puts "____________________________EDIT___________________________"

    end



     def update
       puts "____________________________UPDATE___________________________"
       @projekt = current_admin_user.lektor.gprod.find(params[:id])
       updateProc = Proc.new{|modelinstance ,data|
       if data != nil
         if not modelinstance.update(data)
           render 'edit'
         end
       end}

       updateProc.call(@projekt,permitted_params[:projekt] )
       updateProc.call(@projekt.buch,permitted_params[:buch] )
       if not @projekt.autor
         Autor.autor_name(permitted_params[:autor])
         @projekt.autor = Autor.create(permitted_params[:autor])
         @projekt.save
       else
         updateProc.call(@projekt.autor,permitted_params[:autor])
       end
       # Diese Methode muss noch angepasst werden, dass ggf Bücher und Autren erstellt wrden
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
     column :projektname
     column  "Emailadresse des Projektes", :projekt_email_adresse

     actions
   end



   form partial: 'projectInput'




end
