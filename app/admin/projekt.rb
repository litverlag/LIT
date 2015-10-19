ActiveAdmin.register Projekt do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if resource.something?
#   permitted
# end

   controller do
     def permitted_params
       params.permit!
     end
=begin
     def new
       super
       @projekt = Gprod.new
     end

     def create
       @projekt.save
     end
=end
    end


  menu label: "Meine Projekte"

  index title: "Meine Projekte" do
    column :druck
    column('Name') {|p| p.buch }


  end

   form do |f|


    f.inputs do

      f.has_many :buch do |y|
        y.input :name
      end


      f.actions
    end
   end




end
