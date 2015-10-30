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
    if @departName.include?'superadmin'
      can :manage, :all
    end
    if @departName.include?'Umschlag'
      can :manage, :all
    end
    if @departName.include?'Satz'
      can :manage, :all
    end
    if @departName.include?'Titelei'
      can :manage, :all
    end
    if @departName.include?'PrePs'
      can :manage, :all
    end
    if @departName.include?'Rechnung'
      can :manage, :all
    end
    if @departName.include?'Bildprüfung'
      can :manage, :all
    end
    if @departName.include?'Lektor'
      can :manage, Projekt
    end
    if @departName.include?'Pod'
      can :manage, :all
    end
    if @departName.include?'Binderei'
      can :manage, :all
    end


    can :read, ActiveAdmin::Page, :name => "Dashboard"
    can :read, ActiveAdmin::Page, :name => "Access_denied"

  end
end