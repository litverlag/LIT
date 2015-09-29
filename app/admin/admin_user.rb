  ActiveAdmin.register AdminUser do
    menu priority:2

    permit_params :email, :password, :password_confirmation, :user_role, :lektor


    index do
     
      selectable_column
      id_column
      column :email
      column :current_sign_in_at
      column :sign_in_count
      column :created_at
      column :user_role
      actions
    end

    show do
      attributes_table do
        row :email
        row :current_sign_in_at
        row :sign_in_count
        row :created_at
        row :user_role
      end

      panel "User kann folgende Lektoren sehen" do
        table_for admin_user.lektoren do
           column "Name" do |b|
          b.name
          column "Kürzel" do |b|
          b.fox_name
          end
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
        #To add a new User Role you have to add it in the collection and give them the abilities in the /model/ability.rb file
        f.input :user_role, as: :select, collection: ["Admin","Druck","Lektor"] 

        f.inputs 'Die Werke dieses Lektors soll der User sehen' do
           f.has_many :admin_users_lektoren, heading: nil, allow_destroy: true, new_record: 'Lektor hinzufügen' do |lek|
             lek.input :lektor_id , :label => 'Name',:input_html => { :class => 'lektor-input'}
            end
        end 
      end
      f.actions
    end
  end

