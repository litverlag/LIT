  ActiveAdmin.register AdminUser do
    menu priority:2

    controller do

      def permitted_params
        params.permit!
      end

      def create
        if not @user = AdminUser.create(permitted_params[:user])
          render 'new'
        end
        @user.update(permitted_params[:departments])
        if @user.departments.to_a.include?('Lektor')
          @user.update(permitted_params[:lektor])
        end
      end

      def update

        updateProc = Proc.new{|modelinstance ,data|
          if data != nil
            if not modelinstance.update(data)
              render 'edit'
            end
          end}


        @user = AdminUser.find(params[:id])
        updateProc.call(@user,permitted_params[:user] )
        updateProc.call(@user.departments,permitted_params[:departments] )
        if @user.departments.to_a.include?('Lektor')
          updateProc.call(@user.lektor,permitted_params[:lektor] )
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

      #   f.inputs 'Der User hat folgende Benutzergruppen' do
       #    f.input :lektor, as: :select
      # end


          f.inputs "Lektor", :for => [:lektor] do |lek|
            lek.input :name
          end

        div do
          render('/admin/new.html.erb')
        end

        f.actions

      end
    end
  end

