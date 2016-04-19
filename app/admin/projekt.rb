ActiveAdmin.register Projekt do
  menu label: "Meine Projekte"
  #menu priority: x
  config.filters = false

  #scopes -> filter the viewable project in the table
  scope (I18n.t("scopes_names.alle_filter")), :alle_filter
  scope (I18n.t("scopes_names.fertig_filter")), :fertig_filter
  scope (I18n.t("scopes_names.bearbeitung_filter")), :bearbeitung_filter
  scope (I18n.t("scopes_names.neu_filter")), :neu_filter
  scope (I18n.t("scopes_names.problem_filter")), :problem_filter


   controller do
    
    #from models/concerns
    include StatusLogic, PrintReport

    ##
    # It would be great if this class could be in a helper modulde, but it's not that easy beacause of ActiveAdmin
    # This method is used to replace the string coming from the HTML form ()permitted_params["format"]) by an instance of the right
    # format class so that an association can be done with the klass.update method. Same procedure with papier and umschlag
    # Rouven asks: Who wrote this? please mail me rouvenglauert@gmail.com

    def scoped_collection
      if current_admin_user.departments.where("name = ?", 'Lektor').any?
        super.where(lektor: current_admin_user.lektor)
      else
        super.all
      end
    end


     def permitted_params
       #alle
       params.permit!
     end


     def create
       puts "____________________________CREATE__________________________"
       #Check if the current User is a Lektor if not he is not able to create a Projekt
       if current_admin_user.departments.to_a[0].name == "Lektor"
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
       else
         raise StandardError, "A project can only be created from an account with a lektor"
       end

     end

    def edit
      puts "____________________________EDIT___PROJEKT________________________"
      #Find the new projekt associated with the current Lektor or if superadmin you can access all projects
      @projekt = Projekt.find_projekt_by_id(permitted_params[:id],current_admin_user)
      #This methods are used to check if the Author can actually release project for the departments
      @department = "projekt"
      @array_of_format_bezeichungen = ChoosableOption.instance.format_bezeichnung :all
      @array_of_umschlag_bezeichnungen = ChoosableOption.instance.umschlag_bezeichnung :all
      @array_of_papier_bezeichungen = ChoosableOption.instance.papier_bezeichnung :all
      @array_of_vier_farb = ChoosableOption.instance.vier_farb :all


      @button_text_add = I18n.t 'buttons.author_new'
      @button_text_asso = I18n.t 'buttons.author_asso'
      @button_text_edit =  I18n.t 'buttons.author_edit'


      respond_to do |format|
        format.html
        format.js { }
      end


    end



     def update

       puts "____________________________UPDATE____PROJEKTE_______________________"
       #Proc for the updating if there is already an Author
           updateProc = Proc.new{|modelinstance ,data|
             js_action = "project_changed"
             if data != nil
               if not modelinstance.update(data)
                 render 'edit'
               end
             end}
             
       # TO BE INTERNATIONALIZED this strings are temporary for the names of the buttons
       @button_text_add = I18n.t 'buttons.author_new'
       @button_text_asso = I18n.t 'buttons.author_asso'
       @button_text_edit =  I18n.t 'buttons.author_edit'
  
       
       respond_to do |format|
         format.html {}
         format.js {
           @projekt = Projekt.find_projekt_by_id(permitted_params[:id],current_admin_user)


           if permitted_params[:gprod] then updateProc.call(@projekt,permitted_params[:gprod]) end
           if permitted_params[:buch] then updateProc.call(@projekt.buch,permitted_params[:buch]) end
          puts "__________________TesT________________________________"

          puts permitted_params[:gprod]
          #puts permitted_params[:status][:freigabe_titelei]
          puts "__________________TesT________________________________"

           # This part is used to update to a new status with the status_logic module
           if permitted_params[:status]
             changeStatusByUser(@projekt,@projekt.statusfinal, permitted_params[:status][:freigabe_final])
             changeStatusByUser(@projekt,@projekt.statusumschl, permitted_params[:status][:freigabe_umschlag])
             changeStatusByUser(@projekt,@projekt.statuspreps, permitted_params[:status][:freigabe_preps])
             changeStatusByUser(@projekt,@projekt.statustitelei, permitted_params[:status][:freigabe_titelei])
           end

           #puts permitted_params

           # It is checked if the the User want to create a new Author or if he wants to make an association with one who already exists
           # if there is no Author in the Database we get an Error, if there is on he gets associated.
           if permitted_params[:commit].eql?(@button_text_asso)
             if not Autor.associate_with(@projekt,permitted_params[:autor])
               @js_action = "autor_add"
             end

           end
           if permitted_params[:commit].eql?(@button_text_add)
             @projekt.autor = Autor.create(permitted_params[:autor])
             @projekt.save
             @js_action = "autor_new"

           end
           if permitted_params[:commit].eql?( @button_text_edit)
             updateProc.call(@projekt.autor,permitted_params[:autor])
             @js_action = "autor_new"


           end

           #to obtain modified data (ex rojectShow.js.erb)
           render "_project_Input_Response.js.erb"
         }
       end

      # redirect_to collection_path, notice: "Projekt erfolgreich bearbeitet"

     end
    
    
    
    def show
      #departement is set to choose the right department for the Show / Edit View
      @department = "projekt"
      puts "______________PROJEKT______SHOW___________________-"
      @projekt = Gprod.find(permitted_params[:id])
    end


     def destroy
       #Find the new projekt associated with the current Lektor or if superadmin you can access all projects
       @projekt = Projekt.find_projekt_by_id(permitted_params[:id],current_admin_user)
       @projekt.buch.destroy
       @projekt.destroy
       redirect_to collection_path, notice: "Projekt erfolgreich gelöscht"
     end


    ##
    # Match download link with corresponding method which generates the output
    # in this case we use print_report for the .odt output
    def index
      super do |format|#index!, html
        format.odt {print_report("projekt_report", method(:projekt))}
      end
    end

   end


   index download_links: [:odt] do
     #render partial: 'projectindex'
     @department = "projekt"
     puts "______________PROJEKT______INDEX__________________-"
     puts @department
    
     column('Status') {|projekt| status_tag(projekt.statusfinal.status)}
     column :projektname
     column  "Emailadresse des Projektes", :projekt_email_adresse

     actions
   end






  show do
    render partial: "show_view"
  end



  form partial: 'newInput' 

end
