  ActiveAdmin.register AdminUser do
    menu priority:2

    controller do
      def permitted_params

        params.permit!
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

        panel "Zugewiesene Lektoren" do
          #table_for admin_user.lektoren do
          #  column "Name"  do |b|
          #    b.name
          #  end
          #  column "Kürzel"  do |b|
          #    b.fox_name
          #  end
          #end
        end

      panel "Zugewiesene Abteilungen" do
        table_for admin_user.departments do
          column "Name"  do |b|
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
      f.inputs "Admin Details" do
        f.input :email
        f.input :password
        f.input :password_confirmation

      f.inputs 'Der User hat folgende Benutzergruppen' do
        f.input :departments, as: :select
      end


      f.inputs 'Die Werke dieses Lektors soll der User sehen' do
        #f.input :lektoren, as: :select
      end


      f.actions

      end
    end
  end

