  ActiveAdmin.register AdminUser do
    menu priority:2

    controller do
      def permitted_params
        puts "/n/n/n/n/n"
        puts params
        puts "/n/n/n/n/n"
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

        panel "" do
          table_for admin_user.lektoren do
            column "Name"  do |b|
              b.name
            end
            column "Name"  do |b|
              b.fox_name
            end
          end
        end
      panel "" do
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


=begin
       f.inputs 'Der User hat folgende Benutzergruppen' do
          f.has_many :admin_users_departments, heading: nil, allow_destroy: true, new_record: 'Abteilung hinzufügen' do |dep|
            dep.input :department
          end
       end
=end
        f.inputs 'Die Werke dieses Lektors soll der User sehen' do
           f.has_many :admin_users_lektoren, heading: nil, allow_destroy: true, new_record: 'Lektor hinzufügen' do |lek|
             lek.input :lektor , :label => 'Name',:input_html => { :class => 'lektor-input'}
            end
        end 
      end
      f.actions
    end
  end

