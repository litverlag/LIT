ActiveAdmin.register Projekt do
  menu label: "Terminplanung"
  config.sort_order = 'final_deadline_asc'
  config.filters = true

  #scopes -> filter the viewable project in the table
  scope (I18n.t("scopes_names.alle_filter")), :alle_filter
  scope (I18n.t("scopes_names.fertig_filter")), :fertig_filter
  scope (I18n.t("scopes_names.bearbeitung_filter")), :bearbeitung_filter
  scope (I18n.t("scopes_names.neu_filter")), :neu_filter
  scope (I18n.t("scopes_names.problem_filter")), :problem_filter

  # Automatically generated scopes from app/models/projekt.rb
  #scope (I18n.t("scopes_names.im_verzug_hf")), :im_verzug_hf, :if => proc{current_admin_user.departments.where("name = ?", 'Superadmin').any?}
  #scope (I18n.t("scopes_names.im_verzug_bel")), :im_verzug_bel, :if => proc{current_admin_user.departments.where("name = ?", 'Superadmin').any?}
  #scope (I18n.t("scopes_names.im_verzug_rit")), :im_verzug_rit, :if => proc{current_admin_user.departments.where("name = ?", 'Superadmin').any?}
  #scope (I18n.t("scopes_names.im_verzug_litb")), :im_verzug_litb, :if => proc{current_admin_user.departments.where("name = ?", 'Superadmin').any?}
  #scope (I18n.t("scopes_names.im_verzug_rai")), :im_verzug_rai, :if => proc{current_admin_user.departments.where("name = ?", 'Superadmin').any?}
  #scope (I18n.t("scopes_names.im_verzug_wien")), :im_verzug_wien, :if => proc{current_admin_user.departments.where("name = ?", 'Superadmin').any?}

  ## Department im_verzug scopes.
  #Department.all.map{|d| d.name[0..2].downcase}.each do |dep|
  #  next if ['sup', 'lek'].include? dep
  #  scope (I18n.t("scopes_names.im_verzug_#{dep}")),
  #    ("im_verzug_#{dep}").to_sym,
  #    :if => proc{current_admin_user.departments.where("name = ?", 'Superadmin').any?}
  #end

  controller do
    
    #from models/concerns
    include StatusLogic, PrintReport

    ##
    # It would be great if this class could be in a helper modulde, but it's
    # not that easy beacause of ActiveAdmin This method is used to replace the
    # string coming from the HTML form ()permitted_params["format"]) by an
    # instance of the right format class so that an association can be done
    # with the klass.update method. Same procedure with papier and umschlag
    #
    # Rouven asks: Who wrote this? please mail me rouvenglauert@gmail.com
    #
    # That communication..
    def scoped_collection
      if current_admin_user.departments.where("name = ?", 'Lektor').any?
        super.where(lektor: current_admin_user.lektor)
      else
        super.all

      end

      ##
      # Note that the following super.includes overrides the above super-calls.
      # Buts its fine cuz we have a filter for lektoren.
      #
      # Note also that we need to inlcude all non-local tables (including all
      # stati, except final_status) that we want to be 'sortable'.
      # See 'index' block below.
      # This also prevents N+1 queries to the db when sorting.(?)
      super.includes [
        :statusdruck, :statusumschl, :statuspreps, :statusbinderei,
        :statustitelei, :lektor
      ]

      # Note also that this will be overridden by a click on a scope button.
    end


    def permitted_params
      #alle
      params.permit!
    end


    def create
      puts "____________________________CREATE__________________________"
      #Check if the current User is a Lektor if not he is not able to create a Projekt
      if current_admin_user.departments.to_a[0].name == "Lektor"
        begin
          @projekt = Projekt.create!(permitted_params[:projekt])
          @projekt.buch = Buch.create!( :name => "unbekannt" )
          createStatus(@projekt)
        rescue ActiveRecord::RecordInvalid
          redirect_to '/admin/projekte/new'
          flash[:alert] = I18n.t 'flash_notice.revised_failure.new_project_invalid'
          return
        end
        @projekt.lektor = current_admin_user.lektor
        @projekt.save
        redirect_to  "/admin/projekte/#{@projekt.id}",
          notice: (I18n.t("flash_notice.revised_success.new_project"))
      else
        #raise StandardError, "A project can only be created by a lektor"
      end

    end

    def edit
      puts "____________________________EDIT___PROJEKT________________________"
      #Find the new projekt associated with the current Lektor or if superadmin
      # you can access all projects.
      @projekt = Projekt.find_projekt_by_id(permitted_params[:id],current_admin_user)
      #This methods are used to check if the Author can actually release
      # project for the departments.
      @department = "projekt"
      @array_of_format_bezeichungen = I18n.t('format_names').values
      @array_of_umschlag_bezeichnungen = I18n.t('um_names').values.delete_if { |i| 
        i == I18n.t('um_names.reihe')
      }
      @array_of_papier_bezeichungen = I18n.t('paper_names').values
      @array_of_vier_farb = ChoosableOption.instance.vier_farb :all # wtf is vier_farb


      @button_text_add = I18n.t 'buttons.author_new'
      @button_text_asso = I18n.t 'buttons.author_asso'
      @button_text_edit = I18n.t 'buttons.author_edit'


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

        # Add arbitrary constraint checks here!
        check_constraints(modelinstance, data)

        if data != nil
          begin
            modelinstance.update!(data)
          rescue ActiveRecord::RecordInvalid
            redirect_to "/admin/projekte/#{@projekt.id}/edit"
            flash[:alert] = I18n.t 'flash_notice.revised_failure.new_project_invalid'
            return
          end
        end
      }
            
      @button_text_add = I18n.t 'buttons.author_new'
      @button_text_asso = I18n.t 'buttons.author_asso'
      @button_text_edit = I18n.t 'buttons.author_edit'
  
      
      respond_to do |format|
        format.html {}
        format.js {
          @projekt = Projekt.find_projekt_by_id(permitted_params[:id],current_admin_user)


          if permitted_params[:gprod] then updateProc.call(@projekt,permitted_params[:gprod]) end
          if permitted_params[:buch] then updateProc.call(@projekt.buch,permitted_params[:buch]) end

        #puts "__________________TesT________________________________"
        #puts permitted_params[:gprod]
        #puts permitted_params[:status][:freigabe_titelei]
        #puts "__________________TesT________________________________"

          # This part is used to update to a new status with the status_logic module
          if permitted_params[:status]
            changeStatusByUser(@projekt,@projekt.statusfinal, permitted_params[:status][:freigabe_final])
            changeStatusByUser(@projekt,@projekt.statusumschl, permitted_params[:status][:freigabe_umschlag])
            changeStatusByUser(@projekt,@projekt.statuspreps, permitted_params[:status][:freigabe_preps])
            changeStatusByUser(@projekt,@projekt.statustitelei, permitted_params[:status][:freigabe_titelei])
          end

          #puts permitted_params

          # It is checked if the the User want to create a new Author or if he
          # wants to make an association with one who already exists if there
          # is no Author in the Database we get an Error, if there is on he
          # gets associated.
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

          ##
          # Ok, so they wanted to show the updated stati in the flash notice,
          # which is not that relevant..
          # But they did not redirect at all, so no one would actually see the
          # flash thingy, which is relevant if you mess up your input, thus I
          # just redirect_to.
          #
          # old_comment = '''
          # to obtain modified data (ex rojectShow.js.erb)
          # render "_project_Input_Response.js.erb"
          # '''
          redirect_to "/admin/projekte/#{@projekt.id}"
          flash[:notice] = I18n.t 'flash_notice.revised_success.project_update'
        }
      end

      #redirect_to collection_path, notice: "Projekt erfolgreich bearbeitet"

    end
    
    
    
    def show
      #departement is set to choose the right department for the Show / Edit View
      @department = "projekt"
      puts "______________PROJEKT______SHOW___________________-"
      @projekt = Gprod.find(permitted_params[:id])
      if @projekt.buch.nil?
        @projekt.buch = Buch.create!
      end
      @projekt
    end


    def destroy
      #Find the new projekt associated with the current Lektor or if
      #superadmin you can access all projects.
      @projekt = Projekt.find_projekt_by_id(permitted_params[:id],current_admin_user)
      @projekt.buch.destroy unless @projekt.buch.nil?
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

  index download_links: [:odt, :csv] do
    # We dont need those actions if we link_to(admin/projekte/id) see below.
    #actions
    @department = "projekt"
    puts "______________PROJEKT______INDEX__________________-"
    puts  current_admin_user.departments.to_a[0].name

    column I18n.t("gprod_names.projektname"), sortable: :projektname do |p|
      link_to(p.projektname, "/admin/projekte/#{p.id}")
    end

    column I18n.t("buecher_names.isbn") do |p|
      raw "#{p.buch.isbn.gsub('-', '&#8209;')}" rescue '-'
    end

    column I18n.t("status_names.statusfinal"), sortable: 'status_final.status' do |p|
      status_tag(p.statusfinal.status)
    end

    column I18n.t("gprod_names.prio"), sortable: :prio do |p|
      p.prio
    end

    column I18n.t("buecher_names.r_code") do |p|
      link_to(p.buch.reihen.first.r_code, "/admin/reihen/#{p.buch.reihen.first.id}") rescue "-"
    end

    column I18n.t("status_names.statusbinderei"), sortable: 'status_binderei.status' do |p|
      status_tag(p.statusbinderei.status)
    end

    column I18n.t("status_names.statusdruck"), sortable: 'status_druck.status' do |p|
      begin
        if not p.externer_druck
          status_tag(p.statusdruck.status)
        else
          status_tag(p.statusexternerdruck.status)
        end
      rescue
        '-'
      end
    end

    column I18n.t("status_names.statustitelei"), sortable: 'status_titelei.status' do |p|
      status_tag(p.statustitelei.status)
    end

    column I18n.t("status_names.statussatz"), sortable: 'status_satz.status' do |p|
      if p.satzproduktion
        status_tag(p.statussatz.status)
      else
        "-"
      end
    end

    column I18n.t("status_names.statusumschl"), sortable: 'status_umschl.status' do |p|
      status_tag(p.statusumschl.status)
    end

    column I18n.t('buecher_names.bindung_bezeichnung'), sortable: 'buecher.bindung_bezeichnung' do |p|
      p.buch.bindung_bezeichnung rescue '-'
    end

    column I18n.t("gprod_names.manusskript_eingang_date"), sortable:
      :manusskript_eingang_date do |p|
      p.manusskript_eingang_date
    end

    column I18n.t("gprod_names.final_deadline"), sortable: :final_deadline do |p|
      ##
      # the raw method is used to surround the data with a div element of class='deadline'
      # this is used by the js function deadline_colorcode defined in for_show.js.erb
      # Note: This js function is disabled for whatever reason.
      raw "<div class='deadline'>#{p.final_deadline}</div>"
    end

    column I18n.t("search_labels.lektor"), sortable: 'lektoren.name' do |p|
      p.lektor.fox_name rescue '-'
    end

  end

  filter :final_deadline

  filter :statusbinderei_status_not_eq, as: :select, 
    collection: proc {$BINDEREI_STATUS}, label: I18n.t('status_names.nstatusbinderei')
  filter :statusdruck_status_not_eq, as: :select, 
    collection: proc {$DRUCK_STATUS}, label: I18n.t('status_names.nstatusdruck')
  filter :statusumschl_status_not_eq, as: :select, 
    collection: proc {$UMSCHL_STATUS}, label: I18n.t('status_names.nstatusumschl')
  filter :statustitelei_status_not_eq, as: :select, 
    collection: proc {$TITELEI_STATUS}, label: I18n.t('status_names.nstatustitelei')

  filter :lektor_id_eq, as: :select, collection: proc {Lektor.all}, label: 'Lektoren'
  filter :autor_id_eq, as: :select, collection: proc {Autor.all}, label: 'Autoren'

  filter :lektor_bemerkungen_public
  filter :projekt_email_adresse
  filter :projektname
  filter :prio, as: :select

  show do
    render partial: "show_view"
  end

  form partial: 'newInput' 

end
