ActiveAdmin.register Projekt do
	menu label: "Meine Projekte"
	#menu priority: x
	##
	# Why was this false..?
	config.filters = true

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

			# FIXME .. trying to sort by a status results in an 
			# Error: 'missing FROM-clause entry for table "statusumschl"'
			#
			# Get stati for sorting.
			#super.includes(:statustitelei).references(:statustitelei)
			#super.includes(:statusumschl).references(:statusumschl)
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
					#render 'new'
				elsif not @projekt.buch = Buch.create( :name => "unbekannt" )
					#render 'new'
				elsif not createStatus(@projekt)
					#render 'new'
				else
					@projekt.lektor = current_admin_user.lektor
					@projekt.save
					redirect_to collection_path, notice: (I18n.t("flash_notice.revised_success.new_project"))
				end
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
			@array_of_vier_farb = ChoosableOption.instance.vier_farb :all # wtf is vier_farb anyway


			@button_text_add = I18n.t 'buttons.author_new'
			@button_text_asso = I18n.t 'buttons.author_asso'
			@button_text_edit =	I18n.t 'buttons.author_edit'


			respond_to do |format|
				format.html
				format.js { }
			end


		end

		##
		# Arbitrary constraints checks. 
		# Example: 
		#   So we check if our column is :bindung_bezeichnung, if so we force valid
		#   @projekt.externer_druck entry. We just add to the column hash, if
		#   instance is @projekt, otherwise we add to new_data and
		#   @projekt.update() ourselfs.
		#
		def check_constraints(instance, data)
			puts '[+] starting constraint checks'
			new_data = {}

			# Tiny helper to choose how to update, that is locally or the data hash
			def push(newH, oldH, i, entry, value)
				if i == @projekt
					oldH.update({entry => value}) unless oldH[entry] == value
					puts '[+] updating oldH' unless oldH[entry] == value
				else
					newH.update({entry => value}) unless oldH[entry] == value
					puts '[+] updating newH' unless oldH[entry] == value
				end
			end

			if data.include?(:bindung_bezeichnung)
				puts '[+] they r probably working'
				faden_or_hardcover = I18n.t('bi_names').values.delete_if{ |i| i == I18n.t('bi_names.k') }
				klebe = I18n.t('bi_names.k')
				if faden_or_hardcover.include? data[:bindung_bezeichnung] 
					value = true
				elsif klebe.include? data[:bindung_bezeichnung]
					value = false
				end
				puts "[+] pushing #{value}"
				push(new_data, data, instance, externer_druck, value) unless value.nil?

			end

			@projekt.update(new_data) unless new_data.empty?
			puts '[+] updating locally' unless new_data.empty?
			puts '[-] not updating locally' if new_data.empty?

			puts '[-] finished constraint checks'
		end


		def update

			puts "____________________________UPDATE____PROJEKTE_______________________"
			#Proc for the updating if there is already an Author
					updateProc = Proc.new{|modelinstance ,data|
						js_action = "project_changed"

						# Add arbitrary constraint checks here!
						check_constraints(modelinstance, data)

						if data != nil
							if not modelinstance.update(data)
								render 'edit'
							end
						end}
						
			@button_text_add = I18n.t 'buttons.author_new'
			@button_text_asso = I18n.t 'buttons.author_asso'
			@button_text_edit =	I18n.t 'buttons.author_edit'
	
			
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

					#to obtain modified data (ex rojectShow.js.erb)
					render "_project_Input_Response.js.erb"
				}
			end

			#redirect_to collection_path, notice: "Projekt erfolgreich bearbeitet"

		end
		
		
		
		def show
			#departement is set to choose the right department for the Show / Edit View
			@department = "projekt"
			puts "______________PROJEKT______SHOW___________________-"
			@projekt = Gprod.find(permitted_params[:id])
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


	index download_links: [:odt] do
		#render partial: 'projectindex'
		@department = "projekt"
		puts "______________PROJEKT______INDEX__________________-"
		puts	current_admin_user.departments.to_a[0].name

		column I18n.t("status_names.statusfinal"), sortable: :status_final do |p|
			status_tag(p.statusfinal.status)
		end
		column I18n.t("gprod_names.final_deadline"), sortable: :final_deadline do |p|
			##
			# the raw method is used to surround the data with a div element of class='deadline'
			# this is used by the js function deadline_colorcode defined in for_show.js.erb
			raw "<div class='deadline'>#{p.final_deadline}</div>"
		end
		column I18n.t("status_names.statustitelei") do |p|
			status_tag(p.statustitelei.status)
		end
		column I18n.t("gprod_names.titelei_deadline"), sortable: :titelei_deadline do |p|
			raw "<div class='deadline'>#{p.titelei_deadline}</div>"
		end
		column I18n.t("status_names.statusumschl") do |p|
			status_tag(p.statusumschl.status)
		end
		column I18n.t("gprod_names.umschlag_deadline"), sortable: :umschlag_deadline do |p|
			raw "<div class='deadline'>#{p.umschlag_deadline}</div>"
		end
		column I18n.t("status_names.statuspreps") do |p|
			status_tag(p.statuspreps.status)
		end
		column I18n.t("gprod_names.preps_deadline") do |p|
			raw "<div class='deadline'>#{p.preps_deadline}</div>"
		end
		column I18n.t("gprod_names.projektname"), sortable: :projektname do |p|
			p.projektname
		end
		column I18n.t("gprod_names.projekt_email_adresse"), 
	 		 sortable: :projekt_email_adresse do |p|
			p.projekt_email_adresse
		end

		actions
	end

	filter :statustitelei_status_eq, as: :select, 
		collection: proc {$TITELEI_STATUS}, label: 'statustitelei'
	filter :statusumschl_status_eq, as: :select, 
		collection: proc {$UMSCHL_STATUS}, label: 'statusumschl'
	filter :statuspreps_status_eq, as: :select, 
		collection: proc {$PREPS_STATUS}, label: 'statuspreps'
	filter :statusdruck_status_eq, as: :select, 
		collection: proc {$DRUCK_STATUS}, label: 'statusdruck'
	filter :lektor_id_eq, as: :select, collection: proc {Lektor.all}, label: 'Lektoren'
	filter :autor_id_eq, as: :select, collection: proc {Autor.all}, label: 'Autoren'

	filter :lektor_bemerkungen_public
	filter :projekt_email_adresse
	filter :projektname

	filter :final_deadline
	filter :druck_deadline
	filter :titelei_deadline
	filter :satz_deadline
	filter :preps_deadline
	filter :bildpr_deadline
	filter :offsch_deadline
	filter :umschlag_deadline
	filter :binderei_deadline
	filter :created_at
	filter :final_deadline_not_null, as: :string, label: 'sollf present'

	show do
		render partial: "show_view"
	end



	form partial: 'newInput' 

end
