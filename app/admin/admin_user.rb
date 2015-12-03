  ActiveAdmin.register AdminUser do
    menu priority:2

    controller do

      def permitted_params
        params.permit!
      end

      def edit
        @user = AdminUser.find(permitted_params[:id])
      end

      def update
       @user = AdminUser.find(params[:id])
       if @user.update_attributes(permitted_params[:admin_user])
        redirect_to collection_path, notice: 'User erfolgreich bearbeitet'
      else
        puts "\n\n\n\n\n"
       puts "----------"
       puts "No Update"
       puts "----------"
        puts "\n\n\n\n\n"

        redirect_to collection_path, notice: 'NO UPDATE'
      end

       puts "\n\n\n\n\n"
       puts "Parameter:"
       puts "----------"
       puts permitted_params[:admin_user]
       puts "----------"
        puts "\n\n\n\n\n"

               
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
        row :email
        row :current_sign_in_at
        row :sign_in_count
        row :created_at

      end

      panel "Zugewiesene Abteilungen" do
        table_for admin_user.departments do
          column "Abteilungen"  do |b|
            b.name
          end
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
        f.input :email
        f.input :password, label: "Passwort"
        f.input :password_confirmation, label: "Passwort bestätigen"

      panel "Berechtigungen" do 
        #render("/admin/admin_users/adminuserInput.html.erb")
        render partial: 'adminuserInput'
      end

      f.actions

      end
    end
  end

