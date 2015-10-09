class Ability
  include CanCan::Ability

  def initialize(user)
    #abort("Message goes here")
    user ||= User.new # guest user
    #abort('some user')

    @departName = []
    #depart = user.departments.to_a
    user.departments.to_a.each do |a|
        @departName.append a.name
    end


    #TODO Rechte für alle Benutzergruppen eintragen
    if true #@departName.include?'superadmin'
      can :manage, :all
    end
    if @departName.include?'Umschlag'
      can :read, Buch
    end
    if @departName.include?'Titelei'
      can :read, :lves
    end

      can :read, ActiveAdmin::Page, :name => "Dashboard"
      can :read, ActiveAdmin::Page, :name => "Access_denied"
  end
end