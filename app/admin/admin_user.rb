  ActiveAdmin.register AdminUser do
    menu priority:2
    menu

    controller do

      def permitted_params
        params.permit!
      end

      def new
        @user = AdminUser.new
        super
      end

      def create
        if @user = AdminUser.create(permitted_params[:admin_user])
          redirect_to collection_path
          flash[:notice] = I18n.t 'flash_notice.revised_success.user_create'
        else
          render 'new'
        end
      end

      def edit
        @user = AdminUser.find(permitted_params[:id])
      end

      def update
        @user = AdminUser.find(params[:id])

        ##
        # If password fields are empty these fields will be ignored during update
        if params[:admin_user][:password].blank? && params[:admin_user][:password_confirmation].blank?
        params[:admin_user].delete(:password)
        params[:admin_user].delete(:password_confirmation)
        end

        if @user.update_attributes(permitted_params[:admin_user])
          redirect_to collection_path
          flash[:notice] = I18n.t 'flash_notice.revised_success.user_update'
        else
          redirect_to edit_admin_admin_user_url(@user)
          flash[:alert] = I18n.t 'flash_notice.revised_failure.user_update'
        end      
      end



    end


    index do
      selectable_column
      id_column
      column :email
      column :current_sign_in_at
      column :sign_in_count
      column :created_at

      actions 
    end

    show do
      attributes_table do
        row :vorname
        row :nachname
        row :email
        row :current_sign_in_at
        row :sign_in_count
        row :created_at

      end

      panel "Zugewiesene Abteilungen" do
        table_for admin_user.departments do
          column "Abteilungen", :name
        end
      end

      panel "Zugewiesener Lektor" do
        table_for admin_user.lektor do
          column "Lektor", :name
        end
      end
    end



    filter :email
    filter :current_sign_in_at
    filter :sign_in_count
    filter :created_at
    filter :user_role


    form do |f|
      f.inputs "User Details" do
        f.input :vorname
        f.input :nachname
        f.input :email
        f.input :password, label: "Passwort"
        f.input :password_confirmation, label: "Passwort bestätigen"

        ##
        # check if user is adminuser
        departName = []
        current_admin_user.departments.to_a.each do |a|
          departName.append a.name
        end

        puts "_____________________--DepartName--________________-_____"
        puts departName

        if departName.include? "Superadmin"
          panel "Berechtigungen" do
            render partial: 'adminuserInput'
          end
        end

        f.actions
      end
    end

  end

