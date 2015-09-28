ActiveAdmin.register AdminUser do
  menu priority:2

  permit_params :email, :password, :password_confirmation, :user_role


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

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      #To add a new User Role you have to add it in the collection and give them the abilities in the /model/ability.rb file
      f.input :user_role, as: :select, collection: ["Admin","Druck"] 
    end
    f.actions
  end


end
