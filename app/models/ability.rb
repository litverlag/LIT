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

    end
    if @departName.include?'Satz'

    end
    if @departName.include?'Titelei'

    end
    if @departName.include?'PrePs'

    end
    if @departName.include?'Rechnung'

    end
    if @departName.include?'Bildprüfung'

    end
    if @departName.include?'Lektor'
      can :manage, Projekt
    end
    if @departName.include?'Pod'

    end
    if @departName.include?'Binderei'
      can :read, :bis
    end


    can :read, ActiveAdmin::Page, :name => "Dashboard"
    can :read, ActiveAdmin::Page, :name => "Access_denied"

  end
end